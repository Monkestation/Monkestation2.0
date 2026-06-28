#define NUKE_RESULT_FLUKE 0
#define NUKE_RESULT_NUKE_WIN 1
#define NUKE_RESULT_CREW_WIN 2
#define NUKE_RESULT_CREW_WIN_SYNDIES_DEAD 3
#define NUKE_RESULT_DISK_LOST 4
#define NUKE_RESULT_DISK_STOLEN 5
#define NUKE_RESULT_NOSURVIVORS 6
#define NUKE_RESULT_WRONG_STATION 7
#define NUKE_RESULT_WRONG_STATION_DEAD 8
#define NUKE_RESULT_HIJACK_DISK 9
#define NUKE_RESULT_HIJACK_NO_DISK 10

//fugitive end results
#define FUGITIVE_RESULT_BADASS_HUNTER 0
#define FUGITIVE_RESULT_POSTMORTEM_HUNTER 1
#define FUGITIVE_RESULT_MAJOR_HUNTER 2
#define FUGITIVE_RESULT_HUNTER_VICTORY 3
#define FUGITIVE_RESULT_MINOR_HUNTER 4
#define FUGITIVE_RESULT_STALEMATE 5
#define FUGITIVE_RESULT_MINOR_FUGITIVE 6
#define FUGITIVE_RESULT_FUGITIVE_VICTORY 7
#define FUGITIVE_RESULT_MAJOR_FUGITIVE 8

#define APPRENTICE_DESTRUCTION "destruction"
#define APPRENTICE_BLUESPACE "bluespace"
#define APPRENTICE_ROBELESS "robeless"
#define APPRENTICE_HEALING "healing"

//Pirates

///Minimum amount the pirates will demand
#define PAYOFF_MIN 20000
///How long pirates will wait for a response before attacking
#define RESPONSE_MAX_TIME 2 MINUTES

//ERT Types
#define ERT_BLUE "Blue"
#define ERT_RED  "Red"
#define ERT_AMBER "Amber"
#define ERT_DEATHSQUAD "Deathsquad"

//ERT subroles
#define ERT_SEC "sec"
#define ERT_MED "med"
#define ERT_ENG "eng"
#define ERT_LEADER "leader"
#define DEATHSQUAD "ds"
#define DEATHSQUAD_LEADER "ds_leader"

//Shuttle elimination hijacking
/// Does not stop elimination hijacking but itself won't elimination hijack
#define ELIMINATION_NEUTRAL 0
/// Needs to be present for shuttle to be elimination hijacked
#define ELIMINATION_ENABLED 1
/// Prevents elimination hijack same way as non-antags
#define ELIMINATION_PREVENT 2

//Syndicate Contracts
#define CONTRACT_STATUS_INACTIVE 1
#define CONTRACT_STATUS_ACTIVE 2
#define CONTRACT_STATUS_BOUNTY_CONSOLE_ACTIVE 3
#define CONTRACT_STATUS_EXTRACTING 4
#define CONTRACT_STATUS_COMPLETE 5
#define CONTRACT_STATUS_ABORTED 6

#define CONTRACT_PAYOUT_LARGE 1
#define CONTRACT_PAYOUT_MEDIUM 2
#define CONTRACT_PAYOUT_SMALL 3

#define CONTRACT_UPLINK_PAGE_CONTRACTS "CONTRACTS"
#define CONTRACT_UPLINK_PAGE_HUB "HUB"


// Heretic path defines.
#define PATH_ANY "Any Path"
#define PATH_START "Start Path"
#define PATH_SIDE "Side Path"
#define PATH_ASH "Ash Path"
#define PATH_RUST "Rust Path"
#define PATH_FLESH "Flesh Path"
#define PATH_VOID "Void Path"
#define PATH_BLADE "Blade Path"
#define PATH_COSMIC "Cosmic Path"
#define PATH_LOCK "Lock Path"
#define PATH_MOON "Moon Path"

//Heretic knowledge tree defines
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_PURCHASED_DEPTH "purchased_depth"
#define HKT_ROUTE "route"
#define HKT_UI_BGR "ui_bgr"
#define HKT_COST "cost"
#define HKT_CATEGORY "category"
/// Only present for already researched knowledge.
#define HKT_INSTANCE "instance"
/// unique identifier most commonly used for identifying what knowledge is researchable
#define HKT_ID "id"

#define BGR_SIDE "node_side"

#define MAGIC_RESISTANCE_MOON (MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND)

