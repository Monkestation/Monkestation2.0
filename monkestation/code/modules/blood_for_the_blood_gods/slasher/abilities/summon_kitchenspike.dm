/datum/action/cooldown/slasher/summon_kitchenspike
	name = "Summon Kitchen Spike"
	desc = "Summon a spike to hang up your victims."

	button_icon_state = "summon_machete"

	cooldown_time = 600 SECONDS

/datum/action/cooldown/slasher/summon_kitchenspike/Activate(atom/target)
	. = ..()
	if(owner.stat == DEAD)
		return
	var/turf/spikespot = get_turf(target)
	if(!isspaceturf(spikespot) && !spikespot.density)
		return
	if(do_after(target, 5 SECONDS))
		new /obj/structure/kitchenspike

