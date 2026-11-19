/datum/species/vox
	name = "\improper Vox"
	plural_form = "Vox"
	id = SPECIES_VOX
	visual_gender = FALSE
	inherent_traits = list(
		TRAIT_MUTANT_COLORS, // body markings
		TRAIT_MUTANT_COLORS_SECONDARY, // tail markings
		TRAIT_NO_CLONE,
		TRAIT_RESISTCOLD,
	)
	external_organs = list(
		/obj/item/organ/external/tail/vox = "Plain",
		/obj/item/organ/external/vox_quills = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/external/vox_quills/facial = SPRITE_ACCESSORY_NONE,
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
	meat = /obj/item/food/meat/slab/human/mutant/vox
	skinned_type = /obj/item/stack/sheet/animalhide/vox
	exotic_bloodtype = BLOOD_TYPE_VOX
	species_language_holder = /datum/language_holder/vox
	outfit_important_for_life = /datum/outfit/vox
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	breathid = "n2"
	inherent_respiration_type = RESPIRATION_N2
	// Vox limbs are BODYSHAPE_CUSTOM, so clothing is drawn from these files when they have a sprite for it
	custom_worn_icons = list(
		LOADOUT_ITEM_UNIFORM = 'icons/mob/clothing/species/vox/uniform.dmi',
		LOADOUT_ITEM_SUIT = 'icons/mob/clothing/species/vox/suit.dmi',
		LOADOUT_ITEM_SHOES = 'icons/mob/clothing/species/vox/shoes.dmi',
		LOADOUT_ITEM_GLOVES = 'icons/mob/clothing/species/vox/gloves.dmi',
		LOADOUT_ITEM_HEAD = 'icons/mob/clothing/species/vox/head.dmi',
		LOADOUT_ITEM_MASK = 'icons/mob/clothing/species/vox/mask.dmi',
		LOADOUT_ITEM_GLASSES = 'icons/mob/clothing/species/vox/eyes.dmi',
		LOADOUT_ITEM_EARS = 'icons/mob/clothing/species/vox/ears.dmi',
		LOADOUT_ITEM_MISC = 'icons/mob/clothing/species/vox/back.dmi',
		LOADOUT_ITEM_UNDERWEAR = 'icons/mob/clothing/species/vox/underwear.dmi',
		LOADOUT_ITEM_UNDERSHIRT = 'icons/mob/clothing/species/vox/undershirt.dmi',
		LOADOUT_ITEM_SOCKS = 'icons/mob/clothing/species/vox/socks.dmi',
	)

/datum/species/vox/random_name(gender, unique, last_name)
	if(unique)
		return random_unique_vox_name()
	return capitalize(vox_name())

/datum/species/vox/randomize_features()
	var/list/features = ..()
	features["vox_body_markings"] = pick(GLOB.vox_body_markings_list)
	return features

/// A bare lime vox with cyan eyes, like the species icon on Yogstation
/datum/species/vox/prepare_human_for_preview(mob/living/carbon/human/human)
	human.delete_equipment()
	human.limb_style = VOX_DEFAULT_SKIN_TONE
	human.dna.features["vox_quills"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_facial_quills"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_body_markings"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_tail_markings"] = "Plain"
	regenerate_organs(human, src, visual_only = TRUE)
	human.set_eye_color("#17fdfb")
	human.update_body(is_creating = TRUE)

/// Vox start the shift on internals, with the mask and tank from their preferences
/datum/species/vox/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	var/mask_type = /obj/item/clothing/mask/breath/vox
	if(equipping.dna.features["vox_mask"] == "Respirator")
		mask_type = /obj/item/clothing/mask/breath/vox/respirator
	var/tank_type = /obj/item/tank/internals/emergency_oxygen/vox
	if(equipping.dna.features["vox_tank_type"] == "Large")
		tank_type = /obj/item/tank/internals/nitrogen
	equipping.equip_to_slot_or_del(new mask_type(equipping), ITEM_SLOT_MASK)
	var/obj/item/tank/internals/tank = new tank_type(equipping)
	equipping.put_in_r_hand(tank)
	if(!visuals_only)
		equipping.open_internals(tank)

/// Fitted sprites only exist for some kinds of items. Anything else is drawn with its normal sprite.
/datum/species/vox/generate_custom_worn_icon(item_slot, obj/item/item)
	var/static/list/fitted_types = list(
		LOADOUT_ITEM_UNIFORM = list(/obj/item/clothing/under),
		LOADOUT_ITEM_SUIT = list(/obj/item/clothing/suit),
		LOADOUT_ITEM_SHOES = list(/obj/item/clothing/shoes),
		LOADOUT_ITEM_GLOVES = list(/obj/item/clothing/gloves),
		LOADOUT_ITEM_HEAD = list(/obj/item/clothing/head),
		LOADOUT_ITEM_MASK = list(/obj/item/clothing/mask),
		LOADOUT_ITEM_GLASSES = list(/obj/item/clothing/glasses),
		LOADOUT_ITEM_EARS = list(/obj/item/clothing/ears),
		LOADOUT_ITEM_MISC = list(/obj/item/storage/backpack, /obj/item/defibrillator),
	)
	// Items whose sprite name matches a vox sprite drawn for a different item, so they keep their normal sprite
	var/static/list/mismatched_sprites = typecacheof(list(
		/obj/item/clothing/glasses/godeye,
		/obj/item/clothing/head/helmet/surplus,
		/obj/item/clothing/mask/luchador/enzo,
		/obj/item/clothing/suit/armor/hos_tailcoat,
		/obj/item/clothing/suit/armor/vest/blueshield/jacket,
		/obj/item/clothing/suit/armor/vest/secjacket,
		/obj/item/clothing/under/rank/cargo/qm/nova,
		/obj/item/clothing/under/rank/cargo/tech/nova,
		/obj/item/storage/backpack/deforest_medkit,
	))
	if(is_type_in_typecache(item, mismatched_sprites))
		return null
	if(!is_type_in_list(item, fitted_types[item_slot]))
		return null
	// Greyscale jumpsuits and sneakers generate their worn sprite, from a vox shaped config
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
	// Helmets have a file of their own. Some hats and helmets were drawn in each other's file, so both get checked.
	var/list/icon_files = list(custom_worn_icons[item_slot])
	if(item_slot == LOADOUT_ITEM_HEAD)
		var/is_helmet = istype(item, /obj/item/clothing/head/helmet) && !istype(item, /obj/item/clothing/head/helmet/space/vox)
		if(is_helmet)
			icon_files.Insert(1, 'icons/mob/clothing/species/vox/helmet.dmi')
		else
			icon_files += 'icons/mob/clothing/species/vox/helmet.dmi'
	for(var/icon_file in icon_files)
		if(icon_exists(icon_file, worn_state))
			return icon_file
	return null

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
