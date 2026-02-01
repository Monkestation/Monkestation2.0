/obj/structure/blob/special/node/core
	name = "blob core"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	max_integrity = BLOB_CORE_MAX_HP
	armor_type = /datum/armor/blob_core
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	resistance_flags = LAVA_PROOF
	strong_reinforce_range = BLOB_CORE_STRONG_REINFORCE_RANGE
	reflector_reinforce_range = BLOB_CORE_REFLECTOR_REINFORCE_RANGE
	claim_range = BLOB_CORE_CLAIM_RANGE
	pulse_range = BLOB_CORE_PULSE_RANGE
	expand_range = BLOB_CORE_EXPAND_RANGE
	overlay_icon_state = "blob_core_overlay"

/datum/armor/blob_core
	fire = 75
	acid = 90

/obj/structure/blob/special/node/core/Initialize(mapload, datum/team/blob/owning_team)
	if(owning_team)
		SSpoints_of_interest.make_point_of_interest(src)
	AddComponent(/datum/component/stationloving, FALSE, TRUE)
	AddElement(/datum/element/blocks_explosives)
	return ..()

/obj/structure/blob/special/node/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/special/node/core/ex_act(severity, target)
	var/damage = 10 * (severity + 1) //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, BOMB, FALSE)
