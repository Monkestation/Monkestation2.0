#define CULT_VICTORY 1
#define CULT_LOSS 0
#define CULT_NARSIE_KILLED -1

/datum/team/cult
	name = "\improper Cult"

	///The blood mark target
	var/atom/blood_target
	///Image of the blood mark target
	var/image/blood_target_image
	///Timer for the blood mark expiration
	var/blood_target_reset_timer

	///Has a vote been called for a leader?
	var/cult_vote_called = FALSE
	///The cult leader
	var/mob/living/cult_master
	///Has the mass teleport been used yet?
	var/reckoning_complete = FALSE
	///Has the cult risen, and gotten red eyes?
	var/cult_risen = FALSE
	///Has the cult asceneded, and gotten halos?
	var/cult_ascendent = FALSE

	///Has narsie been summoned yet?
	var/narsie_summoned = FALSE
	///How large were we at max size.
	var/size_at_maximum = 0
	///list of cultists just before summoning Narsie
	var/list/true_cultists = list()


	//////NEW STUFF HERE
	var/stage = BLOODCULT_STAGE_NORMAL
	var/list/bloody_floors = list()
	var/cult_win = FALSE

	var/list/cult_reminders = list()

	var/list/bindings = list()

	var/cultist_cap = 1	//clamped between 5 and 9 depending on crew size. once the cap goes up it cannot go down.
	var/min_cultist_cap = 5
	var/max_cultist_cap = 9

	var/mentor_count = 0 	//so we don't loop through the member list if we already know there are no mentors in there

	var/cult_founding_time = 0
	var/last_process_time = 0
	var/delta = 1

	var/eclipse_progress = 0
	var/eclipse_target = 1800
	var/eclipse_window = 20 MINUTES //I Don't really know how much longer I can make this, for gods sake read your chat window that tells you, that you NEED to do the ritual
	var/eclipse_increments = 0
	var/eclipse_contributors = list()//associative list: /mind = score

	var/soon_announcement = FALSE
	var/overtime_announcement = FALSE

	var/bloodstone_rising_time = 0
	var/bloodstone_duration = 430 SECONDS
	var/bloodstone_target_time = 0

	var/datum/rune_spell/tearreality/tear_ritual = null
	var/obj/structure/cult/bloodstone/bloodstone = null		//we track the one spawned by the Tear Reality rune
	var/obj/narsie/narsie = null

	//we track the mind of anyone that has been converted or made prisoner at least once.
	var/previously_made_prisoner = list()
	var/previously_converted = list()

	var/total_devotion = 0

	var/twister = FALSE

	var/list/deconverted = list()//tracking for scoreboard purposes

	var/datum/bloodcult_ritual/bloodspill_ritual = null

	var/list/possible_rituals = list()
	var/list/rituals = list(RITUAL_FACTION_1, RITUAL_FACTION_2, RITUAL_FACTION_3)

	var/countdown_to_first_rituals = 5

	COOLDOWN_DECLARE(last_reminder)


/datum/team/cult/add_member(datum/mind/new_member)
	. = ..()
	// A little hacky, but this checks that cult ghosts don't contribute to the size at maximum value.
	if(is_unassigned_job(new_member.assigned_role))
		return
	size_at_maximum++

/datum/team/cult/proc/setup_objectives()
	START_PROCESSING(SSobj, src)
	for (var/ritual_type in GLOB.bloodcult_faction_rituals)
		possible_rituals += new ritual_type()
	cult_founding_time = world.time
	initialize_rune_words()
	for (var/datum/mind/mind in members)
		var/mob/M = mind.current
		to_chat(M, span_cult("Our communion must remain small and secretive until we are confident enough.") )
		previously_converted |= mind


/datum/team/cult/proc/check_destroy()
	if(!length(members))
		qdel(src)

/datum/team/cult/proc/replace_rituals(var/slot)
	if (!slot)
		return

	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions())
			valid_rituals += R

	if (valid_rituals.len < 1)
		return

	var/datum/bloodcult_ritual/BR = pick(valid_rituals)
	rituals[slot] = BR
	possible_rituals -= BR
	BR.init_ritual()

	for (var/datum/antagonist/cult/cultist in members)
		var/mob/O = cultist.owner.current
		if (O)
			to_chat(O, span_cult("A new ritual is available...") )
		var/datum/mind/M = cultist.owner
		if ("Cult Panel" in M.active_uis)
			var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/team/cult/proc/UpdateCap()
	if (stage == BLOODCULT_STAGE_DEFEATED)
		cultist_cap = 0
		return
	if (stage == BLOODCULT_STAGE_NARSIE)
		cultist_cap = 666
		return
	var/living_players = 0
	var/new_cap = 0
	for (var/mob/M in GLOB.player_list)
		if (!M.client)
			continue
		if (istype(M, /mob/dead/new_player))
			continue
		if (M.stat != DEAD)
			living_players++
	new_cap =  clamp(round(living_players / 3), min_cultist_cap, max_cultist_cap)
	if (new_cap > cultist_cap)
		cultist_cap = new_cap
		for (var/datum/mind/mind in members)
			var/mob/M = mind.current
			to_chat(M, span_cult("The station population is now large enough for <span class = 'userdanger'>[cultist_cap]</span> cultists, plus one of each construct types.") )

