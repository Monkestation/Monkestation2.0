#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"
#define SS_TICKER_TRAIT "SS_Ticker"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	/// state of current round (used by process()) Use the defines GAME_STATE_* !
	var/current_state = GAME_STATE_STARTUP
	/// Boolean to track if round should be forcibly ended next ticker tick.
	/// Set by admin intervention ([ADMIN_FORCE_END_ROUND])
	/// or a "round-ending" event, like summoning Nar'Sie, a blob victory, the nuke going off, etc. ([FORCE_END_ROUND])
	var/force_ending = END_ROUND_AS_NORMAL
	/// If TRUE, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	/// Boolean to track and check if our subsystem setup is done.
	var/setup_done = FALSE

	var/datum/game_mode/mode = null

	var/login_music_done = FALSE // monkestation edit: : fix-lobby-music
	var/round_end_sound //music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE //If all clients have loaded it

	var/list/datum/mind/minds = list() //The characters in the game. Used for objective tracking.

	var/delay_end = FALSE //if set true, the round will not restart on it's own
	var/admin_delay_notice = "" //a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE //all roundend preparation done with, all that's left is reboot

	var/tipped = FALSE //Did we broadcast the tip of the day yet?
	var/selected_tip // What will be the tip of the day?

	var/timeLeft //pregame timer
	var/start_at

	var/gametime_offset = 432000 //Deciseconds to add to world.time for station time.
	var/station_time_rate_multiplier = 128 //factor of station time progressal vs real time.

	/// Num of players, used for pregame stats on statpanel
	var/totalPlayers = 0
	/// Num of ready players, used for pregame stats on statpanel (only viewable by admins)
	var/totalPlayersReady = 0
	/// Num of ready admins, used for pregame stats on statpanel (only viewable by admins)
	var/total_admins_ready = 0

	var/queue_delay = 0
	var/list/queued_players = list() //used for join queues when the server exceeds the hard population cap

	/// What is going to be reported to other stations at end of round?
	var/news_report


	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"

	var/end_station_state

	/// People who have been commended and will receive a heart
	var/list/hearts

	/// Why an emergency shuttle was called
	var/emergency_reason

	/// ID of round reboot timer, if it exists
	var/reboot_timer = null

	///add bitflags to this that should be rewarded monkecoins, example: DEPARTMENT_BITFLAG_SECURITY
	var/list/bitflags_to_reward = list(DEPARTMENT_BITFLAG_SECURITY,)
	///add jobs to this that should get rewarded monkecoins, example: JOB_SECURITY_OFFICER
	var/list/jobs_to_reward = list(JOB_JANITOR,)

	var/list/popcount

	/// A lazylist of roundstart splashes, so they can be faded out AFTER antags are initialized.
	var/list/roundstart_splashes

	/// (monkestation addition) The station integrity at roundend.
	var/roundend_station_integrity

