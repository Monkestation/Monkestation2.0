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

// Monkestation moved the human scream to /datum/emote/living/scream (the human one is commented out), so hook that.
/datum/emote/living/scream/select_message_type(mob/user, msg, intentional)
	. = ..()
	if(isvox(user) && . == message && !istype(src, /datum/emote/living/scream/screech))
		return "shrieks!"

// Suicide messages

/// Extra bare-handed (combat mode) suicide messages for this species, already formatted for the suicider.
/datum/species/proc/get_suicide_messages(mob/living/carbon/human/suicider)
	return list()

/datum/species/vox/get_suicide_messages(mob/living/carbon/human/suicider)
	return list(
		"[suicider] is jamming [suicider.p_their()] claws into [suicider.p_their()] eye sockets!",
		"[suicider] is deeply inhaling oxygen!",
	)

// Quills in place of hair: mirrors and razors

/**
 * Changes the (facial) quills of a vox.
 * Quills are external organs, so this adds, restyles or removes the organ as needed.
 */
/mob/living/carbon/human/proc/set_vox_quills(new_style, facial = FALSE, update = TRUE)
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
	if(update)
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

/**
 * Magic mirror race change for vox: skin tone, body markings and tail markings, each with its color.
 * Yogstation offers only the two marking colors (they are its mutant colors). Cancelling a choice keeps the current one.
 * The caller redraws the body, which makes the limbs and the tail take up the new features.
 */
/obj/structure/mirror/proc/change_vox_looks(mob/living/carbon/human/vox)
	var/list/features = vox.dna.features
	var/new_skin_tone = tgui_input_list(vox, "Choose your skin tone", "Race change", GLOB.vox_skin_tones, features["vox_skin_tone"])
	if(new_skin_tone)
		features["vox_skin_tone"] = new_skin_tone
		vox.dna.update_uf_block(DNA_VOX_SKIN_TONE_BLOCK)

	var/new_body_markings = tgui_input_list(vox, "Choose your body markings", "Race change", GLOB.vox_body_markings_list, features["vox_body_markings"])
	if(new_body_markings)
		features["vox_body_markings"] = new_body_markings
		vox.dna.update_uf_block(DNA_VOX_BODY_MARKINGS_BLOCK)
	if(features["vox_body_markings"] && features["vox_body_markings"] != SPRITE_ACCESSORY_NONE)
		var/new_body_color = tgui_color_picker(vox, "Choose your body markings color", "Race change", features["vox_body_markings_color"])
		if(new_body_color)
			features["vox_body_markings_color"] = sanitize_hexcolor(new_body_color)
			vox.dna.update_uf_block(DNA_VOX_BODY_MARKINGS_COLOR_BLOCK)

	if(!istype(vox.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/external/tail/vox))
		return
	var/new_tail_markings = tgui_input_list(vox, "Choose your tail markings", "Race change", GLOB.vox_tail_markings_list, features["vox_tail_markings"])
	if(new_tail_markings)
		features["vox_tail_markings"] = new_tail_markings
		vox.dna.update_uf_block(DNA_VOX_TAIL_MARKINGS_BLOCK)
	if(features["vox_tail_markings"] && features["vox_tail_markings"] != SPRITE_ACCESSORY_NONE)
		var/new_tail_color = tgui_color_picker(vox, "Choose your tail markings color", "Race change", features["vox_tail_markings_color"])
		if(new_tail_color)
			features["vox_tail_markings_color"] = sanitize_hexcolor(new_tail_color)
			vox.dna.update_uf_block(DNA_VOX_TAIL_MARKINGS_COLOR_BLOCK)

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

/datum/reagent/mutationtoxin/vox/on_mob_life(mob/living/carbon/human/affected_mob, seconds_per_tick, times_fired)
	var/about_to_turn = current_cycle >= cycles_to_turn
	. = ..()
	if(about_to_turn && isvox(affected_mob))
		to_chat(affected_mob, span_danger("The pain subsides. You feel... beaked."))

/datum/chemical_reaction/slime/slimevox
	desc = "Makes 1u of vox mutation toxin."
	results = list(/datum/reagent/mutationtoxin/vox = 1)
	required_reagents = list(/datum/reagent/nitrogen = 1)
	required_container = /obj/item/slime_extract/green

/// Oxygen is as toxic to a vox in the blood as it is in the lungs. Like Yogstation, this replaces oxygen's normal metabolism.
/datum/species/vox/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent_tick))

/datum/species/vox/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	UnregisterSignal(human, COMSIG_MOB_REAGENT_TICK)
	return ..()

/datum/species/vox/proc/on_reagent_tick(mob/living/carbon/human/source, datum/reagent/chem, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(chem.type != /datum/reagent/oxygen)
		return NONE
	// Yogstation: 1 toxin damage and 0.2u removed per 2 second tick.
	source.adjustToxLoss(0.5 * seconds_per_tick)
	source.reagents.remove_reagent(chem.type, 0.1 * seconds_per_tick)
	return COMSIG_MOB_STOP_REAGENT_TICK

/obj/item/organ/external/tail/vox/fake
	name = "fabricated vox tail"
	desc = "A fabricated severed vox tail. This one's made of synthflesh."

// Limbgrower organs, on a design disk researched with the other xeno-organ disks.

/datum/design/vox_tail
	name = "Vox Tail"
	id = "voxtail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/external/tail/vox/fake
	category = list(SPECIES_VOX)

/datum/design/vox_tongue
	name = "Vox Tongue"
	id = "voxtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/tongue/vox
	category = list(SPECIES_VOX)

/datum/design/vox_eyes
	name = "Vox Eyes"
	id = "voxeyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/eyes/vox
	category = list(SPECIES_VOX)

/datum/design/vox_liver
	name = "Vox Liver"
	id = "voxliver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/liver/vox
	category = list(SPECIES_VOX)

/datum/design/vox_lungs
	name = "Vox Lungs"
	id = "voxlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 10)
	build_path = /obj/item/organ/internal/lungs/vox
	category = list(SPECIES_VOX)

/obj/item/disk/design_disk/limbs/vox
	name = "Vox Limb Design Disk"
	limb_designs = list(/datum/design/vox_tail, /datum/design/vox_tongue, /datum/design/vox_eyes, /datum/design/vox_liver, /datum/design/vox_lungs)

/datum/design/limb_disk/vox
	name = "Vox Limb Design Disk"
	desc = "Contains designs for vox organs for the limbgrower - Vox tail, tongue, eyes, liver, and lungs."
	id = "limbdesign_vox"
	build_path = /obj/item/disk/design_disk/limbs/vox

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
	reward = CARGO_CRATE_VALUE * 6 // Yogstation prices vox like its lizards, so these match Monkestation's lizard prices
	wanted_types = list(/obj/item/organ/external/tail/vox = TRUE)

/datum/export/organ/external/tail/vox
	cost = CARGO_CRATE_VALUE * 1.25
	unit_name = "vox tail"
	export_types = list(/obj/item/organ/external/tail/vox)

/datum/export/stack/skin/vox
	cost = CARGO_CRATE_VALUE * 0.75
	unit_name = "vox hide"
	export_types = list(/obj/item/stack/sheet/animalhide/vox)
