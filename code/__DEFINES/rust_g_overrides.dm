// RUSTG_OVERRIDE_BUILTINS is not used since the file APIs don't work well over Linux.
#define url_encode(text) aneri_url_encode("[text]")
#define url_decode(text) aneri_url_decode("[text]")
