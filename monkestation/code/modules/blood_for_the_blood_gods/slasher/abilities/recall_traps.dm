/datum/action/cooldown/slasher/recall_traps
	name = "Recall Traps"
	desc = "Recall all of your traps to your belt, replacing any destroyed traps."
	button_icon = 'icons/obj/restraints.dmi'
	button_icon_state = "beartrap"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/slasher/recall_traps/Activate(atom/target)
	. = ..()
	if(owner.stat == DEAD)
		return
	var/obj/item/storage/belt/slasher/belt = owner.get_item_by_slot(ITEM_SLOT_BELT)
	if(!istype(belt))
		return
	var/datum/antagonist/slasher/slasherdatum = IS_SLASHER(owner)
	if(!slasherdatum)
		return
	for(var/obj/item/restraints/legcuffs/beartrap/slasher/trap in slasherdatum.linked_traps)
		if(trap.loc == belt)
			continue
		if(ismob(trap.loc))
			var/mob/living/carbon/trapVictim = trap.loc
			if(trapVictim.legcuffed == trap)
				qdel(trap)
		if(QDELETED(trap))
			trap = new /obj/item/restraints/legcuffs/beartrap/slasher(get_turf(owner))
			trap.set_slasher(slasherdatum)
		trap.armed = FALSE
		trap.update_appearance()
		trap.forceMove(belt)
	while(slasherdatum.linked_traps.len < 3)
		var/obj/item/restraints/legcuffs/beartrap/slasher/new_trap = new /obj/item/restraints/legcuffs/beartrap/slasher(get_turf(owner))
		new_trap.set_slasher(slasherdatum)
		new_trap.forceMove(belt)
