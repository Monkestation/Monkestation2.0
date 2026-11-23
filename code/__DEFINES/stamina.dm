#define FILTER_STAMINACRIT filter(type="drop_shadow", x=0, y=0, size=-3, color="#04080F")
///Time before regen restarts when hit with stam damage
#define STAMINA_REGEN_TIME (2.5 SECONDS)
///The amount of stamina a carbon recovers every second
#define STAMINA_REGEN 5


////
/// STATS
////

///The default maximum stamina
#define STAMINA_MAX 100


////
/// COMBAT
////

///Swings only cost stamina while the user has more than this much left, so they can't stamcrit themselves.
#define STAMINA_MAXIMUM_TO_SWING 40
///The time a mob is stunned when stamina stunned
#define STAMINA_STUN_TIME 10 SECONDS

////
/// SPRINTING
////
///The grace period where you can stop sprinting but still be considered sprinting
#define STAMINA_SUSTAINED_RUN_GRACE 0.5 SECONDS
///The amount of tiles you need to move to be considered moving in a sustained sprint
#define STAMINA_SUSTAINED_SPRINT_THRESHOLD 8
///How much stamina is taken per tile while sprinting
#define STAMINA_SPRINT_COST 0.4
