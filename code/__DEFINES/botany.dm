/// -- Botany plant stat defines. --
/// MAXES:
#define MAX_PLANT_YIELD 1e31
#define MAX_PLANT_LIFESPAN 1e31
#define MAX_PLANT_ENDURANCE 1e31
#define MAX_PLANT_PRODUCTION 1e31
#define MAX_PLANT_POTENCY 1e31
#define MAX_PLANT_INSTABILITY 100
#define MAX_PLANT_WEEDRATE 10
#define MAX_PLANT_WEEDCHANCE 67
/// MINS:
#define MIN_PLANT_ENDURANCE 10

/// Default reagent volume for grown plants
#define PLANT_REAGENT_VOLUME 100

/// -- Some botany trait value defines. --
/// Weed Hardy can only reduce plants to 3 yield.
#define WEED_HARDY_YIELD_MIN 3
/// Carnivory potency can only reduce potency to 30.
#define CARNIVORY_POTENCY_MIN 30
/// Fungle megabolism plants have a min yield of 1.
#define FUNGAL_METAB_YIELD_MIN 1

/// -- Hydroponics tray defines. --
///  Base amount of nutrients a tray can old.
#define STATIC_NUTRIENT_CAPACITY 30
/// Maximum amount of toxins a tray can reach.
#define MAX_TRAY_TOXINS 100
/// Maxumum pests a tray can reach.
#define MAX_TRAY_PESTS 10
/// Maximum weeds a tray can reach.
#define MAX_TRAY_WEEDS 10
/// Minumum plant health required for gene shears.
#define GENE_SHEAR_MIN_HEALTH 15
/// Minumum plant endurance required to lock a mutation with a somatoray.
#define FLORA_GUN_MIN_ENDURANCE 20

/// -- Flags for genes --
/// Plant genes that can be removed via gene shears.
#define PLANT_GENE_REMOVABLE (1<<0)
/// Plant genes that can be mutated randomly in strange seeds / due to high instability.
#define PLANT_GENE_MUTATABLE (1<<1)
/// Plant genes that can be graftable. Used in formatting text, as they need to be set to be graftable anyways.
#define PLANT_GENE_GRAFTABLE (1<<2)

/// -- Flags for seeds. --
/// Allows a plant to wild mutate (mutate on haravest) at a certain instability.
#define MUTATE_EARLY (1<<0)

/// -- Trait IDs. Plants that match IDs cannot be added to the same plant. --
/// Plants that glow.
#define GLOW_ID (1<<0)
/// Plant types.
#define PLANT_TYPE_ID (1<<1)
/// Plants that affect the reagent's temperature.
#define TEMP_CHANGE_ID (1<<2)
/// Plants that affect the reagent contents.
#define CONTENTS_CHANGE_ID (1<<3)
/// Plants that do something special when they impact.
#define THROW_IMPACT_ID (1<<4)
/// Plants that transfer reagents on impact.
#define REAGENT_TRANSFER_ID (1<<5)
/// Plants that have a unique effect on attack_self.
#define ATTACK_SELF_ID (1<<6)
/// Plants that override harvest
#define HARVEST_OVERRIDE (1<<7)

/// -- Flags for traits. --
/// When acclimed halves the yield of the plant
#define TRAIT_HALVES_YIELD (1<<0)
#define TRAIT_HALVES_PRODUCTION (1<<1)
#define TRAIT_HALVES_POTENCY (1<<2)
#define TRAIT_HALVES_ENDURANCE (1<<3)
#define TRAIT_HALVES_LIFESPAN (1<<4)

#define GLOWSHROOM_SPREAD_BASE_DIMINISH_FACTOR 10
#define GLOWSHROOM_SPREAD_DIMINISH_FACTOR_PER_GLOWSHROOM 0.2
#define GLOWSHROOM_BASE_INTEGRITY 60

// obj/machinery/hydroponics/var/plant_status defines

/// How long to wait between plant age ticks, by default. See [/obj/machinery/hydroponics/var/cycledelay]
#define HYDROTRAY_CYCLE_DELAY 20 SECONDS

#define HYDROTRAY_NO_PLANT "missing"
#define HYDROTRAY_PLANT_DEAD "dead"
#define HYDROTRAY_PLANT_GROWING "growing"
#define HYDROTRAY_PLANT_HARVESTABLE "harvestable"

