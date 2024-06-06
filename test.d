import std.algorithm;
import std.stdio;

version (OSX)
    version = Apple;
version (iOS)
    version = Apple;
version (TVOS)
    version = Apple;
version (WatchOS)
    version = Apple;

struct MemberInfo
{
    string name;
    size_t offset;
    size_t size;
    size_t bitoffset;
    size_t bitsize;
}
struct RecordInfo
{
    string kind;
    string name;
    string modulename;
    size_t size;
    immutable(MemberInfo)[] members;
}

template collectTypes(string modulename)
{
    immutable RecordInfo[] collectTypes = () {
        RecordInfo[] r;
        mixin("import M = " ~ modulename ~ ";");
        static foreach (member; __traits(allMembers, M))
        {
            //pragma(msg, member);
            /*static if((is(__traits(getMember, M, member) == struct)
                    || is(__traits(getMember, M, member) == union))
                && __traits(compiles, __traits(getMember, M, member).sizeof))*/
            static if (__traits(compiles, {__traits(getMember, M, member) x;})
                && __traits(compiles, __traits(getMember, M, member).sizeof))
            {{
                alias T = __traits(getMember, M, member);
                string kind;
                if (is(T == struct))
                    kind = "struct";
                else if (is(T == union))
                    kind = "union";
                else if (is(T == enum))
                    kind = "enum";
                r ~= RecordInfo(kind, member, modulename, T.sizeof);
                static if (is(T == struct) || is(T == union))
                {
                    static foreach (member2; T.tupleof)
                    {{
                        MemberInfo memberInfo = MemberInfo(__traits(identifier, member2), member2.offsetof, member2.sizeof);
                        static if (__traits(compiles, __traits(isBitfield, member2)))
                        {
                            static if (__traits(isBitfield, member2))
                            {
                                memberInfo.bitoffset = member2.bitoffsetof;
                                memberInfo.bitsize = member2.bitwidth;
                            }
                        }
                        r[$ - 1].members ~= memberInfo;
                    }}
                }
            }}
        }
        return r;
    }();
}

