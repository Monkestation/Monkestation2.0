/datum/outfit/myststranger
	name = "A Mysterious Stranger"

	id = /obj/item/card/id/advanced/debug
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/myststranger
	backpack_contents = list(
		/obj/item/melee/energy/axe = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/backpack/deforest_surgical/stocked = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/bodybag/bluespace = 1,
		/obj/item/gun/ballistic/revolver/lone_wanderer = 1
	)
	belt = /obj/item/defibrillator/compact/combat/loaded/nanotrasen
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/debug
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots/advance
	mask = /obj/item/clothing/mask/chameleon

	r_pocket = /obj/item/reagent_containers/medipen/advanced/blood_loss
	l_pocket = /obj/item/reagent_containers/medipen/ekit

	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/myststranger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = "Mysterious Stranger"
	W.assignment = "???"
	W.update_label()
	W.update_icon()
	var/obj/item/implant/vanish/impl = new /obj/item/implant/vanish(H)//poof
	impl.implant(H, null, silent = TRUE)

/obj/item/implant/vanish
	name = "V.A.N.I.S.H. implant"
	desc = "To go without leaving a corpse. That is the way of the Gerudo."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "supermatter_sliver_pulse"
	actions_types = list(/datum/action/item_action/dust_implant)
	var/popup = FALSE // is the window open?
	var/active = FALSE

/obj/item/implant/vanish/proc/on_death(datum/source)
	SIGNAL_HANDLER
	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish.
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/item/implant/vanish,activate), "death")

/obj/item/implant/vanish/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> V.A.N.I.S.H. Insurance Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Highly unstable.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> To go without leaving a corpse. That is the way of the Gerudo.<BR>
				<b>Special Features:</b> Self Immolation<BR>
				"}
	return dat

/obj/item/implant/vanish/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to well, VANISH!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	to_chat(imp_in, "<span class='notice'>Your V.A.N.I.S.H. implant activates!</span>")

	if(imp_in)
		imp_in.investigate_log("has been QDEL'D by a V.A.N.I.S.H. Implant.", INVESTIGATE_DEATHS)
		QDEL_IN(imp_in,0.1 SECONDS)
		qdel(src)
		return

/obj/item/implant/vanish/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/vanish/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implanter/vanish
	name = "implanter (V.A.N.I.S.H.)"
	imp_type = /obj/item/implant/vanish

/obj/item/implantcase/vanish
	name = "implant case - 'V.A.N.I.S.H.'"
	desc = "A glass case containing a V.A.N.I.S.H. implant."
	imp_type = /obj/item/implant/vanish

/datum/action/item_action/vanish_implant
	check_flags = NONE
	name = "Activate V.A.N.I.S.H. Implant"
