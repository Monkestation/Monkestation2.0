#define PLEXORA_SHUTDOWN_NORMAL 0
#define PLEXORA_SHUTDOWN_HARD 1
#define PLEXORA_SHUTDOWN_HARDEST 2
#define PLEXORA_SHUTDOWN_KILLDD 3

// Client doesn't exist or isn't connected
#define PLEXORA_ERROR_CLIENTNOTEXIST "plx_clientnotexist"
// Client has no mob (what)
#define PLEXORA_ERROR_CLIENTNOMOB "plx_clientnomob"
// Requested ticket doesnt exist
#define PLEXORA_ERROR_TICKETNOTEXIST "plx_ticketnotexist"
// Failed to sanitize a string aka the string was empty when sanitized
#define PLEXORA_ERROR_SANITIZATION_FAILED "plx_sanitizationfailed"
// Topic input didn't pass a ckey
#define PLEXORA_ERROR_MISSING_CKEY "plx_missingckey"
// player_details doesnt exist
#define PLEXORA_ERROR_DETAILSNOTEXIST "plx_detailsnotexist"
// Twitch key isn't configred
#define PLEXORA_ERROR_NOTWITCHKEY "plx_twitchkeynotconfigured"
// Topic call passed invalid smite
#define PLEXORA_ERROR_INVALIDSMITE "plx_invalidsmite"