int main()
{
    RecordInfo[string] importcInfos;
    foreach (info; collectTypes!"importc_includes")
    {
        if (info.name.startsWith("___realtype_"))
            importcInfos[info.name[12 .. $]] = info;
        else
            importcInfos[info.name] = info;
    }

    bool anyFailure;

    void checkInfos(immutable RecordInfo[] infosD)
    {
        foreach (infoD; infosD)
        {
            auto infoC = infoD.name in importcInfos;
            if (!infoC)
            {
                writeln("Warning: Type ", infoD.modulename, ".", infoD.name, " not found in C");
                continue;
            }
            if (infoC.kind.length && infoD.kind != "enum" && infoD.kind != infoC.kind)
            {
                writeln("Error: Type ", infoD.modulename, ".", infoD.name, " is ", infoC.kind, " in C (ImportC), but ", infoD.kind, " in D");
                anyFailure = true;
            }
            bool printLayout;
            if (infoD.size != infoC.size)
            {
                writeln("Error: Type ", infoC.kind, " ", infoD.modulename, ".", infoD.name, " has size ", infoC.size, " in C (ImportC), but size ", infoD.size, " in D");
                printLayout = true;
                anyFailure = true;
            }
            MemberInfo[string] memberByNameC;
            foreach (memberC; infoC.members)
                memberByNameC[memberC.name] = memberC;
            foreach (memberD; infoD.members)
            {
                if (memberD.name.canFind("reserved"))
                    continue;
                if (memberD.name.canFind("pad"))
                    continue;
                auto memberC = memberD.name in memberByNameC;
                if (memberC)
                {
                    if (memberC.offset != memberD.offset)
                    {
                        writeln("Error: Member ", memberD.name, " for type ", infoC.kind, " ", infoD.modulename, ".", infoD.name, " has offset ", memberC.offset, " in C (ImportC), but offset ", memberD.offset, " in D");
                        printLayout = true;
                        anyFailure = true;
                    }
                    if (memberC.size != memberD.size)
                    {
                        writeln("Error: Member ", memberD.name, " for type ", infoC.kind, " ", infoD.modulename, ".", infoD.name, " has size ", memberC.size, " in C (ImportC), but size ", memberD.size, " in D");
                        printLayout = true;
                        anyFailure = true;
                    }
                }
            }
            if (printLayout && (infoC.members.length || infoD.members.length))
            {
                writefln("    offset  size  bitoffset bitsize  %20s %20s", "ImportC layout", "D layout");
                void printInfos(MemberInfo m1, MemberInfo m2)
                {
                    MemberInfo m3 = m1.name.length ? m1 : m2;
                    if (m3.bitsize)
                        writefln("     %5d %5d      %5d   %5d  %20s %20s", m3.offset, m3.size, m3.bitoffset, m3.bitsize, m1.name, m2.name);
                    else
                        writefln("     %5d %5d      %5s   %5s  %20s %20s", m3.offset, m3.size, "", "", m1.name, m2.name);
                }
                immutable(MemberInfo)[] membersC = infoC.members;
                immutable(MemberInfo)[] membersD = infoD.members;
                while (membersC.length || membersD.length)
                {
                    if (membersC.length == 0)
                    {
                        printInfos(MemberInfo.init, membersD[0]);
                        membersD = membersD[1 .. $];
                    }
                    else if (membersD.length == 0)
                    {
                        printInfos(membersC[0], MemberInfo.init);
                        membersC = membersC[1 .. $];
                    }
                    else if (membersC[0].offset == membersD[0].offset
                        && membersC[0].size == membersD[0].size
                        && membersC[0].bitoffset == membersD[0].bitoffset
                        && membersC[0].bitsize == membersD[0].bitsize)
                    {
                        printInfos(membersC[0], membersD[0]);
                        membersC = membersC[1 .. $];
                        membersD = membersD[1 .. $];
                    }
                    else if (membersD[0].offset < membersC[0].offset)
                    {
                        printInfos(MemberInfo.init, membersD[0]);
                        membersD = membersD[1 .. $];
                    }
                    else
                    {
                        printInfos(membersC[0], MemberInfo.init);
                        membersC = membersC[1 .. $];
                    }
                }
            }
        }
    }

    // find /usr/include/dlang/dmd/core/{stdc,sys} -type f | sed "s/.*dmd\///g" | sed "s/\//./g" | sed "s/.d$//g" | sed "s/.*/        \"\0\",/g" | grep -v "\.package\","
    static foreach (modulename; [
        "core.stdc.complex",
        "core.stdc.stdint",
        "core.stdc.stdio",
        "core.stdc.signal",
        "core.stdc.stdlib",
        "core.stdc.limits",
        "core.stdc.locale",
        "core.stdc.fenv",
        "core.stdc.inttypes",
        "core.stdc.string",
        "core.stdc.wctype",
        "core.stdc.config",
        "core.stdc.math",
        "core.stdc.ctype",
        "core.stdc.stddef",
        "core.stdc.stdarg",
        "core.stdc.tgmath",
        "core.stdc.time",
        "core.stdc.wchar_",
        "core.stdc.errno",
        "core.stdc.stdatomic",
        "core.stdc.assert_",
        "core.stdc.float_",
        "core.sys.solaris.dlfcn",
        "core.sys.solaris.link",
        "core.sys.solaris.err",
        "core.sys.solaris.stdlib",
        "core.sys.solaris.sys.priocntl",
        "core.sys.solaris.sys.procset",
        "core.sys.solaris.sys.link",
        "core.sys.solaris.sys.elf_386",
        "core.sys.solaris.sys.elf_notes",
        "core.sys.solaris.sys.elf_amd64",
        "core.sys.solaris.sys.elf",
        "core.sys.solaris.sys.elftypes",
        "core.sys.solaris.sys.elf_SPARC",
        "core.sys.solaris.sys.types",
        "core.sys.solaris.elf",
        "core.sys.solaris.libelf",
        "core.sys.solaris.time",
        "core.sys.solaris.execinfo",
        "core.sys.freebsd.dlfcn",
        "core.sys.freebsd.netinet.in_",
        "core.sys.freebsd.err",
        "core.sys.freebsd.stdlib",
        "core.sys.freebsd.unistd",
        "core.sys.freebsd.pthread_np",
        "core.sys.freebsd.sys.mount",
        "core.sys.freebsd.sys.sysctl",
        "core.sys.freebsd.sys.elf64",
        "core.sys.freebsd.sys.event",
        "core.sys.freebsd.sys._cpuset",
        "core.sys.freebsd.sys.socket",
        "core.sys.freebsd.sys.mman",
        "core.sys.freebsd.sys.elf",
        "core.sys.freebsd.sys.elf32",
        "core.sys.freebsd.sys._bitset",
        "core.sys.freebsd.sys.elf_common",
        "core.sys.freebsd.sys.cdefs",
        "core.sys.freebsd.sys.link_elf",
        "core.sys.freebsd.sys.types",
        "core.sys.freebsd.net.if_",
        "core.sys.freebsd.net.if_dl",
        "core.sys.freebsd.string",
        "core.sys.freebsd.config",
        "core.sys.freebsd.time",
        "core.sys.freebsd.execinfo",
        "core.sys.freebsd.ifaddrs",
        "core.sys.darwin.dlfcn",
        "core.sys.darwin.netinet.in_",
        "core.sys.darwin.err",
        "core.sys.darwin.pthread",
        "core.sys.darwin.stdlib",
        "core.sys.darwin.fcntl",
        "core.sys.darwin.sys.sysctl",
        "core.sys.darwin.sys.event",
        "core.sys.darwin.sys.mman",
        "core.sys.darwin.sys.cdefs",
        "core.sys.darwin.mach.kern_return",
        "core.sys.darwin.mach.thread_act",
        "core.sys.darwin.mach.getsect",
        "core.sys.darwin.mach.loader",
        "core.sys.darwin.mach.stab",
        "core.sys.darwin.mach.port",
        "core.sys.darwin.mach.dyld",
        "core.sys.darwin.mach.semaphore",
        "core.sys.darwin.mach.nlist",
        "core.sys.darwin.string",
        "core.sys.darwin.execinfo",
        "core.sys.darwin.crt_externs",
        "core.sys.darwin.ifaddrs",
        "core.sys.bionic.err",
        "core.sys.bionic.stdlib",
        "core.sys.bionic.unistd",
        "core.sys.bionic.fcntl",
        "core.sys.bionic.string",
        "core.sys.posix.iconv",
        "core.sys.posix.dlfcn",
        "core.sys.posix.stdio",
        "core.sys.posix.poll",
        "core.sys.posix.strings",
        "core.sys.posix.utime",
        "core.sys.posix.netinet.tcp",
        "core.sys.posix.netinet.in_",
        "core.sys.posix.arpa.inet",
        "core.sys.posix.netdb",
        "core.sys.posix.spawn",
        "core.sys.posix.setjmp",
        "core.sys.posix.ucontext",
        "core.sys.posix.pthread",
        "core.sys.posix.signal",
        "core.sys.posix.stdlib",
        "core.sys.posix.syslog",
        "core.sys.posix.unistd",
        "core.sys.posix.stdc.time",
        "core.sys.posix.fcntl",
        "core.sys.posix.dirent",
        "core.sys.posix.locale",
        "core.sys.posix.sys.ioctl",
        "core.sys.posix.sys.shm",
        "core.sys.posix.sys.resource",
        "core.sys.posix.sys.ttycom",
        "core.sys.posix.sys.ipc",
        "core.sys.posix.sys.un",
        "core.sys.posix.sys.utsname",
        "core.sys.posix.sys.statvfs",
        "core.sys.posix.sys.socket",
        "core.sys.posix.sys.mman",
        "core.sys.posix.sys.stat",
        "core.sys.posix.sys.wait",
        "core.sys.posix.sys.filio",
        "core.sys.posix.sys.msg",
        "core.sys.posix.sys.select",
        "core.sys.posix.sys.time",
        "core.sys.posix.sys.uio",
        "core.sys.posix.sys.ioccom",
        "core.sys.posix.sys.types",
        "core.sys.posix.net.if_",
        "core.sys.posix.inttypes",
        "core.sys.posix.libgen",
        "core.sys.posix.string",
        "core.sys.posix.termios",
        "core.sys.posix.aio",
        "core.sys.posix.config",
        "core.sys.posix.mqueue",
        "core.sys.posix.sched",
        "core.sys.posix.semaphore",
        "core.sys.posix.time",
        "core.sys.posix.pwd",
        "core.sys.posix.grp",
        "core.sys.dragonflybsd.dlfcn",
        "core.sys.dragonflybsd.netinet.in_",
        "core.sys.dragonflybsd.err",
        "core.sys.dragonflybsd.stdlib",
        "core.sys.dragonflybsd.pthread_np",
        "core.sys.dragonflybsd.sys.sysctl",
        "core.sys.dragonflybsd.sys.elf64",
        "core.sys.dragonflybsd.sys.event",
        "core.sys.dragonflybsd.sys._cpuset",
        "core.sys.dragonflybsd.sys.socket",
        "core.sys.dragonflybsd.sys.mman",
        "core.sys.dragonflybsd.sys.elf",
        "core.sys.dragonflybsd.sys.elf32",
        "core.sys.dragonflybsd.sys._bitset",
        "core.sys.dragonflybsd.sys.elf_common",
        "core.sys.dragonflybsd.sys.cdefs",
        "core.sys.dragonflybsd.sys.link_elf",
        "core.sys.dragonflybsd.string",
        "core.sys.dragonflybsd.time",
        "core.sys.dragonflybsd.execinfo",
        "core.sys.linux.dlfcn",
        "core.sys.linux.stdio",
        "core.sys.linux.fs",
        "core.sys.linux.netinet.tcp",
        "core.sys.linux.netinet.in_",
        "core.sys.linux.epoll",
        "core.sys.linux.link",
        "core.sys.linux.err",
        "core.sys.linux.io_uring",
        "core.sys.linux.timerfd",
        "core.sys.linux.unistd",
        "core.sys.linux.fcntl",
        "core.sys.linux.sys.file",
        "core.sys.linux.sys.auxv",
        "core.sys.linux.sys.prctl",
        "core.sys.linux.sys.eventfd",
        "core.sys.linux.sys.sysinfo",
        "core.sys.linux.sys.socket",
        "core.sys.linux.sys.mman",
        "core.sys.linux.sys.xattr",
        "core.sys.linux.sys.signalfd",
        "core.sys.linux.sys.time",
        "core.sys.linux.sys.inotify",
        "core.sys.linux.perf_event",
        "core.sys.linux.string",
        "core.sys.linux.termios",
        "core.sys.linux.config",
        "core.sys.linux.tipc",
        "core.sys.linux.sched",
        "core.sys.linux.elf",
        "core.sys.linux.linux.if_packet",
        "core.sys.linux.linux.if_arp",
        "core.sys.linux.time",
        "core.sys.linux.execinfo",
        "core.sys.linux.ifaddrs",
        "core.sys.linux.errno",
        "core.sys.windows.objfwd",
        "core.sys.windows.httpext",
        "core.sys.windows.cguid",
        "core.sys.windows.wtsapi32",
        "core.sys.windows.core",
        "core.sys.windows.ole2",
        "core.sys.windows.prsht",
        "core.sys.windows.nb30",
        "core.sys.windows.ras",
        "core.sys.windows.cderr",
        "core.sys.windows.oleacc",
        "core.sys.windows.lmbrowsr",
        "core.sys.windows.rassapi",
        "core.sys.windows.powrprof",
        "core.sys.windows.unknwn",
        "core.sys.windows.winsvc",
        "core.sys.windows.nspapi",
        "core.sys.windows.cpl",
        "core.sys.windows.rpcdcep",
        "core.sys.windows.w32api",
        "core.sys.windows.winuser",
        "core.sys.windows.objsafe",
        "core.sys.windows.windef",
        "core.sys.windows.tlhelp32",
        "core.sys.windows.rpcndr",
        "core.sys.windows.lmsvc",
        "core.sys.windows.lmapibuf",
        "core.sys.windows.com",
        "core.sys.windows.winsock2",
        "core.sys.windows.ntldap",
        "core.sys.windows.secext",
        "core.sys.windows.accctrl",
        "core.sys.windows.rapi",
        "core.sys.windows.schannel",
        "core.sys.windows.lmwksta",
        "core.sys.windows.uuid",
        "core.sys.windows.dlgs",
        "core.sys.windows.richole",
        "core.sys.windows.idispids",
        "core.sys.windows.nddeapi",
        "core.sys.windows.olectl",
        "core.sys.windows.ntsecapi",
        "core.sys.windows.winver",
        "core.sys.windows.oaidl",
        "core.sys.windows.iphlpapi",
        "core.sys.windows.commdlg",
        "core.sys.windows.lmerr",
        "core.sys.windows.mgmtapi",
        "core.sys.windows.ddeml",
        "core.sys.windows.rpcnsip",
        "core.sys.windows.threadaux",
        "core.sys.windows.sspi",
        "core.sys.windows.shlwapi",
        "core.sys.windows.mswsock",
        "core.sys.windows.custcntl",
        "core.sys.windows.mshtml",
        "core.sys.windows.winldap",
        "core.sys.windows.winerror",
        "core.sys.windows.lmchdev",
        "core.sys.windows.rpcnsi",
        "core.sys.windows.lmshare",
        "core.sys.windows.winnetwk",
        "core.sys.windows.stdc.malloc",
        "core.sys.windows.stdc.time",
        "core.sys.windows.winioctl",
        "core.sys.windows.reason",
        "core.sys.windows.objidl",
        "core.sys.windows.regstr",
        "core.sys.windows.rpcdce2",
        "core.sys.windows.rpc",
        "core.sys.windows.winhttp",
        "core.sys.windows.ntdll",
        "core.sys.windows.ole",
        "core.sys.windows.rpcnterr",
        "core.sys.windows.lzexpand",
        "core.sys.windows.odbcinst",
        "core.sys.windows.ole2ver",
        "core.sys.windows.lmat",
        "core.sys.windows.lm",
        "core.sys.windows.aclui",
        "core.sys.windows.raserror",
        "core.sys.windows.ocidl",
        "core.sys.windows.iprtrmib",
        "core.sys.windows.sqlucode",
        "core.sys.windows.lmstats",
        "core.sys.windows.dll",
        "core.sys.windows.isguids",
        "core.sys.windows.cplext",
        "core.sys.windows.winspool",
        "core.sys.windows.security",
        "core.sys.windows.lmremutl",
        "core.sys.windows.subauth",
        "core.sys.windows.sql",
        "core.sys.windows.winnls",
        "core.sys.windows.wincrypt",
        "core.sys.windows.pbt",
        "core.sys.windows.olectlid",
        "core.sys.windows.stat",
        "core.sys.windows.tmschema",
        "core.sys.windows.mmsystem",
        "core.sys.windows.sqlext",
        "core.sys.windows.errorrep",
        "core.sys.windows.objbase",
        "core.sys.windows.lmerrlog",
        "core.sys.windows.winbase",
        "core.sys.windows.stacktrace",
        "core.sys.windows.imm",
        "core.sys.windows.commctrl",
        "core.sys.windows.intshcut",
        "core.sys.windows.oledlg",
        "core.sys.windows.aclapi",
        "core.sys.windows.winnt",
        "core.sys.windows.shlguid",
        "core.sys.windows.dbt",
        "core.sys.windows.oleauto",
        "core.sys.windows.dbghelp_types",
        "core.sys.windows.rpcdce",
        "core.sys.windows.msacm",
        "core.sys.windows.lmrepl",
        "core.sys.windows.lmuse",
        "core.sys.windows.sdkddkver",
        "core.sys.windows.iptypes",
        "core.sys.windows.dhcpcsdk",
        "core.sys.windows.exdisp",
        "core.sys.windows.ipifcons",
        "core.sys.windows.oleidl",
        "core.sys.windows.lmserver",
        "core.sys.windows.lmaccess",
        "core.sys.windows.lmaudit",
        "core.sys.windows.mcx",
        "core.sys.windows.mciavi",
        "core.sys.windows.ntdef",
        "core.sys.windows.comcat",
        "core.sys.windows.basetyps",
        "core.sys.windows.wincon",
        "core.sys.windows.basetsd",
        "core.sys.windows.lmuseflg",
        "core.sys.windows.imagehlp",
        "core.sys.windows.psapi",
        "core.sys.windows.setupapi",
        "core.sys.windows.rasdlg",
        "core.sys.windows.servprov",
        "core.sys.windows.exdispid",
        "core.sys.windows.shlobj",
        "core.sys.windows.wtypes",
        "core.sys.windows.shellapi",
        "core.sys.windows.lmcons",
        "core.sys.windows.winperf",
        "core.sys.windows.docobj",
        "core.sys.windows.lmalert",
        "core.sys.windows.snmp",
        "core.sys.windows.lmconfig",
        "core.sys.windows.wingdi",
        "core.sys.windows.mapi",
        "core.sys.windows.vfw",
        "core.sys.windows.sqltypes",
        "core.sys.windows.shldisp",
        "core.sys.windows.winreg",
        "core.sys.windows.dbghelp",
        "core.sys.windows.ipexport",
        "core.sys.windows.winber",
        "core.sys.windows.ntsecpkg",
        "core.sys.windows.wininet",
        "core.sys.windows.windows",
        "core.sys.windows.lmsname",
        "core.sys.windows.lmmsg",
        "core.sys.windows.richedit",
        "core.sys.windows.dde",
        "core.sys.netbsd.dlfcn",
        "core.sys.netbsd.err",
        "core.sys.netbsd.stdlib",
        "core.sys.netbsd.sys.sysctl",
        "core.sys.netbsd.sys.elf64",
        "core.sys.netbsd.sys.event",
        "core.sys.netbsd.sys.featuretest",
        "core.sys.netbsd.sys.mman",
        "core.sys.netbsd.sys.elf",
        "core.sys.netbsd.sys.elf32",
        "core.sys.netbsd.sys.elf_common",
        "core.sys.netbsd.sys.link_elf",
        "core.sys.netbsd.string",
        "core.sys.netbsd.time",
        "core.sys.netbsd.execinfo",
        "core.sys.openbsd.dlfcn",
        "core.sys.openbsd.err",
        "core.sys.openbsd.stdlib",
        "core.sys.openbsd.unistd",
        "core.sys.openbsd.pthread_np",
        "core.sys.openbsd.sys.sysctl",
        "core.sys.openbsd.sys.elf64",
        "core.sys.openbsd.sys.mman",
        "core.sys.openbsd.sys.elf",
        "core.sys.openbsd.sys.elf32",
        "core.sys.openbsd.sys.elf_common",
        "core.sys.openbsd.sys.cdefs",
        "core.sys.openbsd.sys.link_elf",
        "core.sys.openbsd.string",
        "core.sys.openbsd.time",
        "core.sys.openbsd.execinfo",
        "core.sys.openbsd.pwd",
        ])
    {{
        bool shouldCheck = true;

        version (Apple)
        {}
        else
            if (modulename.startsWith("core.sys.darwin"))
                shouldCheck = false;

        if (shouldCheck)
            checkInfos(collectTypes!modulename);
    }}
    return anyFailure;
}