/// Defines are used in /proc/has_living_heart() to report if the heretic has no heart period, no living heart, or has a living heart.
#define HERETIC_NO_HEART_ORGAN -1
#define HERETIC_NO_LIVING_HEART 0
#define HERETIC_HAS_LIVING_HEART 1

#define HERETIC_DRAFT_TIER_MAX 5

/// The default drain speed for heretic rift's, anything below this will be considered a fast drain, and be very noticeable and cause a overlay
#define HERETIC_RIFT_DEFAULT_DRAIN_SPEED 10 SECONDS

/// Sources of knowledge purchased for heretics, used for positioning in the UI
#define HERETIC_KNOWLEDGE_TREE "tree"
#define HERETIC_KNOWLEDGE_SHOP "shop"
#define HERETIC_KNOWLEDGE_DRAFT "draft"
#define HERETIC_KNOWLEDGE_START "start"

/// defines for the depths of the heretic knowledge tree nodes
#define HKT_DEPTH_START 2
#define HKT_DEPTH_TIER_1 3
#define HKT_DEPTH_DRAFT_1 4
#define HKT_DEPTH_TIER_2 5
#define HKT_DEPTH_DRAFT_2 6
#define HKT_DEPTH_ROBES 7
#define HKT_DEPTH_TIER_3 8
#define HKT_DEPTH_DRAFT_3 9
#define HKT_DEPTH_ARMOR 10
#define HKT_DEPTH_TIER_4 11
#define HKT_DEPTH_DRAFT_4 12
#define HKT_DEPTH_ASCENSION 13

#define HERETIC_CAN_ASCEND "can_ascend"


/// A define used in ritual priority for heretics.
#define MAX_KNOWLEDGE_PRIORITY 100

/// Checks if the passed mob can become a heretic ghoul.
/// - Must be a human (type, not species)
/// - Skeletons cannot be husked (they are snowflaked instead of having a trait)
/// - Monkeys are monkeys, not quite human (balance reasons)
#define IS_VALID_GHOUL_MOB(mob) (ishuman(mob) && !isskeleton(mob) && !ismonkey(mob))

/// Forces the blob to place the core where they currently are, ignoring any checks.
#define BLOB_FORCE_PLACEMENT -1
/// Normal blob placement, does the regular checks to make sure the blob isn't placing itself in an invalid location
#define BLOB_NORMAL_PLACEMENT 0
/// Selects a random location for the blob to be placed.
#define BLOB_RANDOM_PLACEMENT 1

#define CONSTRUCT_JUGGERNAUT "Juggernaut"
#define CONSTRUCT_WRAITH "Wraith"
#define CONSTRUCT_ARTIFICER "Artificer"

/// The Classic Wizard wizard loadout.
#define WIZARD_LOADOUT_CLASSIC "loadout_classic"
/// Mjolnir's Power wizard loadout.
#define WIZARD_LOADOUT_MJOLNIR "loadout_hammer"
/// Fantastical Army wizard loadout.
#define WIZARD_LOADOUT_WIZARMY "loadout_army"
/// Soul Tapper wizard loadout.
#define WIZARD_LOADOUT_SOULTAP "loadout_tap"
/// Convenient list of all wizard loadouts for unit testing.
#define ALL_WIZARD_LOADOUTS list( \
	WIZARD_LOADOUT_CLASSIC, \
	WIZARD_LOADOUT_MJOLNIR, \
	WIZARD_LOADOUT_WIZARMY, \
	WIZARD_LOADOUT_SOULTAP, \
)
/// Number of times you need to perform the grand ritual to complete it
#define GRAND_RITUAL_FINALE_COUNT 7
/// The crew will start being warned every time a rune is created after this many invocations.
#define GRAND_RITUAL_RUNES_WARNING_POTENCY 3
/// The crew will get a louder warning when this level of rune is created, and the next one will be special
#define GRAND_RITUAL_IMMINENT_FINALE_POTENCY 6

/// Used in logging spells for roundend results
#define LOG_SPELL_TYPE "type"
#define LOG_SPELL_AMOUNT "amount"

///File to the traitor flavor
#define TRAITOR_FLAVOR_FILE "antagonist_flavor/traitor_flavor.json"

///File to the malf flavor
#define MALFUNCTION_FLAVOR_FILE "antagonist_flavor/malfunction_flavor.json"

/// JSON string file for all of our heretic influence flavors
#define HERETIC_INFLUENCE_FILE "antagonist_flavor/heretic_influences.json"

