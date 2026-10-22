/datum/antagonist/nukeop/commando
	name = ROLE_COMMANDO_OPERATIVE
	job_rank =  ROLE_COMMANDO_OPERATIVE
	show_to_ghosts = TRUE
	hijack_speed = 3 //If you can't take out the station, take the shuttle instead.
	remove_from_manifest = TRUE

	/// The DEFAULT outfit we will give to players granted this datum
	nukeop_outfit = /datum/outfit/syndicate/commando

	preview_outfit = /datum/outfit/commando_operative

	preview_outfit_behind = /datum/outfit/syndicate/junior

	/// In the preview icon, a nuclear fission explosive device, only appearing if there's an icon state for it.
	nuke_icon_state = "old_nuclearbomb_base"

/datum/antagonist/nukeop/commando/greet()
	play_stinger()
	to_chat(owner, span_big("You are a [nuke_team ? nuke_team.syndicate_name : "syndicate"] agent!"))
	owner.announce_objectives()

/datum/antagonist/nukeop/commando/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		var/obj/machinery/nuclearbomb/commando/nuke = locate() in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/commando)
		if(nuke)
			nuke_team.tracked_nuke = nuke
			nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Syndicate nuke not found during nuke team creation.")
			nuke_team.memorized_code = null

/// Gets the position we spawn at
/datum/antagonist/nukeop/commando/get_spawnpoint()
	var/team_number = 1
	if(nuke_team)
		team_number = nuke_team.members.Find(owner)

	return GLOB.commando_nukeop_start[((team_number - 1) % GLOB.nukeop_start.len) + 1]

/datum/antagonist/nukeop/commando/leader/get_spawnpoint()
	return pick(GLOB.commando_nukeop_leader_start)

/datum/antagonist/nukeop/commando/create_team(datum/team/nuclear/commando/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/nukeop/commando/N in GLOB.antagonists)
				if(!N.owner)
					stack_trace("Antagonist datum without owner in GLOB.antagonists: [N]")
					continue
				if(N.nuke_team && istype(N.nuke_team, /datum/team/nuclear/commando))
					nuke_team = N.nuke_team
					return
		nuke_team = new /datum/team/nuclear/commando
		nuke_team.update_objectives()
		assign_nuke() //This is bit ugly
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	nuke_team = new_team

/datum/antagonist/nukeop/commando/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.set_assigned_role(SSjob.GetJobType(/datum/job/commando_operative))
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has nuke op'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has nuke op'ed [key_name(new_owner)].")

/datum/antagonist/nukeop/commando/admin_send_to_base(mob/admin)
	owner.current.forceMove(pick(GLOB.commando_nukeop_start))

/datum/antagonist/nukeop/commando/admin_tell_code(mob/admin)
	var/code
	for (var/obj/machinery/nuclearbomb/commando/bombue as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/commando))
		if (length(bombue.r_code) <= 5 && bombue.r_code != initial(bombue.r_code))
			code = bombue.r_code
			break
	if (code)
		antag_memory += "<B>Syndicate Nuclear Bomb Code</B>: [code]<br>"
		to_chat(owner.current, "The nuclear authorization code is: <B>[code]</B>")
	else
		to_chat(admin, span_danger("No valid nuke found!"))

/datum/antagonist/nukeop/commando/leader
	name = "Commando Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/commando/leader
	always_new_team = TRUE
	var/title = "commander"

/datum/antagonist/nukeop/commando/leader/memorize_code()
	..()
	if(nuke_team?.memorized_code)
		var/obj/item/paper/nuke_code_paper = new
		nuke_code_paper.add_raw_text("The nuclear authorization code is: <b>[nuke_team.memorized_code]</b>")
		nuke_code_paper.add_raw_text("Standard decryption time with the given disk: 15 MINUTES <br>Decrypting in the designated areas or with a Nanotrasen NAD will lower the decryption time. <br>NT NAD: 8 MINUTES <br>DECRYPTION AREA: 5 MINUTES")
		nuke_code_paper.name = "nuclear bomb code"
		var/mob/living/carbon/human/H = owner.current
		if(!istype(H))
			nuke_code_paper.forceMove(get_turf(H))
		else
			H.put_in_hands(nuke_code_paper, TRUE)
			H.update_icons()

/datum/antagonist/nukeop/commando/leader/greet()
	play_stinger()
	to_chat(owner, "<span class='warningplain'><B>You are the Syndicate [title] for this mission. You are responsible for guiding the team.</B></span>")
	to_chat(owner, "<span class='warningplain'><B>If you feel you are not up to this task, give your disk and radio to another operative.</B></span>")
	owner.announce_objectives()

/datum/antagonist/nukeop/commando/leader/on_gain()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(nuketeam_name_assign)), 1)

/datum/antagonist/nukeop/commando/leader/proc/nuketeam_name_assign()
	if(!nuke_team)
		return
	nuke_team.rename_team(ask_name())

