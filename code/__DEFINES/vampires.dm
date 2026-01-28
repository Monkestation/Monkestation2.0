/// Uncomment this to enable testing of Vampire features (such as vassalizing people with a mind instead of a client).
//#define VAMPIRE_TESTING
#if defined(VAMPIRE_TESTING) && defined(CIBUILDING)
	#error VAMPIRE_TESTING is enabled, disable this!
#endif
#ifdef TESTING
	#define VAMPIRE_TESTING
#endif

// Blood-level defines
/// Determines Vampire regeneration rate
#define BS_BLOOD_VOLUME_MAX_REGEN 700
/// Cost to torture someone halfway, in blood. Called twice for full cost
#define TORTURE_BLOOD_HALF_COST 8
/// Cost to convert someone after successful torture, in blood
#define TORTURE_CONVERSION_COST 50
/// Once blood is this low, will enter a Frenzy
#define FRENZY_THRESHOLD_ENTER 25
/// Once blood is this high, will exit the Frenzy. Intentionally high, we want to kill the person we feed off of
#define FRENZY_THRESHOLD_EXIT 500
/// How much blood drained from the vampire each lifetick
#define VAMPIRE_PASSIVE_BLOOD_DRAIN 0.1
/// The number that incoming levels are divided by when comitting the Amaranth. Example: 2 would divide the victims level by 2, and give that to the diablerist
#define DIABLERIE_DIVISOR 1.5
/// Amount of vitae drunk from another player required to level up.
#define VITAE_GOAL_STANDARD 250

/// How much the bloodsucker's punch/kick damage increases with each level.
#define VAMPIRE_UNARMED_DMG_INCREASE_ON_RANKUP 0.5

/// How many starting levels do we want each one to have?
#define VAMPIRE_STARTING_LEVELS 3
/// How many free levels the vampire gets gradually.
#define VAMPIRE_FREE_LEVELS 2
/// Vampire's default stamina resist.
#define VAMPIRE_INHERENT_STAMINA_RESIST 0.75

/// When do we warn them about their low blood?
#define VAMPIRE_LOW_BLOOD_WARNING 300

/// Minimum blood required for vampires oozelings to auto-revive.
#define OOZELING_MIN_REVIVE_BLOOD_THRESHOLD (FRENZY_THRESHOLD_ENTER * 5)
/// How long it takes for an vampire oozeling to auto-revive, when left alone.
#define OOZELING_VAMPIRE_REVIVE_TIME (1.5 MINUTES)
/// How many times faster an oozeling vampire will revive if their core is being held by a non-vampire/non-ally.
#define OOZELING_VAMPIRE_REVIVE_HELD_MULTIPLIER 0.5
/// How many times faster an oozeling vampire will revive if their core is being held by an ally.
#define OOZELING_VAMPIRE_REVIVE_ALLY_MULTIPLIER 1.2
/// How many times faster an oozeling vampire will revive if their core is in a coffin.
#define OOZELING_VAMPIRE_REVIVE_COFFIN_MULTIPLIER 2.5

// vassal defines
/// If someone passes all checks and can be vassalized
#define VASSALIZATION_ALLOWED 0
/// If someone has to accept vassalization
#define VASSALIZATION_DISLOYAL 1
/// If someone is not allowed under any circimstances to become a vassal
#define VASSALIZATION_BANNED 2

// Humanity gains (The actual tracking lists and such are in the datum duh)
// These are supposed to be somewhat nontrivial, to the point of sometimes not being viable.
/// Hugging of separate people
#define HUMANITY_HUGGING_TYPE "hug"

/// Petting of separate animals
#define HUMANITY_PETTING_TYPE "pet"

/// Watching of art
#define HUMANITY_ART_TYPE "art"

#define HUMANITY_GAIN_TYPES list(HUMANITY_HUGGING_TYPE, HUMANITY_PETTING_TYPE, HUMANITY_ART_TYPE)

/// Default Humanity
#define VAMPIRE_DEFAULT_HUMANITY 7

// Cooldown defines
// Used to prevent spamming vampires
/// Spam prevention for healing messages.
#define VAMPIRE_SPAM_HEALING 15 SECONDS
/// Spam prevention for Sol Masquerade messages.
#define VAMPIRE_SPAM_MASQUERADE 60 SECONDS

