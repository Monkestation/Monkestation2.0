/obj/item/mmi/posibrain/soul_vessel
	name = "Soul Vessel"
	desc = "A cube of gears, made to capture and store the vitality of living beings."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	base_icon_state = "soul_vessel"
	req_access = list()
	begin_activation_message = span_notice("You start spinning the gears of the Soul Vessel.")
	success_message = span_notice("The gears of the Soul Vessel start spinning at a steady rate, it looks as though it has found a willing soul!")
	fail_message = span_notice("The gears of the Soul Vessel stop spinning. It looks as though it has run out of energy for now, but you could grant it more.")
	new_mob_message = span_notice("The Soul Vessel starts making a steady ticking sound.")
	dead_message = span_deadsay("It's gears are not moving.")
	recharge_message = span_warning("The gears of the Soul Vessel are already spinning.")
	///Should we add the clock cultist antag datum on being entered by a player
	var/give_clock_cultist = TRUE

/obj/item/mmi/posibrain/soul_vessel/Initialize(mapload, autoping)
	. = ..()
	AddElement(/datum/element/clockwork_description, span_brass("A vessel used to hold the souls of the dead, can be converted into a cogscarab shell."))
	laws = new /datum/ai_laws/ratvar()
	radio.set_on(FALSE)
	if(!brainmob) //we might be forcing someone into it right away
		set_brainmob(new /mob/living/brain(src))

/obj/item/mmi/posibrain/soul_vessel/transfer_personality(mob/candidate)
	. = ..()
	if(!.)
		return

	if(give_clock_cultist)
		brainmob?.mind?.add_antag_datum(/datum/antagonist/clock_cultist)

/obj/item/mmi/posibrain/soul_vessel/activate(mob/user)
	if(is_banned_from(user.ckey, list(JOB_CYBORG, ROLE_CLOCK_CULTIST)))
		return
	return ..()

/obj/item/mmi/posibrain/soul_vessel/attack_self(mob/user)
	if(!IS_CLOCK(user))
		balloon_alert(user, "You can't seem to figure out how \the [src] works!")
		return

	if(brainmob.key && brainmob.mind)
		if(length(GLOB.cogscarabs) > MAXIMUM_COGSCARABS)
			balloon_alert(user, "The Ark cannot support any more cogscarabs.")
			return

		balloon_alert(user, "You start converting the vessel into a cogscarab shell.")
		if(do_after(user, 30 SECONDS, src))
			var/mob/living/basic/drone/cogscarab/new_scarab = new(get_turf(src))
			brainmob.mind.transfer_to(new_scarab, TRUE)
			if(!IS_CLOCK(new_scarab))
				new_scarab.mind.add_antag_datum(/datum/antagonist/clock_cultist)
			balloon_alert(user, "You reform [src] into a cogscarab shell.")
			qdel(src)
		return

	if(next_ask > world.time)
		balloon_alert(user, recharge_message)
		return

	balloon_alert(user, begin_activation_message)
	ping_ghosts("requested", FALSE)
	next_ask = world.time + ask_delay
	searching = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(check_success)), ask_delay)
