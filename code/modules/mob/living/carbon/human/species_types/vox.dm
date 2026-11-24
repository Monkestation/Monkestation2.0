/datum/species/vox
	name = "\improper Vox"
	plural_form = "Vox"
	id = SPECIES_VOX
	visual_gender = FALSE
	inherent_traits = list(
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
	cough_sound = 'sound/voice/vox_species/shriekcough.ogg'
	sneeze_sound = 'sound/voice/vox_species/shrieksneeze.ogg'
	scream_message = "shrieks!"
	inherent_respiration_type = RESPIRATION_N2
	// Not set on Yogstation either, left as ideas. Other species use these:
	// species_cookie = /obj/item/food/meat/slab // what admins give for a prayer, a cookie by default. Lizards get meat, and vox tongues like it
	// inert_mutation = /datum/mutation/... // the dormant mutation in the species' genome, dwarfism by default
	// death_sound = 'sound/...' // played when they die, like the lizard one. Would want a proper death shriek
	// inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_REPTILE // biotypes are used by diseases and some chems, lizards are MOB_REPTILE
	mirror_race_change_features = list(
		/datum/preference/choiced/vox_skin_tone,
		/datum/preference/choiced/vox_body_markings,
		/datum/preference/color/vox_body_markings_color,
		/datum/preference/choiced/vox_tail_markings,
		/datum/preference/color/vox_tail_markings_color,
	)
	suicide_messages = list(
		"%SUICIDER% is jamming %THEIR% claws into %THEIR% eye sockets!",
		"%SUICIDER% is deeply inhaling oxygen!",
	)
	// Vox limbs are BODYSHAPE_CUSTOM, so things worn on them are drawn from these files when they have a sprite for it
	custom_worn_icons = list(
		LOADOUT_ITEM_UNIFORM = VOX_UNIFORM_FILE,
		LOADOUT_ITEM_SUIT = VOX_SUIT_FILE,
		LOADOUT_ITEM_SHOES = VOX_SHOES_FILE,
		LOADOUT_ITEM_GLOVES = VOX_GLOVES_FILE,
		LOADOUT_ITEM_HEAD = VOX_HEAD_FILE,
		LOADOUT_ITEM_MASK = VOX_MASK_FILE,
		LOADOUT_ITEM_GLASSES = VOX_EYES_FILE,
		LOADOUT_ITEM_EARS = VOX_EARS_FILE,
		LOADOUT_ITEM_MISC = VOX_BACK_FILE,
		LOADOUT_ITEM_UNDERWEAR = VOX_UNDERWEAR_FILE,
		LOADOUT_ITEM_UNDERSHIRT = VOX_UNDERSHIRT_FILE,
		LOADOUT_ITEM_SOCKS = VOX_SOCKS_FILE,
	)

/datum/species/vox/random_name(gender, unique, last_name)
	if(unique)
		return random_unique_vox_name()
	return capitalize(vox_name())

/datum/species/vox/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent_tick))

/datum/species/vox/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	UnregisterSignal(human, COMSIG_MOB_REAGENT_TICK)
	return ..()

