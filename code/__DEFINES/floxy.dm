#define FLOXY_STATUS_PENDING "pending"
#define FLOXY_STATUS_DOWNLOADING "downloading"
#define FLOXY_STATUS_METADATA "metadata"
#define FLOXY_STATUS_COMPLETED "completed"
#define FLOXY_STATUS_FAILED "failed"

/// File is on disk and available in the cache
#define MEDIA_ENTRY_AVAILABLE (1 << 0)
/// File is on disk but marked as deleted
#define MEDIA_ENTRY_DELETED (1 << 1)
/// Neither the output file nor the deleted file is present on disk
#define MEDIA_ENTRY_MISSING (1 << 2)
