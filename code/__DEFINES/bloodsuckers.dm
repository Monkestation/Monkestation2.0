///Uncomment this to enable testing of Bloodsucker features (such as vassalizing people with a mind instead of a client).
// #define BLOODSUCKER_TESTING

#ifdef BLOODSUCKER_TESTING
#ifdef CIBUILDING
#error BLOODSUCKER_TESTING is enabled, disable this!!!
#else
#warn BLOODSUCKER_TESTING is enabled, you REALLY do not want this enabled outside of local testing!!
#endif //ifdef CIBUILDING
#endif //ifdef BLOODSUCKER_TESTING

/**
 * Blood-level defines
 */
/// Determines Bloodsucker regeneration rate
#define BS_BLOOD_VOLUME_MAX_REGEN 700
/// Cost to torture someone halfway, in blood. Called twice for full cost
#define TORTURE_BLOOD_HALF_COST 8
/// Cost to convert someone after successful torture, in blood
#define TORTURE_CONVERSION_COST 50
/// Once blood is this low, will enter Frenzy
#define FRENZY_THRESHOLD_ENTER 25
/// Once blood is this high, will exit Frenzy
#define FRENZY_THRESHOLD_EXIT 250

/// Minimum blood required for bloodsucker oozelings to auto-revive
#define OOZELING_MIN_REVIVE_BLOOD_THRESHOLD (FRENZY_THRESHOLD_ENTER * 10)

/**
 * Vassal defines
 */
///If someone passes all checks and can be vassalized
#define VASSALIZATION_ALLOWED 0
///If someone has to accept vassalization
#define VASSALIZATION_DISLOYAL 1
///If someone is not allowed under any circumstances to become a Vassal
#define VASSALIZATION_BANNED 2

/**
 * Cooldown defines
 * Used in Cooldowns Bloodsuckers use to prevent spamming
 */
///Spam prevention for healing messages.
#define BLOODSUCKER_SPAM_HEALING (15 SECONDS)
///Spam prevention for Sol Masquerade messages.
#define BLOODSUCKER_SPAM_MASQUERADE (60 SECONDS)
//Torpor softlock prevention - define it high as it is a failsafe
#define BLOODSUCKER_TORPOR_MAX_TIME (120 SECONDS)

/**
 * Clan defines
 */
#define CLAN_NONE "Caitiff"
#define CLAN_BRUJAH "Brujah Clan"
#define CLAN_TOREADOR "Toreador Clan"
#define CLAN_NOSFERATU "Nosferatu Clan"
#define CLAN_TREMERE "Tremere Clan"
#define CLAN_GANGREL "Gangrel Clan"
#define CLAN_VENTRUE "Ventrue Clan"
#define CLAN_MALKAVIAN "Malkavian Clan"
#define CLAN_TZIMISCE "Tzimisce Clan"
#define CLAN_VASSAL "your Master"

#define TREMERE_VASSAL "tremere_vassal"
#define FAVORITE_VASSAL "favorite_vassal"
#define REVENGE_VASSAL "revenge_vassal"

/**
 * Power defines
 */
/// This Power can't be used in Torpor
#define BP_CANT_USE_IN_TORPOR (1<<0)
/// This Power can't be used in Frenzy.
#define BP_CANT_USE_IN_FRENZY (1<<1)
/// This Power can't be used with a stake in you
#define BP_CANT_USE_WHILE_STAKED (1<<2)
/// This Power can't be used while incapacitated
#define BP_CANT_USE_WHILE_INCAPACITATED (1<<3)
/// This Power can't be used while unconscious
#define BP_CANT_USE_WHILE_UNCONSCIOUS (1<<4)
/// This Power CAN be used while silver cuffed
#define BP_ALLOW_WHILE_SILVER_CUFFED (1<<5)

/// This Power can be purchased by Bloodsuckers
#define BLOODSUCKER_CAN_BUY (1<<0)
/// This is a Default Power that all Bloodsuckers get.
#define BLOODSUCKER_DEFAULT_POWER (1<<1)
/// This Power can be purchased by Tremere Bloodsuckers
#define TREMERE_CAN_BUY (1<<2)
/// This Power can be purchased by Vassals
#define VASSAL_CAN_BUY (1<<3)

/// This Power is a Toggled Power
#define BP_AM_TOGGLE (1<<0)
/// This Power is a Single-Use Power
#define BP_AM_SINGLEUSE (1<<1)
/// This Power has a Static cooldown
#define BP_AM_STATIC_COOLDOWN (1<<2)
/// This Power has a custom cooldown scaling (do not use automatic cooldown reduction per level)
#define BP_AM_CUSTOM_COOLDOWN (1<<3)
/// This Power doesn't cost bloot to run while unconscious
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<4)

/**
 * Bloodsucker Signals
 */
