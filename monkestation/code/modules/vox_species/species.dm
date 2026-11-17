/// Vox skin tone name -> bodypart icon file. Every file holds the same icon states, in a different color.
GLOBAL_LIST_INIT(vox_skin_tones, list(
	"azure" = 'icons/mob/human/species/vox/bodyparts_azure.dmi',
	"brown" = 'icons/mob/human/species/vox/bodyparts_brown.dmi',
	"crimson" = 'icons/mob/human/species/vox/bodyparts_crimson.dmi',
	"emerald" = 'icons/mob/human/species/vox/bodyparts_emerald.dmi',
	"grey" = 'icons/mob/human/species/vox/bodyparts_grey.dmi',
	"lime" = 'icons/mob/human/species/vox/bodyparts_lime.dmi',
	"mossy" = 'icons/mob/human/species/vox/bodyparts_mossy.dmi',
	"nebula" = 'icons/mob/human/species/vox/bodyparts_nebula.dmi',
	"plum" = 'icons/mob/human/species/vox/bodyparts_plum.dmi',
))

/// Vox sprites are dark and get their color ADDED rather than multiplied. Returns a color matrix that does that.
/proc/vox_additive_color(color)
	if(!istext(color) || !length(color))
		return null
	var/list/rgb = rgb2num(sanitize_hexcolor(color, include_crunch = TRUE))
	return list(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
		rgb[1] / 255, rgb[2] / 255, rgb[3] / 255, 0,
	)

/proc/vox_name()
	var/new_name = ""
	for(var/i in 1 to rand(2, 8))
		new_name += pick("ti", "hi", "ki", "ya", "ta", "ha", "ka", "yi", "chi", "cha", "kah")
	return new_name

/proc/random_unique_vox_name(attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = capitalize(vox_name())
		if(!findname(.))
			break

/datum/species/vox
	name = "\improper Vox"
	plural_form = "Vox"
	id = SPECIES_VOX
	visual_gender = FALSE
	inherent_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_NO_CLONE, // cannot be cloned
	)
	external_organs = list(
		/obj/item/organ/external/tail/vox = "lime",
		/obj/item/organ/external/vox_quills = "None",
		/obj/item/organ/external/vox_quills/facial = "None",
	)
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/vox,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/vox,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/vox,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/vox,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/vox,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/vox,
	)
	mutantbrain = /obj/item/organ/internal/brain/vox
	mutantheart = /obj/item/organ/internal/heart/vox
	mutantliver = /obj/item/organ/internal/liver/vox
	mutantstomach = /obj/item/organ/internal/stomach/vox
	mutanttongue = /obj/item/organ/internal/tongue/vox
	mutantlungs = /obj/item/organ/internal/lungs/vox
	mutantears = /obj/item/organ/internal/ears/vox
	mutanteyes = /obj/item/organ/internal/eyes/vox
	mutantappendix = /obj/item/organ/internal/appendix/vox
	eyes_icon = 'icons/mob/human/species/vox/eyes.dmi'
	meat = /obj/item/food/meat/slab/human/mutant/vox
	skinned_type = /obj/item/stack/sheet/animalhide/vox
	exotic_bloodtype = BLOOD_TYPE_VOX
	species_language_holder = /datum/language_holder/vox
	outfit_important_for_life = /datum/outfit/vox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/vox/random_name(gender, unique, last_name)
	if(unique)
		return random_unique_vox_name()
	return capitalize(vox_name())

/datum/species/vox/randomize_features()
	var/list/features = ..()
	var/skin_tone = pick(GLOB.vox_skin_tones)
	features -= "tail_vox" // picked for every external organ by the parent, but the tail follows the skin tone
	features["vox_skin_tone"] = skin_tone
	features["vox_body_markings"] = pick(GLOB.vox_body_markings_list)
	features["vox_tail_markings"] = pick(GLOB.vox_tail_markings_list)
	features["vox_body_markings_color"] = "#[random_color()]"
	features["vox_tail_markings_color"] = features["vox_body_markings_color"]
	return features

