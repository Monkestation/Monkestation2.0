/*ALL DNA, SPECIES, AND GENETICS-RELATED DEFINES GO HERE*/

#define CHECK_DNA_AND_SPECIES(C) if(!(C.dna?.species)) return

#define UE_CHANGED "ue changed"
#define UI_CHANGED "ui changed"
#define UF_CHANGED "uf changed"

#define CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY 204

// String identifiers for associative list lookup

//Types of usual mutations
#define POSITIVE 1
#define NEGATIVE 2
#define MINOR_NEGATIVE 4

//Mutation sources. As long as there is at least one, the mutation will stay up after a remove_mutation call
///Source for mutations that have been activated by completing a sequence or using an activator
#define MUTATION_SOURCE_ACTIVATED "activated"
///Source for mutations that have been added via mutators
#define MUTATION_SOURCE_MUTATOR "mutator"
///From timed dna injectors.
#define MUTATION_SOURCE_TIMED_INJECTOR "timed_injector"
///From mob/living/carbon/human/proc/crewlike_monkify()
#define MUTATION_SOURCE_CREW_MONKEY "crew_monkey"
#define MUTATION_SOURCE_MEDIEVAL_CTF "medieval_ctf"
#define MUTATION_SOURCE_DNA_VAULT "dna_vault"
///From the /datum/action/cooldown/spell/apply_mutations spell
#define MUTATION_SOURCE_SPELL "spell"
///From the heart eater component
#define MUTATION_SOURCE_HEART_EATER "heart_eater"
#define MUTATION_SOURCE_RAT_HEART "rat_heart"
#define MUTATION_SOURCE_CLOWN_CLUMSINESS "clown_clumsiness"
#define MUTATION_SOURCE_CHANGELING "changeling"
#define MUTATION_SOURCE_GHOST_ROLE "ghost_role"
#define MUTATION_SOURCE_WISHGRANTER "wishgranter"
#define MUTATION_SOURCE_VV "vv"
#define MUTATION_SOURCE_MANNITOIL "mannitoil"
#define MUTATION_SOURCE_MAINT_ADAPT "maint_adapt"
#define MUTATION_SOURCE_BURDENED_TRAUMA "burdened_trauma"
#define MUTATION_SOURCE_GENE_SYMPTOM "gene_symptom"

//DNA - Because fuck you and your magic numbers being all over the codebase.
#define DNA_BLOCK_SIZE 3

#define DNA_BLOCK_SIZE_COLOR DEFAULT_HEX_COLOR_LEN

#define DNA_GENDER_BLOCK 1
#define DNA_SKIN_TONE_BLOCK 2
#define DNA_EYE_COLOR_LEFT_BLOCK 3
#define DNA_EYE_COLOR_RIGHT_BLOCK 4
#define DNA_HAIRSTYLE_BLOCK 5
#define DNA_HAIR_COLOR_BLOCK 6
#define DNA_FACIAL_HAIRSTYLE_BLOCK 7
#define DNA_FACIAL_HAIR_COLOR_BLOCK 8

#define DNA_UNI_IDENTITY_BLOCKS 8

#define DNA_MUTANT_COLOR_BLOCK 1
#define DNA_ETHEREAL_COLOR_BLOCK 2
#define DNA_LIZARD_MARKINGS_BLOCK 3
#define DNA_TAIL_BLOCK 4
#define DNA_LIZARD_TAIL_BLOCK 5
#define DNA_SNOUT_BLOCK 6
#define DNA_HORNS_BLOCK 7
#define DNA_FRILLS_BLOCK 8
#define DNA_SPINES_BLOCK 9
#define DNA_EARS_BLOCK 10
#define DNA_MOTH_WINGS_BLOCK 11
#define DNA_MOTH_ANTENNAE_BLOCK 12
#define DNA_MOTH_MARKINGS_BLOCK 13
#define DNA_MUSHROOM_CAPS_BLOCK 14
#define DNA_POD_HAIR_BLOCK 15
#define DNA_MUTANT_COLOR_SECONDARY 16
#define DNA_ARM_WINGS_BLOCK 17 // NON-MODULE CHANGE
#define DNA_AVIAN_EARS_BLOCK 18 // NON-MODULE CHANGE
#define DNA_AVIAN_TAIL_BLOCK 19 // NON-MODULE CHANGE
#define DNA_FEATHER_COLOR_BLOCK 20 // NON-MODULE CHANGE

