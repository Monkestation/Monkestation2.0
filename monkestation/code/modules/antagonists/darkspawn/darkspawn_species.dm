////////////////////////////////////////////////////////////////////////////////////
//----------------------Roundstart antag exclusive species------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/species/shadow/darkspawn
	name = "Darkspawn"
	id = SPECIES_DARKSPAWN
	limbs_id = SPECIES_DARKSPAWN
	possible_genders = list(PLURAL)
	nojumpsuit = TRUE
	changesource_flags = MIRROR_BADMIN //never put this in the pride pool because they look super valid and can never be changed off of
	siemens_coeff = 0
	armor = 10
	burnmod = 1.2
	heatmod = 1.5
	no_equip = list(
		ITEM_SLOT_MASK,
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_FEET,
		ITEM_SLOT_ICLOTHING,
		ITEM_SLOT_SUITSTORE,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_EYES
		)
	species_traits = list(
		NOBLOOD,
		NO_UNDERWEAR,
		NO_DNA_COPY,
		NOTRANSSTING,
		NOEYESPRITES,
		NOHUSK
		)
	inherent_traits = list(
		TRAIT_NOGUNS,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NO_SLIP_ICE,
		TRAIT_GENELESS,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOGUNS,
		TRAIT_SPECIESLOCK //never let them swap off darkspawn, it can cause issues
		)
	mutanteyes = /obj/item/organ/eyes/darkspawn
	mutantears = /obj/item/organ/ears/darkspawn
	mutantbrain = /obj/item/organ/internal/brain

	powerful_heal = TRUE
	shadow_charges = 3

/datum/species/shadow/darkspawn/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.fully_replace_character_name(null, darkspawn_name())

/datum/species/shadow/darkspawn/spec_updatehealth(mob/living/carbon/human/H)
	var/datum/antagonist/darkspawn/antag = isdarkspawn(H)
	if(antag)
		dark_healing = antag.dark_healing
		light_burning = antag.light_burning
		if(H.physiology)
			H.physiology.brute_mod = antag.brute_mod
			H.physiology.burn_mod = antag.burn_mod
			H.physiology.stamina_mod = antag.stam_mod

/datum/species/shadow/darkspawn/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, FALSE)

/datum/species/shadow/darkspawn/check_roundstart_eligible()
	return FALSE


////////////////////////////////////////////////////////////////////////////////////
//------------------------------Darkspawn organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/eyes/darkspawn //special eyes that innately have night vision without having a toggle that adds action clutter
	name = "darkspawn eyes"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD //far more durable eyes than most
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	color_cutoffs = list(12, 0, 50)
	sight_flags = SEE_MOBS

/obj/item/organ/ears/darkspawn //special ears that are a bit tankier and have innate sound protection
	name = "darkspawn ears"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD //far more durable ears than most
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	bang_protect = 1
