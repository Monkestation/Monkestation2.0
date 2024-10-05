/**
 * Roles
 */
#define ROLE_MONSTERHUNTER "Monster Hunter"

/**
 * Signals
 */
#define COMSIG_RABBIT_FOUND "rabbit_found"
#define COMSIG_GAIN_INSIGHT "gain_insight"
#define COMSIG_BEASTIFY "beastify"

/**
 * Sources
 */
/// Trait source for monster hunters.
#define HUNTER_TRAIT "hunter_trait"

/**
 * Factions
 */
///Define for the 'Rabbits' faction.
#define FACTION_RABBITS "rabbits"

/**
 * Macros
 */
/// Returns whether a mob is a monster hunter.
#define IS_MONSTERHUNTER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/monsterhunter))
