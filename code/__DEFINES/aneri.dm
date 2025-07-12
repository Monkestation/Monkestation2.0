/* This comment bypasses grep checks */ /var/__aneri

/* This comment also bypasses grep checks */ /var/__aneri_exists

#define ANERI_EXISTS (__aneri_exists ||= fexists(ANERI))
#define ANERI (world.system_type == MS_WINDOWS ? "aneri.dll" : (__aneri ||= __detect_auxtools("aneri")))

// aneri-core
#define aneri_version(...)	call_ext(ANERI, "byond:aneri_version")()
#define aneri_features(...)	call_ext(ANERI, "byond:aneri_features")()
#define aneri_cleanup(...)	call_ext(ANERI, "byond:cleanup")()

/var/__aneri_log_write
#define aneri_log_write(fname, text, format) call_ext(__aneri_log_write ||= load_ext(ANERI, "byond:log_write"))(fname, text, format)
#define aneri_log_close_all(...) call_ext(ANERI, "byond:log_close_all")()