/datum/team/cult/proc/CanConvert(construct_type)
	var/list/free_construct_slots = list()
	var/cultist_count = 0
	for (var/datum/mind/mind in members)
		var/mob/M = mind.current
		//The first construct of each type doesn't take up a slot.
		if (istype(M, /mob/living/basic/construct))
			var/mob/living/basic/construct/C = M
			if (!(C.construct_type in free_construct_slots))
				free_construct_slots += C.construct_type
				continue
		//Living Humans, Shades and extra Constructs all count.
		if (isliving(M))
			if (M.stat != DEAD)
				cultist_count += 1

	if(construct_type && (!(construct_type in free_construct_slots)))
		return TRUE

	return (cultist_count < cultist_cap)


/datum/team/cult/proc/check_ritual(var/key, var/extra)
	switch(stage)
		if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
			return
		if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
			return

	if (key && (stage != BLOODCULT_STAGE_ECLIPSE))
		for (var/ritual_slot in rituals)
			if (rituals[ritual_slot])
				var/datum/bloodcult_ritual/faction_ritual = rituals[ritual_slot]
				if (key in faction_ritual.keys)
					if (faction_ritual.key_found(extra))
						faction_ritual.complete()
						if (!faction_ritual.only_once)
							possible_rituals += faction_ritual
						rituals[ritual_slot] = null
						for (var/datum/mind/mind in members)
							var/mob/M = mind.current
							if (M)
								to_chat(M, span_cult("Someone has completed a ritual, rewarding the entire cult...soon another ritual will take its place.") )
						spawn(10 MINUTES)
							if (!rituals[ritual_slot])
								replace_rituals(ritual_slot)

/datum/team/cult/proc/stage(var/value)
	stage = value
	switch(stage)
		if (BLOODCULT_STAGE_READY)
			eclipse_trigger_cult()
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(3)
			for(var/datum/mind/mind in members)
				var/mob/mob = mind.current
				if(mob)
					to_chat(mob, span_cultlarge("The time to start summoning Nar'Sie has come, check the cultist menu for more information on the ritual she wants you to perform. You have until the end of the eclipse to start the summoning."))
			COOLDOWN_START(src, last_reminder, 1 MINUTES)
		if (BLOODCULT_STAGE_MISSED)
			for (var/datum/mind/mind in members)
				var/mob/M = mind.current
				if (M)
					to_chat(M, span_cult("The Eclipse has passed. You won't be able to tear reality aboard this station anymore. Escape the station alive with your fellow cultists so you may try again another day.") )
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(1)
		if (BLOODCULT_STAGE_ECLIPSE)
			var/list/station_zs = SSmapping.levels_by_trait(ZTRAIT_STATION)
			for(var/datum/space_level/level as anything in SSmapping.z_list)
				if(!(level.z_value in station_zs))
					continue
				level.set_linkage(SELFLOOPING)

			INVOKE_ASYNC(src, PROC_REF(narnar_ghosts))
			bloodstone_rising_time = world.time
			bloodstone_target_time = world.time + bloodstone_duration
			spawn (3 SECONDS)//leaving just a moment for the blood stone to rise.
				var/sec_change = TRUE
				priority_announce("Bluespace fluctuation patterns match those observed during past incursions by the Cult of Nar-Sie, which means a Blood Stone has risen. Find and destroy it at all costs or this station will be lost. Be careful of the eldritch entities that may manifest across the station.", "Cult Activity Detected")
				if (sec_change)
					sleep(2 SECONDS)
					SSsecurity_level.set_level(SEC_LEVEL_RED, announce = FALSE)

		if (BLOODCULT_STAGE_DEFEATED)
			GLOB.eclipse.eclipse_end()
			for (var/obj/effect/new_rune/R in runes)
				qdel(R)//new runes can be written, but any pre-existing one gets nuked.
			cultist_cap = 0
			spawn()
				for(var/mob/living/simple_animal/M in GLOB.mob_list)
					if(!M.client && (M.faction == "cult"))
						M.death()
					CHECK_TICK
			spawn()
			for(var/obj/structure/cult/spire/S in GLOB.cult_spires)
				S.upgrade(1)
			spawn(5 SECONDS)
				for (var/datum/mind/mind in members)
					var/mob/M = mind.current
					to_chat(M, span_cult("With the blood stone destroyed, the tear through the veil has been mended, and a great deal of occult energies have been purged from the Station.") )
					sleep(3 SECONDS)
					to_chat(M, span_cult("Your connection to the Geometer of Blood has grown weaker and you can no longer recall the runes as easily as you did before. Maybe an Arcane Tome can alleviate the problem.") )
					sleep(3 SECONDS)
					to_chat(M, span_cult("Lastly it seems that the toll of the ritual on your body hasn't gone away. Going unnoticed will be a lot harder.") )
		if (BLOODCULT_STAGE_NARSIE)
			if (bloodstone)
				anim(target = bloodstone.loc, a_icon = 'icons/obj/cult/narsie.dmi', flick_anim = "narsie_spawn_anim_start", offX = -236, offY = -256, plane = MASSIVE_OBJ_PLANE)
				sleep(5)
				narsie = new(bloodstone.loc)
	for (var/datum/mind/M in members)
		if ("Cult Panel" in M.active_uis)
			var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()
		if ("Cultist Panel" in M.active_uis)
			var/datum/mind_ui/m_ui = M.active_uis["Cultist Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/team/cult/proc/narnar_ghosts()
	for (var/mob/dead/observer/O in GLOB.player_list)
		O.narsie_act()
		sleep(rand(1, 5))

/datum/team/cult/proc/HandleRecruitedRole(datum/antagonist/R)
	if (cult_reminders.len)
		to_chat(R.owner.current, span_notice("Other cultists have shared some of their knowledge. It will be stored in your memory (check your Notes under the IC tab).") )
	/*
	for (var/reminder in cult_reminders)
		R.antag.store_memory("Shared Cultist Knowledge: [reminder].")
	*/
	previously_converted |= R.owner
	if (R.owner.name in deconverted)
		deconverted -= R.owner.name

/datum/team/cult/proc/assign_rituals()
	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions())
			valid_rituals += R

	if (valid_rituals.len < 3)
		return

	for (var/ritual_slot in rituals)
		var/datum/bloodcult_ritual/BR = pick(valid_rituals)
		rituals[ritual_slot] = BR
		possible_rituals -= BR
		valid_rituals -= BR
		BR.init_ritual()

	for (var/datum/mind/M in members)
		if ("Cult Panel" in M.active_uis)
			var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
			if (m_ui.active)
				m_ui.Display()

