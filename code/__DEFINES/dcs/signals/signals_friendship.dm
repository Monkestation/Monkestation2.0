/// from /datum/component/friendship_container: (atom/target, friendship_level). Returns TRUE if the target's friendship is at or above friendship_level
#define COMSIG_FRIENDSHIP_CHECK_LEVEL "friendship_check_level"
/// from /datum/component/friendship_container: (atom/target, amount). Adds amount (can be negative) to the target's friendship
#define COMSIG_FRIENDSHIP_CHANGE "friendship_change"
/// from /datum/component/friendship_container: (atom/target). Copies all of our friendships onto the target
#define COMSIG_FRIENDSHIP_PASS_FRIENDSHIP "friendship_passfriends"