/// This number needs to equal the total number of DNA blocks
#define DNA_FEATURE_BLOCKS 20

#define DNA_SEQUENCE_LENGTH 4
#define DNA_MUTATION_BLOCKS 8
#define DNA_UNIQUE_ENZYMES_LEN 32

///flag for the transfer_flag argument from dna/proc/copy_dna(). This one makes it so the SE is copied too.
#define COPY_DNA_SE (1<<0)
///flag for the transfer_flag argument from dna/proc/copy_dna(). This one copies the species.
#define COPY_DNA_SPECIES (1<<1)
///flag for the transfer_flag argument from dna/proc/copy_dna(). This one copies the mutations.
#define COPY_DNA_MUTATIONS (1<<2)

#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

/// Use this if you want to change the race's color without the player being able to pick their own color. AKA special color shifting
#define DYNCOLORS 7
#define AGENDER 8
///If we have a limb-specific overlay sprite
#define HAS_MARKINGS 9
/// Do not draw blood overlay
#define NOBLOODOVERLAY 10
///No augments, for monkeys in specific because they will turn into fucking freakazoids https://cdn.discordapp.com/attachments/326831214667235328/791313258912153640/102707682-fa7cad80-4294-11eb-8f13-8c689468aeb0.png
#define NOAUGMENTS 11
///will be assigned a universal vampire themed last name shared by their department. this is preferenced!
#define BLOOD_CLANS 12

#define REVIVESBYHEALING 13

//organ slots
#define ORGAN_SLOT_ADAMANTINE_RESONATOR "adamantine_resonator"
#define ORGAN_SLOT_APPENDIX "appendix"
#define ORGAN_SLOT_BRAIN "brain"
#define ORGAN_SLOT_BRAIN_ANTIDROP "brain_antidrop"
#define ORGAN_SLOT_BRAIN_ANTISTUN "brain_antistun"
#define ORGAN_SLOT_BREATHING_TUBE "breathing_tube"
#define ORGAN_SLOT_EARS "ears"
#define ORGAN_SLOT_EYES "eye_sight"
#define ORGAN_SLOT_HEART "heart"
#define ORGAN_SLOT_HEART_AID "heartdrive"
#define ORGAN_SLOT_HUD "eye_hud"
#define ORGAN_SLOT_LIVER "liver"
#define ORGAN_SLOT_SPLEEN "spleen" //monkestation addition
#define ORGAN_SLOT_LUNGS "lungs"
#define ORGAN_SLOT_PARASITE_EGG "parasite_egg"
#define ORGAN_SLOT_MONSTER_CORE "monstercore"
#define ORGAN_SLOT_RIGHT_ARM_AUG "r_arm_device"
#define ORGAN_SLOT_LEFT_ARM_AUG "l_arm_device" //This one ignores alphabetical order cause the arms should be together
#define ORGAN_SLOT_RIGHT_ARM_MUSCLE "r_arm_muscle"
#define ORGAN_SLOT_LEFT_ARM_MUSCLE "l_arm_muscle" //same as above
#define ORGAN_SLOT_STOMACH "stomach"
#define ORGAN_SLOT_STOMACH_AID "stomach_aid"
#define ORGAN_SLOT_STORAGE_CAVITY "storage_cavity" // monkestation edit
#define ORGAN_SLOT_THRUSTERS "thrusters"
#define ORGAN_SLOT_TONGUE "tongue"
#define ORGAN_SLOT_VOICE "vocal_cords"
#define ORGAN_SLOT_ZOMBIE "zombie_infection"
#define ORGAN_SLOT_BUTT "butt"
#define ORGAN_SLOT_BLADDER "bladder"
#define ORGAN_SLOT_LINK "cyber_link"
#define ORGAN_SLOT_RIGHT_LEG_AUG "r_leg_device"
#define ORGAN_SLOT_LEFT_LEG_AUG "l_leg_device"
#define ORGAN_SLOT_SPINAL "spinal_implant"
#define ORGAN_SLOT_BRAIN_NIF "nif"