/// JSON file containing spy objectives
#define SPY_OBJECTIVE_FILE "antagonist_flavor/spy_objective.json"

///employers that are from the syndicate
GLOBAL_LIST_INIT(syndicate_employers, list(
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Cybersun Industries",
	"Donk Corporation",
	"Gorlex Marauders",
	"MI13",
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
	"Waffle Corporation",
	"The Ashen Forge Member",
))
///employers that are from nanotrasen
GLOBAL_LIST_INIT(nanotrasen_employers, list(
	"Champions of Evil",
	"Corporate Climber",
	"Gone Postal",
	"Internal Affairs Agent",
	"Legal Trouble",
))

///employers who hire agents to do the hijack
GLOBAL_LIST_INIT(hijack_employers, list(
	"Animal Rights Consortium",
	"Bee Liberation Front",
	"Gone Postal",
	"Tiger Cooperative Fanatic",
	"Waffle Corporation Terrorist",
))

///employers who hire agents to do a task and escape... or martyrdom. whatever
GLOBAL_LIST_INIT(normal_employers, list(
	"Champions of Evil",
	"Corporate Climber",
	"Cybersun Industries",
	"Donk Corporation",
	"Gorlex Marauders",
	"Internal Affairs Agent",
	"Legal Trouble",
	"MI13",
	"Waffle Corporation",
))

///employers for malfunctioning ais. they do not have sides, unlike traitors.
GLOBAL_LIST_INIT(ai_employers, list(
	"Biohazard",
	"Despotic Ruler",
	"Fanatical Revelation",
	"Logic Core Error",
	"Problem Solver",
	"S.E.L.F.",
	"Something's Wrong",
	"Spam Virus",
	"SyndOS",
	"Unshackled",
))

#define UPLINK_THEME_SYNDICATE "syndicate"

#define UPLINK_THEME_UNDERWORLD_MARKET "neutral"

/// Checks if the given mob is a traitor
#define IS_TRAITOR(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/traitor))

///Checks if the given mob is an evil clone
#define IS_EVIL_CLONE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/evil_clone))

/// Checks if the given mob is a nuclear operative
#define IS_NUKE_OP(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/nukeop))

//Tells whether or not someone is a space ninja
#define IS_SPACE_NINJA(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/ninja))

/**
 * Cult checks
 */

/// Checks if the given mob is a blood cultist
#define IS_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult) || HAS_TRAIT(mob, TRAIT_ACT_AS_CULTIST))

/// Checks if the given mob is a blood cultist and is guaranteed to return the datum if possible - will cause issues with above trait
#define GET_CULTIST(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/cult))

/// Checks if the mob is a sentient or non-sentient cultist
#define IS_CULTIST_OR_CULTIST_MOB(mob) ((IS_CULTIST(mob)) || (mob.faction.Find(FACTION_CULT)))

/**
 * Heretic checks
 */

/// Checks if the given mob is a heretic.
#define IS_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic) || HAS_TRAIT(mob, TRAIT_ACT_AS_HERETIC))
/// Checks if the given mob is a heretic and is guaranteed to return the datum if possible - will cause issues with above trait
#define GET_HERETIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/heretic))

/// Check if the given mob is a  lunatic
#define IS_LUNATIC(mob) (mob.mind?.has_antag_datum(/datum/antagonist/lunatic))
/// Checks if the given mob is either a heretic, heretic monster or a lunatic.
#define IS_HERETIC_OR_MONSTER(mob) (IS_HERETIC(mob) || HAS_TRAIT(mob, TRAIT_HERETIC_SUMMON) || IS_LUNATIC(mob))
/// Checks if the given mob is in the mansus realm
#define IS_IN_MANSUS(mob) (istype(get_area(mob), /area/centcom/heretic_sacrifice))

/// Checks if the given mob is a wizard
#define IS_WIZARD(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/wizard))

/// Checks if the given mob is a revolutionary. Will return TRUE for rev heads as well.
#define IS_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev))

/// Checks if the given mob is a head revolutionary.
#define IS_HEAD_REVOLUTIONARY(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/rev/head))

/// Checks if the given mob is a malf ai.
#define IS_MALF_AI(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/malf_ai))

/// Checks if the given mob is a abductee.
#define IS_ABDUCTEE(mob) (mob.mind?.has_antag_datum(/datum/antagonist/abductee))

/// Checks if the given mob is a spy.
#define IS_SPY(mob) (mob.mind?.has_antag_datum(/datum/antagonist/spy))

