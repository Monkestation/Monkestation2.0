/obj/item/organ/external/tail/cetanoid
	name = "cetanoid tail"
	desc = "A severed cetanoid tail."
	preference = "feature_cetanoid_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cetanoid
	var/no_suit = TRUE

/obj/item/organ/external/tail/cetanoid/on_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(speed_boost))

/obj/item/organ/external/tail/cetanoid/on_remove(mob/living/carbon/organ_owner)
	. = ..()
	remove_speed_boost(organ_owner) //fuck you you dont get an infinite speed boost by removing your tail while underwater
	UnregisterSignal(organ_owner, COMSIG_MOVABLE_PRE_MOVE)

/obj/item/organ/external/tail/cetanoid/proc/speed_boost()
	SIGNAL_HANDLER

	var/turf/cur_turf = get_turf(owner)
	if(!cur_turf || !cur_turf.liquids)
		return

	var/depth = cur_turf.liquids.liquid_state
	if(depth >= LIQUID_STATE_SHOULDERS && no_suit && !owner.usable_legs)
		add_speed_boost(owner)
	else
		remove_speed_boost(owner)

/obj/item/organ/external/tail/cetanoid/proc/add_speed_boost(mob/living/carbon/target)
	target.add_movespeed_modifier(/datum/movespeed_modifier/cetanoid_swimming)
	target.remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
	REMOVE_TRAIT(target, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

/obj/item/organ/external/tail/cetanoid/proc/remove_speed_boost(mob/living/carbon/target)
	target.remove_movespeed_modifier(/datum/movespeed_modifier/cetanoid_swimming)
	target.set_usable_legs(target.usable_legs) //does this to reset the limbless movespeed modifier, fucking hate this.

/datum/bodypart_overlay/mutant/tail/cetanoid
	feature_key = "cetanoid_tail"

/datum/bodypart_overlay/mutant/tail/cetanoid/get_global_feature_list()
	return GLOB.cetanoid_tail_list

/obj/item/organ/external/frills/cetanoid
	name = "cetanoid frills"
	preference = "feature_cetanoid_frills"

	bodypart_overlay = /datum/bodypart_overlay/mutant/frills/cetanoid

/datum/bodypart_overlay/mutant/frills/cetanoid
	layers = EXTERNAL_ADJACENT
	feature_key = "cetanoid_frills"

/datum/bodypart_overlay/mutant/frills/cetanoid/get_global_feature_list()
	return GLOB.cetanoid_frills_list

/obj/item/organ/external/cetanoid_fins
	name = "cetanoid fins"
	icon_state = "spines"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_SPINES

	preference = "feature_cetanoid_fins"

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	bodypart_overlay = /datum/bodypart_overlay/mutant/cetanoid_fins

/datum/bodypart_overlay/mutant/cetanoid_fins
	layers = EXTERNAL_ADJACENT|EXTERNAL_BEHIND
	feature_key = "cetanoid_fins"

/datum/bodypart_overlay/mutant/cetanoid_fins/get_global_feature_list()
	return GLOB.cetanoid_fins_list

/datum/bodypart_overlay/mutant/cetanoid_fins/can_draw_on_bodypart(mob/living/carbon/human/human)
	. = ..()
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
