///Tail parent, it doesn't do very much.
/obj/item/organ/external/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"

	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_TAIL

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail

	dna_block = DNA_TAIL_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	///Does this tail have a wagging sprite, and is it currently wagging?
	var/wag_flags = NONE
	///The original owner of this tail
	var/original_owner //Yay, snowflake code!

/obj/item/organ/external/tail/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(.)
		RegisterSignal(receiver, COMSIG_ORGAN_WAG_TAIL, PROC_REF(wag))
		original_owner ||= WEAKREF(receiver)

		receiver.clear_mood_event("tail_lost")
		receiver.clear_mood_event("tail_balance_lost")

		if(IS_WEAKREF_OF(receiver, original_owner))
			receiver.clear_mood_event("wrong_tail_regained")
		else if(type in receiver.dna.species.external_organs)
			receiver.add_mood_event("wrong_tail_regained", /datum/mood_event/tail_regained_wrong)

/obj/item/organ/external/tail/Remove(mob/living/carbon/organ_owner, special, moving)
	if(wag_flags & WAG_WAGGING)
		wag(FALSE)

	return ..()

/obj/item/organ/external/tail/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, COMSIG_ORGAN_WAG_TAIL)

	if(!special && (type in organ_owner.dna?.species.external_organs))
		organ_owner.add_mood_event("tail_lost", /datum/mood_event/tail_lost)
		organ_owner.add_mood_event("tail_balance_lost", /datum/mood_event/tail_balance_lost)


/obj/item/organ/external/tail/proc/wag(mob/user, start = TRUE, stop_after = 0)
	if(!(wag_flags & WAG_ABLE))
		return

	if(start)
		start_wag()
		if(stop_after)
			addtimer(CALLBACK(src, PROC_REF(wag), FALSE), stop_after, TIMER_STOPPABLE|TIMER_DELETE_ME)
	else
		stop_wag()
	owner.update_body_parts()
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.update_mutant_bodyparts()

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/start_wag()
	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags |= WAG_WAGGING
	accessory.wagging = TRUE

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/stop_wag()
	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags &= ~WAG_WAGGING
	accessory.wagging = FALSE

///Tail parent type (which is MONKEEEEEEEEEEE by default), with wagging functionality
/datum/bodypart_overlay/mutant/tail
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
	)
	feature_key = "tail_monkey"
	/// Tracks if it's currently wagging or not
	var/wagging = FALSE
	/// If TRUE the tail is shown when over supported suits like space suits
	var/mesh_in_suits = FALSE

/datum/bodypart_overlay/mutant/tail/get_base_icon_state()
	return "[wagging ? "wagging_" : ""][sprite_datum.icon_state]" //add the wagging tag if we be wagging

/datum/bodypart_overlay/mutant/tail/get_global_feature_list()
	return GLOB.tails_list_human

/datum/bodypart_overlay/mutant/tail/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if(human.obscured_slots & HIDETAIL)
		return FALSE
	if(!(human.obscured_slots & HIDEJUMPSUIT))
		return TRUE
	if(!mesh_in_suits)
		return FALSE
	if(!(locate(/datum/bodypart_texture/mesh) in bodypart_owner.bodypart_textures))
		return FALSE
	return TRUE

/obj/item/organ/external/tail/cat
	name = "tail"
	preference = "feature_human_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cat

	wag_flags = WAG_ABLE

///Cat tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/cat
	feature_key = "tail_cat"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/cat/get_global_feature_list()
	return GLOB.tails_list_human

/obj/item/organ/external/tail/monkey
	name = "monkey tail"
	preference = "feature_monkey_tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/monkey

	dna_block = null

///Monkey tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/monkey
	feature_key = "tail_monkey"

/datum/bodypart_overlay/mutant/tail/monkey/get_global_feature_list()
	return GLOB.tails_list_monkey

/obj/item/organ/external/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	preference = "feature_lizard_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/lizard

	wag_flags = WAG_ABLE
	dna_block = DNA_LIZARD_TAIL_BLOCK
	///A reference to the paired_spines, since for some fucking reason tail spines are tied to the spines themselves.
	var/obj/item/organ/external/spines/paired_spines

/obj/item/organ/external/tail/lizard/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(.)
		paired_spines = ownerlimb.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES)
		paired_spines?.paired_tail = src

/obj/item/organ/external/tail/lizard/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	if(paired_spines)
		paired_spines.paired_tail = null
		paired_spines = null

/obj/item/organ/external/tail/lizard/start_wag()
	if(paired_spines)
		var/datum/bodypart_overlay/mutant/spines/accessory = paired_spines.bodypart_overlay
		accessory.wagging = TRUE
	return ..()

/obj/item/organ/external/tail/lizard/stop_wag()
	if(paired_spines)
		var/datum/bodypart_overlay/mutant/spines/accessory = paired_spines.bodypart_overlay
		accessory.wagging = FALSE
	return ..()

///Lizard tail bodypart overlay datum
/datum/bodypart_overlay/mutant/tail/lizard
	feature_key = "tail_lizard"
	mesh_in_suits = TRUE

/datum/bodypart_overlay/mutant/tail/lizard/get_global_feature_list()
	return GLOB.tails_list_lizard

/obj/item/organ/external/tail/lizard/fake
	name = "fabricated lizard tail"
	desc = "A fabricated severed lizard tail. This one's made of synthflesh. Probably not usable for lizard wine."


/// end of lizard stuff

