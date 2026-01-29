/// Panel containing information, variables and controls about the gamemode and scheduled event
/datum/controller/subsystem/gamemode/proc/admin_panel(mob/user)
	update_crew_infos()
	var/round_started = SSticker.HasRoundStarted()
	var/list/dat = list()
	dat += "Storyteller: [current_storyteller ? "[current_storyteller.name]" : "None"] "
	dat += " <a href='byond://?src=[REF(src)];panel=main;action=halt_storyteller' [halted_storyteller ? "class='linkOn'" : ""]>HALT Storyteller</a> <a href='byond://?src=[REF(src)];panel=main;action=open_stats'>Event Panel</a> <a href='byond://?src=[REF(src)];panel=main;action=set_storyteller'>Set Storyteller</a> <a href='byond://?src=[REF(src)];panel=main'>Refresh</a>"
	dat += "<BR><font color='#888888'><i>Storyteller determines points gained, event chances, and is the entity responsible for rolling events.</i></font>"
	dat += "<BR>Active Players: [active_players]   (Head: [head_crew], Sec: [sec_crew], Eng: [eng_crew], Med: [med_crew])"
	dat += "<BR>Antagonist Point Count vs Maximum: [get_antag_count()] / [get_antag_cap()]"
	dat += "<HR>"
	dat += "<a href='byond://?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_MAIN]' [panel_page == GAMEMODE_PANEL_MAIN ? "class='linkOn'" : ""]>Main</a>"
	dat += " <a href='byond://?src=[REF(src)];panel=main;action=tab;tab=[GAMEMODE_PANEL_VARIABLES]' [panel_page == GAMEMODE_PANEL_VARIABLES ? "class='linkOn'" : ""]>Variables</a>"
	dat += "<HR>"
	switch(panel_page)
		if(GAMEMODE_PANEL_VARIABLES)
			dat += "<a href='byond://?src=[REF(src)];panel=main;action=reload_config_vars'>Reload Config Vars</a> <font color='#888888'><i>Configs located in game_options.txt.</i></font>"
			dat += "<BR><b>Point Gains Multipliers (only over time):</b>"
			dat += "<BR><font color='#888888'><i>This affects points gained over time towards scheduling new events of the tracks.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=pts_multiplier;track=[track]'>[point_gain_multipliers[track]]</a>"
			dat += "<HR>"

			dat += "<b>Roundstart Points Multipliers:</b>"
			dat += "<BR><font color='#888888'><i>This affects points generated for roundstart events and antagonists.</i></font>"
			dat += "<BR>[EVENT_TRACK_ROLESET]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=roundstart_pts;track=[EVENT_TRACK_ROLESET]'>[roundstart_roleset_multiplier]</a>"
			dat += "<HR>"

			dat += "<b>Minimum Population for Tracks:</b>"
			dat += "<BR><font color='#888888'><i>This are the minimum population caps for events to be able to run.</i></font>"
			for(var/track in event_tracks)
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=min_pop;track=[track]'>[min_pop_thresholds[track]]</a>"
			dat += "<HR>"

			dat += "<b>Point Thresholds:</b>"
			dat += "<BR><font color='#888888'><i>Those are thresholds the tracks require to reach with points to make an event.</i></font>"
			//we probably dont need to show tracks that dont use points, this will mean that if you make a track that manually adds points this wont work
			for(var/track in point_gain_multipliers)
				var/datum/storyteller_track/track_datum = event_tracks[track]
				if(!track_datum.threshold)
					continue
				dat += "<BR>[track]: <a href='byond://?src=[REF(src)];panel=main;action=vars;var=pts_threshold;track=[track]'>[track_datum.threshold]</a>"

		if(GAMEMODE_PANEL_MAIN)
			var/even = TRUE
			dat += "<h2>Event Tracks:</h2>"
			dat += "<font color='#888888'><i>Every track represents progression towards scheduling an event of it's severity</i></font>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=25%><b>Track</b></td>"
			dat += "<td width=20%><b>Progress</b></td>"
			dat += "<td width=10%><b>Next</b></td>"
			dat += "<td width=10%><b>Forced</b></td>"
			dat += "<td width=35%><b>Actions</b></td>"
			dat += "</tr>"
			for(var/track in point_gain_multipliers)
				even = !even
				var/datum/storyteller_track/track_datum = event_tracks[track]
				var/background_cl = even ? "#17191C" : "#23273C"
				var/points = track_datum.points
				var/threshold = track_datum.threshold
				var/percent = round((points/threshold)*100)
				var/next = 0
				var/last_points = last_point_gains[track]
				if(last_points)
					next = round(((threshold - points) / last_points))
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[track] - [last_points] per process.</td>" //Track
				dat += "<td>[percent]% ([points]/[threshold])</td>" //Progress
				dat += "<td>~[next] seconds</td>" //Next
				var/datum/round_event_control/forced_event = forced_next_events[track]
				var/forced = forced_event ? "[forced_event.name] <a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=remove_forced;track=[track]'>X</a>" : ""
				dat += "<td>[forced]</td>" //Forced
				dat += "<td><a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=set_pts;track=[track]'>Set Pts.</a> <a href='byond://?src=[REF(src)];panel=main;action=track_action;track_action=next_event;track=[track]'>Next Event</a></td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Scheduled Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=17%><b>Severity</b></td>"
			dat += "<td width=12%><b>Time</b></td>"
			dat += "<td width=41%><b>Actions</b></td>"
			dat += "</tr>"
			var/sorted_scheduled = list()
			for(var/datum/scheduled_event/scheduled as anything in scheduled_events)
				sorted_scheduled[scheduled] = scheduled.start_time
			sortTim(sorted_scheduled, cmp=/proc/cmp_numeric_asc, associative = TRUE)
			even = TRUE
			for(var/datum/scheduled_event/scheduled as anything in sorted_scheduled)
				even = !even
				var/background_cl = even ? "#17191C" : "#23273C"
				dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
				dat += "<td>[scheduled.event.name]</td>" //Name
				dat += "<td>[scheduled.event.track]</td>" //Severity
				var/time = (scheduled.event.roundstart && !round_started) ? "ROUNDSTART" : "[(scheduled.start_time - world.time) / (1 SECONDS)] s."
				dat += "<td>[time]</td>" //Time
				dat += "<td>[scheduled.get_href_actions()]</td>" //Actions
				dat += "</tr>"
			dat += "</table>"

			dat += "<h2>Running Events:</h2>"
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%><b>Name</b></td>"
			dat += "<td width=70%><b>Actions</b></td>"
			dat += "</tr>"
			even = TRUE
			dat += "</table>"

	var/datum/browser/popup = new(user, "gamemode_admin_panel", "Gamemode Panel", 670, 650)
	popup.set_content(dat.Join())
	popup.open()