/datum/species/vox/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["vox_skin_tone"] = "lime"
	human.dna.features["vox_quills"] = "Kingly"
	human.set_haircolor(COLOR_DARKER_BROWN, update = FALSE)
	human.dna.features["vox_facial_quills"] = "None"
	human.dna.features["vox_body_markings"] = "None"
	human.dna.features["vox_tail_markings"] = "None"
	human.eye_color_left = COLOR_CYAN
	human.eye_color_right = COLOR_CYAN
	regenerate_organs(human, src, visual_only = TRUE)
	human.update_body(is_creating = TRUE)

/// Vox lose their quills instead of hair, like on Yogstation.
/datum/species/vox/go_bald(mob/living/carbon/human/target)
	if(QDELETED(target)) //may be called from a timer
		return
	..()
	target.set_vox_quills(SPRITE_ACCESSORY_NONE, facial = TRUE)
	target.set_vox_quills(SPRITE_ACCESSORY_NONE, facial = FALSE)

/// Don't forget your voxygen tank. Runs after the job outfit, like on Yogstation.
/datum/species/vox/post_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE, datum/preferences/used_pref)
	// A mask we can't breathe through goes into the bag. Breathable job masks (clown, mime) stay on.
	var/obj/item/current_mask = equipping.wear_mask
	if(current_mask && !equipping.can_breathe_mask())
		equipping.temporarilyRemoveItemFromInventory(current_mask, force = TRUE)
		if(!equipping.equip_to_slot_if_possible(current_mask, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
			equipping.put_in_hands(current_mask)
	var/mask_type = (used_pref?.read_preference(/datum/preference/choiced/vox_mask) == "Respirator") ? /obj/item/clothing/mask/breath/vox/respirator : /obj/item/clothing/mask/breath/vox
	equipping.equip_to_slot_or_del(new mask_type(equipping), ITEM_SLOT_MASK)
	var/tank_type = (used_pref?.read_preference(/datum/preference/choiced/vox_tank_type) == "Large") ? /obj/item/tank/internals/nitrogen : /obj/item/tank/internals/emergency_oxygen/vox
	var/obj/item/tank/internals/internals_tank = new tank_type(equipping)
	if(!equipping.equip_to_appropriate_slot(internals_tank))
		equipping.put_in_hands(internals_tank)
	if(visuals_only)
		return
	to_chat(equipping, span_notice("You are now running on nitrogen internals from [internals_tank]. Your species finds oxygen toxic, so you must breathe pure nitrogen."))
	equipping.open_internals(internals_tank)

/datum/species/vox/get_species_description()
	return "The Vox are remnants of an ancient race, that originate from arkships. \
		These bioengineered, reptilian, beaked, and quilled beings have a physiological caste system and follow 'The Inviolate' tenets. \
		Breathing pure nitrogen, they need specialized masks and tanks for survival outside their arkships. \
		Their insular nature limits their involvement in broader galactic affairs, maintaining a distinct, yet isolated presence away from other species."

/datum/species/vox/get_species_lore()
	return list(
		"Vox have no colonies of their own to speak of. Most Vox originate from a location known as the Shoal, \
		a sprawling, labyrinth-like space megalith of debris and asteroids fused together over countless orbits. \
		It is there where their cutthroat and opportunistic behavior stems from.",

		"Little is known of Vox history itself, as the Vox do not keep many records beyond personal accomplishments and tales of profit and triumph. \
		They have lived among the Shoal and the stars as long as they or anyone else can remember.",

		"It is possible the species went through a dark age before being introduced to the greater galactic community. \
		Those taken by Vox raiders are rumored to be taken back to the Shoal to be sold as slaves. \
		Other rumors speculate those not cut out to be slaves are sold by fleshpeddlers for \"extraction\".",

		"Many Vox have grown fond of life among the stars, and typically avoid living on planetary colonies. \
		They have a penchant for capitalism and goods peddling, deep space salvage, and sometimes interstellar crime. \
		Many Vox now seek their fortune on the border of civilized space. Some trading with stations and worlds as (questionably legal) merchants, \
		or applying to work for any one of the countless mega-corporations on the frontier. \
		Others profit off crime and marauding, hijacking ships, cargo, and sometimes people to bring back to the Shoal.",
	)

/datum/species/vox/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Resistance",
			SPECIES_PERK_DESC = "Vox hides provide excellent insulation against the coldness of space.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "heart-circle-check",
			SPECIES_PERK_NAME = "Imperishable Organs",
			SPECIES_PERK_DESC = "Vox organs contain advanced cybernetics that prevent them from decaying.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "EMP Sensitivity",
			SPECIES_PERK_DESC = "Due to their organs being partially synthetic, Vox are susceptible to EMPs.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "head-side-mask",
			SPECIES_PERK_NAME = "Nitrogen Breathing",
			SPECIES_PERK_DESC = "Oxygen is toxic to Vox, they must breathe pure nitrogen.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "Unclonable",
			SPECIES_PERK_DESC = "Their peculiar physiology prevents Vox from being cloned.",
		),
	)

	return to_add

