/* This comment bypasses grep checks */ /var/__aneri

/proc/__detect_aneri()
	if (world.system_type == UNIX)
		return __aneri = (fexists("./libaneri.so") ? "./libaneri.so" : "libaneri")
	else
		return __aneri = "aneri"

#define ANERI (__aneri || __detect_aneri())
#define ANERI_CALL(name, args...) call_ext(ANERI, "byond:" + name)(args)

// aneri-core
#define aneri_version(...)	(ANERI_CALL("aneri_version"))
#define aneri_features(...)	(ANERI_CALL("aneri_features"))
#define aneri_cleanup(...)	(ANERI_CALL("cleanup"))

// aneri-dmi
#define ANERI_RESIZE_NEAREST	"nearest"
#define ANERI_RESIZE_CATMULL	"catmull"
#define ANERI_RESIZE_GAUSSIAN	"gaussian"
#define ANERI_RESIZE_LANCZOS3	"lanczos3"
#define ANERI_RESIZE_TRIANGLE	"triangle"

// aneri-encode
#define aneri_url_encode(data)			(ANERI_CALL("url_encode", data))
#define aneri_url_decode(data)			(ANERI_CALL("url_decode", data))
#define aneri_hex_decode(data)			(ANERI_CALL("hex_decode", data))
#define aneri_base64_encode(data)		(ANERI_CALL("base64_encode", data))
#define aneri_base64_decode(data)		(ANERI_CALL("base64_decode", data))
#define aneri_base64url_encode(data)	(ANERI_CALL("base64url_encode", data))
#define aneri_base64url_decode(data)	(ANERI_CALL("base64url_decode", data))

/proc/aneri_hex_encode(data, upper = FALSE)
	return ANERI_CALL("hex_encode", data, upper)

// aneri-file
#define aneri_file_exists(path)				(ANERI_CALL("file_exists", path))
#define aneri_file_read(path)				(ANERI_CALL("file_read", path))
#define aneri_file_write(data, path)		(ANERI_CALL("file_write", path, data))
#define aneri_file_append(data, path)		(ANERI_CALL("file_append", path, data))
#define aneri_file_get_line_count(path)		(ANERI_CALL("file_get_line_count", path))
#define aneri_file_seek_line(path, line)	(ANERI_CALL("file_seek_line", path, line))
#define aneri_file_delete(path)				(ANERI_CALL("file_delete", path))
#define aneri_mkdir(path)					(ANERI_CALL("mkdir", path))
#define aneri_rmdir(path)					(ANERI_CALL("rmdir", path))

// aneri-logger
#define aneri_log_write(path, message, format)	(ANERI_CALL("log_write", path, message, format))
#define aneri_log_close_all(...)				(ANERI_CALL("log_close_all"))

// aneri-regex
#define aneri_regex_is_match(regex, haystack)			(ANERI_CALL("regex_is_match", regex, haystack))
#define aneri_regex_split(regex, haystack)				(ANERI_CALL("regex_split", regex, haystack))
#define aneri_regex_replace(regex, haystack, with)		(ANERI_CALL("regex_replace", regex, haystack, with))
#define aneri_regex_replace_all(regex, haystack, with)	(ANERI_CALL("regex_replace_all", regex, haystack, with))
#define aneri_regex_find(regex, haystack)				(ANERI_CALL("regex_find", regex, haystack))

/proc/aneri_regex_splitn(regex, haystack, limit = 1)
	return ANERI_CALL("regex_splitn", regex, haystack, limit)

// aneri-time
#define aneri_unix_timestamp(...)	(ANERI_CALL("unix_timestamp"))
#define human_readable_timestamp(...) (ANERI_CALL("human_readable_timestamp"))

// aneri-util
#define aneri_json_is_valid(json)					(ANERI_CALL("json_is_valid", json))
#define aneri_toml_is_valid(toml)					(ANERI_CALL("toml_is_valid", toml))
#define aneri_toml_file_is_valid(file)				(ANERI_CALL("toml_file_is_valid", "[file]"))

#define aneri_levenshtein(a, b)						(ANERI_CALL("levenshtein", a, b))
#define aneri_damerau_levenshtein(a, b)				(ANERI_CALL("damerau_levenshtein", a, b))
#define aneri_normalized_levenshtein(a, b)			(ANERI_CALL("normalized_levenshtein", a, b))
#define aneri_normalized_damerau_levenshtein(a, b)	(ANERI_CALL("normalized_damerau_levenshtein", a, b))
#define aneri_hamming(a, b)							(ANERI_CALL("hamming", a, b))

#define aneri_deunicode(string, placeholder)		(ANERI_CALL("deunicode", string, placeholder))
#define aneri_toml_decode(toml)						(ANERI_CALL("toml_decode", toml))
#define aneri_toml_decode_file(file)				(ANERI_CALL("toml_decode_file", "[file]"))

#define aneri_uuid(...)			(ANERI_CALL("uuid"))
#define aneri_cuid2(...)		(ANERI_CALL("cuid2"))
#define aneri_cuid2_len(len)	(ANERI_CALL("cuid2", len))

// rust-g overrides
#define rustg_file_read(fname) 				aneri_file_read(fname)
#define rustg_file_exists(fname)			aneri_file_exists(fname)
#define rustg_file_write(text, fname)		aneri_file_write(text, fname)
#define rustg_file_append(text, fname)		aneri_file_append(text, fname)
#define rustg_file_get_line_count(fname)	aneri_file_get_line_count(fname)
#define rustg_file_seek_line(fname, line)	aneri_file_seek_line(fname, line)
#define rustg_json_is_valid(json)			aneri_json_is_valid(json)