/// Panel containing information and actions regarding events
/datum/controller/subsystem/gamemode/proc/event_panel(mob/user)
	var/list/dat = list()
	if(current_storyteller)
		dat += "Storyteller: [current_storyteller.name]"
		dat += "<BR>Repetition penalty multiplier: [current_storyteller.event_repetition_multiplier]"
		dat += "<BR>Cost variance: [current_storyteller.cost_variance]"
		if(current_storyteller.tag_multipliers)
			dat += "<BR>Tag multipliers:"
			for(var/tag in current_storyteller.tag_multipliers)
				dat += "[tag]:[current_storyteller.tag_multipliers[tag]] | "
		current_storyteller.calculate_weights(statistics_track_page)
	else
		dat += "Storyteller: None<BR>Weight and chance statistics will be inaccurate due to the present lack of a storyteller."
	dat += "<BR><a href='byond://?src=[REF(src)];panel=stats;action=set_roundstart'[roundstart_event_view ? "class='linkOn'" : ""]>Roundstart Events</a> Forced Roundstart events will use rolled points, and are guaranteed to trigger (even if the used points are not enough)"
	dat += "<BR>Avg. event intervals: "
	for(var/track, track_d in event_tracks)
		if(last_point_gains[track]) //DOUBLE CHECK THIS CALCULATION IS CORRECT
			var/est_time = round(astype(track_d, /datum/storyteller_track).threshold / last_point_gains[track] / 40 / 6) / 10
			dat += "[track]: ~[est_time] m. | "
	dat += "<HR>"
	for(var/track in EVENT_PANEL_TRACKS)
		dat += "<a href='byond://?src=[REF(src)];panel=stats;action=set_cat;cat=[track]'[(statistics_track_page == track) ? "class='linkOn'" : ""]>[track]</a>"
	dat += "<HR>"
	/// Create event info and stats table
	dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
	dat += "<tr style='vertical-align:top'>"
	dat += "<td width=17%><b>Name</b></td>"
	dat += "<td width=16%><b>Tags</b></td>"
	dat += "<td width=8%><b>Occurences</b></td>"
	dat += "<td width=8%><b>Max Occurences</b></td>"
	dat += "<td width=5%><b>M.Pop</b></td>"
	dat += "<td width=5%><b>M.Time</b></td>"
	dat += "<td width=7%><b>Can Occur</b></td>"
	dat += "<td width=7%><b>Failure Reason</b></td>"
	dat += "<td width=16%><b>Weight</b></td>"
	dat += "<td width=26%><b>Actions</b></td>"
	dat += "</tr>"
	var/even = TRUE
	var/total_weight = 0
	var/list/event_lookup
	switch(statistics_track_page)
		if(ALL_EVENTS)
			event_lookup = SSevents.control
		if(UNCATEGORIZED_EVENTS)
			event_lookup = uncategorized
		else
			event_lookup = event_pools[statistics_track_page]
	var/list/assoc_spawn_weight = list()
	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	for(var/datum/round_event_control/event as anything in event_lookup)
		if(event.roundstart != roundstart_event_view)
			continue
		if(event.can_spawn_event(players_amt))
			total_weight += event.calculated_weight
			assoc_spawn_weight[event] = event.calculated_weight
		else
			assoc_spawn_weight[event] = 0
	sortTim(assoc_spawn_weight, cmp=/proc/cmp_numeric_dsc, associative = TRUE)
	for(var/datum/round_event_control/event as anything in assoc_spawn_weight)
		even = !even
		var/background_cl = even ? "#17191C" : "#23273C"
		dat += "<tr style='vertical-align:top; background-color: [background_cl];'>"
		dat += "<td>[event.name]</td>" //Name
		dat += "<td>" //Tags
		for(var/tag in event.tags)
			dat += "[tag] "
		dat += "</td>"
		var/occurence_string = "[event.get_occurrences()]"
		if(event.shared_occurence_type)
			occurence_string += " (shared: [event.get_occurrences()])"
		var/max_occurence_string = "[event.max_occurrences]"
		dat += "<td>[occurence_string]</td>" //Occurences
		dat += "<td>[max_occurence_string]</td>" //Max Occurences
		dat += "<td>[event.min_players]</td>" //Minimum pop
		dat += "<td>[event.earliest_start / (1 MINUTES)] m.</td>" //Minimum time
		dat += "<td>[assoc_spawn_weight[event] ? "Yes" : "No"]</td>" //Can happen?
		dat += "<td>[event.return_failure_string(active_players)]</td>" //Why can't happen?
		var/weight_string = "(new.[event.calculated_weight] /raw.[event.get_weight()]/base.[event.weight])"
		if(assoc_spawn_weight[event])
			var/percent = round((event.calculated_weight / total_weight) * 100)
			weight_string = "[percent]% - [weight_string]"
		dat += "<td>[weight_string]</td>" //Weight
		dat += "<td>[event.get_href_actions()]</td>" //Actions
		dat += "</tr>"
	dat += "</table>"
	var/datum/browser/popup = new(user, "gamemode_event_panel", "Event Panel", 1100, 600)
	popup.set_content(dat.Join())
	popup.open()

