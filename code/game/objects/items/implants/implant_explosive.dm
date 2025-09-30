/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/explosive_implant)
	// Explosive implant action is always available.
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7
	///If the delay is equal or lower to MICROBOMB_DELAY (0.7 sec), the explosion will be instantaneous.
	var/instant_explosion = TRUE
	var/popup = FALSE // is the DOUWANNABLOWUP window open?
	var/active = FALSE
	///Will this implant notify ghosts when activated?
	var/notify_ghosts = TRUE

/obj/item/implant/explosive/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish. Also, the "delayed explosion"
	// uses sleeps, which is bad for signal handlers to do.
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				"}
	return dat

/obj/item/implant/explosive/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(locate(/obj/item/implant/fakemacro) in imp_in.implants)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to explode!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	var/turf/boomturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(boomturf)], with cause of [cause].")
	//If the delay is shorter or equal to the default delay, just blow up already jeez
	if(delay <= delay && instant_explosion)
		explosion(src, devastation_range = heavy, heavy_impact_range = medium, light_impact_range = weak, flame_range = weak, flash_range = weak, explosion_cause = src)
		if(imp_in)
			imp_in.investigate_log("has been gibbed by an explosive implant.", INVESTIGATE_DEATHS)
			imp_in.gib(TRUE, safe_gib = FALSE)
		qdel(src)
		return
	timed_explosion()

/obj/item/implant/explosive/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/X in target.implants)
		if(istype(X, /obj/item/implant/explosive)) //we don't use our own type here, because macrobombs inherit this proc and need to be able to upgrade microbombs
			var/obj/item/implant/explosive/imp_e = X
			imp_e.heavy += heavy
			imp_e.medium += medium
			imp_e.weak += weak
			imp_e.delay += delay
			qdel(src)
			return TRUE

	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/explosive/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message(span_warning("[imp_in] starts beeping ominously!"))

	if(notify_ghosts)
		notify_ghosts(
			"[imp_in] is about to detonate their explosive implant!",
			source = src,
			header = "Tick Tick Tick...",
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
			ghost_sound = 'sound/machines/warning-buzzer.ogg',
			notify_volume = 75,
		)

	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message(span_warning("[imp_in] doubles over in pain!"))
		imp_in.Paralyze(140)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	explosion(src, devastation_range = heavy, heavy_impact_range = medium, light_impact_range = weak, flame_range = weak, flash_range = weak, explosion_cause = src)
	if(imp_in)
		imp_in.investigate_log("has been gibbed by an explosive implant.", INVESTIGATE_DEATHS)
		imp_in.gib(TRUE)
	qdel(src)

/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	weak = 20 //the strength and delay of 10 microbombs
	medium = 8
	heavy = 4
	delay = 70

/obj/item/implant/explosive/deathmatch
	name = "deathmatch microbomb implant"
	delay = 0.5 SECONDS
	actions_types = null
	instant_explosion = FALSE
	notify_ghosts = FALSE

/obj/item/implanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro

/obj/item/implanter/fakemacro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/fakemacro

/datum/action/item_action/explosive_implant
	check_flags = NONE
	name = "Activate Explosive Implant"

/obj/item/implant/fakemacro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	var/delay = 7 SECONDS

/obj/item/implant/fakemacro/proc/do_revive()
	imp_in.visible_message(span_warning("[imp_in] starts beeping ominously!"))
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message(span_warning("[imp_in] doubles over in pain!"))
		imp_in.Paralyze(14 SECONDS)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/atropine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/stimulants, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/sal_acid, 15)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/oxandrolone, 15)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/syndicate_nanites, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/painkiller/morphine, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/coagulant/seraka_extract, 5)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 50)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/modafinil, 10)
	imp_in.reagents.add_reagent(/datum/reagent/medicine/c2/seiver, 15)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay*0.25)
	if(imp_in.getBruteLoss() <= 299)
		imp_in.setBruteLoss(99)
	else
		imp_in.adjustBruteLoss(-200)
	if(imp_in.getFireLoss() <= 299)
		imp_in.setFireLoss(99)
	else
		imp_in.adjustFireLoss(-200)
	imp_in.revive(excess_healing=50, force_grab_ghost=TRUE) //tadaa
	qdel(src)


/obj/item/implant/fakemacro/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish. Also, the "delayed explosion"
	// uses sleeps, which is bad for signal handlers to do.
	INVOKE_ASYNC(src, PROC_REF(do_revive))

/obj/item/implant/fakemacro/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implant/fakemacro/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-79 Employee Protection Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Revives.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact bluespace canister that releases a variety of medicines upon host death, before subsequently restarting their brain function.<BR>
				<b>Special Features:</b> Appears exactly as a macrobomb before revival.<BR>
				"}
	return dat

/obj/item/implant/fakemacro/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))
