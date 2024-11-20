/obj/item/implant/dust
	name = "self immolation implant"
	desc = "Dust to dust."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_sliver_pulse"
	actions_types = list(/datum/action/item_action/duster_implant)
	var/popup = FALSE // is the window open?
	var/active = FALSE

/obj/item/implant/dust/proc/on_death(datum/source)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish.
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/dust/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-81 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Highly unstable.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact supermatter fragment surrounded in a protective bluespace capsule that releases upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Self Immolation<BR>
				"}
	return dat

obj/item/implant/dust/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to self immolate!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(get_turf(imp_in))], with cause of [cause].")

	if(imp_in)
		imp_in.investigate_log("has been dusted by a self immolation implant.", INVESTIGATE_DEATHS)
		imp_in.dust(just_ash)
		qdel(src)
		return


/obj/item/implant/dust/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implanter/dust
	name = "implanter (self immolation)"
	imp_type = /obj/item/implant/dust

/obj/item/implantcase/dust
	name = "implant case - 'Self Immolation'"
	desc = "A glass case containing a self immolation implant."
	imp_type = /obj/item/implant/dust

/datum/action/item_action/dust_implant
	check_flags = NONE
	name = "Activate Self Immolation Implant"
