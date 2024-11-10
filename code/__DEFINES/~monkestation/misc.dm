//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define OLD_MAN_HENDERSON_DRUNKENNESS 41

#define OVERRIDE_DYNAMIC_HAIR_SUFFIX(typepath, suffix, facial_suffix) \
	##typepath { dynamic_hair_suffix = suffix; dynamic_fhair_suffix = facial_suffix; }
#define NO_DYNAMIC_HAIR_SUFFIX(typepath) OVERRIDE_DYNAMIC_HAIR_SUFFIX(typepath, "", "")
