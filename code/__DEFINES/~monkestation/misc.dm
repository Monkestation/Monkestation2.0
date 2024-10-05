//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define OLD_MAN_HENDERSON_DRUNKENNESS 41

/// File path used for the "enable tracy next round" functionality
#define TRACY_ENABLE_PATH	"data/enable_tracy"
/// The DLL path for byond-tracy.
#define TRACY_DLL_PATH		(world.system_type == MS_WINDOWS ? "prof.dll" : "./libprof.so")