/datum/controller/subsystem/ticker/Initialize()
	// monkestation start: fix-lobby-music
	var/old_login_music = trim(file2text("data/last_round_lobby_music.txt"))

	var/base_provisional_music_path = "[global.config.directory]/title_music/sounds/"
	var/list/provisional_title_music = flist(base_provisional_music_path)
	for(var/S in provisional_title_music)
		var/fullpath = base_provisional_music_path + S
		if (fexists(fullpath))
			try
				var/list/json = json_decode(file2text(fullpath))
				if (json["url"] != old_login_music)
					GLOB.jukebox_track_files += fullpath
			catch
				if (S == "exclude") continue
				log_runtime("Failed to parse [fullpath], likely an invalid file.")
	login_music_done = TRUE
	// monkestation end

	/* //monkestation removal start: fix-lobby-music
	var/list/byond_sound_formats = list(
		"mid" = TRUE,
		"midi" = TRUE,
		"mod" = TRUE,
		"it" = TRUE,
		"s3m" = TRUE,
		"xm" = TRUE,
		"oxm" = TRUE,
		"wav" = TRUE,
		"ogg" = TRUE,
		"raw" = TRUE,
		"wma" = TRUE,
		"aiff" = TRUE,
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = lowertext(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.current_map.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.current_map.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.current_map.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				if(L[1] == "exclude")
					continue
				music += S

	var/old_login_music = trim(file2text("data/last_round_lobby_music.txt"))
	if(music.len > 1)
		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = lowertext(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(!length(music))
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"
	*/ // monkestation removal end


	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday
	else
		gametime_offset = (CONFIG_GET(number/shift_time_start_hour) HOURS)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
			to_chat(world, span_notice("<b>Welcome to [station_name()]!</b>"))
			send2chat(new /datum/tgs_message_content("New round starting on [SSmapping.current_map.map_name]!"), CONFIG_GET(string/channel_announce_new_game))
			current_state = GAME_STATE_PREGAME
			SEND_SIGNAL(src, COMSIG_TICKER_ENTER_PREGAME)
			SStitle.update_init_text()
			// MONKESTATION EDIT START - lobby notices
			if (length(config.lobby_notices))
				config.ShowLobbyNotices(world)
			// MONKESTATION END
			fire()
		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = LAZYLEN(GLOB.new_player_list)
			totalPlayersReady = 0
			total_admins_ready = 0
			for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady
					if(player.client?.holder)
						++total_admins_ready

			if(start_immediately)
				timeLeft = 0

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round(world, selected_tip)
				tipped = TRUE
				SStitle.update_init_text()

			if(timeLeft <= 0)
				SEND_SIGNAL(src, COMSIG_TICKER_ENTER_SETTING_UP)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)
				SEND_SIGNAL(src, COMSIG_TICKER_ERROR_SETTING_UP)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()

			if(!roundend_check_paused && (mode.check_finished() || force_ending))
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, span_boldannounce("Starting game..."))
	var/init_start = world.timeofday

	mode = new /datum/game_mode/dynamic
	SSgamemode.init_storyteller() //monkestation addition
	CHECK_TICK
	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	//monkestation addition start
	can_continue =	SSgamemode.pre_setup()
	CHECK_TICK
	//monkestation addition end
	can_continue = src.mode.pre_setup() //Choose antagonists
	CHECK_TICK
	can_continue = can_continue && SSjob.DivideOccupations() //Distribute jobs
	CHECK_TICK

	if(!GLOB.Debug2)
		if(!can_continue)
			log_game("Game failed pre_setup")
			QDEL_NULL(mode)
			to_chat(world, "<B>Error setting up game.</B> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return FALSE
	else
		message_admins(span_notice("DEBUG: Bypassing prestart checks..."))

	CHECK_TICK

	// There may be various config settings that have been set or modified by this point.
	// This is the point of no return before spawning in new players, let's run over the
	// job trim singletons and update them based on any config settings.
	SSid_access.refresh_job_trim_singletons()

	CHECK_TICK

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	equip_characters()

	GLOB.manifest.build()

	transfer_characters() //transfer keys to the new mobs

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	round_start_time = world.time //otherwise round_start_time would be 0 for the signals
	SEND_SIGNAL(src, COMSIG_TICKER_ROUND_STARTING, world.time)

	log_world("Game start took [(world.timeofday - init_start)/10]s")
	INVOKE_ASYNC(SSdbcore, TYPE_PROC_REF(/datum/controller/subsystem/dbcore,SetRoundStart))

	to_chat(world, span_notice("<B>Welcome to [station_name()], enjoy your stay!</B>"))

	for(var/mob/player as anything in GLOB.player_list)
		welcome_player(player)

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	if(length(GLOB.holidays))
		to_chat(world, span_notice("and..."))
		for(var/holidayname in GLOB.holidays)
			var/datum/holiday/holiday = GLOB.holidays[holidayname]
			to_chat(world, span_info(holiday.greet()))

	PostSetup()
	INVOKE_ASYNC(Tracy, TYPE_PROC_REF(/datum/tracy, flush)) // monkestation edit: byond-tracy

	return TRUE

/datum/controller/subsystem/ticker/proc/welcome_player(mob/player)
	var/client/client = player.client
	var/list/channel_volume = client?.prefs?.channel_volume?.Copy()
	if(!client)
		SEND_SOUND(player, sound(SSstation.announcer.get_rand_welcome_sound(), volume = 100))
	else if("[CHANNEL_VOX]" in channel_volume)
		SEND_SOUND(player, sound(SSstation.announcer.get_rand_welcome_sound(), volume = channel_volume["[CHANNEL_VOX]"] * (channel_volume["[CHANNEL_MASTER_VOLUME]"] * 0.01)))

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	if(!CONFIG_GET(flag/disable_storyteller))
		SSgamemode.current_storyteller.round_started = TRUE
		SSgamemode.current_storyteller.tick(STORYTELLER_WAIT_TIME * 0.1) // we want this asap
	mode.post_setup()
	addtimer(CALLBACK(src, PROC_REF(fade_all_splashes)), 1 SECONDS) // extra second to make SURE all antags are setup

	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2adminchat("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]" : ""] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE

	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S)) //we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")

	// handle persistence stuff that requires ckeys, in this case hardcore mode and temporal scarring
	for(var/i in GLOB.player_list)
		if(!ishuman(i))
			continue
		var/mob/living/carbon/human/iter_human = i

		iter_human.increment_scar_slot()
		iter_human.load_persistent_scars()
		SSpersistence.load_modular_persistence(iter_human.get_organ_slot(ORGAN_SLOT_BRAIN))

		if(!iter_human.hardcore_survival_score)
			continue
		if(iter_human.mind?.special_role)
			to_chat(iter_human, span_notice("You will gain [round(iter_human.hardcore_survival_score) * 2] hardcore random points if you greentext this round!"))
		else
			to_chat(iter_human, span_notice("You will gain [round(iter_human.hardcore_survival_score)] hardcore random points if you survive this round!"))

