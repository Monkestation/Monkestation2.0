/// Path to the base directory for cassette stuff
#define CASSETTE_BASE_DIR "data/cassette_storage/"
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
