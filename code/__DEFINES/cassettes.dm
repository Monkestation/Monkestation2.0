#ifndef CASSETTE_BASE_DIR
/// Path to the base directory for cassette stuff
#define CASSETTE_BASE_DIR "data/cassette_storage/"
#endif
/// Path to the file containing a list of cassette IDs.
#define CASSETTE_ID_FILE (CASSETTE_BASE_DIR + "ids.json")
/// Path to the data for the cassette of the given ID.
#define CASSETTE_FILE(id) (CASSETTE_BASE_DIR + "[id].json")

/// This cassette is unapproved, and has not been submitted for review.
#define CASSETTE_STATUS_UNAPPROVED 0
/// This cassette is under review.
#define CASSETTE_STATUS_REVIEWING 1
/// This cassette has been approved.
#define CASSETTE_STATUS_APPROVED 2
/// This cassette has been denied.
#define CASSETTE_STATUS_DENIED 3

/// The maximum amount of songs one side of a cassette tape can hold.
#define MAX_SONGS_PER_CASSETTE_SIDE 7

#define PLAY_CASSETTE_SOUND(sfx) playsound(src, ##sfx, vol = 90, vary = FALSE, mixer_channel = CHANNEL_MACHINERY)
