
// Workaround for https://issues.dlang.org/show_bug.cgi?id=24580
#define __attribute__(a)

#define __alignof__ _Alignof

#define BIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD

#undef __SIZEOF_INT128__

#ifdef _WIN32
#define __pragma(a)
#define _Pragma(a)
#endif

#define _FILE_OFFSET_BITS 64

// Skip header ucrt/fenv.h
#define _FENV

#include <sys/stat.h>
#include <sys/types.h>
#if __has_include(<termios.h>)
#include <termios.h>
#endif
#if __has_include(<sys/socket.h>)
#include <sys/socket.h>
#endif
#if __has_include(<pwd.h>)
#include <pwd.h>
#endif
#if __has_include(<sys/statvfs.h>)
#include <sys/statvfs.h>
#endif
#include <time.h>
#if __has_include(<unistd.h>)
#include <unistd.h>
#endif
#if __has_include(<iconv.h>)
#include <iconv.h>
#endif
#if __has_include(<aio.h>)
#include <aio.h>
#endif
#if __has_include(<semaphore.h>)
#include <semaphore.h>
#endif
#if __has_include(<signal.h>)
#include <signal.h>
#endif
#if __has_include(<sys/wait.h>)
#include <sys/wait.h>
#endif
#if __has_include(<netdb.h>)
#include <netdb.h>
#endif
#if __has_include(<dirent.h>)
#include <dirent.h>
#endif
#if __has_include(<sched.h>)
#include <sched.h>
#endif
#if __has_include(<grp.h>)
#include <grp.h>
#endif
#if __has_include(<sys/utsname.h>)
#include <sys/utsname.h>
#endif
#include <setjmp.h>
#if __has_include(<arpa/inet.h>)
#include <arpa/inet.h>
#endif
#if __has_include(<sys/un.h>)
#include <sys/un.h>
#endif
#if __has_include(<locale.h>)
#include <locale.h>
#endif
#if __has_include(<poll.h>)
#include <poll.h>
#endif
#if __has_include(<utime.h>)
#include <utime.h>
#endif
#if __has_include(<sys/ipc.h>)
#include <sys/ipc.h>
#endif
#if __has_include(<sys/shm.h>)
#include <sys/shm.h>
#endif
#if __has_include(<spawn.h>)
#include <spawn.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#if __has_include(<sys/eventfd.h>)
#include <sys/eventfd.h>
#endif
#if __has_include(<stdatomic.h>)
#include <stdatomic.h>
#endif
#if __has_include(<ifaddrs.h>)
#include <ifaddrs.h>
#endif
#ifdef linux
#include <linux/perf_event.h>
#include <linux/if_packet.h>
#include <linux/sysinfo.h>
#include <linux/elf.h>
#include <linux/if_arp.h>
#include <linux/prctl.h>
#include <linux/inotify.h>
#include <linux/io_uring.h>
#include <linux/eventpoll.h>
#endif
//#include <link.h>
#include <math.h>
#include <fenv.h>
#include <inttypes.h>
#include <wctype.h>
#include <complex.h>
#if __has_include(<sys/msg.h>)
#include <sys/msg.h>
#endif
#include <wchar.h>
#if __has_include(<sys/resource.h>)
#include <sys/resource.h>
#endif
#ifdef _WIN32
// Skip header ws2def.h
#define _WS2DEF_
#define SECURITY_WIN32
#include <Windows.h>
#include <AccCtrl.h>
#include <AclAPI.h>
//#include <AclUI.h>
#include <basetsd.h>
#include <basetyps.h>
#include <cderr.h>
//#include <cguid.h>
#include <comcat.h>
#include <CommCtrl.h>
#include <commdlg.h>
#include <Cpl.h>
#include <Cplext.h>
#include <CustCntl.h>
//#include <DbgHelp.h>
#include <Dbt.h>
#include <dde.h>
#include <ddeml.h>
#include <DhcpCSdk.h>
#include <dlgs.h>
#include <DocObj.h>
#include <ErrorRep.h>
#include <ExDisp.h>
#include <ExDispid.h>
#include <HttpExt.h>
#include <IDispIds.h>
//#include <ImageHlp.h>
#include <imm.h>
#include <IntShCut.h>
#include <IPExport.h>
#include <iphlpapi.h>
#include <ipifcons.h>
#include <Iprtrmib.h>
#include <IPTypes.h>
//#include <IsGuids.h>
//#include <LM.h>
//#include <LMaccess.h>
//#include <LMalert.h>
//#include <LMAPIbuf.h>
//#include <LMat.h>
//#include <LMaudit.h>
//#include <LMConfig.h>
//#include <lmcons.h>
//#include <lmerr.h>
//#include <LMErrlog.h>
//#include <LMMsg.h>
//#include <LMRemUtl.h>
//#include <LMRepl.h>
//#include <LMServer.h>
//#include <LMShare.h>
//#include <LMSName.h>
//#include <lmstats.h>
//#include <LMSvc.h>
//#include <LMUse.h>
//#include <lmuseflg.h>
//#include <lmwksta.h>
#include <lzexpand.h>
#include <MAPI.h>
#include <MciAvi.h>
#include <mcx.h>
#include <MgmtAPI.h>
#include <mmsystem.h>
//#include <MSAcm.h>
#include <MsHTML.h>
//#include <MSWSock.h>
#include <nb30.h>
#include <NspAPI.h>
//#include <ntdef.h>
#include <NtLdap.h>
#include <NTSecAPI.h>
//#include <NTSecPKG.h>
#include <oaidl.h>
#include <objbase.h>
#include <objidl.h>
#include <ObjSafe.h>
#include <ocidl.h>
#include <odbcinst.h>
//#include <ole.h>
//#include <ole2.h>
//#include <Ole2Ver.h>
//#include <oleacc.h>
//#include <oleauto.h>
//#include <olectl.h>
//#include <OleDlg.h>
//#include <oleidl.h>
#include <powrprof.h>
#include <prsht.h>
#include <Psapi.h>
#include <Ras.h>
#include <RasDlg.h>
#include <RasError.h>
#include <reason.h>
#include <RegStr.h>
#include <Richedit.h>
//#include <RichOle.h>
#include <rpc.h>
#include <rpcdce.h>
#include <rpcdcep.h>
#include <rpcndr.h>
#include <rpcnsi.h>
#include <rpcnsip.h>
#include <rpcnterr.h>
#include <schannel.h>
#include <sdkddkver.h>
//#include <secext.h>
#include <security.h>
#include <servprov.h>
#include <SetupAPI.h>
#include <shellapi.h>
//#include <ShlDisp.h>
//#include <ShlGuid.h>
//#include <ShlObj.h>
//#include <Shlwapi.h>
#include <Snmp.h>
#include <sql.h>
#include <sqlext.h>
#include <sqltypes.h>
#include <sqlucode.h>
#include <sspi.h>
#include <SubAuth.h>
#include <TlHelp32.h>
#include <Unknwn.h>
#include <Vfw.h>
#include <WinBase.h>
//#include <WinBer.h>
#include <wincon.h>
#include <wincrypt.h>
#include <windef.h>
#include <Windows.h>
#include <winerror.h>
#include <wingdi.h>
//#include <winhttp.h>
#include <wininet.h>
#include <winioctl.h>
//#include <Winldap.h>
#include <winnetwk.h>
#include <WinNls.h>
//#include <winnt.h>
#include <winperf.h>
#include <winreg.h>
//#include <WinSock2.h>
#include <winspool.h>
#include <winsvc.h>
#include <WinUser.h>
#include <winver.h>
#include <WtsApi32.h>
#include <wtypes.h>
#endif

typedef struct stat stat_t;
typedef struct statvfs statvfs_t;
typedef struct timezone timezone_t;
typedef struct sysinfo sysinfo_t;

typedef unsigned long ulong_t;
typedef long slong_t;
typedef unsigned long c_ulong;
typedef long c_long;
typedef long double c_long_double;
typedef long __c_long;
typedef unsigned long __c_ulong;
typedef long long __c_longlong;
typedef unsigned long long __c_ulonglong;
typedef long cpp_long;
typedef unsigned long cpp_ulong;
typedef long long cpp_longlong;
typedef unsigned long long cpp_ulonglong;
typedef size_t cpp_size_t;
typedef ptrdiff_t cpp_ptrdiff_t;
typedef float _Complex __c_complex_float;
typedef double _Complex __c_complex_double;
typedef long double _Complex __c_complex_real;
typedef float _Complex c_complex_float;
typedef double _Complex c_complex_double;
typedef long double _Complex c_complex_real;

/* These types are defined as macros on Android and are not usable directly in ImportC. */
#ifdef ipc_perm
typedef ipc_perm ___realtype_ipc_perm;
#endif
#ifdef shmid_ds
typedef shmid_ds ___realtype_shmid_ds;
#endif
