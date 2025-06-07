//The borer spawner is the base type for any 'worm' type subservient atagonists.

/obj/item/neutered_borer_spawner
	name = "syndicate cortical borer cage"
	desc = "The opposite of a harmless cage that is intended to capture cortical borer, \
			as this one contains a borer trained to assist anyone who it first sees in completing their goals."
	icon = 'monkestation/code/modules/antagonists/borers/icons/items.dmi'
	icon_state = "cage"
	/// Used to animate the cage opening when you use the borer spawner, and closing if it fails to spawn a borer. Also midly against spam
	var/opened = FALSE
	/// Toggles if the borer spawner should be delayed or not, if this gets a value if will use that value to delay (for example: 5 SECONDS)
	var/delayed = FALSE
	/// Dictates the poll time
	var/polling_time = 10 SECONDS
	var/worm = "borer"

/obj/item/neutered_borer_spawner/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/neutered_borer_spawner/update_overlays()
	. = ..()
	. += worm
	if(opened)
		. += "doors_open"
	else
		. += "doors_closed"

/obj/item/neutered_borer_spawner/proc/do_wriggler_messages()
	if(!opened) // there were no candidates at all somehow, probably tests on local. Lets not give messages after the fail message comes up
		return
	sleep(polling_time * 0.2)
	visible_message(span_notice("The [worm] seems to have woken up"))
	if(!opened) // one more check to be sure
		return
	sleep(polling_time * 0.2)
	visible_message(span_notice("The [worm] has perked up their head, finally noticing the opened cage..."))
	sleep(polling_time * 0.2)
	visible_message(span_notice("The [worm] seems to slither cautiously to the cage entrance..."))
	sleep(polling_time * 0.1)
	visible_message(span_notice("The [worm]'s head peeks outside of the cage..."))

/obj/item/neutered_borer_spawner/attack_self(mob/living/user)
	if(opened)
		return
	user.visible_message("[user] opens [src].", "You have opened the [src], awaiting for the [worm] to come out.", "You hear a metallic thunk.")
	opened = TRUE
	playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
	if(delayed)
		sleep(delayed)
	INVOKE_ASYNC(src, PROC_REF(do_wriggler_messages)) // give them something to look at whilst we poll the ghosts
	update_appearance()
	//handles the spawning, canididate selecting and assigning of objectives for the new worm
	var/mob/living/new_mob
	var/mob/dead/observer/picked_candidate
	var/list/candidates
	var/datum/antagonist/worm_antagonist_datum
	var/datum/objective/protect/protect_objective = new
	var/datum/objective/custom/listen_objective = new
	protect_objective.target = user.mind
	protect_objective.update_explanation_text()

	listen_objective.explanation_text = "Listen to any commands given by [user.name]"
	listen_objective.completed = TRUE // its just an objective for flavor less-so than for greentext

		//The wormy types
	if(worm == "borer")
	//spawn a borer
		candidates = SSpolling.poll_ghost_candidates(
			role = ROLE_CORTICAL_BORER,
			poll_time = polling_time,
			ignore_category = POLL_IGNORE_CORTICAL_BORER,
			alert_pic = /mob/living/basic/cortical_borer/neutered,
		)
		if(QDELETED(src)) // prevent shenanigans with refunds
			return
		if(!LAZYLEN(candidates))
			opened = FALSE
			to_chat(user, "Yet the [worm] after looking at you quickly retreats back into their cage, visibly scared. Perhaps try later?")
			playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
			update_appearance()
			return
		new_mob = new /mob/living/basic/cortical_borer/neutered(drop_location())
		worm_antagonist_datum = new /datum/antagonist/cortical_borer

	else // if worm == "larva"
	//spawn a larva
		candidates = SSpolling.poll_ghost_candidates(
			role = ROLE_ALIEN,
			poll_time = polling_time,
			ignore_category = POLL_IGNORE_ALIEN_LARVA,
			alert_pic = /mob/living/carbon/alien/larva,
		)
		if(QDELETED(src)) // prevent shenanigans with refunds
			return
		if(!LAZYLEN(candidates))
			opened = FALSE
			to_chat(user, "Yet the [worm] after looking at you quickly retreats back into their cage, visibly scared. Perhaps try later?")
			playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
			update_appearance()
			return
		new_mob = new /mob/living/carbon/alien/larva(drop_location(), TRUE)
		worm_antagonist_datum = new /datum/antagonist/xeno/neutered
	//else new_worm
	picked_candidate = pick(candidates)
	new_mob.PossessByPlayer(picked_candidate.ckey)

	//all worms get the same objectives
	worm_antagonist_datum.objectives += protect_objective
	worm_antagonist_datum.objectives += listen_objective
	new_mob.mind.remove_all_antag_datums()
	new_mob.mind.add_antag_datum(worm_antagonist_datum)

	var/obj/item/cortical_cage/empty_cage = new(drop_location())
	var/user_held = user.get_held_index_of_item(src)
	if(user_held) // seems more immersive if you don't just suddenly drop the cage, and it empties while still seemingly in your hand.
		user.dropItemToGround(src, force = TRUE, silent = TRUE)
		user.put_in_hand(empty_cage, user_held, ignore_anim = TRUE)
	qdel(src)

/obj/item/neutered_larva_spawner //the subtype for a larva spawner
    parent_type = /obj/item/neutered_borer_spawner
    name = "syndicate xenomorph larva cage"
    desc = "A cage containing a neutered xenomorph larva, modified to assist anyone it first sees in completing their goals."
    worm = "larva"