//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/player in GLOB.new_player_list)
		create_character(player)
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/create_character(mob/dead/new_player/player)
	if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
		if(interview_safety(player, "readied up"))
			player.ready = PLAYER_NOT_READY
			QDEL_IN(player.client, 0)
			return
		GLOB.joined_player_list += player.ckey
		var/chosen_title = player.client?.prefs.alt_job_titles[player.mind.assigned_role.title] || player.mind.assigned_role.title
		var/atom/destination = player.mind.assigned_role.get_roundstart_spawn_point(chosen_title)
		if(!destination) // Failed to fetch a proper roundstart location, won't be going anywhere.
			return
		player.create_character(destination)

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	GLOB.security_officer_distribution = decide_security_officer_departments(
		shuffle(GLOB.new_player_list),
		shuffle(GLOB.available_depts),
	)

	var/captainless = TRUE

	var/highest_rank = length(SSjob.chain_of_command) + 1
	var/list/spare_id_candidates = list()
	var/mob/dead/new_player/picked_spare_id_candidate

	// Find a suitable player to hold captaincy.
	for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
		if(is_banned_from(new_player_mob.ckey, list(JOB_CAPTAIN)))
			CHECK_TICK
			continue
		if(!ishuman(new_player_mob.new_character))
			continue
		var/mob/living/carbon/human/new_player_human = new_player_mob.new_character
		if(!new_player_human.mind || is_unassigned_job(new_player_human.mind.assigned_role))
			continue
		// Keep a rolling tally of who'll get the cap's spare ID vault code.
		// Check assigned_role's priority and curate the candidate list appropriately.
		var/player_assigned_role = new_player_human.mind.assigned_role.title
		var/spare_id_priority = SSjob.chain_of_command[player_assigned_role]
		if(spare_id_priority)
			if(spare_id_priority < highest_rank)
				spare_id_candidates.Cut()
				spare_id_candidates += new_player_mob
				highest_rank = spare_id_priority
			else if(spare_id_priority == highest_rank)
				spare_id_candidates += new_player_mob
		CHECK_TICK

	if(length(spare_id_candidates))
		picked_spare_id_candidate = pick(spare_id_candidates)

	for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
		if(QDELETED(new_player_mob) || !isliving(new_player_mob.new_character) || !new_player_mob.client)
			CHECK_TICK
			continue
		var/mob/living/new_player_living = new_player_mob.new_character
		if(!new_player_living.mind)
			CHECK_TICK
			continue
		var/datum/job/player_assigned_role = new_player_living.mind.assigned_role
		if(player_assigned_role.job_flags & JOB_EQUIP_RANK)
			SSjob.EquipRank(new_player_living, player_assigned_role, new_player_mob.client)
		player_assigned_role.after_roundstart_spawn(new_player_living, new_player_mob.client)
		if(picked_spare_id_candidate == new_player_mob)
			captainless = FALSE
			var/acting_captain = !is_captain_job(player_assigned_role)
			SSjob.promote_to_captain(new_player_living, acting_captain)
			OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), player_assigned_role.get_captaincy_announcement(new_player_living)))
		if((player_assigned_role.job_flags & JOB_ASSIGN_QUIRKS) && ishuman(new_player_living) && CONFIG_GET(flag/roundstart_traits))
			if(new_player_mob.client?.prefs?.should_be_random_hardcore(player_assigned_role, new_player_living.mind))
				new_player_mob.client.prefs.hardcore_random_setup(new_player_living)
			SSquirks.AssignQuirks(new_player_living, new_player_mob.client)

		if(ishuman(new_player_living))
			for(var/datum/loadout_item/item as anything in loadout_list_to_datums(new_player_mob.client?.prefs?.loadout_list))
				if (item.restricted_roles && length(item.restricted_roles) && !(player_assigned_role.title in item.restricted_roles))
					continue
				item.post_equip_item(new_player_mob.client?.prefs, new_player_living)

		if(new_player_mob.client?.readied_store?.bought_item)
			new_player_mob.client.readied_store.finalize_purchase_spawn(new_player_mob, new_player_living)

		CHECK_TICK

	if(captainless)
		for(var/mob/dead/new_player/new_player_mob as anything in GLOB.new_player_list)
			var/mob/living/carbon/human/new_player_human = new_player_mob.new_character
			if(new_player_human)
				to_chat(new_player_mob, span_notice("Captainship not forced on anyone."))
			CHECK_TICK