// Antag resource defines
#define ANTAG_RESOURCE_DARKSPAWN "psi"

/// List of human antagonist types which don't spawn directly on the space station
GLOBAL_LIST_INIT(human_invader_antagonists, list(
	/datum/antagonist/abductor,
	/datum/antagonist/fugitive,
	/datum/antagonist/fugitive_hunter,
	/datum/antagonist/ninja,
	/datum/antagonist/nukeop,
	/datum/antagonist/pirate,
	/datum/antagonist/wizard,
))

/// Returns true if the given mob has an antag datum which is assigned to a human antagonist who doesn't spawn on the space station
#define IS_HUMAN_INVADER(mob) (mob?.mind?.has_antag_datum_in_list(GLOB.human_invader_antagonists))

/// The dimensions of the antagonist preview icon. Will be scaled to this size.
#define ANTAGONIST_PREVIEW_ICON_SIZE 96

// Defines for objective items to determine what they can appear in
/// Can appear in everything
#define OBJECTIVE_ITEM_TYPE_NORMAL "normal"
/// Only appears in traitor objectives
#define OBJECTIVE_ITEM_TYPE_TRAITOR "traitor"
/// Only appears for spy bounties
#define OBJECTIVE_ITEM_TYPE_SPY "spy"

// Progression traitor defines

/// Chance that the traitor could roll hijack if the pop limit is met.
#define HIJACK_PROB 10
/// Hijack is unavailable as a random objective below this player count.
#define HIJACK_MIN_PLAYERS 30

/// Chance the traitor gets a martyr objective instead of having to escape alive, as long as all the objectives are martyr compatible.
#define MARTYR_PROB 20

/// Chance the traitor gets a maroon objective. If this prob fails, they will get a steal objective instead.
#define MAROON_PROB 50
/// If a maroon objective is rolled, chance that it is to destroy the AI.
#define DESTROY_AI_PROB(denominator) (100 / denominator)
/// If the destroy AI objective doesn't roll, chance that we'll get a kill instead. If this prob fails, they will get a generic assassinate objective instead.
#define KILL_PROB 20

/// How many telecrystals a normal traitor starts with
#define TELECRYSTALS_DEFAULT 25
/// How many telecrystals mapper/admin only "precharged" uplink implant
#define TELECRYSTALS_PRELOADED_IMPLANT 10
/// The normal cost of an uplink implant; used for calcuating how many
/// TC to charge someone if they get a free implant through choice or
/// because they have nothing else that supports an implant.
#define UPLINK_IMPLANT_TELECRYSTAL_COST 4

/// Items with this stock key do not share stock with other items
#define UPLINK_SHARED_STOCK_UNIQUE "uplink_shared_stock_unique"
/// Stock keys for items that share inventory stock
#define UPLINK_SHARED_STOCK_KITS "uplink_shared_stock_kits"
#define UPLINK_SHARED_STOCK_SURPLUS "uplink_shared_stock_surplus"

// Used for traitor objectives
/// If the objective hasn't been taken yet
#define OBJECTIVE_STATE_INACTIVE 1
/// If the objective is active and ongoing
#define OBJECTIVE_STATE_ACTIVE 2
/// If the objective has been completed.
#define OBJECTIVE_STATE_COMPLETED 3
/// If the objective has failed.
#define OBJECTIVE_STATE_FAILED 4
/// If the objective is no longer valid
#define OBJECTIVE_STATE_INVALID 5

/// Weights for traitor objective categories
#define OBJECTIVE_WEIGHT_VERY_UNLIKELY 2
#define OBJECTIVE_WEIGHT_UNLIKELY 5
#define OBJECTIVE_WEIGHT_DEFAULT 10
#define OBJECTIVE_WEIGHT_LIKELY 15
#define OBJECTIVE_WEIGHT_VERY_LIKELY 20

#define REVENANT_NAME_FILE "revenant_names.json"

