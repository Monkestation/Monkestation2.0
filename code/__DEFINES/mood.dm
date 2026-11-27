#define MOOD_CATEGORY_LEGION_CORE "regenerative core"

/// Relates to fear or resisting fear
#define MOOD_EVENT_FEAR (1<<0)
/// Relates to art
#define MOOD_EVENT_ART (1<<1)
/// Relates to being a generally silly guy
#define MOOD_EVENT_WHIMSY (1<<2)
/// Playing games and goofing off
#define MOOD_EVENT_GAMING (1<<3)
/// Relates to food
#define MOOD_EVENT_FOOD (1<<4)
/// Relates to being in pain
#define MOOD_EVENT_PAIN (1<<5)
/// Relates to spirituality
#define MOOD_EVENT_SPIRITUAL (1<<6)

/// Checks if the mob has the given personality typepath
#define HAS_PERSONALITY(mob, personality) (LAZYACCESS(mob.personalities, personality))

/// Return from /be_replaced or /be_refreshed to actually go prevent the new mood event from being added
#define BLOCK_NEW_MOOD FALSE
/// Return from /be_replaced or /be_refreshed to actually go through and allow the new mood event to be added
#define ALLOW_NEW_MOOD TRUE
// Threshold levels for beauty for humans
#define BEAUTY_LEVEL_HORRID -66
#define BEAUTY_LEVEL_BAD -33
#define BEAUTY_LEVEL_DECENT 33
#define BEAUTY_LEVEL_GOOD 66
#define BEAUTY_LEVEL_GREAT 100

// Moods levels for humans
#define MOOD_HAPPY4 15
#define MOOD_HAPPY3 10
#define MOOD_HAPPY2 6
#define MOOD_HAPPY1 2
#define MOOD_NEUTRAL 0
#define MOOD_SAD1 -3
#define MOOD_SAD2 -7
#define MOOD_SAD3 -15
#define MOOD_SAD4 -20

// Moods levels for humans
#define MOOD_LEVEL_HAPPY4 9
#define MOOD_LEVEL_HAPPY3 8
#define MOOD_LEVEL_HAPPY2 7
#define MOOD_LEVEL_HAPPY1 6
#define MOOD_LEVEL_NEUTRAL 5
#define MOOD_LEVEL_SAD1 4
#define MOOD_LEVEL_SAD2 3
#define MOOD_LEVEL_SAD3 2
#define MOOD_LEVEL_SAD4 1

// Sanity values for humans
#define SANITY_MAXIMUM 150
#define SANITY_GREAT 125
#define SANITY_NEUTRAL 100
#define SANITY_DISTURBED 75
#define SANITY_UNSTABLE 50
#define SANITY_CRAZY 25
#define SANITY_INSANE 0

// Sanity levels for humans
#define SANITY_LEVEL_GREAT 1
#define SANITY_LEVEL_NEUTRAL 2
#define SANITY_LEVEL_DISTURBED 3
#define SANITY_LEVEL_UNSTABLE 4
#define SANITY_LEVEL_CRAZY 5
#define SANITY_LEVEL_INSANE 6
/// Equal to the highest sanity level
#define SANITY_LEVEL_MAX SANITY_LEVEL_INSANE

/// Threshold for desensitization effects to start applying
#define DESENSITIZED_THRESHOLD 0.5
/// Minimum level for desensitization multiplier
#define DESENSITIZED_MINIMUM 0.1
/// Reduction in desensitization level per death witnessed
#define DESENSITIZED_REDUCTION_PER_DEATH 0.025

/// Check if a mob is desensitized (passes the threshold)
#define IS_DESENSITIZED(mob) ((mob.mind?.desensitized_level || 1) <= DESENSITIZED_THRESHOLD)
