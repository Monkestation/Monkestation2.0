/obj/item/mmi/posibrain/ipc
	name = "compact positronic brain"
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "posibrain"
	base_icon_state = "posibrain"

	begin_activation_message = "<span class='notice'>You carefully locate the manual activation switch and start the compact positronic brain's boot process.</span>"
	success_message = "<span class='notice'>The compact positronic brain pings, and its lights start flashing. Success!</span>"
	fail_message = "<span class='notice'>The compact positronic brain buzzes quietly, and the golden lights fade away. Perhaps you could try again?</span>"
	new_mob_message = "<span class='notice'>The compact positronic brain chimes quietly.</span>"
	recharge_message = "<span class='warning'>The compact positronic brain isn't ready to activate again yet! Give it some time to recharge.</span>"

/obj/item/mmi/posibrain/ipc/transfer_personality(mob/candidate)
	if(candidate)
		var/obj/item/organ/internal/brain/synth/ipc_brain = new /obj/item/organ/internal/brain/synth(get_turf(src))
		ipc_brain.brainmob = new /mob/living/brain(ipc_brain)
		if(candidate.mind)
			candidate.mind.transfer_to(ipc_brain.brainmob)
		else
			ipc_brain.brainmob.key = candidate.key
		visible_message(success_message)
		playsound(src, 'sound/machines/ping.ogg', 15, TRUE)
		ipc_brain.brain_gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)
		qdel(src)

/obj/item/mmi/posibrain/ipc/update_icon_state()
	. = ..()
	if(searching)
		icon = 'icons/obj/assemblies/assemblies.dmi'
		icon_state = "[base_icon_state]-searching"
		return
	if(brainmob?.key)
		icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
		icon_state = "posibrain-ipc"
		return
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "[base_icon_state]"
	return
