import core.thread;
import std.algorithm;
import std.conv;
import std.datetime.stopwatch;
import std.file;
import std.path;
import std.process;
import std.range;
import std.stdio;
import std.string;
static import std.system;
import std.typecons;

struct Test
{
    string name;
    string[] extraArgs;
    bool buildOnly;
}

version (Windows)
{
    enum os = "win";
    enum libExt = ".lib";
    enum exeExt = ".exe";
}
else
{
    enum os = text(std.system.os);
    enum libExt = ".a";
    enum exeExt = "";
}

auto executeTimeout(string[] args, Duration timeout, const string[string] env = null, string workDir = null)
{
    auto pipes = pipeProcess(args, Redirect.stdin | Redirect.stdout | Redirect.stderrToStdout, env, Config.none, workDir);
    pipes.stdin.close();

    auto sw = StopWatch(AutoStart.yes);
    while (true)
    {
        auto status = pipes.pid.tryWait();
        if (status.terminated || sw.peek > timeout)
        {
            if (!status.terminated)
            {
                kill(pipes.pid);
            }
            Appender!string app;
            foreach (ubyte[] chunk; pipes.stdout.byChunk(4096))
                app.put(chunk);
            if (!status.terminated)
                status.status = -1;
            return Tuple!(bool, "terminated", int, "status", string, "output")(status.terminated, status.status, app.data);
        }
        Thread.sleep(1.seconds);
    }
}

string translateCompileArg(string compiler, string arg)
{
    if (compiler.endsWith("ldc2"))
    {
        if (arg.startsWith("-version="))
            arg = "--d-version=" ~ arg[9 .. $];
    }
    return arg;
}

int main(string[] args)
{
    bool anyFailure;

    string model;
    static if (size_t.sizeof == 8)
        model = "64";
    else static if (size_t.sizeof == 4)
        model = "32";
    else
        static assert("Unknown size of size_t");

    string compiler = "dmd";
    bool verbose;
    bool github;

    for (size_t i = 1; i < args.length; i++)
    {
        if (args[i].startsWith("-m"))
        {
            model = args[i][2 .. $];
        }
        else if (args[i].startsWith("--compiler="))
        {
            compiler = args[i]["--compiler=".length .. $];
        }
        else if (args[i] == "-v")
        {
            verbose = true;
        }
        else if (args[i] == "--github")
        {
            github = true;
        }
        else
        {
            stderr.writeln("Unknown argument ", args[i]);
            return 1;
        }
    }

    version (Windows)
    {
        import core.sys.windows.winbase : SetErrorMode, SEM_NOGPFAULTERRORBOX;

        uint dwMode = SetErrorMode(SEM_NOGPFAULTERRORBOX);
        SetErrorMode(dwMode | SEM_NOGPFAULTERRORBOX);
    }

    Test[] tests;
    tests ~= Test("test.d");

    // Compile and run the tests
    foreach (ref test; tests)
    {
        auto sw = StopWatch(AutoStart.yes);

        string resultDir = buildPath("results", dirName(test.name));
        string executable = buildPath(resultDir, baseName(test.name, ".d") ~ exeExt);

        string[] dmdArgs = [compiler];
        string[string] env;
        dmdArgs ~= "-g";
        dmdArgs ~= "-w";
        dmdArgs ~= "-m" ~ model;
        dmdArgs ~= test.name;
        version (Windows) {}
        else version (OSX)
            dmdArgs ~= "-L-lc++";
        else
            dmdArgs ~= "-L-lstdc++";
        dmdArgs ~= "-od" ~ resultDir;
        dmdArgs ~= "-of" ~ executable;
        dmdArgs ~= test.extraArgs;

        auto dmdRes = execute(dmdArgs);
        if (dmdRes.status || verbose)
        {
            stderr.writeln(escapeShellCommand(dmdArgs));
        }
        if (dmdRes.output.length)
            stderr.writeln(dmdRes.output.strip());
        if (dmdRes.status)
        {
            sw.stop();
            stderr.writef("[%d.%03d] ", sw.peek.total!"msecs" / 1000,
                    sw.peek.total!"msecs" % 1000);
            stderr.writeln("Failure compiling ", test.name);
            anyFailure = true;
            continue;
        }

        string testOutput;
        bool buildOnly = test.buildOnly || model.canFind("android");
        if (!buildOnly)
        {
            string[] testArgs = [absolutePath(executable)];
            auto testRes = executeTimeout(testArgs, 2.minutes, env, resultDir);
            if (testRes.status || verbose)
            {
                stderr.writeln(escapeShellCommand(testArgs));
                if (testRes.output.length)
                    stderr.writeln(testRes.output.strip());
            }
            if (testRes.status)
            {
                sw.stop();
                stderr.writef("[%d.%03d] ", sw.peek.total!"msecs" / 1000,
                        sw.peek.total!"msecs" % 1000);
                stderr.writeln("Failure executing ", test.name, testRes.terminated ? text(" (status=", testRes.status, ")") : " (timeout)");
                anyFailure = true;
                continue;
            }
            testOutput = testRes.output.strip();
        }
        sw.stop();
        stderr.writef("[%d.%03d] ", sw.peek.total!"msecs" / 1000, sw.peek.total!"msecs" % 1000);
        stderr.writeln("Done ", test.name, buildOnly ? " (build only)" : "", testOutput.length ? ": " : "", testOutput);
    }

    return anyFailure;
}