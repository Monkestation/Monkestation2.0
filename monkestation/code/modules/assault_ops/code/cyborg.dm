//big ol copy of nukie code but to make it play nice with assault ops datums
/obj/item/antag_spawner/assault_operative
	name = "syndicate saboteur beacon"
	desc = "A single-use beacon designed to quickly launch reinforcement operatives into the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	/// The name of the special role given to the recruit
	var/special_role_name = ROLE_ASSAULT_OPERATIVE
	/// The antag datum applied
	var/datum/antagonist/assault_operative/antag_datum = /datum/antagonist/assault_operative
	/// Style used by the droppod
	var/pod_style = STYLE_SYNDICATE

/obj/item/antag_spawner/assault_operative/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!user.mind.has_antag_datum(/datum/antagonist/assault_operative,TRUE))
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	return TRUE

/// Creates the drop pod the nukie will be dropped by
/obj/item/antag_spawner/assault_operative/proc/setup_pod()
	var/obj/structure/closet/supplypod/pod = new(null, pod_style)
	pod.explosionSize = list(0,0,0,0)
	pod.bluespace = TRUE
	return pod

/obj/item/antag_spawner/assault_operative/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))
	var/mob/chosen_one = SSpolling.poll_ghost_candidates("Do you want to play as a reinforcement [special_role_name]?", check_jobban = ROLE_ASSAULT_OPERATIVE, role = ROLE_ASSAULT_OPERATIVE, poll_time = 15 SECONDS, ignore_category = POLL_IGNORE_SYNDICATE, alert_pic = src, role_name_text = special_role_name, amount_to_pick = 1)
	if(chosen_one)
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		spawn_antag(chosen_one.client, get_turf(src), "assault_operative", user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the beacon on your uplink to get your points refunded."))

/obj/item/antag_spawner/assault_operative/spawn_antag(client/our_client, turf/T, kind, datum/mind/user)
	var/mob/living/silicon/robot/borg = new /mob/living/silicon/robot/model/syndicate/saboteur/operative()
	var/datum/antagonist/assault_operative/creator_op = user.has_antag_datum(/datum/antagonist/assault_operative,TRUE)
	if(!creator_op)
		return
	our_client.prefs.safe_transfer_prefs_to(borg, is_antag = TRUE)
	borg.PossessByPlayer(our_client.key)
	var/obj/structure/closet/supplypod/pod = setup_pod()
	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	borg.mmi.name = "[initial(borg.mmi.name)]: [brainopsname]"
	borg.mmi.brain.name = "[brainopsname]'s brain"
	borg.mmi.brainmob.real_name = brainopsname
	borg.mmi.brainmob.name = brainopsname
	borg.real_name = borg.name

	borg.PossessByPlayer(our_client.key)

	var/datum/antagonist/assault_operative/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	borg.mind.add_antag_datum(new_borg,creator_op.assault_team)
	borg.mind.special_role = "Syndicate Cyborg"
	borg.forceMove(pod)
	new /obj/effect/pod_landingzone(get_turf(src), pod)
