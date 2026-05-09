#define DOOM_EVENTS "events"
#define DOOM_ANTAGS "threats"
#define DOOM_ROD "rod"

/// Kill yourself and probably a bunch of other people
/datum/grand_finale/armageddon
	name = "Annihilation"
	desc = "This crew have offended you beyond the realm of pranks. Make the ultimate sacrifice to teach them a lesson your elders can really respect. \
		YOU WILL NOT SURVIVE THIS."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "wounded"
	minimum_time = 75 MINUTES // This will probably immediately end the round if it gets finished. //monkestation edit: from 90 to 75 minutes
	ritual_invoke_time = 40 SECONDS // Give the crew a bit of extra time to stop it
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Things to yell before you die
	var/static/list/possible_last_words = list(
		"Flames and ruin!",
		"Dooooooooom!!",
		"HAHAHAHAHAHA!! AHAHAHAHAHAHAHAHAA!!",
		"Hee hee hee!! Hoo hoo hoo!! Ha ha haaa!!",
		"Ohohohohohoho!!",
		"Cower in fear, puny mortals!",
		"Tremble before my glory!",
		"Pick a god and pray!",
		"It's no use!",
		"If the gods wanted you to live, they would not have created me!",
		"God stays in heaven out of fear of what I have created!",
		"Ruination is come!",
		"All of creation, bend to my will!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker, picked_doom)
	priority_announce(pick(possible_last_words), "ERROR", 'sound/magic/voidblink.ogg', sender_override = "[invoker.real_name]", color_override = "purple")
	var/turf/current_location = get_turf(invoker)
	if(iscarbon(invoker))
		invoker.gib()

	picked_doom ||= pick(list(DOOM_EVENTS, DOOM_ANTAGS, DOOM_ROD))
	switch(picked_doom)
		if(DOOM_EVENTS) //triggers a MASSIVE amount of events pretty quickly
			summon_events() //wont effect the events created directly from this, but it will effect any events that happen after
			var/list/possible_events = list()
			for(var/datum/round_event_control/possible_event as anything in SSevents.control)
				if(possible_event.max_wizard_trigger_potency < 5) //only run the decently big ones
					continue
				possible_events += possible_event
			var/timer_counter = 1
			for(var/i in 1 to 50) //high chance this number needs tweaking, but we do want this to be a round ending amount of events
				var/datum/round_event_control/event = pick(possible_events)
				addtimer(CALLBACK(event, TYPE_PROC_REF(/datum/round_event_control, run_event)), (10 * timer_counter) SECONDS)
				timer_counter++

		if(DOOM_ANTAGS) //make 50% of the crew be traitors with an objective to kill each other, give the rest guns
			var/list/active_players = shuffle(SSgamemode.get_active_players())
			var/desired_traitors = length(active_players) / 2
			var/list/traitors = list()
			for(var/mob/player in active_players)
				if(player.mind && length(traitors) < desired_traitors && !player.mind.has_antag_datum(/datum/antagonist/traitor))
					traitors += player.mind.add_antag_datum(/datum/antagonist/traitor)
					continue

				if(!ishuman(player))
					continue

				//give gun
				var/gun_type = pick(GLOB.summoned_guns)
				var/obj/item/gun/spawned_gun = new gun_type(get_turf(player))
				if(istype(spawned_gun))
					spawned_gun.unlock()
				playsound(get_turf(player), 'sound/magic/summon_guns.ogg', 50, TRUE)
				var/in_hand = player.put_in_hands(spawned_gun)
				to_chat(player, span_warning("\A [spawned_gun] appears [in_hand ? "in your hand" : "at your feet"]!"))

			var/list/possible_targets = shuffle(traitors.Copy())
			for(var/datum/antagonist/traitor/tator in traitors)
				var/datum/objective/assassinate/objective = new
				objective.target = astype(pick_n_take(possible_targets - tator), /datum/antagonist/traitor).owner
				objective.update_explanation_text()
				tator.objectives.Insert(length(tator.objectives) - 1, objective)

		if(DOOM_ROD) //spawns a ghost controlled, forced looping rod, only technically less damaging then singaloth or tesloose
			var/obj/effect/immovablerod/rod = new(current_location)
			rod.loopy_rod = TRUE
			rod.can_suplex = FALSE
			rod.deadchat_plays(ANARCHY_MODE, 3 SECONDS)

#undef DOOM_EVENTS
#undef DOOM_ANTAGS
#undef DOOM_ROD
