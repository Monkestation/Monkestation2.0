
#define DISEASE_LIMIT 1
#define VIRUS_SYMPTOM_LIMIT 6

//Visibility Flags
#define HIDDEN_SCANNER (1<<0)
#define HIDDEN_PANDEMIC (1<<1)

DEFINE_BITFIELD(visibility_flags, list(
	"HIDDEN_SCANNER" = HIDDEN_SCANNER,
	"HIDDEN_PANDEMIC" = HIDDEN_PANDEMIC,
))

//Disease Flags
#define CURABLE (1<<0)
#define CAN_CARRY (1<<1)
#define CAN_RESIST (1<<2)
#define DISEASE_DORMANT (1<<3)
#define DISEASE_COPYSTAGE (1<<4)
#define DISEASE_ANALYZED (1<<5)

DEFINE_BITFIELD(disease_flags, list(
	"CURABLE" = CURABLE,
	"CAN_CARRY" = CAN_CARRY,
	"CAN_RESIST" = CAN_RESIST,
	"DORMANT" = DISEASE_DORMANT,
	"STAGE_COPY" = DISEASE_COPYSTAGE,
	"ANALYZED" = DISEASE_ANALYZED,
))

//Spread Flags
#define DISEASE_SPREAD_SPECIAL (1<<0)
#define DISEASE_SPREAD_NON_CONTAGIOUS (1<<1)
#define DISEASE_SPREAD_BLOOD (1<<2)
#define DISEASE_SPREAD_CONTACT_FLUIDS (1<<3)
#define DISEASE_SPREAD_CONTACT_SKIN (1<<4)
#define DISEASE_SPREAD_AIRBORNE (1<<5)

DEFINE_BITFIELD(spread_flags, list(
	"DISEASE_SPREAD_SPECIAL" = DISEASE_SPREAD_SPECIAL,
	"DISEASE_SPREAD_NON_CONTAGIOUS" = DISEASE_SPREAD_NON_CONTAGIOUS,
	"DISEASE_SPREAD_BLOOD" = DISEASE_SPREAD_BLOOD,
	"DISEASE_SPREAD_CONTACT_FLUIDS" = DISEASE_SPREAD_CONTACT_FLUIDS,
	"DISEASE_SPREAD_CONTACT_SKIN" = DISEASE_SPREAD_CONTACT_SKIN,
	"DISEASE_SPREAD_AIRBORNE" = DISEASE_SPREAD_AIRBORNE,
))

//Severity Defines
/// Diseases that buff, heal, or at least do nothing at all
#define DISEASE_SEVERITY_POSITIVE "Positive"
/// Diseases that may have annoying effects, but nothing disruptive (sneezing)
#define DISEASE_SEVERITY_NONTHREAT "Harmless"
/// Diseases that can annoy in concrete ways (dizziness)
#define DISEASE_SEVERITY_MINOR "Minor"
/// Diseases that can do minor harm, or severe annoyance (vomit)
#define DISEASE_SEVERITY_MEDIUM "Medium"
/// Diseases that can do significant harm, or severe disruption (brainrot)
#define DISEASE_SEVERITY_HARMFUL "Harmful"
/// Diseases that can kill or maim if left untreated (flesh eating, blindness)
#define DISEASE_SEVERITY_DANGEROUS "Dangerous"
/// Diseases that can quickly kill an unprepared victim (fungal tb, gbs)
#define DISEASE_SEVERITY_BIOHAZARD "BIOHAZARD"

#define DISEASE_HOLOSIGN_BLOCK 3

/// Any non predefined disease subtype.
#define WILD_ACUTE_DISEASES (subtypesof(/datum/disease/acute) - typesof(/datum/disease/acute/premade))