/datum/controller/subsystem/gamemode/Topic(href, href_list)
	. = ..()
	var/mob/user = usr
	if(!check_rights(R_ADMIN))
		return
	switch(href_list["panel"])
		if("main")
			switch(href_list["action"])
				if("set_storyteller")
					message_admins("[key_name_admin(usr)] is picking a new Storyteller.")
					var/list/name_list = list()
					for(var/storyteller_type in storytellers)
						var/datum/storyteller/storyboy = storytellers[storyteller_type]
						name_list[storyboy.name] = storyboy.type
					var/new_storyteller_name = input(usr, "Choose new storyteller (circumvents voted one):", "Storyteller")  as null|anything in name_list
					if(!new_storyteller_name)
						message_admins("[key_name_admin(usr)] has cancelled picking a Storyteller.")
						return
					message_admins("[key_name_admin(usr)] has chosen [new_storyteller_name] as the new Storyteller.")
					log_admin("[key_name(usr)] has chosen [new_storyteller_name] as the new Storyteller.")
					var/new_storyteller_type = name_list[new_storyteller_name]
					set_storyteller(new_storyteller_type)
				if("halt_storyteller")
					halted_storyteller = !halted_storyteller
					message_admins("[key_name_admin(usr)] has [halted_storyteller ? "HALTED" : "un-halted"] the Storyteller.")
					log_admin("[key_name(usr)] has [halted_storyteller ? "HALTED" : "un-halted"] the Storyteller.")
				if("vars")
					var/track = href_list["track"]
					switch(href_list["var"])
						if("pts_multiplier")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point gain multiplier for [track] track to [new_value].")
							point_gain_multipliers[track] = new_value
						if("roundstart_pts")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set roundstart pts multiplier for [track] track to [new_value].")
							roundstart_roleset_multiplier = new_value
						if("min_pop")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set minimum population for [track] track to [new_value].")
							min_pop_thresholds[track] = new_value
						if("pts_threshold")
							var/new_value = input(usr, "New value:", "Set new value") as num|null
							if(isnull(new_value) || new_value < 0)
								return
							message_admins("[key_name_admin(usr)] set point threshold of [track] track to [new_value].")
							event_tracks[track].threshold = new_value
				if("reload_config_vars")
					message_admins("[key_name_admin(usr)] reloaded gamemode config vars.")
					log_admin("[key_name(usr)] reloaded gamemode config vars.")
					load_config_vars()
				if("tab")
					var/tab = href_list["tab"]
					panel_page = tab
				if("open_stats")
					event_panel(user)
					return
				if("track_action")
					var/track = href_list["track"]
					var/datum/storyteller_track/track_datum = event_tracks[track]
					if(!(track in event_tracks))
						return
					switch(href_list["track_action"])
						if("remove_forced")
							if(forced_next_events[track])
								var/datum/round_event_control/event = forced_next_events[track]
								message_admins("[key_name_admin(usr)] removed forced event [event.name] from track [track].")
								log_admin("[key_name(usr)] removed forced event [event.name] from track [track].")
								forced_next_events -= track
						if("set_pts")
							var/set_pts = input(usr, "New point amount ([track_datum.threshold]+ invokes event):", "Set points for [track]") as num|null
							if(isnull(set_pts))
								return
							track_datum.points = set_pts
							message_admins("[key_name_admin(usr)] set points of [track] track to [set_pts].")
							log_admin("[key_name(usr)] set points of [track] track to [set_pts].")
						if("next_event")
							message_admins("[key_name_admin(usr)] invoked next event for [track] track.")
							log_admin("[key_name(usr)] invoked next event for [track] track.")
							track_datum.points = track_datum.threshold
							if(current_storyteller)
								current_storyteller.handle_tracks()
			admin_panel(user)
		if("stats")
			switch(href_list["action"])
				if("set_roundstart")
					roundstart_event_view = !roundstart_event_view
				if("set_cat")
					var/new_category = href_list["cat"]
					if(new_category in EVENT_PANEL_TRACKS)
						statistics_track_page = new_category
			event_panel(user)