/// Spam prevention for Sol messages.
#define VAMPIRE_SPAM_SOL 30 SECONDS

// Clan defines
#define CLAN_BRUJAH "Brujah Clan"
#define CLAN_TOREADOR "Toreador Clan"
#define CLAN_NOSFERATU "Nosferatu Clan"
#define CLAN_TREMERE "Tremere Clan"
#define CLAN_GANGREL "Gangrel Clan"
#define CLAN_VENTRUE "Ventrue Clan"
#define CLAN_MALKAVIAN "Malkavian Clan"
#define CLAN_TZIMISCE "Tzimisce Clan"
#define CLAN_HECATA "Hecata Clan"
#define CLAN_LASOMBRA "Lasombra Clan"

// Power defines
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

/// This is a Default Power that all Vampires get.
#define VAMPIRE_DEFAULT_POWER (1<<1)

/// This Power is a Toggled Power
#define BP_AM_TOGGLE (1<<0)
/// This Power is a Single-Use Power
#define BP_AM_SINGLEUSE (1<<1)
/// This Power has a Static cooldown
#define BP_AM_STATIC_COOLDOWN (1<<2)
/// This Power doesn't cost bloot to run while unconscious
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<3)
/// This Power has a cooldown that is more dynamic than a typical power
#define BP_AM_VERY_DYNAMIC_COOLDOWN (1<<4)

///Called when a Vampire reaches Final Death.
#define COMSIG_VAMPIRE_FINAL_DEATH "vampire_final_death"
	///Whether the vampire should not be dusted when arriving Final Death
	#define DONT_DUST (1<<0)

// Vampire Signals
/// Called when a Vampire breaks the Masquerade
#define COMSIG_VAMPIRE_BROKE_MASQUERADE "comsig_vampire_broke_masquerade"

// Signals & Defines
/// Sent whenever vampires get a "natural" rank up.
#define COMSIG_SOL_RANKUP_VAMPIRES "sol_rankup_vampires"
/// Sent when tracking humanity gain progress: (type, subject)
#define COMSIG_VAMPIRE_TRACK_HUMANITY_GAIN "comsig_vampire_track_humanity_gain"

/// Called on the mind when a Vampire chooses a clan: (datum/antagonist/vampire, datum/vampire_clan)
#define COMSIG_VAMPIRE_CLAN_CHOSEN "vampire_clan_chosen"

#define DANGER_LEVEL_FIRST_WARNING 1
#define DANGER_LEVEL_SECOND_WARNING 2
#define DANGER_LEVEL_THIRD_WARNING 3
#define DANGER_LEVEL_SOL_ROSE 4
#define DANGER_LEVEL_SOL_ENDED 5

// Clan defines
/// Drinks blood the normal Vampire way.
#define VAMPIRE_DRINK_NORMAL "vampire_drink_normal"
/// Drinks blood but is snobby, refusing to drink from mindless
#define VAMPIRE_DRINK_SNOBBY "vampire_drink_snobby"
// Masquerade ability given at this point or above
#define VAMPIRE_HUMANITY_MASQUERADE_POWER 7

// Traits
/// Falsifies Health analyzer blood levels
#define TRAIT_MASQUERADE "masquerade"
/// For people in the middle of being staked
#define TRAIT_BEINGSTAKED "beingstaked"
/// This vampire is currently in a frenzy,
#define TRAIT_FRENZY "frenzy"
/// This vampire is currently in torpor.
#define TRAIT_TORPOR "torpor"

// Trait sources
/// Source trait for all vampire traits
#define TRAIT_VAMPIRE "trait_vampire"
/// Source trait for vampire mesmerization.
#define TRAIT_MESMERIZED "trait_mesmerized"
/// Source trait for vampire commandment.
#define TRAIT_COMMANDED "trait_commanded"

// Macros
#define IS_CURATOR(mob) istype(mob?.mind?.assigned_role, /datum/job/curator)
#define IS_VAMPIRE_HUNTER(mob) (IS_CURATOR(mob) || IS_MONSTERHUNTER(mob))
