/**
 * Macros
 */
/// Returns a lifeforce change source for the given action.
#define VAMPIRE_CONSTANT_LIFEFORCE_COST(action) (action?.name + " constant lifeforce cost")

/**
 * Lifeforce
 */
/// The maximum amount of lifeforce a vampire can carry. This is a soft cap.
#define LIFEFORCE_MAXIMUM (LIFEFORCE_PER_HUMAN * 3)
/// How much lifeforce one human is roughly worth. Can vary wildly sometimes.
#define LIFEFORCE_PER_HUMAN 100
/// How much lifeforce is lost per second by default. 1 hr/human
#define LIFEFORCE_DRAIN_BASE (LIFEFORCE_PER_HUMAN / -3600)
/// How much lifeforce it costs to enthrall someone.
#define LIFEFORCE_THRALL (LIFEFORCE_PER_HUMAN / 2)
/// Multiply lifeforce by this to get an equivalent amount of blood.
#define LIFEFORCE_TO_BLOOD (BLOOD_VOLUME_NORMAL / LIFEFORCE_PER_HUMAN)
/// Multiply blood by this to get an equivalent amount of lifeforce.
#define BLOOD_TO_LIFEFORCE (LIFEFORCE_PER_HUMAN / BLOOD_VOLUME_NORMAL)

/**
 * Lifeforce Change Sources
 */
#define LIFEFORCE_CHANGE_THIRST "thirst"
#define LIFEFORCE_CHANGE_OVERFLOW "overflow"
#define LIFEFORCE_CHANGE_MASQUERADE "masquerade"

/**
 * Vampire Rank
 */
/// The maximum vampire rank achievable.
#define VAMPIRE_RANK_MAX 6
/// The amount of lifeforce ranking up costs initially.
#define VAMPIRE_RANKUP_COST LIFEFORCE_PER_HUMAN
/// The amount of extra lifeforce per rank that ranking up costs.
#define VAMPIRE_RANKUP_SCALING (LIFEFORCE_PER_HUMAN * 0.25)

/**
 * Stats
 */
/// The amount of stat points a vampire gets when they rank up.
#define VAMPIRE_SP_PER_RANK 2
/// The amount of *extra* stat points a Caitiff gets when they rank up.
#define VAMPIRE_SP_CAITIFF_BONUS 1
/// The maximum amount of stat points in any given stat. The total goes above this if you're a Caitiff.
#define VAMPIRE_SP_MAXIMUM 12

/// Grants offensive passives and abilities.
#define VAMPIRE_STAT_BRUTALITY "Brutality"
/// Grants defensive passives and abilities.
#define VAMPIRE_STAT_TENACITY "Tenacity"
/// Grants movement passives and abilities.
#define VAMPIRE_STAT_PURSUIT "Pursuit"
/// Grants regeneration passives and abilities.
#define VAMPIRE_STAT_RECOVERY "Recovery"
/// Grants information passives and abilities.
#define VAMPIRE_STAT_PERCEPTION "Perception"
/// Grants stealth passives and abilities.
#define VAMPIRE_STAT_DISCRETION "Discretion"

/**
 * Abilities
 */
/// Associative key for all vampire abilities.
#define VAMPIRE_ABILITIES_ALL "All"
/// Associative key for vampire abilities that are unlocked by ranking up. (min_rank)
#define VAMPIRE_ABILITIES_RANK "Rank"

/**
 * Clans
 */
/// No special abilities, but gets extra stat points.
#define VAMPIRE_CLAN_CAITIFF "Caitiff"

/**
 * Recuperation Stat Thresholds
 */
// These thresholds are in recovery stat points.
#define VAMPIRE_REGEN_THRESHOLD_TOX 3 // heals tox and clone
#define VAMPIRE_REGEN_THRESHOLD_WOUNDS 4 // heals wounds
#define VAMPIRE_REGEN_THRESHOLD_OXY 5 // heals oxy
#define VAMPIRE_REGEN_THRESHOLD_ORGANS 6 // heals organs and mild brain traumas
#define VAMPIRE_REGEN_THRESHOLD_PURGE 7 // purges toxic reagents
#define VAMPIRE_REGEN_THRESHOLD_REGROW_LIMBS 8 // regrows limbs
#define VAMPIRE_REGEN_THRESHOLD_REGROW_ORGANS 9 // regrows organs and heals severe brain traumas
#define VAMPIRE_REGEN_THRESHOLD_REVIVE 10 // revives from death