/// Oxygen is as toxic to vox in the blood as it is in the lungs, so it replaces oxygen's normal metabolism
/datum/species/vox/proc/on_reagent_tick(mob/living/carbon/human/source, datum/reagent/chem, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(chem.type != /datum/reagent/oxygen)
		return NONE
	source.adjustToxLoss(0.5 * seconds_per_tick)
	source.reagents.remove_reagent(chem.type, 0.1 * seconds_per_tick)
	return COMSIG_MOB_STOP_REAGENT_TICK

/datum/species/vox/randomize_features()
	var/list/features = ..()
	features["vox_body_markings"] = pick(GLOB.vox_body_markings_list)
	features["vox_skin_tone"] = pick(GLOB.vox_skin_tones)
	return features

/// A bare lime vox with cyan eyes, like the species icon on Yogstation
/datum/species/vox/prepare_human_for_preview(mob/living/carbon/human/human)
	human.delete_equipment()
	human.dna.features["vox_skin_tone"] = "lime"
	human.dna.features["vox_quills"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_facial_quills"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_body_markings"] = SPRITE_ACCESSORY_NONE
	human.dna.features["vox_tail_markings"] = "Plain"
	regenerate_organs(human, visual_only = TRUE)
	human.set_eye_color("#17fdfb")
	human.update_body(is_creating = TRUE)

/// Any outfit gets vox their mask and nitrogen tank, see equip_internals()
/datum/species/vox/post_equip_species_outfit(mob/living/carbon/human/equipping, visuals_only = FALSE)
	equip_internals(equipping, /obj/item/clothing/mask/breath/vox, /obj/item/tank/internals/emergency_oxygen/vox, visuals_only)

/// Jobs swap them for the mask and tank picked in the preferences
/datum/species/vox/apply_gear_preferences(mob/living/carbon/human/equipping, datum/preferences/used_pref, visuals_only = FALSE)
	if(!used_pref)
		return
	var/mask_type = (used_pref.read_preference(/datum/preference/choiced/vox_mask) == "Respirator") ? /obj/item/clothing/mask/breath/vox/respirator : /obj/item/clothing/mask/breath/vox
	var/tank_type = (used_pref.read_preference(/datum/preference/choiced/vox_tank_type) == "Large") ? /obj/item/tank/internals/nitrogen : /obj/item/tank/internals/emergency_oxygen/vox
	equip_internals(equipping, mask_type, tank_type, visuals_only)

/**
 * Makes sure a vox wears a mask of mask_type and runs on a tank of tank_type.
 * Masks they can't breathe through go in the bag, and the other kind of vox mask or the default vox tank is swapped out,
 * so equipping again never stacks up tanks.
 */
/datum/species/vox/proc/equip_internals(mob/living/carbon/human/equipping, mask_type, tank_type, visuals_only = FALSE)
	var/obj/item/current_mask = equipping.wear_mask
	if(istype(current_mask, /obj/item/clothing/mask/breath/vox) && current_mask.type != mask_type)
		qdel(current_mask)
	else if(current_mask && !equipping.can_breathe_mask()) // job masks we can breathe through (like the clown's) stay on
		equipping.temporarilyRemoveItemFromInventory(current_mask, force = TRUE)
		if(!equipping.equip_to_slot_if_possible(current_mask, ITEM_SLOT_BACKPACK, disable_warning = TRUE))
			equipping.put_in_hands(current_mask)
	if(!equipping.wear_mask)
		equipping.equip_to_slot_or_del(new mask_type(equipping), ITEM_SLOT_MASK)

	var/already_told = istype(equipping.internal, /obj/item/tank/internals/emergency_oxygen/vox) // swapping out the default vox tank for the preferred one
	var/obj/item/tank/internals/tank
	for(var/obj/item/tank/internals/carried_tank in equipping.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		if(carried_tank.type == tank_type)
			tank = carried_tank
		else if(carried_tank.type == /obj/item/tank/internals/emergency_oxygen/vox)
			qdel(carried_tank)
	if(!tank)
		tank = new tank_type(equipping)
		if(!equipping.equip_to_appropriate_slot(tank))
			equipping.put_in_hands(tank)
	if(visuals_only || equipping.internal == tank)
		return
	if(!already_told)
		to_chat(equipping, span_notice("You are now running on nitrogen internals from [tank]. Your species finds oxygen toxic, so you must breathe pure nitrogen."))
	equipping.open_internals(tank)

/// Fitted sprites only exist for some kinds of items. Anything else is drawn with its normal sprite.
/datum/species/vox/get_fitted_worn_icon(item_slot, obj/item/item)
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
	// Items with a vox sprite in a file of their own
	var/static/list/item_worn_icons = list(
		/obj/item/clothing/mask/breath/vox/octus = 'icons/mob/clothing/donator/mask_vox.dmi',
	)
	if(item_worn_icons[item.type])
		return item_worn_icons[item.type]
	if(is_type_in_typecache(item, mismatched_sprites) || !is_type_in_list(item, fitted_types[item_slot]))
		return null
	// Greyscale jumpsuits and sneakers generate their worn sprite from a vox shaped config, which only fits vox legs
	if(item.greyscale_config_worn)
		var/mob/living/carbon/human/wearer = item.loc
		if(ishuman(wearer) && !(id in wearer.get_fitting_limb_ids(LOADOUT_ITEM_SHOES)))
			return null
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
			icon_files.Insert(1, VOX_HELMET_FILE)
		else
			icon_files += VOX_HELMET_FILE
	for(var/icon_file in icon_files)
		if(icon_exists(icon_file, worn_state))
			return icon_file
	return null

/// Fitted to the box: breath masks become ones that fit a beak, the nitrogen tank matches the box's tank size,
/// and the box keeps its other masks (like gas masks) and its medipen
/datum/species/vox/get_survival_box_overrides(obj/item/storage/box/survival/box)
	return list(
		SURVIVAL_MASK_TYPE = ispath(box.mask_type, /obj/item/clothing/mask/breath) ? pick(/obj/item/clothing/mask/breath/vox, /obj/item/clothing/mask/breath/vox/respirator) : box.mask_type,
		SURVIVAL_INTERNALS_TYPE = ispath(box.internal_type, /obj/item/tank/internals/emergency_oxygen/engi) ? /obj/item/tank/internals/emergency_oxygen/emergency_nitrogen/engi : /obj/item/tank/internals/emergency_oxygen/emergency_nitrogen,
		SURVIVAL_MEDIPEN_TYPE = box.medipen_type,
	)

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