/datum/controller/subsystem/ticker/proc/decide_security_officer_departments(
	list/new_players,
	list/departments,
)
	var/list/officer_mobs = list()
	var/list/officer_preferences = list()

	for (var/mob/dead/new_player/new_player_mob as anything in new_players)
		var/mob/living/carbon/human/character = new_player_mob.new_character
		if (istype(character) && is_security_officer_job(character.mind?.assigned_role))
			officer_mobs += character

			var/datum/client_interface/client = GET_CLIENT(new_player_mob)
			var/preference = client?.prefs?.read_preference(/datum/preference/choiced/security_department)
			officer_preferences += preference

	var/distribution = get_officer_departments(officer_preferences, departments)

	var/list/output = list()

	for (var/index in 1 to officer_mobs.len)
		output[REF(officer_mobs[index])] = distribution[index]

	return output

/datum/controller/subsystem/ticker/proc/transfer_single_character(mob/dead/new_player/player)
	var/mob/living = player.transfer_character()
	if(!living)
		return
	ADD_TRAIT(living, TRAIT_NO_TRANSFORM, SS_TICKER_TRAIT)
	if(living.client)
		var/atom/movable/screen/splash/splash = new(null, null, living.client, TRUE)
		LAZYADD(roundstart_splashes, splash)
		living.client?.init_verbs()
	. = living
	var/datum/persistent_client/persistent_client = living.persistent_client
	if(persistent_client)
		SSchallenges.apply_challenges(persistent_client)
		for(var/processing_reward_bitflags in bitflags_to_reward)//you really should use department bitflags if possible
			if(living.mind.assigned_role.departments_bitflags & processing_reward_bitflags)
				persistent_client.roundend_monkecoin_bonus += 425
		for(var/processing_reward_jobs in jobs_to_reward)//just in case you really only want to reward a specific job
			if(living.job == processing_reward_jobs)
				persistent_client.roundend_monkecoin_bonus += 425

/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		livings += transfer_single_character(player)
	list_clear_nulls(livings)
	if(length(livings))
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 3 SECONDS, TIMER_CLIENT_TIME)

