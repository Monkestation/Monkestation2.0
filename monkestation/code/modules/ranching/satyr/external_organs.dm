/obj/item/organ/external/satyr_fluff
	name = "satyr fluff"
	desc = "A goat's fur"
	icon_state = "satyr_fluff"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_fluff"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_FLUFF

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_fluff
	var/datum/action/cooldown/mob_cooldown/dash/headbutt/headbutt

/obj/item/organ/external/satyr_fluff/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	headbutt = new
	headbutt.Grant(receiver)

/obj/item/organ/external/satyr_fluff/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	if(headbutt)
		headbutt.Remove(organ_owner)
		qdel(headbutt)

/datum/bodypart_overlay/mutant/satyr_fluff
	layers = EXTERNAL_ADJACENT //| EXTERNAL_FRONT
	feature_key = "satyr_fluff"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/satyr_fluff/get_global_feature_list()
	return GLOB.satyr_fluff_list

/datum/bodypart_overlay/mutant/satyr_fluff/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_fluff/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE


/obj/item/organ/external/horns/satyr_horns
	name = "satyr horns"
	desc = "A goat's horns"
	icon_state = "satyr_horns"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_satyr_horns"

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/satyr_horns

/datum/bodypart_overlay/mutant/satyr_horns
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	feature_key = "satyr_horns"

/datum/bodypart_overlay/mutant/satyr_horns/get_global_feature_list()
	return GLOB.satyr_horns_list

/datum/bodypart_overlay/mutant/satyr_horns/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/satyr_horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

//ONI STUFF

/obj/item/organ/external/oni_tail
	name = "oni tail"
	desc = "An Oni's tail. Put it back!"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_oni_tail"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_TAIL

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/oni_tail

/datum/bodypart_overlay/mutant/oni_tail
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	feature_key = "oni_tail"
	color_source = DNA_MUTANT_COLOR_BLOCK

/datum/bodypart_overlay/mutant/oni_tail/get_global_feature_list()
	return GLOB.oni_tail_list

/datum/bodypart_overlay/mutant/oni_tail/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/oni_tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/oni_wings
	name = "oni wings"
	desc = "An Oni's wings. Put it back!"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_oni_wings"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/oni_wings

/datum/bodypart_overlay/mutant/oni_wings
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT
	feature_key = "oni_wings"
	color_source = DNA_MUTANT_COLOR_BLOCK

/datum/bodypart_overlay/mutant/oni_wings/get_global_feature_list()
	return GLOB.oni_wings_list

/datum/bodypart_overlay/mutant/oni_wings/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/oni_wings/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE

/obj/item/organ/external/oni_horns
	name = "oni horns"
	desc = "An Oni's horns. Put them back!"
	icon_state = ""
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_oni_horns"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_HORNS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/oni_horns

/datum/bodypart_overlay/mutant/oni_horns
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	feature_key = "oni_horns"
	color_source = DNA_MUTANT_COLOR_BLOCK

/datum/bodypart_overlay/mutant/oni_horns/get_global_feature_list()
	return GLOB.oni_horns_list

/datum/bodypart_overlay/mutant/oni_horns/get_base_icon_state()
	return sprite_datum.icon_state

/datum/bodypart_overlay/mutant/oni_horns/can_draw_on_bodypart(mob/living/carbon/human/human)
	return TRUE