/datum/antagonist/nukeop/commando/leader/proc/ask_name()
	var/randomname = pick(GLOB.operative_aliases)
	var/newname = tgui_input_text(owner.current, "You are the commando operative [title]. Please choose an operator name for your team.", "Name change", randomname, MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	else
		newname = reject_bad_name(newname)
		if(!newname)
			newname = randomname

	return capitalize(newname)

/datum/antagonist/nukeop/commando/give_alias()
	if(nuke_team?.syndicate_name)
		var/mob/living/carbon/human/human_to_rename = owner.current
		if(istype(human_to_rename)) // Reinforcements get a real name
			var/first_name = owner.current.client?.prefs?.read_preference(/datum/preference/name/operative_alias) || pick(GLOB.operative_aliases)
			var/chosen_name = "[nuke_team.syndicate_name] [first_name] "
			human_to_rename.fully_replace_character_name(human_to_rename.real_name, chosen_name)
		else
			var/number = 1
			number = nuke_team.members.Find(owner)
			owner.current.real_name = "[nuke_team.syndicate_name] Operative #[number]"

/datum/outfit/commando_operative
	name = "Commando Operative (Preview only)"

	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack/fireproof
	head = /obj/item/clothing/head/helmet/space/syndicate/black/red
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/syndicate/black/red
	suit_store = /obj/item/tank/jetpack/harness
	belt = /obj/item/storage/belt/military

/datum/team/nuclear/commando

/datum/team/nuclear/commando/rename_team(new_name)
	syndicate_name = new_name
	name = "[syndicate_name] Operators"
	for(var/I in members)
		var/datum/mind/synd_mind = I
		var/mob/living/carbon/human/human_to_rename = synd_mind.current
		if(!istype(human_to_rename))
			continue
		var/first_name = human_to_rename.client?.prefs?.read_preference(/datum/preference/name/operative_alias) || pick(GLOB.operative_aliases)
		var/chosen_name = "[syndicate_name] [first_name]"
		human_to_rename.fully_replace_character_name(human_to_rename.real_name, chosen_name)

/datum/team/nuclear/commando/get_result()
	var/shuttle_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/shuttle_landed_base = SSshuttle.emergency.is_hijacked()
	var/syndies_didnt_escape = !is_infiltrator_docked_at_syndiebase()
	var/team_is_dead = are_all_operatives_dead()
	var/station_was_nuked = GLOB.station_was_nuked
	var/station_nuke_source = GLOB.station_nuke_source

	// The station was nuked
	if(station_was_nuked)
		return NUKE_RESULT_NUKE_WIN

	// The station was not nuked, but something was
	if(station_nuke_source == DETONATION_MISSED_STATION)
		// The station was not nuked, but something was, and the syndicates didn't escape it
		if(syndies_didnt_escape)
			return NUKE_RESULT_WRONG_STATION_DEAD
		// The station was not nuked, but something was, and the syndicates returned to their base
		else
			return NUKE_RESULT_WRONG_STATION

	// Nuke didn't blow, but nukies somehow hijacked the emergency shuttle to land at the base anyways.
	if(shuttle_landed_base)
		return NUKE_RESULT_HIJACK_NO_DISK

		// No nuke went off, the shuttle left, and the team is dead
	if(shuttle_evacuated && team_is_dead)
		if(team_is_dead)
			return NUKE_RESULT_CREW_WIN_SYNDIES_DEAD
		else
		// No nuke went off, but the nuke ops survived
			return NUKE_RESULT_CREW_WIN

	CRASH("[type] - got an undefined / unexpected result.")

/datum/team/nuclear/commando/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>[syndicate_name] Operatives:</span>"

	switch(get_result())
		if(NUKE_RESULT_NUKE_WIN)
			parts += "<span class='greentext big'>Syndicate Major Victory!</span>"
			parts += "<B>[syndicate_name] operatives have destroyed [station_name()]!</B>"
		if(NUKE_RESULT_WRONG_STATION)
			parts += "<span class='redtext big'>Crew Minor Victory!</span>"
			parts += "<B>[syndicate_name] operatives blew up something that wasn't [station_name()].</B> Next time, don't do that!"
		if(NUKE_RESULT_WRONG_STATION_DEAD)
			parts += "<span class='redtext big'>Humiliating Syndicate Defeat!</span>"
			parts += "<B>[syndicate_name] operatives blew up something that wasn't [station_name()] and got themselves all killed.</B> How did you even manage that?!"
		if(NUKE_RESULT_HIJACK_NO_DISK)
			parts += "<span class='greentext big'>Syndicate Minior Victory!</span>"
			parts += "<B>[syndicate_name] operatives failed to destroy [station_name()], but hijack the emergency shuttle, causing it to land on the syndicate base. Good job?</B>"
		if(NUKE_RESULT_CREW_WIN_SYNDIES_DEAD)
			parts += "<span class='redtext big'>Crew Major Victory!</span>"
			parts += "<B>The Research Staff has saved the station and killed the [syndicate_name] operatives</B>"
		if(NUKE_RESULT_CREW_WIN)
			parts += "<span class='redtext big'>Crew Major Victory!</span>"
			parts += "<B>The Research Staff has stopped the [syndicate_name] operatives!</B>"
		else
			parts += "<span class='neutraltext big'>Neutral Victory</span>"
			parts += "<B>Mission aborted!</B>"

	var/text = "<br><span class='header'>The syndicate operatives were:</span>"
	text += printplayerlist(members)
	text += "<br>"

	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/nuclear/commando/antag_listing_entry()
	var/disk_report = "<b>Nuclear Disk(s)</b><br>"
	disk_report += "<table cellspacing=5>"
	for(var/obj/item/disk/nuclear/N in SSpoints_of_interest.real_nuclear_disks)
		disk_report += "<tr><td>[N.name], "
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				disk_report += "carried by <a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a> "
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				disk_report += "in \a [O.name] "
			disk_loc = disk_loc.loc
		disk_report += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td><td><a href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(N)]'>FLW</a></td></tr>"
	disk_report += "</table>"
	var/common_part = ..()
	return common_part + disk_report
