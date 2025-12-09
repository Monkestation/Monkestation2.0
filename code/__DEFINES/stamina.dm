#define FILTER_STAMINACRIT filter(type="drop_shadow", x=0, y=0, size=-3, color="#04080F")
///Time before regen restarts when hit with stam damage
#define STAMINA_REGEN_TIME (2.5 SECONDS)
///The amount of stamina a carbon recovers every second
#define STAMINA_REGEN 5

#define ATTACK_DO_NOTHING (0<<0)
#define ATTACK_HANDLED (1<<1)
#define ATTACK_CONSUME_STAMINA (1<<2)

////
/// STATS
////

///The default maximum stamina
#define STAMINA_MAX 100


////
/// COMBAT
////

///The default swing cost of an item.
#define STAMINA_SWING_COST_ITEM 25
///The default stamina damage of an item
#define STAMINA_DAMAGE_ITEM 15
///The default stamina damage of unarmed attacks
#define STAMINA_DAMAGE_UNARMED 24
///The default stamina consumption of unarmed attacks
#define STAMINA_SWING_COST_UNARMED 12
///The default critical hit chance of an item
#define STAMINA_CRITICAL_RATE_ITEM 25
///The multiplier applied to damage on a critical
#define STAMINA_CRITICAL_MODIFIER 2
///The amount of stamina at which point swinging is free.
#define STAMINA_MAXIMUM_TO_SWING 100
///The time a mob is stunned when stamina stunned
#define STAMINA_STUN_TIME 10 SECONDS

////
/// DISARM
////
/// How much stamina it costs to Disarm/Shove
#define STAMINA_DISARM_COST 30
/// The amount of stamina damage dealt on disarm by default.
#define STAMINA_DISARM_DMG 18

////
/// SPRINTING
////
///The grace period where you can stop sprinting but still be considered sprinting
#define STAMINA_SUSTAINED_RUN_GRACE 0.5 SECONDS
///The amount of tiles you need to move to be considered moving in a sustained sprint
#define STAMINA_SUSTAINED_SPRINT_THRESHOLD 8
///How much stamina is taken per tile while sprinting
#define STAMINA_SPRINT_COST 0.4

////
/// GRAPPLING
////
/// Chance to resist out of passive grabs.
#define STAMINA_GRAB_PASSIVE_RESIST_CHANCE 100
/// Chance to resist out of a strong grab (i.e. werewolves)
#define STAMINA_GRAB_AGGRESSIVE_RESIST_CHANCE 60
/// Chance to resist out of chokeholds grabs.
#define STAMINA_GRAB_CHOKE_RESIST_CHANCE 45

