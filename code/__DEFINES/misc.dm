//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define OLD_MAN_HENDERSON_DRUNKENNESS 41

/// Path for the byond-memorystats dll
#define MEMORYSTATS_DLL_PATH (world.system_type == MS_WINDOWS ? "memorystats.dll" : "./libmemorystats.so")

/// File path used for the "enable tracy next round" functionality
/// The server port is appended to the end of the filename to avoid conflicts if multiple servers share the same data folder.
#define TRACY_ENABLE_PATH	"data/enable_tracy"
/// The DLL path for byond-tracy, which is linked into the replay recorder's library.
#define TRACY_DLL_PATH		(world.system_type == MS_WINDOWS ? "replay_recorder.dll" : "./libreplay_recorder.so")
/// What byond_tracy.dm calls into.
#define BYOND_TRACY_DLL		TRACY_DLL_PATH
/// Each trace part (.utracy.001, .002, ...) stays under this many MiB, so no part passes 2 GB.
#define TRACY_SPLIT_MIB		1800

#define CODE_STORAGE_PATH "data/generated_codes.json"
#define CODE_METADATA_PATH "data/code_metadata.json"
