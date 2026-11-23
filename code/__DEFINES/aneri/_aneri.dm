/* This comment bypasses grep checks */ /var/__aneri

/proc/__detect_aneri()
	if (world.system_type == UNIX)
		return __aneri = (fexists("./libaneri.so") ? "./libaneri.so" : "libaneri")
	else
		return __aneri = "aneri"

#define ANERI (__aneri || __detect_aneri())
#define ANERI_CALL(name, args...) __ANERI_EXT(__aneri_##name, "byond:" + #name)(args)

/// Deletes every Rust-side object, cancels background work, and closes log files.
/// Call it first thing in `/world/New()` and `/world/Del()`.
/proc/aneri_cleanup()	return call_ext(ANERI, "byond:cleanup")()

/// The library's name, version and git commit, like `aneri v1.2.3 (abc1234)`.
/proc/aneri_version()	return call_ext(ANERI, "byond:aneri_version")()

/// The Cargo features this build was compiled with, comma-separated.
/proc/aneri_features()	return call_ext(ANERI, "byond:aneri_features")()

/// Sets the folder where panic reports are written, creating it if needed.
/proc/aneri_set_panic_output_folder(path)	return call_ext(ANERI, "byond:set_panic_output_folder")(path)

/// Base type for datums whose data lives on the Rust side.
/// It holds the key that Rust uses to find that data.
/datum/aneri
	VAR_FINAL/__aneri_key_low
	VAR_FINAL/__aneri_key_high

/datum/aneri/Del()
	if(!gc_destroyed)
		gc_destroyed = world.time
		// no signal don't put a signal on this shit
		UNLINT(Destroy())
	return ..()
