// Everything vox-related that is not the species itself: toys, food, cargo, research and small hooks.

// Sounds and emote text

/datum/emote/living/cough/get_sound(mob/living/user)
	if(isvox(user))
		return 'sound/voice/vox_species/shriekcough.ogg'
	return ..()

/datum/emote/living/sneeze/get_sound(mob/living/user)
	if(isvox(user))
		return 'sound/voice/vox_species/shrieksneeze.ogg'
	return ..()

/datum/emote/living/carbon/human/scream/select_message_type(mob/user, msg, intentional)
	. = ..()
	if(isvox(user) && . == message)
		return "shrieks!"

// Quills in place of hair: mirrors and razors

/**
 * Changes the (facial) quills of a vox.
 * Quills are external organs, so this adds, restyles or removes the organ as needed.
 */
/mob/living/carbon/human/proc/set_vox_quills(new_style, facial = FALSE)
	var/feature = facial ? "vox_facial_quills" : "vox_quills"
	var/slot = facial ? ORGAN_SLOT_EXTERNAL_VOX_FACIAL_QUILLS : ORGAN_SLOT_EXTERNAL_VOX_QUILLS
	var/obj/item/organ/external/vox_quills/quills = get_organ_slot(slot)
	dna.features[feature] = new_style
	dna.update_uf_block(facial ? DNA_VOX_FACIAL_QUILLS_BLOCK : DNA_VOX_QUILLS_BLOCK)
	if(new_style == SPRITE_ACCESSORY_NONE)
		if(quills)
			quills.Remove(src, special = TRUE)
			qdel(quills)
	else if(quills)
		quills.bodypart_overlay.set_appearance_from_name(new_style)
	else
		var/quills_type = facial ? /obj/item/organ/external/vox_quills/facial : /obj/item/organ/external/vox_quills
		quills = new quills_type()
		quills.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	update_body_parts()

/// Vox version of changing hair or beard at a mirror.
/obj/structure/mirror/proc/change_vox_quills(mob/living/carbon/human/vox, facial = FALSE)
	var/new_style = tgui_input_list(vox, "Select a [facial ? "facial " : ""]quill style", "Grooming", facial ? GLOB.vox_facial_quills_list : GLOB.vox_quills_list)
	if(isnull(new_style))
		return TRUE
	if(HAS_TRAIT(vox, facial ? TRAIT_SHAVED : TRAIT_BALD))
		to_chat(vox, span_notice("If only growing back quills were that easy for you... The reminder makes you feel terrible."))
		vox.add_mood_event("bald_hair_day", /datum/mood_event/bald_reminder)
		return TRUE
	vox.set_vox_quills(new_style, facial)

// Underwear, socks and undershirts drawn from species-fitted icon files

/datum/species
	/// If set, underwear is drawn from these files instead: list("underwear" = icon, "undershirt" = icon, "socks" = icon).
	/// Anything that does not have a sprite in there is not drawn at all.
	var/list/fitted_underwear_icons

/datum/species/vox
	fitted_underwear_icons = list(
		"underwear" = 'icons/mob/clothing/species/vox/underwear.dmi',
		"undershirt" = 'icons/mob/clothing/species/vox/undershirt.dmi',
		"socks" = 'icons/mob/clothing/species/vox/socks.dmi',
	)

/// Returns the fitted version of an underwear sprite if there is one, or the normal one like on Yogstation.
/datum/species/proc/get_fitted_underwear_icon(datum/sprite_accessory/accessory, kind)
	var/fitted_icon = fitted_underwear_icons[kind]
	if(fitted_icon && icon_exists(fitted_icon, accessory.icon_state))
		return fitted_icon
	return accessory.icon

/datum/species/proc/get_fitted_underwear_overlays(mob/living/carbon/human/species_human)
	. = list()
	if(HAS_TRAIT(species_human, TRAIT_NO_UNDERWEAR))
		return
	var/datum/sprite_accessory/underwear = GLOB.underwear_list[species_human.underwear]
	if(underwear)
		var/mutable_appearance/underwear_overlay = mutable_appearance(get_fitted_underwear_icon(underwear, "underwear"), underwear.icon_state, -BODY_LAYER)
		if(!underwear.use_static)
			underwear_overlay.color = species_human.underwear_color
		. += underwear_overlay
	var/datum/sprite_accessory/undershirt = GLOB.undershirt_list[species_human.undershirt]
	if(undershirt)
		. += mutable_appearance(get_fitted_underwear_icon(undershirt, "undershirt"), undershirt.icon_state, -BODY_LAYER)
	var/datum/sprite_accessory/socks = GLOB.socks_list[species_human.socks]
	if(socks && species_human.num_legs >= 2)
		var/mutable_appearance/socks_overlay = mutable_appearance(get_fitted_underwear_icon(socks, "socks"), socks.icon_state, -BODY_LAYER)
		if(!socks.use_static)
			socks_overlay.color = species_human.socks_color
		. += socks_overlay

// Toys and decorations

/obj/item/toy/plush/voxplushie
	name = "vox plushie"
	desc = "A stitched-together Vox, fresh from the skipjack. Press its belly to hear it skree!"
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "plushie_vox"
	inhand_icon_state = null
	squeak_override = list('sound/voice/vox_species/shriek1.ogg' = 1)

/obj/item/flag
	name = "flag"
	desc = "It's a flag."
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "voxflag"
	lefthand_file = 'icons/obj/species/vox/items_lefthand.dmi'
	righthand_file = 'icons/obj/species/vox/items_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	max_integrity = 40
	resistance_flags = FLAMMABLE
	/// Is the flag rolled up around its pole?
	var/rolled = FALSE

