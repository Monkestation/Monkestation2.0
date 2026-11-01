#define BASIC_MOB_MAX_STAMINALOSS 200

///Basic mob flags

/// Delete mob upon death
#define DEL_ON_DEATH (1<<0)
/// Rotate mob 180 degrees while it is dead
#define FLIP_ON_DEATH (1<<1)
/// Mob remains dense while dead
#define REMAIN_DENSE_WHILE_DEAD (1<<2)
/// Mob can be set on fire
#define FLAMMABLE_MOB (1<<3)
/// Mob never takes damage from unarmed attacks
#define IMMUNE_TO_FISTS (1<<4)

/// Temporary trait applied when an attack forecast animation has completed
#define TRAIT_BASIC_ATTACK_FORECAST "trait_basic_attack_forecast"
#define INTERACTION_BASIC_ATTACK_FORCEAST "interaction_basic_attack_forecast"

/// Above this speed we stop gliding because it looks silly
#define END_GLIDE_SPEED 10

///mook attack status flags
#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_STRIKE 3

#define EMOTION_HAPPY "happy"
#define EMOTION_SAD "sad"
#define EMOTION_SCARED "scared"
#define EMOTION_FUNNY "funny"
#define EMOTION_ANGER "anger"
#define EMOTION_SURPRISED "suprised"
#define EMOTION_HUNGRY "hungry"

#define FRIENDSHIP_HATED "hated"
#define FRIENDSHIP_DISLIKED "disliked"
#define FRIENDSHIP_STRANGER "stranger"
#define FRIENDSHIP_NEUTRAL "neutral"
#define FRIENDSHIP_ACQUAINTANCES "acquaintances"
#define FRIENDSHIP_FRIEND "friend"
#define FRIENDSHIP_BESTFRIEND "bestfriend"

///keeps track of how many gutlunches are born
GLOBAL_VAR_INIT(gutlunch_count, 0)
