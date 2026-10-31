//defines for antag opt in objective checking
//objectives check for all players with a value equal or greater than the 'threat' level of an objective then pick from that list
//command + sec roles are always opted in regardless of opt in status

/// For temporary or otherwise 'inconvenient' objectives like kidnapping or theft
#define OPT_IN_YES_TEMP 1
/// Cool with being killed or otherwise occupied but not removed from the round
#define OPT_IN_YES_KILL 2
/// Fine with being round removed.
#define OPT_IN_YES_ROUND_REMOVE 3

#define OPT_IN_YES_TEMP_STRING "Yes - Temporary/Inconvenience"
#define OPT_IN_YES_KILL_STRING "Yes - Kill"
#define OPT_IN_YES_ROUND_REMOVE_STRING "Yes - Round Remove"
#define OPT_IN_NOT_TARGET_STRING "No"

/// Prefers not to be a target. Will still be a potential target if playing sec or command.
#define OPT_IN_NOT_TARGET 0

/// The minimum opt-in level for people playing sec.
#define SECURITY_OPT_IN_LEVEL OPT_IN_YES_ROUND_REMOVE
/// The minimum opt-in level for people playing command.
#define COMMAND_OPT_IN_LEVEL OPT_IN_YES_ROUND_REMOVE

/// The default opt in level for preferences and mindless mobs.
#define OPT_IN_DEFAULT_LEVEL OPT_IN_YES_KILL

/// If the player has any non-ghost role antags enabled, they are forced to use a minimum of this.
#define OPT_IN_ANTAG_ENABLED_LEVEL OPT_IN_YES_KILL