/obj/item/flag/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/flag/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(item.get_temperature() && !(resistance_flags & ON_FIRE))
		user.visible_message(span_notice("[user] lights [src] with [item]."), span_notice("You light [src] with [item]."), span_hear("You hear a low whoosh."))
		fire_act()

/obj/item/flag/attack_self(mob/user)
	rolled = !rolled
	user.visible_message(span_notice("[user] [rolled ? "rolls up" : "unfurls"] [src]."), span_notice("You [rolled ? "roll up" : "unfurl"] [src]."), span_hear("You hear fabric rustling."))
	update_appearance()

/obj/item/flag/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	update_appearance()

/obj/item/flag/extinguish()
	. = ..()
	update_appearance()

/obj/item/flag/update_icon_state()
	icon_state = "[initial(icon_state)][rolled ? "_rolled" : ""]"
	inhand_icon_state = "[initial(icon_state)][(resistance_flags & ON_FIRE) ? "_fire" : ""]"
	// flags burn with their own flames, shaped to the cloth
	custom_fire_overlay = mutable_appearance(icon, rolled ? "flag_fire_rolled" : "flag_fire", appearance_flags = RESET_COLOR)
	return ..()

/obj/item/flag/species/vox
	name = "\improper Vox flag"
	desc = "A flag proudly proclaiming the superior heritage of Vox."
	icon_state = "voxflag"

/obj/structure/sign/pox
	name = "\improper NO VOX ALLOWED sign"
	desc = "A sign which reads 'NO VOX ALLOWED'."
	icon = 'icons/obj/species/vox/signs.dmi'
	icon_state = "novox1-b"
	is_editable = FALSE

/obj/structure/sign/pox/no_cross
	icon_state = "novox2-b"

/obj/structure/sign/pox/red
	icon_state = "novox1-r"

/obj/structure/sign/pox/red/no_cross
	icon_state = "novox2-r"

/obj/structure/sign/pox/red/circle
	icon_state = "novox_circle1"

/obj/structure/sign/pox/red/circle/no_cross
	icon_state = "novox_circle2"

// Food

/obj/item/food/fried_vox
	name = "Kentucky Fried Vox"
	desc = "11 herbs and spices."
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "fried_vox"
	inhand_icon_state = "fried_vox"
	lefthand_file = 'icons/obj/species/vox/items_lefthand.dmi'
	righthand_file = 'icons/obj/species/vox/items_righthand.dmi'
	trash_type = /obj/item/trash/fried_vox
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("quills" = 1, "the Shoal" = 1)
	foodtypes = MEAT | FRIED

/obj/item/trash/fried_vox
	name = "Kentucky Fried Vox"
	icon = 'icons/obj/species/vox/items.dmi'
	icon_state = "fried_vox_empty"
	inhand_icon_state = "fried_vox_empty"
	lefthand_file = 'icons/obj/species/vox/items_lefthand.dmi'
	righthand_file = 'icons/obj/species/vox/items_righthand.dmi'
	worn_icon = 'icons/obj/species/vox/items_worn.dmi'
	worn_icon_state = "fried_vox_empty"
	slot_flags = ITEM_SLOT_HEAD
	dog_fashion = /datum/dog_fashion/head/fried_vox_empty

/datum/dog_fashion/head/fried_vox_empty
	name = "Colonel %REAL_NAME%"
	desc = "Keep away from live Vox."

/datum/crafting_recipe/food/fried_vox
	name = "Kentucky Fried Vox"
	reqs = list(
		/obj/item/food/meat/slab/human/mutant/vox = 1,
		/obj/item/stack/sheet/animalhide/vox = 1,
	)
	result = /obj/item/food/fried_vox
	category = CAT_MEAT

// Medical and chemistry

/obj/item/reagent_containers/blood/vox
	blood_type = BLOOD_TYPE_VOX

/datum/reagent/mutationtoxin/vox
	name = "Vox Mutation Toxin"
	description = "A shrieking toxin."
	color = "#5EFF3B"
	race = /datum/species/vox
	taste_description = "dust and quills"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/// Oxygen is as toxic to a vox in the blood as it is in the lungs.
/datum/reagent/oxygen/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!isvox(affected_mob))
		return
	affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, FALSE)
	. = TRUE
	holder?.remove_reagent(type, metabolization_rate * seconds_per_tick)

/obj/item/organ/external/tail/vox/fake
	name = "fabricated vox tail"
	desc = "A fabricated severed vox tail. This one's made of synthflesh."

// Research and cargo

/datum/design/vox_tank
	name = "Vox Nitrogen Tank"
	id = "vox_tank"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 8)
	build_path = /obj/item/tank/internals/emergency_oxygen/vox/empty
	category = list(
		RND_CATEGORY_HACKED,
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_GAS_TANKS,
	)

/datum/bounty/item/medical/vox_tail
	name = "Vox Tail"
	description = "Negotiations have broken down between Central Command and a group of Vox raiders. Ship us a vox tail so we can show them we mean business."
	reward = 3000
	wanted_types = list(/obj/item/organ/external/tail/vox = TRUE)

/datum/export/organ/vox_tail
	cost = 300
	unit_name = "vox tail"
	export_types = list(/obj/item/organ/external/tail/vox)

/datum/export/stack/skin/vox
	cost = 2500
	unit_name = "vox hide"
	export_types = list(/obj/item/stack/sheet/animalhide/vox)
