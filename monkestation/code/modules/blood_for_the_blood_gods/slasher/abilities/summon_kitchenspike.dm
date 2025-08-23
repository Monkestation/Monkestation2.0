/datum/action/cooldown/slasher/summon_kitchenspike
	name = "Summon Kitchen Spike"
	desc = "Summon a spike to hang up your victims."
	button_icon = 'icons/obj/kitchen.dmi'
	button_icon_state = "spike"

	cooldown_time = 6 SECONDS

/datum/action/cooldown/slasher/summon_kitchenspike/Activate(atom/target)
	. = ..()
	if(owner.stat == DEAD)
		return
	var/turf/spikespot = get_turf(owner)
	if(isspaceturf(spikespot) || spikespot.is_blocked_turf(exclude_mobs = TRUE))
		return
	if(do_after(owner, 5 SECONDS))
		new /obj/structure/kitchenspike(spikespot)
