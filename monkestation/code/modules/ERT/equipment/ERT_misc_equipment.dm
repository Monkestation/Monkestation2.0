/obj/item/implant/dust
	name = "self immolation implant"
	desc = "Dust to dust."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_sliver_pulse"
	actions_types = list(/datum/action/item_action/dust_implant)
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

/obj/item/implant/dust/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to disintergrate!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	var/turf/immolationturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(immolationturf)], with cause of [cause].")

	if(imp_in)
		imp_in.investigate_log("has been dusted by a self immolation implant.", INVESTIGATE_DEATHS)
		imp_in.dust()
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		qdel(src)
		return

/obj/item/implant/dust/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

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

/obj/item/mod/module/energy_shield/nanotrasen
	name = "MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		though with its' low amount of separate charges, the user remains mortal."
	shield_icon = "shield-old" //red syndicate blue nanotrasen :P

/obj/item/storage/belt/security/full/bola/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded(src)
	update_appearance()

/obj/item/clothing/mask/gas/sechailer/swat/ert
	name = "\improper emergency response team mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. This one is designed for Nanotrasen Emergency Response Teams and has an inbuilt air-freshener. Fancy!"
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	worn_icon_snouted = 'monkestation/icons/mob/clothing/species/mask_muzzled.dmi'
	icon_state = "ert"

/obj/item/storage/box/survival/ert
	name = "emergency response survival box"
	desc = "A box with the bare essentials of ensuring the survival of your team. This one is labelled to contain a double tank."
	icon_state = "ntbox"
	illustration = "ntlogo"
	internal_type = /obj/item/tank/internals/emergency_oxygen/double
	medipen_type =  /obj/item/reagent_containers/hypospray/medipen/atropine

/obj/item/storage/box/survival/ert/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/pill/patch/advanced(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/spess_knife(src) // i love this thing and i want it to be out there more
	new /obj/item/flashlight/flare(src)

/obj/item/reagent_containers/pill/patch/advanced
	name = "advanced health patch"
	desc = "Helps with brute and burn injuries while stabilizing the patient. Contains anti-toxin along with formaldehyde."
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 5, /datum/reagent/medicine/sal_acid = 5, /datum/reagent/medicine/granibitaluri = 10, /datum/reagent/medicine/c2/seiver = 5, /datum/reagent/toxin/formaldehyde = 3, /datum/reagent/medicine/coagulant = 2, /datum/reagent/medicine/epinephrine = 10)
	icon_state = "bandaid_msic" //they misspelt it

/obj/item/storage/box/rcd_upgrades
	name = "RCD upgrade diskette box"
	desc = "A box of essential RCD upgrade disks."
	illustration = "disk_kit"

/obj/item/storage/box/rcd_upgrades/PopulateContents()
	. = ..()
	new /obj/item/rcd_upgrade/simple_circuits(src)
	new /obj/item/rcd_upgrade/anti_interrupt(src)
	new /obj/item/rcd_upgrade/cooling(src)
	new /obj/item/rcd_upgrade/silo_link(src)
	new /obj/item/rcd_upgrade/frames(src)
	new /obj/item/rcd_upgrade/furnishing(src)

/obj/item/reagent_containers/spray/drying
	name = "drying agent spray"
	list_reagents = list(/datum/reagent/drying_agent = 250)

