/obj/structure/blob/special/resource
	name = "resource blob"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blob_resource"
	desc = "A thin spire of slightly swaying tendrils."
	max_integrity = BLOB_RESOURCE_MAX_HP
	point_return = BLOB_REFUND_RESOURCE_COST
	resistance_flags = LAVA_PROOF
	armor_type = /datum/armor/structure_blob/resource
	point_cost = 40
	///the next world.time to give resources
	var/resource_delay = 0
	///list of soverminds gaining resources from us
	var/list/give_to

/datum/armor/structure_blob/resource
	laser = 25

/obj/structure/blob/special/resource/set_owner(datum/team/blob/new_owner)
	. = ..()
	if(. == FALSE)
		return

	if(new_owner)
		give_to = list(new_owner.main_overmind)
	else
		give_to = null

/obj/structure/blob/special/resource/scannerreport()
	return "Gradually supplies the blob with resources, increasing the rate of expansion."

/obj/structure/blob/special/resource/be_pulsed()
	. = ..()
	if(resource_delay > world.time)
		return

	resource_delay = world.time + BLOB_RESOURCE_GATHER_DELAY
	flick("blob_resource_glow", src)
	if(length(give_to))
		resource_delay += ((length(blob_team.all_blobs_by_type[src.type])) * BLOB_RESOURCE_GATHER_ADDED_DELAY)
		for(var/mob/eye/blob/overmind in give_to)
			overmind.add_points(BLOB_RESOURCE_GATHER_AMOUNT)
			balloon_alert(overmind, "+[BLOB_RESOURCE_GATHER_AMOUNT] resource\s") //4 seconds plus a quarter second for each resource blob the overmind has
