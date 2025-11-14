/obj/structure/blob/special/node
	name = "blob node"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	max_integrity = BLOB_NODE_MAX_HP
	health_regen = BLOB_NODE_HP_REGEN
	armor_type = /datum/armor/special_node
	point_return = BLOB_REFUND_NODE_COST
	claim_range = BLOB_NODE_CLAIM_RANGE
	pulse_range = BLOB_NODE_PULSE_RANGE
	expand_range = BLOB_NODE_EXPAND_RANGE
	resistance_flags = LAVA_PROOF

/datum/armor/special_node
	fire = 65
	acid = 90
	laser = 25

/obj/structure/blob/special/node/Initialize(mapload, datum/team/blob/owning_team)
	GLOB.blob_nodes += src
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/blob/special/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/special/node/update_icon()
	. = ..()
	color = null

/obj/structure/blob/special/node/update_overlays()
	. = ..()
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob")
	if(blob_team)
		blob_overlay.color = blob_team.blobstrain.color
		if(!legit) //depending on when this gets called we might just be able to check legit
			blob_overlay.color = blob_team.blobstrain.cached_faded_color
	. += blob_overlay
	. += mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob_node_overlay")

/obj/structure/blob/special/node/Destroy()
	GLOB.blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/special/node/process(seconds_per_tick)
	if(blob_team)
		pulse_area(blob_team, claim_range, pulse_range, expand_range)
		reinforce_area(seconds_per_tick)
