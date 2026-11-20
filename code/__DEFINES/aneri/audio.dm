#define ANERI_AUDIO_SUCCESSES "successes"
#define ANERI_AUDIO_ERRORS "errors"

/// How long each sound file in a list is, in deciseconds.
/// Returns `list(ANERI_AUDIO_SUCCESSES = list(path = length), ANERI_AUDIO_ERRORS = list(path = message))`,
/// where every path you passed appears in exactly one of the two.
/// A file whose header has no length goes in the errors.
/// Files are read in parallel. Runtimes if an entry isn't a string.
/proc/aneri_audio_length_list(list/paths) as /list
	RETURN_TYPE(/list)
	return ANERI_CALL(audio_length_list, paths)