/// Organ slot external
#define ORGAN_SLOT_EXTERNAL_TAIL "tail"
#define ORGAN_SLOT_EXTERNAL_SPINES "spines"
#define ORGAN_SLOT_EXTERNAL_SNOUT "snout"
#define ORGAN_SLOT_EXTERNAL_FRILLS "frills"
#define ORGAN_SLOT_EXTERNAL_HORNS "horns"
#define ORGAN_SLOT_EXTERNAL_WINGS "wings"
#define ORGAN_SLOT_EXTERNAL_ANTENNAE "antennae"
#define ORGAN_SLOT_EXTERNAL_BODYMARKINGS "bodymarkings"
#define ORGAN_SLOT_EXTERNAL_POD_HAIR "pod_hair"
#define ORGAN_SLOT_EXTERNAL_ANIME_HEAD "anime_head"
#define ORGAN_SLOT_EXTERNAL_ANIME_CHEST "anime_chest"
#define ORGAN_SLOT_EXTERNAL_ANIME_BOTTOM "anime_bottom"
#define ORGAN_SLOT_EXTERNAL_FLORAN_LEAVES "floran_leaves"
#define ORGAN_SLOT_EXTERNAL_FLUFF "fluff"
#define ORGAN_SLOT_EXTERNAL_FEATHERS "feathers"

/// Xenomorph organ slots
#define ORGAN_SLOT_XENO_ACIDGLAND "acid_gland"
#define ORGAN_SLOT_XENO_EGGSAC "eggsac"
#define ORGAN_SLOT_XENO_HIVENODE "hive_node"
#define ORGAN_SLOT_XENO_NEUROTOXINGLAND "neurotoxin_gland"
#define ORGAN_SLOT_XENO_PLASMAVESSEL "plasma_vessel"
#define ORGAN_SLOT_XENO_RESINSPINNER "resin_spinner"

//organ defines
#define STANDARD_ORGAN_THRESHOLD 100
#define STANDARD_ORGAN_HEALING (50 / 100000)
/// designed to fail organs when left to decay for ~15 minutes
#define STANDARD_ORGAN_DECAY (111 / 100000)

//used for the can_chromosome var on mutations
#define CHROMOSOME_NEVER 0
#define CHROMOSOME_NONE 1
#define CHROMOSOME_USED 2

#define MUTATION_COEFFICIENT_UNMODIFIABLE -1

//used for mob's genetic gender (mainly just for pronouns, members of sexed species with plural gender refer to their physique for the actual sprites, which is not genetic)
#define G_MALE 1
#define G_FEMALE 2
#define G_PLURAL 3