/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/mob/living/living_mob as anything in livings)
		REMOVE_TRAIT(living_mob, TRAIT_NO_TRANSFORM, SS_TICKER_TRAIT)

/datum/controller/subsystem/ticker/proc/check_queue()
	if(!queued_players.len)
		return
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	if(!hard_popcap)
		list_clear_nulls(queued_players)
		for (var/mob/dead/new_player/new_player in queued_players)
			to_chat(new_player, span_userdanger("The alive players limit has been released!<br><a href='byond://?src=[REF(new_player)];late_join=override'>[html_encode(">>Join Game<<")]</a>"))
			SEND_SOUND(new_player, sound('sound/misc/notice1.ogg'))
			GLOB.latejoin_menu.ui_interact(new_player)
		queued_players.len = 0
		queue_delay = 0
		return

	queue_delay++
	var/mob/dead/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			list_clear_nulls(queued_players)
			if(living_player_count() < hard_popcap)
				if(next_in_line?.client)
					to_chat(next_in_line, span_userdanger("A slot has opened! You have approximately 20 seconds to join. <a href='byond://?src=[REF(next_in_line)];late_join=override'>\>\>Join Game\<\<</a>"))
					SEND_SOUND(next_in_line, sound('sound/misc/notice1.ogg'))
					next_in_line.ui_interact(next_in_line)
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, span_danger("No response received. You have been removed from the line."))
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/fade_all_splashes()
	for(var/atom/movable/screen/splash/splash in roundstart_splashes)
		splash.Fade(TRUE)
	LAZYNULL(roundstart_splashes)

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	mode = SSticker.mode

	//monkestation removal start: fix-lobby-music
	// login_music = SSticker.login_music
	//monkestation removal end
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady
	total_admins_ready = SSticker.total_admins_ready

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	round_start_time = SSticker.round_start_time

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players

	if (Master) //Set Masters run level if it exists
		switch (current_state)
			if(GAME_STATE_SETTING_UP)
				Master.SetRunLevel(RUNLEVEL_SETUP)
			if(GAME_STATE_PLAYING)
				Master.SetRunLevel(RUNLEVEL_GAME)
			if(GAME_STATE_FINISHED)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Nanotrasen News Network"
	var/decoded_station_name = html_decode(station_name()) //decode station_name to avoid minor_announce double encode

	switch(news_report)
		// The nuke was detonated on the syndicate recon outpost
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [decoded_station_name] \
				detonated a nuclear device in the heart of a terrorist base."
		// The station was destroyed by nuke ops
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate \
				backed nuclear attack on [decoded_station_name] are, in fact, a hoax. Have a secure day!"
		// The station was evacuated (normal result)
		if(STATION_EVACUATED)
			// Had an emergency reason supplied to pass along
			if(emergency_reason)
				news_message = "[decoded_station_name] has been evacuated after transmitting \
					the following distress beacon:\n\n[html_decode(emergency_reason)]"
			else
				news_message = "The crew of [decoded_station_name] has been \
					evacuated amid unconfirmed reports of enemy activity."
		// A blob won
		if(BLOB_WIN)
			news_message = "[decoded_station_name] was overcome by an unknown biological outbreak, killing \
				all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		// A blob was destroyed
		if(BLOB_DESTROYED)
			news_message = "[decoded_station_name] is currently undergoing decontamination procedures \
				after the destruction of a biological hazard. As a reminder, any crew members experiencing \
				cramps or bloating should report immediately to security for incineration."
		// A certain percentage of all cultists managed to escape at the end of round
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [decoded_station_name]."
		// Cult was completely or almost completely wiped out
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [decoded_station_name], \
				we would like to remind all employees that worship outside of the Chapel is strictly prohibited, \
				and cause for termination."
		// Cult summoned Nar'sie
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [decoded_station_name] was scheduled \
				to be decommissioned following meteor damage earlier this year. Earlier reports of an \
				unknowable eldritch horror were made in error."
		// Nuke detonated, but missed the station entirely
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [decoded_station_name], \
				detonating a nuclear weapon in empty space nearby."
		// All nuke ops got killed
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [decoded_station_name] are underway after an elite \
				Syndicate death squad was wiped out by the crew."
		// Nuke ops results inconclusive - Crew escaped without the disk, or nukies were left alive, or something
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [decoded_station_name] \
				ended with both sides bloodied but intact."
		// Revolution victory
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt \
				aboard [decoded_station_name] there will be no wage increases for workers."
		// Revolution defeat
		if(REVS_LOSE)
			news_message = "[decoded_station_name] quickly put down a misguided attempt at mutiny. \
				Remember, unionizing is illegal!"
		// All wizards (plus apprentices) have been killed
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Space Wizard Federation following the death \
				of one of their members aboard [decoded_station_name]."
		// The station was nuked generically
		if(STATION_NUKED)
			// There was a blob on board, guess it was nuked to stop it
			if(length(GLOB.overminds))
				for(var/mob/camera/blob/overmind as anything in GLOB.overminds)
					if(overmind.max_count < overmind.announcement_size)
						continue

					news_message = "[decoded_station_name] is currently undergoing decontanimation after a controlled \
						burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, \
						and are enjoying a relaxing vacation."
					break
			// A self destruct or something else
			else
				news_message = "[decoded_station_name] activated its self-destruct device for unknown reasons. \
					Attempts to clone the Captain for arrest and execution are underway."
		// The emergency escape shuttle was hijacked
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [decoded_station_name] \
				had its navigation protocols corrupted and went off course, but was recovered shortly after."
		// A supermatter cascade triggered
		if(SUPERMATTER_CASCADE)
			news_message = "Officials are advising nearby colonies about a newly declared exclusion zone in \
				the sector surrounding [decoded_station_name]."

	if(news_message)
		send2otherserver(news_source, news_message, "News_Report")

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft)) //remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("An admin has delayed the round end."))
		return

	to_chat(world, span_boldannounce("Rebooting World in [DisplayTimeText(delay)]. [reason]"))

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2)) //don't wait forever
	reboot_timer = addtimer(CALLBACK(src, PROC_REF(reboot_callback), reason, end_string), delay - (world.time - start_wait), TIMER_STOPPABLE)