/mob/living/carbon/human/species/vox
	race = /datum/species/vox

// Fitted clothing. Vox are BODYSHAPE_CUSTOM, anything without a fitted sprite falls back to the human one.

/// Loadout slot -> list of icon files with vox-fitted worn sprites.
GLOBAL_LIST_INIT(vox_worn_icons, list(
	LOADOUT_ITEM_HEAD = list('icons/mob/clothing/species/vox/head.dmi', 'icons/mob/clothing/species/vox/helmet.dmi'),
	LOADOUT_ITEM_MASK = list('icons/mob/clothing/species/vox/mask.dmi'),
	LOADOUT_ITEM_GLASSES = list('icons/mob/clothing/species/vox/eyes.dmi'),
	LOADOUT_ITEM_EARS = list('icons/mob/clothing/species/vox/ears.dmi'),
	LOADOUT_ITEM_NECK = list('icons/mob/clothing/species/vox/collar.dmi'),
	LOADOUT_ITEM_GLOVES = list('icons/mob/clothing/species/vox/gloves.dmi'),
	LOADOUT_ITEM_SHOES = list('icons/mob/clothing/species/vox/shoes.dmi'),
	LOADOUT_ITEM_SUIT = list('icons/mob/clothing/species/vox/suit.dmi'),
	LOADOUT_ITEM_UNIFORM = list('icons/mob/clothing/species/vox/uniform.dmi'),
	LOADOUT_ITEM_MISC = list('icons/mob/clothing/species/vox/back.dmi'),
))

/datum/species/vox/generate_custom_worn_icon(item_slot, obj/item/item)
	// Greyscale items generate their own worn icon. A few of them have a vox shaped config, the rest fall back to the human shape.
	if(item.greyscale_config_worn)
		var/static/list/fitted_configs = list(
			/datum/greyscale_config/jumpsuit/worn = /datum/greyscale_config/jumpsuit/worn/vox,
			/datum/greyscale_config/jumpsuit_prison_worn = /datum/greyscale_config/jumpsuit_prison_worn/vox,
			/datum/greyscale_config/sneakers/worn = /datum/greyscale_config/sneakers/worn/vox,
			/datum/greyscale_config/sneakers_orange/worn = /datum/greyscale_config/sneakers_orange/worn/vox,
		)
		var/fitted_config = fitted_configs[item.greyscale_config_worn]
		if(!fitted_config || !item.greyscale_colors)
			return null
		return SSgreyscale.GetColoredIconByType(fitted_config, item.greyscale_colors)
	var/worn_state = item.worn_icon_state || item.icon_state
	for(var/icon_file in GLOB.vox_worn_icons[item_slot])
		if(icon_exists(icon_file, worn_state))
			return icon_file
	return null
