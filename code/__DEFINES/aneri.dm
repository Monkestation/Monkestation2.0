#ifndef ANERI

//#define ANERI_OVERRIDE_PICK
#define ANERI_OVERRIDE_PICK_WEIGHT
//#define ANERI_OVERRIDE_SORT
#define ANERI_OVERRIDE_RAND

/* This comment bypasses grep checks */ /var/__aneri

/proc/__detect_aneri()
	if(world.system_type == UNIX)
		return __aneri = "libaneri"
	else
		return __aneri = "aneri"

#define ANERI (__aneri || __detect_aneri())
#define ANERI_CALL(name, args...) call_ext(ANERI, "byond:" + name)(args)

/proc/aneri_version()	return ANERI_CALL("aneri_version")
/proc/aneri_features()	return ANERI_CALL("aneri_features")
/proc/aneri_cleanup()	return ANERI_CALL("cleanup")

#define aneri_log_write(fname, text, format)	ANERI_CALL("log_write", "[fname]", text, format)
/proc/aneri_log_close_all()						return ANERI_CALL("log_close_all")

#define aneri_json_is_valid(text)		ANERI_CALL("json_is_valid", text)

/proc/aneri_hex_encode(input, upper = FALSE)
	return ANERI_CALL("hex_encode", input, upper)

#define aneri_hex_decode(input)			ANERI_CALL("hex_decode", input)

#define aneri_url_encode(input) 		ANERI_CALL("url_encode", input)
#define aneri_url_decode(input) 		ANERI_CALL("url_decode", input)

#define url_encode(text) aneri_url_encode("[text]")
#define url_decode(text) aneri_url_decode("[text]")

#define aneri_base64_encode(input)		ANERI_CALL("base64_encode", input)
#define aneri_base64_decode(input)		ANERI_CALL("base64_decode", input)
#define aneri_base64url_encode(input)	ANERI_CALL("base64url_encode", input)
#define aneri_base64url_decode(input)	ANERI_CALL("base64url_decode", input)

/proc/aneri_uuid()						return ANERI_CALL("uuid")
/proc/aneri_cuid2(len = null)			return ANERI_CALL("cuid2", len)
/proc/aneri_unix_timestamp()			return ANERI_CALL("unix_timestamp")

#define aneri_sort(value, sorter)			ANERI_CALL("sort", value, sorter)

#define aneri_file_exists(file)				ANERI_CALL("file_exists", "[file]")
#define aneri_file_read(file)				ANERI_CALL("file_read", "[file]")
#define aneri_file_write(data, file)		ANERI_CALL("file_write", "[file]", "[data]")
#define aneri_file_append(data, file)		ANERI_CALL("file_append", "[file]", "[data]")
#define aneri_file_get_line_count(file)		ANERI_CALL("file_get_line_count", "[file]")
#define aneri_file_seek_line(file, line)	ANERI_CALL("file_seek", "[file]", line)
#define aneri_file_delete(file)				ANERI_CALL("file_delete", "[file]")
#define aneri_mkdir(path)					ANERI_CALL("mkdir", "[path]")
#define aneri_rmdir(path)					ANERI_CALL("rmdir", "[path]")

#define aneri_toml_is_valid(toml)			ANERI_CALL("aneri_toml_is_valid", "[toml]")
#define aneri_toml_decode(toml)				ANERI_CALL("toml_decode", "[toml]")
#define aneri_toml_decode_file(file)		ANERI_CALL("toml_decode_file", "[file]")

/// Use instead of REGEX_QUOTE for aneri regex
#define aneri_regex_escape(pattern)			ANERI_CALL("regex_escape", "[pattern]")
#define aneri_regex_combine_list(patterns)	ANERI_CALL("regex_combine_list", islist(patterns) ? patterns : list(patterns))

//#define file2text(fname)		aneri_file_read("[fname]")
//#define text2file(text, fname)	aneri_file_append(text, "[fname]")

#define aneri_md5(input)		ANERI_CALL("hash", "md5", input)
#define aneri_md5_file(fname)	ANERI_CALL("hash_file", "md5", fname)

/proc/aneri_replace_chars_prob(input, replacement, probability = 25, skip_whitespace = FALSE) as text
	return ANERI_CALL("replace_chars_prob", input, replacement, probability, skip_whitespace)

#if defined(ANERI_OVERRIDE_PICK) || defined(ANERI_OVERRIDE_PICK_WEIGHT)
#define pick_weight(list)		_aneri_pick_weighted(list)
#endif

#ifdef ANERI_OVERRIDE_PICK
#define pick(list...)			_apick(list)

/proc/_apick(...)
	switch(length(args))
		if(0)
			CRASH("pick() called with no arguments")
		if(1)
			var/list/arg = args[1]
			if(!islist(arg))
				CRASH("pick() called with non-list argument")
			return _aneri_pick(arg)
		else
			return _aneri_pick(args)
#endif

#ifdef ANERI_OVERRIDE_RAND
/proc/_arand(...)
	switch(length(args))
		if(0)
			return ANERI_CALL("random_float")
		if(1)
			return ANERI_CALL("random_range_int_unsigned", 0, args[1])
		if(2)
			return ANERI_CALL("random_range_int_signed", args[1], args[2])
		else
			CRASH("arand() takes 0-2 arguments")

#define rand(args...)	_arand(args)
#define prob(val)		ANERI_CALL("prob", val)
#endif

/world/New()
	aneri_startup_log()
	aneri_cleanup()
	..()

#endif