/datum/controller/subsystem/ticker/proc/reboot_callback(reason, end_string)
	if(end_string)
		end_state = end_string

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, span_info("Round statistics and logs can be viewed <a href=\"[statspage][GLOB.round_id]\">at this website!</a>"))
	else if(gamelogloc)
		to_chat(world, span_info("Round logs can be located <a href=\"[gamelogloc]\">at this website!</a>"))

	log_game(span_boldannounce("Rebooting World. [reason]"))

	world.Reboot()

/**
 * Deletes the current reboot timer and nulls the var
 *
 * Arguments:
 * * user - the user that cancelled the reboot, may be null
 */
/datum/controller/subsystem/ticker/proc/cancel_reboot(mob/user)
	if(!reboot_timer)
		to_chat(user, span_warning("There is no pending reboot!"))
		return FALSE
	to_chat(world, span_boldannounce("An admin has delayed the round end."))
	deltimer(reboot_timer)
	reboot_timer = null
	return TRUE

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()
	save_mentor_data() //MONKE EDIT
	if(!round_end_sound)
		round_end_sound = choose_round_end_song()
	///The reference to the end of round sound that we have chosen.
	var/sound/end_of_round_sound_ref = sound(round_end_sound)
	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.read_preference(/datum/preference/toggle/sound_endofround))
			SEND_SOUND(M.client, end_of_round_sound_ref)

	// monkestation removal start: fix-lobby-music
	// text2file(login_music, "data/last_round_lobby_music.txt")
	// monkestation removal end
/datum/controller/subsystem/ticker/proc/choose_round_end_song()
	var/list/reboot_sounds = flist("[global.config.directory]/reboot_themes/")
	var/list/possible_themes = list()

	for(var/themes in reboot_sounds)
		possible_themes += themes
	if(possible_themes.len)
		return "[global.config.directory]/reboot_themes/[pick(possible_themes)]"

#undef ROUND_START_MUSIC_LIST
#undef SS_TICKER_TRAIT
