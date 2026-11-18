///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

///Checks if the wings can soften short falls
/obj/item/organ/external/wings/proc/can_soften_fall()
	return TRUE

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_BEHIND = BODY_BEHIND_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER,
	)
	feature_key = "wings"
	overlay_flags = parent_type::overlay_flags | LIMB_OVERLAY_WIDE_ICON | LIMB_OVERLAY_TALL_ICON

/datum/bodypart_overlay/mutant/wings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE
	if(human.obscured_slots & HIDEMUTWINGS)
		return FALSE
	if(!(human.obscured_slots & HIDEJUMPSUIT))
		return TRUE
	if(human.wear_suit?.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE

