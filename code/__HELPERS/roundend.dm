#define POPCOUNT_SURVIVORS "survivors" //Not dead at roundend
#define POPCOUNT_ESCAPEES "escapees" //Not dead and on centcom/shuttles marked as escaped
#define POPCOUNT_SHUTTLE_ESCAPEES "shuttle_escapees" //Emergency shuttle only.
#define POPCOUNT_ESCAPEES_HUMANONLY "human_escapees"
#define PERSONAL_LAST_ROUND "personal last round"
#define SERVER_LAST_ROUND "server last round"
#define DISCORD_SUPPRESS_NOTIFICATIONS (1 << 12) // monke edit: discord flag for silent messages

GLOBAL_LIST_INIT(achievements_unlocked, list())

GLOBAL_LIST_INIT(round_end_images, world.file2list("data/image_urls.txt")) // MONKEYSTATION EDIT ADDITION PR #11 - update roundend.dm

/datum/controller/subsystem/ticker/proc/gather_roundend_feedback()
	gather_antag_data()
	record_nuke_disk_location()
	var/json_file = file("[GLOB.log_directory]/round_end_data.json")
	// All but npcs sublists and ghost category contain only mobs with minds
	var/list/file_data = list("escapees" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "abandoned" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()), "ghosts" = list(), "additional data" = list())
	var/num_survivors = 0 //Count of non-brain non-camera mobs with mind that are alive
	var/num_escapees = 0 //Above and on centcom z
	var/num_human_escapees = 0 //Above but humans only
	var/num_shuttle_escapees = 0 //Above and on escape shuttle
	var/list/list_of_human_escapees = list() //References to all escaped humans
	var/list/list_of_mobs_on_shuttle = list()
	var/list/area/shuttle_areas
	if(SSshuttle?.emergency)
		shuttle_areas = SSshuttle.emergency.shuttle_areas

	for(var/mob/M in GLOB.mob_list)
		var/list/mob_data = list()
		if(isnewplayer(M))
			continue

		var/escape_status = "abandoned" //default to abandoned
		var/category = "npcs" //Default to simple count only bracket
		var/count_only = TRUE //Count by name only or full info

		mob_data["name"] = M.name
		if(M.mind)
			count_only = FALSE
			mob_data["ckey"] = M.mind.key
			if(M.onCentCom())
				list_of_mobs_on_shuttle += M
			if(M.stat != DEAD && !isbrain(M) && !iscameramob(M))
				num_survivors++
				if(EMERGENCY_ESCAPED_OR_ENDGAMED && (M.onCentCom() || M.onSyndieBase()))
					num_escapees++
					escape_status = "escapees"
					if(shuttle_areas[get_area(M)])
						num_shuttle_escapees++
						if(ishuman(M))
							num_human_escapees++
							list_of_human_escapees += M
			if(isliving(M))
				var/mob/living/L = M
				mob_data["location"] = get_area(L)
				mob_data["health"] = L.health
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					category = "humans"
					if(H.mind)
						mob_data["job"] = H.mind.assigned_role.title
					else
						mob_data["job"] = "Unknown"
					mob_data["species"] = H.dna.species.name
				else if(issilicon(L))
					category = "silicons"
					if(isAI(L))
						mob_data["module"] = "AI"
					else if(ispAI(L))
						mob_data["module"] = "pAI"
					else if(iscyborg(L))
						var/mob/living/silicon/robot/R = L
						mob_data["module"] = (R.model ? R.model.name : "Null Model")
				else
					category = "others"
					mob_data["typepath"] = M.type
		//Ghosts don't care about minds, but we want to retain ckey data etc
		if(isobserver(M))
			count_only = FALSE
			escape_status = "ghosts"
			if(!M.mind)
				mob_data["ckey"] = M.key
			category = null //ghosts are one list deep
		//All other mindless stuff just gets counts by name
		if(count_only)
			var/list/npc_nest = file_data["[escape_status]"]["npcs"]
			var/name_to_use = initial(M.name)
			if(ishuman(M))
				name_to_use = "Unknown Human" //Monkeymen and other mindless corpses
			if(npc_nest.Find(name_to_use))
				file_data["[escape_status]"]["npcs"][name_to_use] += 1
			else
				file_data["[escape_status]"]["npcs"][name_to_use] = 1
		else
			//Mobs with minds and ghosts get detailed data
			if(category)
				var/pos = length(file_data["[escape_status]"]["[category]"]) + 1
				file_data["[escape_status]"]["[category]"]["[pos]"] = mob_data
			else
				var/pos = length(file_data["[escape_status]"]) + 1
				file_data["[escape_status]"]["[pos]"] = mob_data

	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	roundend_station_integrity = min(PERCENT(GLOB.start_state.score(end_state)), 100)
	file_data["additional data"]["station integrity"] = roundend_station_integrity
	WRITE_FILE(json_file, json_encode(file_data))

	SSblackbox.record_feedback("nested tally", "round_end_stats", num_survivors, list("survivors", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", num_escapees, list("escapees", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len, list("players", "total"))
	SSblackbox.record_feedback("nested tally", "round_end_stats", GLOB.joined_player_list.len - num_survivors, list("players", "dead"))
	. = list()
	.[POPCOUNT_SURVIVORS] = num_survivors
	.[POPCOUNT_ESCAPEES] = num_escapees
	.[POPCOUNT_ESCAPEES_HUMANONLY] = num_human_escapees
	.[POPCOUNT_SHUTTLE_ESCAPEES] = num_shuttle_escapees
	.["all_mobs_on_shuttle"] = list_of_mobs_on_shuttle
	.["human_escapees_list"] = list_of_human_escapees
	.["station_integrity"] = roundend_station_integrity

/datum/controller/subsystem/ticker/proc/gather_antag_data()
	var/team_gid = 1
	var/list/team_ids = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue

		var/list/antag_info = list()
		antag_info["key"] = A.owner.key
		antag_info["name"] = A.owner.name
		antag_info["antagonist_type"] = A.type
		antag_info["antagonist_name"] = A.name //For auto and custom roles
		antag_info["objectives"] = list()
		antag_info["team"] = list()
		var/datum/team/T = A.get_team()
		if(T)
			antag_info["team"]["type"] = T.type
			antag_info["team"]["name"] = T.name
			if(!team_ids[T])
				team_ids[T] = team_gid++
			antag_info["team"]["id"] = team_ids[T]

		if(A.objectives.len)
			for(var/datum/objective/O in A.objectives)
				var/result = O.check_completion() ? "SUCCESS" : "FAIL"
				antag_info["objectives"] += list(list("objective_type"=O.type,"text"=O.explanation_text,"result"=result))
		SSblackbox.record_feedback("associative", "antagonists", 1, antag_info)

/datum/controller/subsystem/ticker/proc/record_nuke_disk_location()
	var/disk_count = 1
	for(var/obj/item/disk/nuclear/nuke_disk as anything in SSpoints_of_interest.real_nuclear_disks)
		var/list/data = list()
		var/turf/disk_turf = get_turf(nuke_disk)
		if(disk_turf)
			data["x"] = disk_turf.x
			data["y"] = disk_turf.y
			data["z"] = disk_turf.z
		var/atom/outer = get_atom_on_turf(nuke_disk, /mob/living)
		if(outer != nuke_disk)
			if(isliving(outer))
				var/mob/living/disk_holder = outer
				data["holder"] = disk_holder.real_name
			else
				data["holder"] = outer.name

		SSblackbox.record_feedback("associative", "roundend_nukedisk", disk_count, data)
		disk_count++

/datum/controller/subsystem/ticker/proc/gather_newscaster()
	var/json_file = file("[GLOB.log_directory]/newscaster.json")
	var/list/file_data = list()
	var/pos = 1
	for(var/V in GLOB.news_network.network_channels)
		var/datum/feed_channel/channel = V
		if(!istype(channel))
			stack_trace("Non-channel in newscaster channel list")
			continue
		file_data["[pos]"] = list("channel name" = "[channel.channel_name]", "author" = "[channel.author]", "censored" = channel.censored ? 1 : 0, "author censored" = channel.author_censor ? 1 : 0, "messages" = list())
		for(var/M in channel.messages)
			var/datum/feed_message/message = M
			if(!istype(message))
				stack_trace("Non-message in newscaster channel messages list")
				continue
			var/list/comment_data = list()
			for(var/C in message.comments)
				var/datum/feed_comment/comment = C
				if(!istype(comment))
					stack_trace("Non-message in newscaster message comments list")
					continue
				comment_data += list(list("author" = "[comment.author]", "time stamp" = "[comment.time_stamp]", "body" = "[comment.body]"))
			file_data["[pos]"]["messages"] += list(list("author" = "[message.author]", "time stamp" = "[message.time_stamp]", "censored" = message.body_censor ? 1 : 0, "author censored" = message.author_censor ? 1 : 0, "photo file" = "[message.photo_file]", "photo caption" = "[message.caption]", "body" = "[message.body]", "comments" = comment_data))
		pos++
	if(GLOB.news_network.wanted_issue.active)
		file_data["wanted"] = list("author" = "[GLOB.news_network.wanted_issue.scanned_user]", "criminal" = "[GLOB.news_network.wanted_issue.criminal]", "description" = "[GLOB.news_network.wanted_issue.body]", "photo file" = "[GLOB.news_network.wanted_issue.photo_file]")
	WRITE_FILE(json_file, json_encode(file_data))

///Handles random hardcore point rewarding if it applies.
/datum/controller/subsystem/ticker/proc/HandleRandomHardcoreScore(client/player_client)
	if(!ishuman(player_client?.mob))
		return FALSE
	var/mob/living/carbon/human/human_mob = player_client.mob
	if(!human_mob.hardcore_survival_score) ///no score no glory
		return FALSE

	if(human_mob.mind && (human_mob.mind.special_role || length(human_mob.mind.antag_datums) > 0))
		for(var/datum/antagonist/antag_datums as anything in human_mob.mind.antag_datums)
			if(initial(antag_datums.can_assign_self_objectives) && !antag_datums.can_assign_self_objectives)
				return FALSE // You don't get a prize if you picked your own objective, you can't fail those
			for(var/datum/objective/objective_datum as anything in antag_datums.objectives)
				if(!objective_datum.check_completion())
					return FALSE
		player_client.give_award(/datum/award/score/hardcore_random, human_mob, round(human_mob.hardcore_survival_score * 2))
	else if(considered_escaped(human_mob.mind))
		player_client.give_award(/datum/award/score/hardcore_random, human_mob, round(human_mob.hardcore_survival_score))

/datum/controller/subsystem/ticker/proc/declare_completion(was_forced = END_ROUND_AS_NORMAL)
	set waitfor = FALSE

	INVOKE_ASYNC(Tracy, TYPE_PROC_REF(/datum/tracy, flush)) // monkestation edit: byond-tracy

	for(var/datum/callback/roundend_callbacks as anything in round_end_events)
		roundend_callbacks.InvokeAsync()
	LAZYCLEARLIST(round_end_events)

	var/speed_round = (STATION_TIME_PASSED() <= 10 MINUTES)

	var/list/rewards = calculate_rewards()

	popcount = gather_roundend_feedback()

	for(var/client/C in GLOB.clients)
		C?.playtitlemusic(40)
		if(speed_round && was_forced != ADMIN_FORCE_END_ROUND)
			C?.give_award(/datum/award/achievement/misc/speed_round, C?.mob)
		HandleRandomHardcoreScore(C)

	RollCredits()

	display_report(popcount)

	CHECK_TICK

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/datum/atom_hud/alternate_appearance/basic/antagonist_hud/antagonist_hud in GLOB.active_alternate_appearances)
		for(var/mob/player as anything in GLOB.player_list)
			antagonist_hud.show_to(player)

	CHECK_TICK

	//Set news report and mode result
	mode.set_round_result()
	SSgamemode.round_end_report()
	SSgamemode.store_roundend_data() // store data on roundend for next round

	to_chat(world, span_infoplain(span_big(span_bold("<BR><BR><BR>The round has ended."))))
	log_game("The round has ended.")
	send2chat(new /datum/tgs_message_content("[GLOB.round_id ? "Round [GLOB.round_id]" : "The round has"] just ended."), CONFIG_GET(string/channel_announce_end_game))
	send2adminchat("Server", "Round just ended.")


	if(length(CONFIG_GET(keyed_list/cross_server)))
		send_news_report()

	CHECK_TICK

	handle_hearts()
	set_observer_default_invisibility(0, span_warning("The round is over! You are now visible to the living."))

	CHECK_TICK

	//These need update to actually reflect the real antagonists
	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(!(A.name in total_antagonists))
			total_antagonists[A.name] = list()
		total_antagonists[A.name] += "[key_name(A.owner)]"

	CHECK_TICK

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/antag_name in total_antagonists)
		var/list/L = total_antagonists[antag_name]
		log_game("[antag_name]s :[L.Join(", ")].")

	CHECK_TICK
	SSdbcore.SetRoundEnd()

	//Collects persistence features
	SSpersistence.collect_data()
	SSpersistent_paintings.save_paintings()

	//stop collecting feedback during grifftime
	SSblackbox.Seal()

	// monkestation start: token backups, monkecoin rewards, challenges, and roundend webhook
	save_tokens()
	refund_cassette()
	distribute_rewards(rewards)
	sleep(5 SECONDS)
	ready_for_reboot = TRUE
	var/datum/discord_embed/embed = format_roundend_embed("<@&999008528595419278>")
	send2roundend_webhook(embed)
	SSplexora.roundended()
	// monkestation end
	standard_reboot()

/datum/controller/subsystem/ticker/proc/format_roundend_embed(message)
	var/datum/discord_embed/embed = new()
	embed.title = "Round End"
	embed.description = CONFIG_GET(string/roundend_webhook_description)
	embed.author = "Round Controller"
	embed.content = CONFIG_GET(string/roundend_webhook_content)
	if(length(GLOB.round_end_images))
		embed.image = pick(GLOB.round_end_images)
	var/round_state = "Round has ended"

	var/player_count = "**Total**: [length(GLOB.clients)], **Living**: [length(GLOB.alive_player_list)], **Dead**: [length(GLOB.dead_player_list)], **Observers**: [length(GLOB.current_observers_list)]"
	embed.fields = list(
		"PLAYERS" = player_count,
		"ROUND STATE" = round_state,
		"ROUND ID" = GLOB.round_id,
		"ROUND TIME" = ROUND_TIME(),
		"MESSAGE" = message,
	)
	return embed

/datum/controller/subsystem/ticker/proc/send2roundend_webhook(message_or_embed)
	var/webhook = CONFIG_GET(string/regular_roundend_webhook_url)

	if(!webhook)
		return
	var/list/webhook_info = list()
	if(istext(message_or_embed))
		var/message_content = replacetext(replacetext(message_or_embed, "\proper", ""), "\improper", "")
		message_content = GLOB.has_discord_embeddable_links.Replace(replacetext(message_content, "`", ""), " ```$1``` ")
		webhook_info["content"] = message_content
	else
		var/datum/discord_embed/embed = message_or_embed
		webhook_info["embeds"] = list(embed.convert_to_list())
		if(embed.content)
			webhook_info["content"] = embed.content
	if(CONFIG_GET(string/mentorhelp_webhook_name))
		webhook_info["username"] = CONFIG_GET(string/roundend_webhook_name)
	if(CONFIG_GET(string/mentorhelp_webhook_pfp))
		webhook_info["avatar_url"] = CONFIG_GET(string/roundend_webhook_pfp)
	webhook_info["flags"] = DISCORD_SUPPRESS_NOTIFICATIONS
	// Uncomment when servers are moved to TGS4
	// send2chat(new /datum/tgs_message_conent("[initiator_ckey] | [message_content]"), "ahelp", TRUE)
	var/list/headers = list()
	headers["Content-Type"] = "application/json"
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, webhook, json_encode(webhook_info), headers, "tmp/response.json")
	request.begin_async()

/datum/controller/subsystem/ticker/proc/standard_reboot()
	Tracy.flush() // monkestation edit: byond-tracy
	if(ready_for_reboot)
		if(GLOB.station_was_nuked)
			Reboot("Station destroyed by Nuclear Device.", "nuke")
		else
			Reboot("Round ended.", "proper completion")
	else
		CRASH("Attempted standard reboot without ticker roundend completion")

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	//might want to make this a full section, monkestation edit
	parts += "<div class='panel stationborder'><span class='header'>[("Storyteller: [SSgamemode.current_storyteller ? SSgamemode.current_storyteller.name : "N/A"]")]</span></div>"

	//AI laws
	parts += law_report()

	CHECK_TICK

	//Antagonists
	parts += antag_report()

	parts += opfor_report()

	parts += hardcore_random_report()

	CHECK_TICK
	//Medals
	parts += medal_report()
	//Station Goals
	parts += goal_report()
	//Economy & Money
	parts += market_report()
	//Player Achievements
	parts += cheevo_report()

	list_clear_nulls(parts)

	return parts.Join()

/datum/controller/subsystem/ticker/proc/survivor_report(popcount)
	var/list/parts = list()
	var/station_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED

	if(GLOB.round_id)
		var/statspage = CONFIG_GET(string/roundstatsurl)
		var/info = statspage ? "<a href='byond://?action=openLink&link=[url_encode(statspage)][GLOB.round_id]'>[GLOB.round_id]</a>" : GLOB.round_id
		parts += "[FOURSPACES]Round ID: <b>[info]</b>"
	parts += "[FOURSPACES]Shift Duration: <B>[DisplayTimeText(world.time - SSticker.round_start_time)]</B>"
	parts += "[FOURSPACES]Station Integrity: <B>[GLOB.station_was_nuked ? span_redtext("Destroyed") : "[popcount["station_integrity"]]%"]</B>"
	var/total_players = GLOB.joined_player_list.len
	if(total_players)
		parts+= "[FOURSPACES]Total Population: <B>[total_players]</B>"
		if(station_evacuated)
			parts += "<BR>[FOURSPACES]Evacuation Rate: <B>[popcount[POPCOUNT_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_ESCAPEES]/total_players)]%)</B>"
			parts += "[FOURSPACES](on emergency shuttle): <B>[popcount[POPCOUNT_SHUTTLE_ESCAPEES]] ([PERCENT(popcount[POPCOUNT_SHUTTLE_ESCAPEES]/total_players)]%)</B>"
		parts += "[FOURSPACES]Survival Rate: <B>[popcount[POPCOUNT_SURVIVORS]] ([PERCENT(popcount[POPCOUNT_SURVIVORS]/total_players)]%)</B>"
		if(SSblackbox.first_death)
			var/list/ded = SSblackbox.first_death
			if(ded.len)
				parts += "[FOURSPACES]First Death: <b>[ded["name"]], [ded["role"]], at [ded["area"]]. Damage taken: [ded["damage"]].[ded["last_words"] ? " Their last words were: \"[ded["last_words"]]\"" : ""]</b>"
			//ignore this comment, it fixes the broken sytax parsing caused by the " above
			else
				parts += "[FOURSPACES]<i>Nobody died this shift!</i>"
	if(istype(SSticker.mode, /datum/game_mode/dynamic))
		var/datum/game_mode/dynamic/mode = SSticker.mode
		parts += "[FOURSPACES]Threat level: [mode.threat_level]"
		parts += "[FOURSPACES]Threat left: [mode.mid_round_budget]"
		if(mode.roundend_threat_log.len)
			parts += "[FOURSPACES]Threat edits:"
			for(var/entry as anything in mode.roundend_threat_log)
				parts += "[FOURSPACES][FOURSPACES][entry]<BR>"
		parts += "[FOURSPACES]Executed rules:"
		for(var/datum/dynamic_ruleset/rule in mode.executed_rules)
			parts += "[FOURSPACES][FOURSPACES][rule.ruletype] - <b>[rule.name]</b>: -[rule.cost + rule.scaled_times * rule.scaling_cost] threat"
	return parts.Join("<br>")

/client/proc/roundend_report_file()
	return "data/roundend_reports/[ckey].html"

/**
 * Log the round-end report as an HTML file
 *
 * Composits the roundend report, and saves it in two locations.
 * The report is first saved along with the round's logs
 * Then, the report is copied to a fixed directory specifically for
 * housing the server's last roundend report. In this location,
 * the file will be overwritten at the end of each shift.
 */
/datum/controller/subsystem/ticker/proc/log_roundend_report()
	var/roundend_file = file("[GLOB.log_directory]/round_end_data.html")
	var/list/parts = list()
	parts += "<div class='panel stationborder'>"
	parts += GLOB.survivor_report
	parts += "</div>"
	parts += GLOB.common_report
	var/content = parts.Join()
	//Log the rendered HTML in the round log directory
	fdel(roundend_file)
	WRITE_FILE(roundend_file, content)
	//Place a copy in the root folder, to be overwritten each round.
	roundend_file = file("data/server_last_roundend_report.html")
	fdel(roundend_file)
	WRITE_FILE(roundend_file, content)

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, report_type = null)
	var/datum/browser/roundend_report = new(C, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(report_type == PERSONAL_LAST_ROUND) //Look at this player's last round
		content = file2text(filename)
	else if (report_type == SERVER_LAST_ROUND) //Look at the last round that this server has seen
		content = file2text("data/server_last_roundend_report.html")
	else //report_type is null, so make a new report based on the current round and show that to the player
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		fdel(filename)
		text2file(content, filename)

	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	roundend_report.open(FALSE)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/M = C.mob
	if(M.mind && !isnewplayer(M))
		if(M.stat != DEAD && !isbrain(M))
			if(EMERGENCY_ESCAPED_OR_ENDGAMED)
				if(!M.onCentCom() && !M.onSyndieBase())
					parts += "<div class='panel stationborder'>"
					parts += "<span class='marooned'>You managed to survive, but were marooned on [station_name()]...</span>"
				else
					parts += "<div class='panel greenborder'>"
					parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")
			else
				parts += "<div class='panel greenborder'>"
				parts += span_greentext("You managed to survive the events on [station_name()] as [M.real_name].")

		else
			parts += "<div class='panel redborder'>"
			parts += span_redtext("You did not survive the events on [station_name()]...")
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += GLOB.survivor_report
	parts += "</div>"

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report(popcount)
	GLOB.common_report = build_roundend_report()
	GLOB.survivor_report = survivor_report(popcount)
	log_roundend_report()
	for(var/client/C in GLOB.clients)
		show_roundend_report(C)
		give_show_report_button(C)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/law_report()
	var/list/parts = list()
	var/borg_spacer = FALSE //inserts an extra linebreak to separate AIs from independent borgs, and then multiple independent borgs.
	//Silicon laws report
	for (var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/aiPlayer = i
		var/datum/mind/aiMind = aiPlayer.deployed_shell?.mind || aiPlayer.mind
		if(aiMind)
			parts += "<b>[aiPlayer.name]</b> (Played by: <b>[aiMind.key]</b>)'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was [span_redtext("deactivated")]"] were:"
			parts += aiPlayer.laws.get_law_list(include_zeroth=TRUE)

		parts += "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if (aiPlayer.connected_robots.len)
			var/borg_num = aiPlayer.connected_robots.len
			parts += "<br><b>[aiPlayer.real_name]</b>'s minions were:"
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				borg_num--
				if(robo.mind)
					parts += "<b>[robo.name]</b> (Played by: <b>[robo.mind.key]</b>)[robo.stat == DEAD ? " [span_redtext("(Deactivated)")]" : ""][borg_num ?", ":""]"
		if(!borg_spacer)
			borg_spacer = TRUE

	for (var/mob/living/silicon/robot/robo in GLOB.silicon_mobs)
		if (!robo.connected_ai && robo.mind)
			parts += "[borg_spacer?"<br>":""]<b>[robo.name]</b> (Played by: <b>[robo.mind.key]</b>) [(robo.stat != DEAD)? "[span_greentext("survived")] as an AI-less borg!" : "was [span_redtext("unable to survive")] the rigors of being a cyborg without an AI."] Its laws were:"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				parts += robo.laws.get_law_list(include_zeroth=TRUE)

			if(!borg_spacer)
				borg_spacer = TRUE

	if(parts.len)
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	else
		return ""

/datum/controller/subsystem/ticker/proc/goal_report()
	var/list/parts = list()
	if(GLOB.station_goals.len)
		for(var/datum/station_goal/goal as anything in GLOB.station_goals)
			parts += goal.get_result()
		return "<div class='panel stationborder'><ul>[parts.Join()]</ul></div>"

///Generate a report for how much money is on station, as well as the richest crewmember on the station.
/datum/controller/subsystem/ticker/proc/market_report()
	var/list/parts = list()

	///total service income
	var/tourist_income = 0
	///This is the richest account on station at roundend.
	var/datum/bank_account/mr_moneybags
	///This is the station's total wealth at the end of the round.
	var/station_vault = 0
	///How many players joined the round.
	var/total_players = GLOB.joined_player_list.len
	var/static/list/typecache_bank = typecacheof(list(/datum/bank_account/department, /datum/bank_account/remote))
	for(var/i in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/current_acc = SSeconomy.bank_accounts_by_id[i]
		if(typecache_bank[current_acc.type])
			continue
		station_vault += current_acc.account_balance
		if(!mr_moneybags || mr_moneybags.account_balance < current_acc.account_balance)
			mr_moneybags = current_acc
	parts += "<div class='panel stationborder'><span class='header'>Station Economic Summary:</span><br>"
	parts += "<span class='service'>Service Statistics:</span><br>"
	for(var/venue_path in SSrestaurant.all_venues)
		var/datum/venue/venue = SSrestaurant.all_venues[venue_path]
		tourist_income += venue.total_income
		parts += "The [venue] served [venue.customers_served] customer\s and made [venue.total_income] credits.<br>"
	parts += "In total, they earned [tourist_income] credits[tourist_income ? "!" : "..."]<br>"
	log_econ("Roundend service income: [tourist_income] credits.")
	switch(tourist_income)
		if(0)
			parts += "[span_redtext("Service did not earn any credits...")]<br>"
		if(1 to 2000)
			parts += "[span_redtext("Centcom is displeased. Come on service, surely you can do better than that.")]<br>"
			award_service(/datum/award/achievement/jobs/service_bad)
		if(2001 to 4999)
			parts += "[span_greentext("Centcom is satisfied with service's job today.")]<br>"
			award_service(/datum/award/achievement/jobs/service_okay)
		else
			parts += "<span class='reallybig greentext'>Centcom is incredibly impressed with service today! What a team!</span><br>"
			award_service(/datum/award/achievement/jobs/service_good)

	parts += "<b>General Statistics:</b><br>"
	parts += "There were [station_vault] credits collected by crew this shift.<br>"
	if(total_players > 0)
		parts += "An average of [station_vault/total_players] credits were collected.<br>"
		log_econ("Roundend credit total: [station_vault] credits. Average Credits: [station_vault/total_players]")
	if(mr_moneybags)
		parts += "The most affluent crew member at shift end was <b>[mr_moneybags.account_holder] with [mr_moneybags.account_balance]</b> cr!</div>"
	else
		parts += "Somehow, nobody made any money this shift! This'll result in some budget cuts...</div>"
	return parts

/**
 * Awards the service department an achievement and updates the chef and bartender's highscore for tourists served.
 *
 * Arguments:
 * * award: Achievement to give service department
 */
/datum/controller/subsystem/ticker/proc/award_service(award)
	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		if(!human.client || !human.mind)
			continue
		var/datum/job/human_job = human.mind.assigned_role
		if(!(human_job.departments_bitflags & DEPARTMENT_BITFLAG_SERVICE))
			continue
		human_job.award_service(human.client, award)


/datum/controller/subsystem/ticker/proc/medal_report()
	if(GLOB.commendations.len)
		var/list/parts = list()
		parts += "<span class='header'>Medal Commendations:</span>"
		for (var/com in GLOB.commendations)
			parts += com
		return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"
	return ""

///Generate a report for all players who made it out alive with a hardcore random character and prints their final score
/datum/controller/subsystem/ticker/proc/hardcore_random_report()
	. = list()
	var/list/hardcores = list()
	for(var/i in GLOB.player_list)
		if(!ishuman(i))
			continue
		var/mob/living/carbon/human/human_player = i
		if(!human_player.hardcore_survival_score || !human_player.onCentCom() || human_player.stat == DEAD) ///gotta escape nerd
			continue
		if(!human_player.mind)
			continue
		hardcores += human_player
	if(!length(hardcores))
		return
	. += "<div class='panel stationborder'><span class='header'>The following people made it out as a random hardcore character:</span>"
	. += "<ul class='playerlist'>"
	for(var/mob/living/carbon/human/human_player in hardcores)
		. += "<li>[printplayer(human_player.mind)] with a hardcore random score of [round(human_player.hardcore_survival_score)]</li>"
	. += "</ul></div>"

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/result = list()
	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/team/team as anything in GLOB.antagonist_teams)
		if(!istype(team))
			stack_trace("Non-team ([team?.type]) found in GLOB.antagonist_teams!")
			continue
		all_teams |= team

	for(var/datum/antagonist/antagonists as anything in GLOB.antagonists)
		if(!istype(antagonists))
			stack_trace("Non-antagonist ([antagonists?.type]) found in GLOB.antagonists!")
			continue
		if(!antagonists.owner)
			continue
		all_antagonists |= antagonists

	for(var/datum/team/active_teams as anything in all_teams)
		//check if we should show the team
		if(!active_teams.show_roundend_report)
			all_teams -= active_teams
			continue
		result += active_teams.roundend_report()
		result += " "//newline between teams
		CHECK_TICK

	var/currrent_category
	var/datum/antagonist/previous_category

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	for(var/datum/antagonist/antagonists in all_antagonists)
		if(!antagonists.show_in_roundend)
			continue
		// if the antag datum is associated with a team that appeared in the report, skip it.
		var/datum/team/antag_team = antagonists.get_team()
		if(!isnull(antag_team) && (antag_team in all_teams))
			continue
		if(antagonists.roundend_category != currrent_category)
			if(previous_category)
				result += previous_category.roundend_report_footer()
				result += "</div>"
			result += "<div class='panel redborder'>"
			result += antagonists.roundend_report_header()
			currrent_category = antagonists.roundend_category
			previous_category = antagonists
		result += antagonists.roundend_report()
		result += "<br><br>"
		CHECK_TICK

	if(length(all_antagonists))
		var/datum/antagonist/last = all_antagonists[length(all_antagonists)]
		result += last.roundend_report_footer()
		result += "</div>"

	return result.Join()

/proc/cmp_antag_category(datum/antagonist/A,datum/antagonist/B)
	return sorttext(B.roundend_category,A.roundend_category)


/datum/controller/subsystem/ticker/proc/give_show_report_button(client/C)
	var/datum/action/report/R = new
	C.persistent_client.player_actions += R
	R.Grant(C.mob)
	to_chat(C,"<span class='infoplain'><a href='byond://?src=[REF(R)];report=1'>Show roundend report again</a></span>")

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "round_end"
	show_to_observers = FALSE

/datum/action/report/Trigger(trigger_flags)
	if(owner && GLOB.common_report && SSticker.current_state == GAME_STATE_FINISHED)
		SSticker.show_roundend_report(owner.client)

/datum/action/report/IsAvailable(feedback = FALSE)
	return TRUE

/datum/action/report/Topic(href,href_list)
	if(usr != owner)
		return
	if(href_list["report"])
		Trigger()
		return


/proc/printplayer(datum/mind/ply, fleecheck)
	var/jobtext = ""
	if(!is_unassigned_job(ply.assigned_role))
		jobtext = " the <b>[ply.assigned_role.title]</b>"
	var/text = "<b>[ply.key]</b> was <b>[ply.name]</b>[jobtext] and"
	if(ply.current)
		if(ply.current.stat == DEAD)
			text += " [span_redtext("died")]"
		else
			text += " [span_greentext("survived")]"
		if(fleecheck)
			var/turf/T = get_turf(ply.current)
			if(!T || !is_station_level(T.z))
				text += " while [span_redtext("fleeing the station")]"
		if(ply.current.real_name != ply.name)
			text += " as <b>[ply.current.real_name]</b>"
	else
		text += " [span_redtext("had their body destroyed")]"
	return text

/proc/printplayerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printplayer(M,fleecheck)]</li>"
	parts += "</ul>"
	return parts.Join()


/proc/printobjectives(list/objectives)
	if(!objectives || !objectives.len)
		return
	var/list/objective_parts = list()
	var/count = 1
	for(var/datum/objective/objective in objectives)
		objective_parts += "<b>[objective.objective_name] #[count]</b>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"
		count++
	return objective_parts.Join("<br>")

/datum/controller/subsystem/ticker/proc/save_admin_data()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Admin rank DB Sync blocked: Advanced ProcCall detected.</span>")
		return
	if(CONFIG_GET(flag/admin_legacy_system)) //we're already using legacy system so there's nothing to save
		return
	else if(load_admins(TRUE)) //returns true if there was a database failure and the backup was loaded from
		return
	sync_ranks_with_db()
	var/list/sql_admins = list()
	for(var/i in GLOB.protected_admins)
		var/datum/admins/A = GLOB.protected_admins[i]
		sql_admins += list(list("ckey" = A.target, "rank" = A.rank_names()))
	SSdbcore.MassInsert(format_table_name("admin"), sql_admins, duplicate_key = TRUE)
	var/datum/db_query/query_admin_rank_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] p INNER JOIN [format_table_name("admin")] a ON p.ckey = a.ckey SET p.lastadminrank = a.rank")
	query_admin_rank_update.Execute()
	qdel(query_admin_rank_update)

	//json format backup file generation stored per server
	var/json_file = file("data/admins_backup.json")
	var/list/file_data = list(
		"ranks" = list(),
		"admins" = list(),
		"connections" = list(),
	)
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		file_data["ranks"]["[R.name]"] = list()
		file_data["ranks"]["[R.name]"]["include rights"] = R.include_rights
		file_data["ranks"]["[R.name]"]["exclude rights"] = R.exclude_rights
		file_data["ranks"]["[R.name]"]["can edit rights"] = R.can_edit_rights

	for(var/admin_ckey in GLOB.admin_datums + GLOB.deadmins)
		var/datum/admins/admin = GLOB.admin_datums[admin_ckey]

		if(!admin)
			admin = GLOB.deadmins[admin_ckey]
			if (!admin)
				continue

		file_data["admins"][admin_ckey] = admin.rank_names()

		if (admin.owner)
			file_data["connections"][admin_ckey] = list(
				"cid" = admin.owner.computer_id,
				"ip" = admin.owner.address,
			)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/ticker/proc/update_everything_flag_in_db()
	for(var/datum/admin_rank/R in GLOB.admin_ranks)
		var/list/flags = list()
		if(R.include_rights == R_EVERYTHING)
			flags += "flags"
		if(R.exclude_rights == R_EVERYTHING)
			flags += "exclude_flags"
		if(R.can_edit_rights == R_EVERYTHING)
			flags += "can_edit_flags"
		if(!flags.len)
			continue
		var/flags_to_check = flags.Join(" != [R_EVERYTHING] AND ") + " != [R_EVERYTHING]"
		var/datum/db_query/query_check_everything_ranks = SSdbcore.NewQuery(
			"SELECT flags, exclude_flags, can_edit_flags FROM [format_table_name("admin_ranks")] WHERE rank = :rank AND ([flags_to_check])",
			list("rank" = R.name)
		)
		if(!query_check_everything_ranks.Execute())
			qdel(query_check_everything_ranks)
			return
		if(query_check_everything_ranks.NextRow()) //no row is returned if the rank already has the correct flag value
			var/flags_to_update = flags.Join(" = [R_EVERYTHING], ") + " = [R_EVERYTHING]"
			var/datum/db_query/query_update_everything_ranks = SSdbcore.NewQuery(
				"UPDATE [format_table_name("admin_ranks")] SET [flags_to_update] WHERE rank = :rank",
				list("rank" = R.name)
			)
			if(!query_update_everything_ranks.Execute())
				qdel(query_update_everything_ranks)
				return
			qdel(query_update_everything_ranks)
		qdel(query_check_everything_ranks)