/// Defines how a mob's organs_slot is ordered
/// Exists so Life()'s organ process order is consistent
GLOBAL_LIST_INIT(organ_process_order, list(
	ORGAN_SLOT_BRAIN,
	ORGAN_SLOT_LINK,
	ORGAN_SLOT_SPINAL,
	ORGAN_SLOT_APPENDIX,
	ORGAN_SLOT_RIGHT_ARM_AUG,
	ORGAN_SLOT_LEFT_ARM_AUG,
	ORGAN_SLOT_LEFT_ARM_MUSCLE,
	ORGAN_SLOT_RIGHT_ARM_MUSCLE,
	ORGAN_SLOT_RIGHT_LEG_AUG,
	ORGAN_SLOT_LEFT_LEG_AUG,
	ORGAN_SLOT_STOMACH,
	ORGAN_SLOT_STOMACH_AID,
	ORGAN_SLOT_BREATHING_TUBE,
	ORGAN_SLOT_EARS,
	ORGAN_SLOT_EYES,
	ORGAN_SLOT_LUNGS,
	ORGAN_SLOT_HEART,
	ORGAN_SLOT_ZOMBIE,
	ORGAN_SLOT_THRUSTERS,
	ORGAN_SLOT_HUD,
	ORGAN_SLOT_LIVER,
	ORGAN_SLOT_SPLEEN, //monkestation addition
	ORGAN_SLOT_TONGUE,
	ORGAN_SLOT_VOICE,
	ORGAN_SLOT_ADAMANTINE_RESONATOR,
	ORGAN_SLOT_HEART_AID,
	ORGAN_SLOT_BRAIN_ANTIDROP,
	ORGAN_SLOT_BRAIN_ANTISTUN,
	ORGAN_SLOT_PARASITE_EGG,
	ORGAN_SLOT_MONSTER_CORE,
	ORGAN_SLOT_XENO_PLASMAVESSEL,
	ORGAN_SLOT_XENO_HIVENODE,
	ORGAN_SLOT_XENO_RESINSPINNER,
	ORGAN_SLOT_XENO_ACIDGLAND,
	ORGAN_SLOT_XENO_NEUROTOXINGLAND,
	ORGAN_SLOT_XENO_EGGSAC,))

//Defines for Golem Species IDs
#define SPECIES_GOLEM "golem"
#define SPECIES_GOLEM_ADAMANTINE "a_golem"
#define SPECIES_GOLEM_PLASMA "p_golem"
#define SPECIES_GOLEM_DIAMOND "diamond_golem"
#define SPECIES_GOLEM_GOLD "gold_golem"
#define SPECIES_GOLEM_SILVER "silver_golem"
#define SPECIES_GOLEM_PLASTEEL "plasteel_golem"
#define SPECIES_GOLEM_TITANIUM "titanium_golem"
#define SPECIES_GOLEM_PLASTITANIUM "plastitanium_golem"
#define SPECIES_GOLEM_ALIEN "alloy_golem"
#define SPECIES_GOLEM_WOOD "wood_golem"
#define SPECIES_GOLEM_URANIUM "uranium_golem"
#define SPECIES_GOLEM_SAND "sand_golem"
#define SPECIES_GOLEM_GLASS "glass_golem"
#define SPECIES_GOLEM_BLUESPACE "bluespace_golem"
#define SPECIES_GOLEM_BANANIUM "ba_golem"
#define SPECIES_GOLEM_CULT "cultgolem"
#define SPECIES_GOLEM_CLOTH "clothgolem"
#define SPECIES_GOLEM_PLASTIC "plastic_golem"
#define SPECIES_GOLEM_BRONZE "bronze_golem"
#define SPECIES_GOLEM_CARDBOARD "c_golem"
#define SPECIES_GOLEM_LEATHER "leather_golem"
#define SPECIES_GOLEM_DURATHREAD "d_golem"
#define SPECIES_GOLEM_BONE "b_golem"
#define SPECIES_GOLEM_SNOW "sn_golem"
#define SPECIES_GOLEM_HYDROGEN "metallic_hydrogen_golem"

// Defines for used in creating "perks" for the species preference pages.
/// A key that designates UI icon displayed on the perk.
#define SPECIES_PERK_ICON "ui_icon"
/// A key that designates the name of the perk.
#define SPECIES_PERK_NAME "name"
/// A key that designates the description of the perk.
#define SPECIES_PERK_DESC "description"
/// A key that designates what type of perk it is (see below).
#define SPECIES_PERK_TYPE "perk_type"

// The possible types each perk can be.
// Positive perks are shown in green, negative in red, and neutral in grey.
#define SPECIES_POSITIVE_PERK "positive"
#define SPECIES_NEGATIVE_PERK "negative"
#define SPECIES_NEUTRAL_PERK "neutral"