/datum/team/cult/process()
	..()
	if (cultist_cap >= 1) //The first call occurs in OnPostSetup()
		UpdateCap()

	switch(stage)
		if (BLOODCULT_STAGE_NORMAL)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
			//if there is at least one cultist alive, the eclipse comes forward
			for (var/datum/mind/mind in members)
				var/mob/M = mind.current
				calculate_eclipse_rate()
				if (isliving(M) && M.stat != DEAD)
					//we calculate the progress relative to the time since the last process so the overall time is independant from server lag and shit
					delta = 1
					if (last_process_time && (last_process_time < world.time))//carefully dealing with midnight rollover
						delta = (world.time - last_process_time)
						if(SSticker.initialized)
							delta /= SSticker.wait
					last_process_time = world.time

					eclipse_progress += max(0.1, eclipse_increments) * delta
					if (eclipse_progress >= eclipse_target)
						stage(BLOODCULT_STAGE_READY)
					break
			if (countdown_to_first_rituals)
				countdown_to_first_rituals--
				if (countdown_to_first_rituals <= 0)
					assign_rituals()
					for (var/datum/mind/mind in members)
						var/datum/antagonist/cult/cult_datum = mind.has_antag_datum(/datum/antagonist/cult)
						cult_datum.assign_rituals()
						var/mob/M = mind.current
						if (M)
							to_chat(M, span_cult("Although you can generate devotion by performing most cult activities, a couple rituals for you to perform are now available. Check the cult panel.") )


		if (BLOODCULT_STAGE_MISSED)
			if (bloodspill_ritual)
				check_ritual("bloodspill", bloody_floors.len)
		if (BLOODCULT_STAGE_READY)
			if(COOLDOWN_FINISHED(src, last_reminder))
				for(var/datum/mind/mind in members)
					var/mob/mob = mind.current
					if(mob)
						to_chat(mob, span_cultlarge("The eclipse is still ongoing and you haven't started the ritual yet, your time is fading."))
				COOLDOWN_START(src, last_reminder, 1 MINUTES)
			if (GLOB.eclipse.eclipse_finished)
				stage(BLOODCULT_STAGE_MISSED)
		if (BLOODCULT_STAGE_ECLIPSE)
			bloodstone.update_icon()
			if (world.time >= bloodstone_target_time)
				stage(BLOODCULT_STAGE_NARSIE)

