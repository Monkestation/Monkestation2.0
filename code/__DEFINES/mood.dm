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