///Called when a Bloodsucker ranks up: (datum/bloodsucker_datum, mob/owner, mob/target)
#define COMSIG_BLOODSUCKER_RANK_UP "bloodsucker_rank_up"
///Called when a Bloodsucker interacts with a Vassal on their persuasion rack.
#define COMSIG_BLOODSUCKER_INTERACT_WITH_VASSAL "bloodsucker_interact_with_vassal"
///Called when a Bloodsucker makes a Vassal into their Favorite Vassal: (datum/vassal_datum, mob/master)
#define COMSIG_BLOODSUCKER_MAKE_FAVORITE "bloodsucker_make_favorite"
///Called when a new Vassal is successfully made: (datum/bloodsucker_datum)
#define COMSIG_BLOODSUCKER_MADE_VASSAL "bloodsucker_made_vassal"
///Called when a Bloodsucker exits Torpor.
#define COMSIG_BLOODSUCKER_EXIT_TORPOR "bloodsucker_exit_torpor"
///Called when a Bloodsucker reaches Final Death.
#define COMSIG_BLOODSUCKER_FINAL_DEATH "bloodsucker_final_death"
	///Whether the Bloodsucker should not be dusted when arriving Final Death
	#define DONT_DUST (1<<0)
///Called when a Bloodsucker breaks the Masquerade
#define COMSIG_BLOODSUCKER_BROKE_MASQUERADE "bloodsucker_broke_masquerade"
///Called when a Bloodsucker enters Frenzy
#define COMSIG_BLOODSUCKER_ENTERS_FRENZY "bloodsucker_enters_frenzy"
///Called when a Bloodsucker exits Frenzy
#define COMSIG_BLOODSUCKER_EXITS_FRENZY "bloodsucker_exits_frenzy"
/// Called on the mind when a Bloodsucker chooses a clan: (datum/antagonist/bloodsucker, datum/bloodsucker_clan)
#define COMSIG_BLOODSUCKER_CLAN_CHOSEN "clan_chosen"

/**
 * Sol signals & Defines
 */
#define COMSIG_SOL_RANKUP_BLOODSUCKERS "sol_rankup_bloodsuckers"

///Called on a Bloodsucker's Lifetick.
#define COMSIG_BLOODSUCKER_ON_LIFETICK "bloodsucker_on_lifetick"

#define DANGER_LEVEL_FIRST_WARNING 1
#define DANGER_LEVEL_SECOND_WARNING 2
#define DANGER_LEVEL_THIRD_WARNING 3
#define DANGER_LEVEL_SOL_ROSE 4
#define DANGER_LEVEL_SOL_ENDED 5


/**
 * Clan defines
 *
 * This is stuff that is used solely by Clans for clan-related activity.
 */
///Drinks blood the normal Bloodsucker way.
#define BLOODSUCKER_DRINK_NORMAL "bloodsucker_drink_normal"
///Drinks blood but is snobby, taking a mood penalty for drinking from mindless
#define BLOODSUCKER_DRINK_SNOBBY "bloodsucker_drink_snobby"
///Drinks blood from disgusting creatures without Humanity consequences.
#define BLOODSUCKER_DRINK_INHUMANELY "bloodsucker_drink_imhumanely"

/**
 * Role defines
 */
#define ROLE_BLOODSUCKER "Bloodsucker"
#define ROLE_VAMPIRICACCIDENT "Vampiric Accident"
#define ROLE_BLOODSUCKERBREAKOUT "Bloodsucker Breakout"
#define ROLE_INFILTRATOR "Infiltrator"

/**
 * Macros
 */
///Whether a mob is a Bloodsucker
#define IS_BLOODSUCKER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/bloodsucker))
///Whether a mob is a Vassal
#define IS_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal))
///Whether a mob is a Bloodsucker OR a Vassal
#define IS_BLOODSUCKER_OR_VASSAL(mob) (IS_BLOODSUCKER(mob) || IS_VASSAL(mob))
///Whether a mob is a Favorite Vassal
#define IS_FAVORITE_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal/favorite))
///Whether a mob is a Revenge Vassal
#define IS_REVENGE_VASSAL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/vassal/revenge))

//Used in bloodsucker_life.dm
#define MARTIALART_FRENZYGRAB "frenzy grabbing"

/// The level needed to complete the Tremere objective.
#define TREMERE_OBJECTIVE_POWER_LEVEL 5

#define BLOODSUCKER_MAX_BLOOD_DEFAULT 600
#define BLOODSUCKER_MAX_BLOOD_INCREASE_ON_RANKUP 80
#define BLOODSUCKER_REGEN_INCREASE_ON_RANKUP 0.1
#define BLOODSUCKER_UNARMED_DMG_INCREASE_ON_RANKUP 0.5
