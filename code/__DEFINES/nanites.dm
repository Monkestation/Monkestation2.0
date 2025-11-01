///Trait given by Nanites
#define TRAIT_NANITES "Nanites"

#define NANITE_SHOCK_IMMUNE (1<<0)
#define NANITE_EMP_IMMUNE (1<<1)

///Nanite Protocol types
#define NANITE_PROTOCOL_REPLICATION "nanite_replication"
#define NANITE_PROTOCOL_STORAGE "nanite_storage"

///Nanite extra settings types: used to help uis know what type an extra setting is
#define NESTYPE_TEXT "text"
#define NESTYPE_NUMBER "number"
#define NESTYPE_TYPE "type"
#define NESTYPE_BOOLEAN "boolean"

///Nanite Extra Settings - Note that these will also be the names displayed in the UI
#define NES_SENT_CODE "Sent Code"
#define NES_SENT_CODE_INVERTED "Sent Code (Inverted)"
#define NES_SENT_CODE_SIGNAL "Sent Code (Signal)"
#define NES_SENT_CODE_SIGNAL_INVERTED "Sent Code (Signal, Inverted)"
#define NES_SENT_CODE_TRIGGER "Sent Code (Trigger)"
#define NES_SENT_CODE_TRIGGER_INVERTED "Sent Code (Trigger, Inverted)"
#define NES_DELAY "Delay"
#define NES_COMM_CODE "Comm Code"
#define NES_RELAY_CHANNEL "Relay Channel"
#define NES_HEALTH_PERCENT "Health Percent"
#define NES_NANITE_PERCENT "Nanite Percent"
#define NES_BLOOD_PERCENT "Blood Percent"
#define NES_NUTRITION_PERCENT "Nutrition Percent"
#define NES_DIRECTION "Direction"
#define NES_DAMAGE_TYPE "Damage Type"
#define NES_DAMAGE "Damage"
#define NES_MESSAGE "Message"
#define NES_DIRECTIVE "Directive"
#define NES_SENTENCE "Sentence"
#define NES_MATCH_MODE "Match Mode"
#define NES_RACE "Race"
#define NES_HALLUCINATION_TYPE "Hallucination Type"
#define NES_HALLUCINATION_DETAIL "Hallucination Detail"
#define NES_MODE "Mode"
#define NES_MOOD_MESSAGE "Mood Message"
#define NES_PROGRAM_OVERWRITE "Program Overwrite"
#define NES_CLOUD_OVERWRITE "Cloud Overwrite"
#define NES_SCAN_TYPE "Scan Type"
#define NES_BUTTON_NAME "Button Name"
#define NES_ICON "Icon"
#define NES_INVALID_PHRASE "Invalid Phrase"
#define NES_PHRASE_REPLACEMENT "Phrase Replacement"
#define NES_REPLACEMENT_MODE "Replacement Mode"

#define NANITE_CATEGORY_UTILITIES "Utility Nanites"
#define NANITE_CATEGORY_MEDICAL "Medical Nanites"
#define NANITES_CATEGORY_SENSOR "Sensor Nanites"
#define NANITES_CATEGORY_AUGMENTATION "Augmentation Nanites"
#define NANITES_CATEGORY_SUPPRESSION "Suppression Nanites"
#define NANITES_CATEGORY_WEAPONIZED "Weaponized Nanites"
#define NANITES_CATEGORY_PROTOCOLS "Protocols Nanites"
#define NANITES_CATEGORY_DEFECTIVE "Defective Nanites"

// To be moved to code\__DEFINES\research\techweb_nodes.dm once reesarch node defines are ported.
#define TECHWEB_NODE_NANITE_BASE "nanite_base"
#define TECHWEB_NODE_NANITE_SMART "nanite_smart"
#define TECHWEB_NODE_NANITE_MESH "nanite_mesh"
#define TECHWEB_NODE_NANITE_BIO "nanite_bio"
#define TECHWEB_NODE_NANITE_NEURAL "nanite_neural"
#define TECHWEB_NODE_NANITE_SYNAPTIC "nanite_synaptic"
#define TECHWEB_NODE_NANITE_HARMONIC "nanite_harmonic"
#define TECHWEB_NODE_NANITE_MILITARY "nanite_military"
#define TECHWEB_NODE_NANITE_HAZARD "nanite_hazard"
#define TECHWEB_NODE_NANITE_REPLICATION "nanite_replication_protocols"
#define TECHWEB_NODE_NANITE_STORAGE "nanite_storage_protocols"

///How long it takes to break out of a nanite chamber (including public)
#define NANITE_CHAMBER_BREAKOUT_TIME (2 MINUTES)

///The biotypes that are compatible to get nanites.
#define NANITE_COMPATIBLE_BIOTYPES (MOB_ORGANIC|MOB_UNDEAD|MOB_ROBOTIC)