/datum/team/cult/proc/calculate_eclipse_rate()
	eclipse_increments = 0
	for (var/datum/mind/mind in members)
		var/mob/M = mind.current
		var/datum/antagonist/cult/R = mind.has_antag_datum(/datum/antagonist/cult)
		if (isliving(M) && M.stat != DEAD)
			if (M.occult_muted())
				eclipse_increments -= R.get_eclipse_increment()
			else
				eclipse_increments += R.get_eclipse_increment()


/datum/team/cult/proc/add_bloody_floor(turf/T)
	if (!istype(T))
		return
	if(T && (is_station_level(T.z)))
		if(!(locate("\ref[T]") in bloody_floors))
			bloody_floors[T] = T


/datum/team/cult/proc/remove_bloody_floor(turf/T)
	if (!istype(T))
		return
	bloody_floors -= T

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(O.check_completion() == CULT_NARSIE_KILLED)
			return CULT_NARSIE_KILLED
		else if(!O.check_completion())
			return CULT_LOSS
	return CULT_VICTORY

/datum/team/cult/roundend_report()
	var/list/parts = list()

	switch(stage)
		if(BLOODCULT_STAGE_MISSED)
			parts += "<span class = 'redtext big'>The cult missed the chance to summon Nar'Sie. They have failed her!</span>"
		if(BLOODCULT_STAGE_DEFEATED)
			parts +=  "<span class = 'redtext big'>The crew has destroyed the bloodstone preventing Nar'Sie from destroying the station.</span>"
		if(BLOODCULT_STAGE_NARSIE)
			parts += "<span class = 'greentext big'>The cult has succeeded! Nar'Sie has snuffed out another torch in the void!</span>"

	if(members.len)
		parts += span_header("The cultists were:")
		if(length(true_cultists))
			parts += printplayerlist(true_cultists)
		else
			parts += printplayerlist(members)

	return "<div class = 'panel redborder'>[parts.Join("<br>")]</div>"

/// Sets a blood target for the cult.
/datum/team/cult/proc/set_blood_target(atom/new_target, mob/marker, duration = 90 SECONDS)
	if(QDELETED(new_target))
		CRASH("A null or invalid target was passed to set_blood_target.")

	if(duration != INFINITY && blood_target_reset_timer)
		return FALSE

	deltimer(blood_target_reset_timer)
	blood_target = new_target
	RegisterSignal(blood_target, COMSIG_QDELETING, PROC_REF(unset_blood_target_and_timer))
	var/area/target_area = get_area(new_target)

	blood_target_image = image('icons/effects/mouse_pointers/cult_target.dmi', new_target, "glow", ABOVE_MOB_LAYER)
	blood_target_image.appearance_flags = RESET_COLOR
	blood_target_image.pixel_x = -new_target.pixel_x
	blood_target_image.pixel_y = -new_target.pixel_y

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		to_chat(cultist.current, span_bold(span_cultlarge("[marker] has marked [blood_target] in the [target_area.name] as the cult's top priority, get there immediately!")))
		SEND_SOUND(cultist.current, sound(pick('sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg'), 0, 1, 75))
		cultist.current.client.images += blood_target_image

	if(duration != INFINITY)
		blood_target_reset_timer = addtimer(CALLBACK(src, PROC_REF(unset_blood_target)), duration, TIMER_STOPPABLE)
	return TRUE

/// Unsets our blood target when they get deleted.
/datum/team/cult/proc/unset_blood_target_and_timer(datum/source)
	SIGNAL_HANDLER

	deltimer(blood_target_reset_timer)
	unset_blood_target()

/// Unsets out blood target, clearing the images from all the cultists.
/datum/team/cult/proc/unset_blood_target()
	blood_target_reset_timer = null

	for(var/datum/mind/cultist as anything in members)
		if(!cultist.current)
			continue
		if(cultist.current.stat == DEAD || !cultist.current.client)
			continue

		if(QDELETED(blood_target))
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark's target is lost!")))
		else
			to_chat(cultist.current, span_bold(span_cultlarge("The blood mark has expired!")))
		cultist.current.client.images -= blood_target_image

	UnregisterSignal(blood_target, COMSIG_QDELETING)
	blood_target = null

	QDEL_NULL(blood_target_image)

/datum/antagonist/cult/antag_token(datum/mind/hosts_mind, mob/spender)
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.cult_team = get_team()
	new_cultist.give_equipment = TRUE
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type( /mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		new_mob.mind.add_antag_datum(new_cultist)
	else
		hosts_mind.add_antag_datum(new_cultist)

/datum/outfit/cultist
	name = "Cultist (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt
	r_hand = /obj/item/melee/blood_magic/stun

/datum/outfit/cultist/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	equipped.eye_color_left = BLOODCULT_EYE
	equipped.eye_color_right = BLOODCULT_EYE
	equipped.update_body()

#undef CULT_LOSS
#undef CULT_NARSIE_KILLED
#undef CULT_VICTORY
