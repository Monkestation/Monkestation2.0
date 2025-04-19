/obj/item/neutered_larva_spawner
	name = "syndicate larva cage"
	desc = "The fearsome xenomorph, contained and modified to treat the first person it sees \
			as its queen. Because of its extensive modifications, this larva is not capable of turning into a Drone, or evolving into a Queen."
	icon = 'monkestation/code/modules/antagonists/borers/icons/items.dmi'
	icon_state = "cage"
	/// Used to animate the cage opening when you use the borer spawner, and closing if it fails to spawn a borer. Also midly against spam
	var/opened = FALSE
	/// Toggles if the borer spawner should be delayed or not, if this gets a value if will use that value to delay (for example: 5 SECONDS)
	var/delayed = FALSE
	/// Dictates the poll time
	var/polling_time = 10 SECONDS

/obj/item/neutered_larva_spawner/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/neutered_larva_spawner/update_overlays()
	. = ..()
	. += "larva"
	if(opened)
		. += "doors_open"
	else
		. += "doors_closed"

/obj/item/neutered_larva_spawner/proc/do_wriggler_messages()
	if(!opened) // there were no candidates at all somehow, probably tests on local. Lets not give messages after the fail message comes up
		return
	sleep(polling_time * 0.2)
	visible_message(span_notice("The larva seems to have woken up"))
	if(!opened) // one more check to be sure
		return
	sleep(polling_time * 0.2)
	visible_message(span_notice("The larva has perked up their head, finally noticing the opened cage..."))
	sleep(polling_time * 0.2)
	visible_message(span_notice("The larva seems to slither cautiously to the cage entrance..."))
	sleep(polling_time * 0.1)
	visible_message(span_notice("The larva's head peeks outside of the cage..."))

/obj/item/neutered_larva_spawner/attack_self(mob/living/user)
	if(opened)
		return
	user.visible_message("[user] opens [src].", "You have opened the [src], awaiting for the larva to come out.", "You hear a metallic thunk.")
	opened = TRUE
	playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
	if(delayed)
		sleep(delayed)
	INVOKE_ASYNC(src, PROC_REF(do_wriggler_messages)) // give them something to look at whilst we poll the ghosts
	update_appearance()
	var/list/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a neutered alien larva?",
		role = ROLE_ALIEN,
		poll_time = polling_time,
		check_jobban = ROLE_ALIEN,
		alert_pic = /mob/living/carbon/alien/larva,
		role_name_text = "neutered alien larva"
	)
	if(QDELETED(src)) // prevent shenanigans with refunds
		return
	if(!LAZYLEN(candidates))
		opened = FALSE
		to_chat(user, "Yet the larva after looking at you quickly retreats back into their cage, visibly scared. Perhaps try later?")
		playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
		update_appearance()
		return

	var/mob/dead/observer/picked_candidate = pick(candidates)

	var/mob/living/carbon/alien/larva/new_mob = new(drop_location(), TRUE)
	new_mob.PossessByPlayer(picked_candidate.ckey)

	var/datum/antagonist/xeno/neutered/xeno_antagonist_datum = new

	var/datum/objective/protect/protect_objective = new
	var/datum/objective/custom/listen_objective = new

	protect_objective.target = user.mind
	protect_objective.update_explanation_text()

	listen_objective.explanation_text = "Listen to any commands given by [user.name]"
	listen_objective.completed = TRUE // its just an objective for flavor less-so than for greentext

	xeno_antagonist_datum.objectives += protect_objective
	xeno_antagonist_datum.objectives += listen_objective

	new_mob.mind.remove_all_antag_datums() //removes the default xeno antag datum
	new_mob.mind.add_antag_datum(xeno_antagonist_datum)


	notify_ghosts(
		"[new_mob] has been chosen from the ghost pool!",
		source = new_mob,
		action = NOTIFY_ORBIT,
		header = "Someone just got a new friend!"
	)
	message_admins("[ADMIN_LOOKUPFLW(new_mob)] has been made into a larva via a traitor item used by [user].")
	log_game("[key_name(new_mob)] was spawned as a larva by [key_name(user)].")
	visible_message("A larva wriggles out of the [src]!")

	var/obj/item/cortical_cage/empty_cage = new(drop_location())
	var/user_held = user.get_held_index_of_item(src)
	if(user_held) // seems more immersive if you don't just suddenly drop the cage, and it empties while still seemingly in your hand.
		user.dropItemToGround(src, force = TRUE, silent = TRUE)
		user.put_in_hand(empty_cage, user_held, ignore_anim = TRUE)
	qdel(src)
