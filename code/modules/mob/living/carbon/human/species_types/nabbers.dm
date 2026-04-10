#define NABBER_DAMAGE_ONBURNING 5

//Handles species

//Nabbers armor datum. Change this to change their resistances. Is now affected by armor piercing/etc
//By default, this is a way easier method of balancing a species rather than directly affecting burn/brute_mod, as this takes into account AP.
//Currently Nabbers also recieve a 5% brute damage reduction atop of this, and a 1.8x burn modifier, atop of their pre-existing heat modifiers.
//Whenever you adjust these variables, make sure to adjust their damage reduction, heat modifiers, and burn vulnerability to prevent scaling issues.
//All values are currently temporary and will require further balancing as eye protection, and nabber nukie modsuits are added.

/datum/armor/nabbers
	melee = 45 //Massively reduce incoming melee damage
	bullet = 25 //Reduce incoming bullet damage, too
	wound = 25 //Bare wound chance reduction
	acid = 15 // Acid reduction
	bomb = 10 //Forgot to add this earlier. Should stop them from instantly getting eviscerated from things like exploding vines/etc

/datum/species/nabber
	id = SPECIES_NABBER
	name = "Giant Armored Serpentid"
	held_accessory = null
	held_accessory_path = 'icons/mob/species/nabber/bodypart_overlays.dmi'

	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_PUSHIMMUNE, //You aint pushing it, chief.
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_HARD_SOLES,
		TRAIT_NO_AUGMENTS, //it looks BAD
		TRAIT_RADIMMUNE, //Flavor, could be removed if deemed too much
		TRAIT_MUTANT_COLORS,
		EYE_COLOR,
		TRAIT_SILENT_FOOTSTEPS, //They slither and don't step
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_ZOMBIFY, //Breaks things majorly if they get zombified
		TRAIT_NO_DNA_COPY //Cannot be cloned, body too big.
	)

	digitigrade_customization = DIGITIGRADE_NEVER
	no_equip_flags = ITEM_SLOT_FEET | ITEM_SLOT_OCLOTHING
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID

	eyes_icon = 'icons/mob/species/nabber/nabber_eyes_new.dmi'
	hair_alpha = 0
	coldmod = 0.3 //Very very resistant to cold
	heatmod = 2.5 // IT BURNS
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 5) //-10 was a bit too high, as it already does damage to their lungs
	outfit_important_for_life = /datum/outfit/nabber
	species_language_holder = /datum/language_holder/nabber
	species_cookie = /obj/item/food/meat/slab
	exotic_bloodtype = /datum/blood_type/crew/nabber

	mutanttongue = /obj/item/organ/internal/tongue/nabber
	mutantbrain = /obj/item/organ/internal/brain/nabber
	mutanteyes = /obj/item/organ/internal/eyes/nabber
	mutantlungs = /obj/item/organ/internal/lungs/nabber
	mutantheart = /obj/item/organ/internal/heart/nabber
	mutantliver = /obj/item/organ/internal/liver/nabber
	mutantears = /obj/item/organ/internal/ears/nabber
	mutantappendix = null

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/mutant/nabber,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/mutant/nabber,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/mutant/nabber,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/mutant/nabber,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/mutant/nabber,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/mutant/nabber,
	)

	// These link to specific sets of icons for which custom sprites have been made.
	// Suits are included in this list for this reason eventhough nabbers cannot wear most of them.
	// (Ponchos and aprons as example).
	custom_worn_icons = list(
		LOADOUT_ITEM_HEAD = 'icons/mob/species/nabber/custom_clothing/head.dmi',
		LOADOUT_ITEM_MASK = 'icons/mob/species/nabber/custom_clothing/mask.dmi',
		LOADOUT_ITEM_UNIFORM = 'icons/mob/species/nabber/custom_clothing/uniform.dmi',
		LOADOUT_ITEM_HANDS = 'icons/mob/species/nabber/custom_clothing/hands.dmi',
		LOADOUT_ITEM_BELT = 'icons/mob/species/nabber/custom_clothing/belt.dmi',
		LOADOUT_ITEM_MISC = 'icons/mob/species/nabber/custom_clothing/back.dmi',
		LOADOUT_ITEM_EARS = 'icons/mob/species/nabber/custom_clothing/ears.dmi',
		LOADOUT_ITEM_SUIT = 'icons/mob/species/nabber/custom_clothing/suit.dmi',
		LOADOUT_ITEM_GLASSES = 'icons/mob/species/nabber/custom_clothing/glasses.dmi',
		LOADOUT_ITEM_GLOVES = 'icons/mob/species/nabber/custom_clothing/gloves.dmi',
	)

	var/datum/action/cooldown/toggle_arms/arms
	var/datum/action/cooldown/optical_camouflage/camouflage
	//var/datum/action/cooldown/nabber_threat/threat_mod

