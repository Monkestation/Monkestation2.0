/// Whether `file` is a valid TOML document.
/// Takes a path or a file reference.
#define aneri_toml_file_is_valid(file)	(ANERI_CALL(toml_file_is_valid, "[file]"))
/// Decodes a TOML file into an assoc list.
/// Takes a path or a file reference.
/// Runtimes if it can't be read or isn't valid TOML.
#define aneri_toml_decode_file(file)	(ANERI_CALL(toml_decode_file, "[file]"))