//MONKE EDIT START
/datum/controller/subsystem/ticker/proc/save_mentor_data()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>Mentor rank DB Sync blocked: Advanced ProcCall detected.</span>")
		return
	if(CONFIG_GET(flag/mentor_legacy_system)) //we're already using legacy system so there's nothing to save
		return
	else if(load_mentors(TRUE)) //returns true if there was a database failure and the backup was loaded from
		return
	sync_mentor_ranks_with_db()
	var/list/sql_mentors = list()
	for(var/i in GLOB.protected_mentors)
		var/datum/mentors/A = GLOB.protected_mentors[i]
		sql_mentors += list(list("ckey" = A.target, "rank" = A.rank_names()))

	SSdbcore.MassInsert(format_table_name("mentor"), sql_mentors, duplicate_key = TRUE)
	var/datum/db_query/query_mentor_rank_update = SSdbcore.NewQuery("UPDATE [format_table_name("player")] p INNER JOIN [format_table_name("mentor")] a ON p.ckey = a.ckey SET p.lastmentorrank = a.rank")
	query_mentor_rank_update.Execute()
	qdel(query_mentor_rank_update)

	//json format backup file generation stored per server
	var/json_file = file("data/mentors_backup.json")
	var/list/file_data = list(
		"ranks" = list(),
		"mentors" = list(),
		"connections" = list(),
	)
	for(var/datum/mentor_rank/R in GLOB.mentor_ranks)
		file_data["ranks"]["[R.name]"] = list()
		file_data["ranks"]["[R.name]"]["include rights"] = R.include_rights
		file_data["ranks"]["[R.name]"]["exclude rights"] = R.exclude_rights
		file_data["ranks"]["[R.name]"]["can edit rights"] = R.can_edit_rights

	for(var/mentor_ckey in GLOB.mentor_datums + GLOB.dementors)
		var/datum/mentors/mentor = GLOB.mentor_datums[mentor_ckey]

		if(!mentor)
			mentor = GLOB.dementors[mentor_ckey]
			if (!mentor)
				continue

		file_data["mentors"][mentor_ckey] = mentor.rank_names()

		if (mentor.owner)
			file_data["connections"][mentor_ckey] = list(
				"cid" = mentor.owner.computer_id,
				"ip" = mentor.owner.address,
			)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
//MONK EDIT END

/datum/controller/subsystem/ticker/proc/cheevo_report()
	var/list/parts = list()
	if(length(GLOB.achievements_unlocked))
		parts += "<span class='header'>Achievement Get!</span><BR>"
		parts += "<span class='infoplain'>Total Achievements Earned: <B>[length(GLOB.achievements_unlocked)]!</B></span><BR>"
		parts += "<ul class='playerlist'>"
		for(var/datum/achievement_report/cheevo_report in GLOB.achievements_unlocked)
			parts += "<BR>[cheevo_report.winner_key] was <b>[cheevo_report.winner]</b>, who earned the [span_greentext("'[cheevo_report.cheevo]'")] achievement at [cheevo_report.award_location]!<BR>"
		parts += "</ul>"
		return "<div class='panel greenborder'><ul>[parts.Join()]</ul></div>"

///A datum containing the info necessary for an achievement readout, reported and added to the global list in /datum/award/achievement/on_unlock(mob/user)
/datum/achievement_report
	///The winner of this achievement.
	var/winner
	///The achievement that was won.
	var/cheevo
	///The ckey of our winner
	var/winner_key
	///The name of the area we earned this cheevo in
	var/award_location

#undef DISCORD_SUPPRESS_NOTIFICATIONS