/// A list of possible egg laying descriptions
#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")

/// limiter for potency
#define TRAIT_LIMIT_POTENCY (1<<0)

#define COMSIG_GROWING_WATER_UPDATE "growing_water_update"
#define COMSIG_PLANT_TRY_POLLINATE "try_pollinate"
#define COMSIG_PLANT_TRY_HARVEST "plant_try_harvest"
#define COMSIG_PLANT_BUILD_IMAGE "plant_build_image"
#define COMSIG_PLANT_ADJUST_WEED "plant_adjust_weeds"
#define COMSIG_PLANT_GROWTH_PROCESS "process_plant_growth"
#define COMSIG_TRY_HARVEST_SEEDS "try_harvest_seeds"
#define COMSIG_TRY_PLANT_SEED "try_plant_seeds"
#define COMSIG_PLANT_CHANGE_PLANTER "plant_change_planter"
#define COMSIG_PLANT_SENDING_IMAGE "plant_sending_image"
#define COMSIG_TRY_POLLINATE "try_pollinate_grower"
#define COMSIG_ADJUST_PLANT_HEALTH "adjust_plant_health"
#define COMSIG_GROWING_ADJUST_TOXIN "adjust_growing_toxicity"
#define COMSIG_GROWING_ADJUST_PEST "adjust_growing_pests"
#define COMSIG_PLANT_UPDATE_HEALTH_COLOR "update_health_color"
#define COMSIG_GROWING_ADJUST_WEED "adjust_growing_weed"
#define COMSIG_GROWER_ADJUST_SELFGROW "adjust_grower_selfgrow"
#define COMSIG_GROWER_INCREASE_WORK_PROCESSES "increase_work_process_grower"
#define COMSIG_NUTRIENT_UPDATE "nutrient_update"
#define COMSIG_TOXICITY_UPDATE "toxicity_update"
#define COMSIG_PEST_UPDATE "pest_update"
#define COMSIG_WEEDS_UPDATE "weeds_update"
#define COMSIG_GROWER_SET_HARVESTABLE "set_harvestable_grower"
#define COMSIG_REMOVE_PLANT "remove_plant_grower"
#define REMOVE_PLANT_VISUALS "remove_plant_visuals"
#define COMSIG_GROWER_CHECK_POLLINATED "check_grower_pollinated"
#define COMSIG_ATTEMPT_BIOBOOST "attempt_bioboost"
#define COMSIG_PLANTER_REMOVE_PLANTS "remove_all_plants"
#define COMSIG_TOGGLE_BIOBOOST "toggle_bioboost"
#define COMSIG_REAGENT_CACHE_ADD_ATTEMPT "reagent_cache_attempt"
#define COMSIG_REAGENT_PRE_TRANS_TO "reagent_pre_trans"
#define COMSIG_GROWING_TRY_SECATEUR "try_secateur"
#define COMSIG_PLANT_TRY_SECATEUR "plant_try_secateur"
#define COMSIG_GROWER_TRY_GRAFT "plant_grower_try_graft"

#define SHOW_WATER (1<<0)
#define SHOW_HEALTH (1<<1)
#define SHOW_WEED (1<<2)
#define SHOW_PEST (1<<3)
#define SHOW_TOXIC (1<<4)
#define SHOW_NUTRIENT (1<<5)
#define SHOW_HARVEST (1<<6)

#define SPECIES_APID "apid"

#define COMSIG_MUTATION_TRIGGER "mutation_trigger"
#define COMSIG_AGE_ADJUSTMENT "age_adjust"
#define COMSIG_AGE_RETURN_AGE "age_return"
#define COMSIG_HAPPINESS_ADJUST "happiness_adjustment"
#define COMSIG_HAPPINESS_CHECK_RANGE "happiness_check_range"
#define COMSIG_HAPPINESS_PASS_HAPPINESS "happiness_pass"

#define COMSIG_MOB_SHEARED "comsig_mob_sheared"

#define TRAIT_TIN_EATER "tin_eater"
#define TRAIT_LIVING_DRUNK "living_drunk"
#define COMSIG_TRY_EAT_TRAIT "try_eat_trait"

/// Returns the potency for a seed, capped at 100.
#define CAPPED_POTENCY(seed) (min(seed.potency, 100))
