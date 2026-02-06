/// Marks a level as being "safe", even if it is a station z level.
/// Nukes will not kill players on such levels.
#define ZTRAIT_FORCED_SAFETY "Forced Safety"

#define is_safe_level(z) SSmapping.level_trait(z, ZTRAIT_FORCED_SAFETY)