/obj/item/organ/external/tail/shadekin
	name = "shadekin tail"
	desc = "A fluffy shadekin tail."
	preference = "feature_shadekin_tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/shadekin

/datum/bodypart_overlay/mutant/tail/shadekin
	feature_key = "tail_shadekin"

/datum/bodypart_overlay/mutant/tail/shadekin/get_global_feature_list()
	return GLOB.tails_list_shadekin

/obj/item/organ/external/tail/vox
	name = "vox tail"
	desc = "A severed vox tail. Somewhere, no doubt, a vox hater is very pleased with themselves."
	icon = 'icons/mob/human/species/vox/tails.dmi'
	icon_state = "m_tail_vox_lime_BEHIND"
	preference = "feature_vox_tail_markings"
	dna_block = DNA_VOX_TAIL_MARKINGS_BLOCK
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/vox

/obj/item/organ/external/tail/vox/Initialize(mapload, accessory_type)
	. = ..()
	if(accessory_type || !loc)
		return
	// Spawned on its own (loot, the limbgrower): plain and lime, until it's first worn
	bodypart_overlay.set_appearance(/datum/sprite_accessory/vox_tail_markings/plain)
	bodypart_overlay.draw_color = null
	bodypart_overlay.imprint_on_next_insertion = TRUE
	update_appearance()

/obj/item/organ/external/tail/vox/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!.)
		return
	var/datum/bodypart_overlay/mutant/tail/vox/vox_overlay = bodypart_overlay
	vox_overlay.original_owner = original_owner

/obj/item/organ/external/tail/vox/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	color = null // our draw color is the color of the markings, the tail sprite has its own colors
	update_appearance()

/// Someone else's tail keeps looking like theirs
/obj/item/organ/external/tail/vox/mutate_feature(features, mob/living/carbon/human/human)
	if(original_owner && !IS_WEAKREF_OF(human, original_owner))
		return
	return ..()

/// A severed tail looks like the tail it was: skin tone and markings
/obj/item/organ/external/tail/vox/update_icon_state()
	var/datum/bodypart_overlay/mutant/tail/vox/vox_overlay = bodypart_overlay
	icon_state = "m_tail_vox_[vox_overlay?.skin_tone || VOX_DEFAULT_SKIN_TONE]_BEHIND"
	return ..()

/obj/item/organ/external/tail/vox/update_overlays()
	. = ..()
	var/datum/bodypart_overlay/mutant/tail/vox/vox_overlay = bodypart_overlay
	if(isnull(vox_overlay?.sprite_datum) || vox_overlay.sprite_datum.icon_state == "plain")
		return
	var/mutable_appearance/markings = mutable_appearance(vox_overlay.sprite_datum.icon, "m_vox_tail_markings_[vox_overlay.sprite_datum.icon_state]_BEHIND")
	markings.color = color_matrix_additive(vox_overlay.draw_color)
	. += markings

/// The tail is drawn in the skin tone of the body it grew on, with its markings (the sprite accessory) on top.
/// The markings sprites are dark, the secondary mutant color gets added to them.
/datum/bodypart_overlay/mutant/tail/vox
	feature_key = "vox_tail_markings"
	palette = /datum/color_palette/generic_colors
	palette_key = MUTANT_COLOR_SECONDARY
	/// The skin tone of the body this tail grew on, which it keeps when transplanted or severed
	var/skin_tone = VOX_DEFAULT_SKIN_TONE
	/// The mob this tail grew on, see /obj/item/organ/external/tail/var/original_owner
	var/datum/weakref/original_owner

/datum/bodypart_overlay/mutant/tail/vox/get_global_feature_list()
	return GLOB.vox_tail_markings_list

/// Whether the given limb is on the body this tail grew on, so the tail follows that body's looks
/datum/bodypart_overlay/mutant/tail/vox/proc/on_original_body(obj/item/bodypart/limb)
	return !limb?.owner || !original_owner || IS_WEAKREF_OF(limb.owner, original_owner)

/datum/bodypart_overlay/mutant/tail/vox/inherit_color(obj/item/bodypart/ownerlimb, force)
	if(draw_color && !on_original_body(ownerlimb))
		return FALSE // someone else's tail keeps its markings color
	return ..()

/datum/bodypart_overlay/mutant/tail/vox/get_image(obj/item/bodypart/limb, layer_index, layer_real, layer_name)
	if(limb && on_original_body(limb))
		skin_tone = limb.get_drawn_limb_style() || VOX_DEFAULT_SKIN_TONE
	var/wagging_prefix = wagging ? "wagging_" : ""
	var/mutable_appearance/tail = mutable_appearance('icons/mob/human/species/vox/tails.dmi', "m_tail_vox_[wagging_prefix][skin_tone]_[layer_index]", layer = layer_real)
	if(sprite_datum.icon_state != "plain")
		var/mutable_appearance/markings = mutable_appearance(sprite_datum.icon, "m_[wagging_prefix]vox_tail_markings_[sprite_datum.icon_state]_[layer_index]")
		markings.color = color_matrix_additive(draw_color)
		tail.overlays += markings
	return tail

/datum/bodypart_overlay/mutant/tail/vox/color_image(image/overlay, obj/item/bodypart/limb, layer_index, key_name)
	return // the markings are colored in get_image(), the tail itself isn't

/datum/bodypart_overlay/mutant/tail/vox/generate_icon_cache()
	. = ..()
	. += skin_tone

/obj/item/organ/external/tail/vox/fake
	name = "fabricated vox tail"
	desc = "A fabricated severed vox tail. This one's made of synthflesh."