/datum/species/nabber/on_species_gain(mob/living/carbon/human/nabber, datum/species/old_species, pref_load, regenerate_icons = TRUE)
	. = ..()
	arms = new(nabber)
	arms.Grant(nabber)
	camouflage = new(nabber)
	camouflage.Grant(nabber)
	//threat_mod = new(nabber)
	//threat_mod.Grant(nabber)
	nabber.physiology.armor = nabber.physiology.armor.add_other_armor(/datum/armor/nabbers)

/datum/species/nabber/get_species_description()
	return "TODO: Put a good description in here."

/datum/species/nabber/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only)
	. = ..()
	if(job?.nabber_outfit)
		equipping.equipOutfit(job.nabber_outfit, visuals_only)
	else
		give_important_for_life(equipping)

/datum/species/nabber/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	qdel(arms)
	qdel(camouflage)
	C.physiology.armor = C.physiology.armor.subtract_other_armor(/datum/armor/nabbers)
	//threat_mod.Destroy()

/datum/species/nabber/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	if(H.stat == DEAD) //Should never allow for them to keep burning forever
		return
	//Handles bonus burn damage
	if(H.on_fire) //Make sure this isn't being applied if they're fire immune.
		H.apply_damage(NABBER_DAMAGE_ONBURNING, OXY)
	if(H.fire_stacks <= 5 && !H.on_fire) //Never give more than 15 firestacks... Normally. Or if they have enough fire armor.
		H.adjust_fire_stacks(10)

/datum/species/nabber/prepare_human_for_preview(mob/living/carbon/human/nabber)
	var/nabber_color = "#00ac1d"
	nabber.dna.features["mcolor"] = nabber_color
	nabber.dna.features["mcolor2"] = nabber_color
	nabber.dna.features["mcolor3"] = nabber_color
	regenerate_organs(nabber, src, visual_only = TRUE)
	nabber.update_body(TRUE)

/datum/species/nabber/create_pref_unique_perks()
	var/list/perk_descriptions = list()

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "dna",
		SPECIES_PERK_NAME = "Inhuman Proportions",
		SPECIES_PERK_DESC = "Giant Armoured Serpentids are, unfortunately, too different to wear a majority of traditional armor, MODsuits and goggles!."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "dna",
		SPECIES_PERK_NAME = "Robust Chitin",
		SPECIES_PERK_DESC = "Giant Armoured Serpentids have a robust external chitin layer that protects them from a majority of brute damage sources."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "star-of-life",
		SPECIES_PERK_NAME = "Chitin-Breather",
		SPECIES_PERK_DESC = "Due to the fact Giant Armoured Serpentids (Nabbers) rely on spiracles beneath their chitin to breathe, when set on fire - they are unable to intake oxygen!"
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "star-of-life",
		SPECIES_PERK_NAME = "Flammable Chitin",
		SPECIES_PERK_DESC = "Due to the photoreflectivity and nature of their chitin, Giant Armoured Serpentids are known to be EXTREMELY burn weak, taking almost double damage from all sources, and combusting on exposure to open flame or hot enough atmospherics."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "user-plus",
		SPECIES_PERK_NAME = "Nictating Membrane",
		SPECIES_PERK_DESC = "Giant Armoured Serpentids have a secondary membrane in their eyes that allows them to shield their sensitive vision from bright lights."
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "user-plus",
		SPECIES_PERK_NAME = "Mantid Bladearms",
		SPECIES_PERK_DESC = "Giant Armoured Serpentids have two sets of arms - with the upper Bladearms requiring a majority of their haemolyph to remain active and mobile. These are dangerous weapons, and are treated by Security as such!"
	))

	perk_descriptions += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "user-plus",
		SPECIES_PERK_NAME = "Natural Electrochromic Chitin",
		SPECIES_PERK_DESC = "Giant Armoured Serpentids have naturally-electrochromic chitin. Easily disrupted by grounding to any object they touch, they can remain mostly invisible, so long as they are not disturbed nor interact with their surroundings."
	))

	return perk_descriptions
