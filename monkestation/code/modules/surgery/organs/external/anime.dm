/obj/item/organ/external/anime_head
	name = "anime implants"
	desc = "An anime implant fitted for a persons head."
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANIME_HEAD

	preference = "feature_anime_top"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_head

/datum/bodypart_overlay/mutant/anime_head
	color_source = ORGAN_COLOR_ANIME
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_top"

/datum/bodypart_overlay/mutant/anime_head/get_global_feature_list()
	return GLOB.anime_top_list

/datum/bodypart_overlay/mutant/anime_head/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/anime_head/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.head?.flags_inv & HIDEEARS)
		return FALSE
	return ..()

/obj/item/organ/external/anime_middle
	name = "anime implants"
	desc = "An anime implant fitted for a persons chest."
	icon_state = "antennae"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_ANIME_CHEST

	preference = "feature_anime_middle"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_middle

/datum/bodypart_overlay/mutant/anime_middle
	color_source = ORGAN_COLOR_ANIME
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_middle"

/datum/bodypart_overlay/mutant/anime_middle/get_global_feature_list()
	return GLOB.anime_middle_list

/datum/bodypart_overlay/mutant/anime_middle/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/anime_middle/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.wear_suit?.flags_inv & HIDEJUMPSUIT)
		return FALSE
	return ..()

/obj/item/organ/external/anime_bottom
	name = "anime implants"
	desc = "An anime implant fitted for a persons lower half."
	icon_state = "antennae"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_ANIME_BOTTOM

	preference = "feature_anime_bottom"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_bottom

/datum/bodypart_overlay/mutant/anime_bottom
	color_source = ORGAN_COLOR_ANIME
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_bottom"

/datum/bodypart_overlay/mutant/anime_bottom/get_global_feature_list()
	return GLOB.anime_bottom_list

/datum/bodypart_overlay/mutant/anime_bottom/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/anime_bottom/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.wear_suit?.flags_inv & HIDEJUMPSUIT)
		return FALSE
	return ..()

/obj/item/organ/external/anime_halo
	name = "anime halo projector"
	desc = "A holoprojector fitted for a persons head."
	icon_state = "antennae"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_ANIME_HALO
	organ_flags = ORGAN_ROBOTIC

	preference = "feature_anime_halo"

	bodypart_overlay = /datum/bodypart_overlay/mutant/anime_halo

/obj/item/organ/external/anime_halo/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOB_STATCHANGE, PROC_REF(update_halo_on_death))

/obj/item/organ/external/anime_halo/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_STATCHANGE)

/obj/item/organ/external/anime_halo/proc/update_halo_on_death(mob/living/carbon/halo_owner, new_owner_stat, old_owner_stat)
	SIGNAL_HANDLER
	
	if((new_owner_stat == DEAD) || (old_owner_stat == DEAD))
		halo_owner.update_body_parts()

/datum/bodypart_overlay/mutant/anime_halo
	color_source = ORGAN_COLOR_ANIME_HALO
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "anime_halo"

/datum/bodypart_overlay/mutant/anime_halo/get_global_feature_list()
	return GLOB.anime_halo_list

/datum/bodypart_overlay/mutant/anime_halo/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/anime_halo/get_emissive_overlay(layer, obj/item/bodypart/limb)
	if(!sprite_datum.is_emissive)
		return
	layer = bitflag_to_layer(layer)
	var/mutable_appearance/halo_emissive_overlay = emissive_appearance_copy(get_image(layer, limb), limb)
	halo_emissive_overlay.pixel_y = 0
	halo_emissive_overlay.pixel_z = -16
	return halo_emissive_overlay

/datum/bodypart_overlay/mutant/anime_halo/can_draw_on_bodypart(mob/living/carbon/human/human)
	if((human.head?.flags_inv & HIDEEARS) || (human.stat == DEAD))
		return FALSE
	return ..()