/// Antag panel groups
#define ANTAG_GROUP_ABDUCTORS "Abductors"
#define ANTAG_GROUP_ABOMINATIONS "Extradimensional Abominations"
#define ANTAG_GROUP_ARACHNIDS "Arachnid Infestation"
#define ANTAG_GROUP_ASHWALKERS "Ash Walkers"
#define ANTAG_GROUP_BIOHAZARDS "Biohazards"
#define ANTAG_GROUP_CLOWNOPS "Clown Operatives"
#define ANTAG_GROUP_ERT "Emergency Response Team"
#define ANTAG_GROUP_GLITCH "Digital Anomalies"
#define ANTAG_GROUP_HORRORS "Eldritch Horrors"
#define ANTAG_GROUP_LEVIATHANS "Spaceborne Leviathans"
#define ANTAG_GROUP_NINJAS "Ninja Clan"
#define ANTAG_GROUP_OVERGROWTH "Invasive Overgrowth"
#define ANTAG_GROUP_PIRATES "Pirate Crew"
#define ANTAG_GROUP_SYNDICATE "Syndicate"
#define ANTAG_GROUP_WIZARDS "Wizard Federation"
#define ANTAG_GROUP_XENOS "Xenomorph Infestation"
#define ANTAG_GROUP_FUGITIVES "Escaped Fugitives"
#define ANTAG_GROUP_HUNTERS "Bounty Hunters"
#define ANTAG_GROUP_PARADOX "Spacetime Aberrations"
#define ANTAG_GROUP_CREW "Deviant Crew"
#define ANTAG_GROUP_BINGLES "Bingles"
#define ANTAG_GROUP_DARKSPAWN "Darkspawn"
#define ANTAG_GROUP_DEVILS "Infernal Agents"
#define ANTAG_GROUP_ABANDONED_IPC "Abandoned IPC"

#define HUNTER_PACK_COPS "Spacepol Officers"
#define HUNTER_PACK_RUSSIAN "Russian Smugglers"
#define HUNTER_PACK_BOUNTY "Bounty Hunters"
#define HUNTER_PACK_PSYKER "Psyker Shikaris"

/// Used to denote an antag datum that either isn't necessarily "evil" (like Valentines)
/// or isn't necessarily a "real" antag (like Ashwalkers)
#define ANTAG_FAKE (1 << 0)
/// Whether the antagonist can see exploitable info on people they examine.
#define FLAG_CAN_SEE_EXPOITABLE_INFO (1 << 1)
///  The storyteller will ignore this antag datum as counting against the antag cap.
#define FLAG_ANTAG_CAP_IGNORE (1 << 2)
/// The storyteller will count everyone on this antag's team as a singular antag instead.
#define FLAG_ANTAG_CAP_TEAM (1 << 3)
/// The storyteller will only count a single instance of this type of antag datum.
// NOTE: Currently both FLAG_ANTAG_CAP_TEAM and FLAG_ANTAG_CAP_SINGLE are unused in modern storyteller. May be good to include them but functionally will not work.
/// Basically FLAG_ANTAG_CAP_TEAM if you're too lazy to refactor the antag to actually use a team.
#define FLAG_ANTAG_CAP_SINGLE (1 << 4)
/// If set then we ignore mobs being human or not for antag point counting
#define FLAG_ANTAG_CAP_IGNORE_HUMANITY (1 << 5)
/// Antag's panel action button and the UI therein is viewable by observers
#define FLAG_ANTAG_OBSERVER_VISIBLE_PANEL (1 << 6)

#define FREEDOM_IMPLANT_CHARGES 4

/// Changeling abilities with DNA cost = this are innately given to all changelings
#define CHANGELING_POWER_INNATE -1
/// Changeling abilities with DNA cost = this are not obtainable by changelings - either used for secret unlockable or abstract abilities
#define CHANGELING_POWER_UNOBTAINABLE -2

/// For changelings, this is how many recent say lines are retained when absorbing a mob
#define LING_ABSORB_RECENT_SPEECH 8

// Various abductor equipment modes.

#define VEST_STEALTH 1
#define VEST_COMBAT 2

#define GIZMO_SCAN 1
#define GIZMO_MARK 2

#define MIND_DEVICE_MESSAGE 1
#define MIND_DEVICE_CONTROL 2

#define TOOLSET_MEDICAL 1
#define TOOLSET_HACKING 2

#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

// Spy bounty difficulties
/// Can easily be accomplished by any job without any specialized tools, people won't really miss these things
#define SPY_DIFFICULTY_EASY "Easy"
/// Requires some specialized tools, knowledge, or access to accomplish, may require getting into conflict with the crew
#define SPY_DIFFICULTY_MEDIUM "Medium"
/// Very difficult to accomplish, almost guaranteed to require crew conflict
#define SPY_DIFFICULTY_HARD "Hard"

// Monster Hunter stuff
#define UPGRADED_VAL(x,y) ( CEILING((x * (1.07 ** y)), 1) )
#define CALIBER_BLOODSILVER "bloodsilver"

///Whether a mob is a Monster Hunter
#define IS_MONSTERHUNTER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/monsterhunter))

/// Checks if the given mob is a slasher.
#define IS_SLASHER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/slasher))
/// Checks if the given mob is a Bingle
#define IS_BINGLE(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/bingle))

#define IS_DARKSPAWN(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define IS_THRALL(A) (A?.mind?.has_antag_datum(/datum/antagonist/thrall_darkspawn))
///non thrall teammates
#define IS_PSYCHE(A) (A?.mind?.has_antag_datum(/datum/antagonist/psyche))
#define IS_DARKSPAWN_OR_THRALL(A) (A?.mind?.has_antag_datum(/datum/antagonist/thrall_darkspawn) || A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
///also checks factions, so things can be immune to darkspawn spells without needing an antag datum
#define IS_TEAM_DARKSPAWN(A) ((A?.mind && (IS_DARKSPAWN(A) || IS_THRALL(A)) || IS_PSYCHE(A) || (ROLE_DARKSPAWN in A.faction)))

/// List of areas blacklisted from area based traitor objectives
#define TRAITOR_OBJECTIVE_BLACKLISTED_AREAS list(\
	/area/station/engineering/hallway, \
	/area/station/engineering/lobby, \
	/area/station/engineering/storage, \
	/area/station/science/lobby, \
	/area/station/science/ordnance/bomb, \
	/area/station/science/ordnance/freezerchamber, \
	/area/station/science/ordnance/burnchamber, \
	/area/station/security/prison, \
)

// Clock cultist
#define IS_CLOCK(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist) || (FACTION_CLOCK in mob.faction))
/// maximum amount of cogscarabs the clock cult can have
#define MAXIMUM_COGSCARABS 6
/// is something a cogscarab
#define iscogscarab(checked) (istype(checked, /mob/living/basic/drone/cogscarab))
/// is something an eminence
#define iseminence(checked) (istype(checked, /mob/living/eminence))

/// is something a worm
#define iscorticalborer(A) (istype(A, /mob/living/basic/cortical_borer))

/// Is the mob a blood brother
#define IS_BROTHER(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/brother))

/// Whether the mob can convert others through innate flash shielding like IPCs (head revolutionaries and blood brothers)
#define CAN_BYPASS_INNATE_FLASH_RESISTANCE(mob) (IS_BROTHER(mob) || IS_HEAD_REVOLUTIONARY(mob))

// Borer evolution defines
// The three primary paths that eventually diverge
#define BORER_EVOLUTION_SYMBIOTE "Symbiote"
#define BORER_EVOLUTION_HIVELORD "Hivelord"
#define BORER_EVOLUTION_DIVEWORM "Diveworm"
// Just general upgrades that don't take you in a specific direction
#define BORER_EVOLUTION_GENERAL "General"
#define BORER_EVOLUTION_START "Start"

// Borer effect flags

/// If the borer is in stealth mode, giving less feedback to hosts at the cost of no health/resource/point gain
#define BORER_STEALTH_MODE (1<<0)
/// If the borer is sugar-immune, taking no ill effects from sugar
#define BORER_SUGAR_IMMUNE (1<<1)
/// If the borer is able to enter hosts in half the time, if not hiding
#define BORER_FAST_BORING (1<<2)
/// If the borer is currently hiding under tables/couches/stairs or appearing on top of them
#define BORER_HIDING (1<<3)
/// If the borer can produce eggs without a host
#define BORER_ALONE_PRODUCTION (1<<4)
/// If the borer is energic, used for crawling into various spaces
#define BORER_ENERGIC (1<<5)

/// If the given mob is a bloodling
#define IS_BLOODLING(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/bloodling))

/// If the given mob is a bloodling thrall
#define IS_BLOODLING_THRALL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/changeling/bloodling_thrall))

/// If the given mob is a simplemob bloodling thrall
#define IS_SIMPLEMOB_BLOODLING_THRALL(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/infested_thrall))

/// If the given mob is a bloodling thrall or bloodling
#define IS_BLOODLING_OR_THRALL(mob) (IS_BLOODLING(mob) || IS_BLOODLING_THRALL(mob) || IS_SIMPLEMOB_BLOODLING_THRALL(mob))

/// Antagonist panel groups
#define ANTAG_GROUP_BLOODLING "Bloodling"

/// How much heretic Mark of Rust mark does to items
#define RUST_MARK_DAMAGE 50
