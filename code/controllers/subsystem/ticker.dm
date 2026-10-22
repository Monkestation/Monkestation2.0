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

	///The status of the NT Rep, updated when one joins or the round ends.
	var/nanotrasen_rep_status = NT_REP_STATUS_DOESNT_EXIST
	///The score, out of 5, that the NT rep has given the station. 0 if they died.
	var/nanotrasen_rep_score = 0
	///A comment the rep has given, if any.
	var/nanotrasen_rep_comments


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
	var/list/bitflags_to_reward = list(DEPARTMENT_BITFLAG_SECURITY, DEPARTMENT_BITFLAG_SILICON)
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
		var/lower = LOWER_TEXT(S)
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
			var/ext = LOWER_TEXT(L[L.len]) //pick the real extension, no 'honk.ogg.exe' nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(!length(music))
		music = file2list(ROUND_START_MUSIC_LIST, "\n")
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
				config.show_lobby_notices(world)
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
	SSgamemode.roll_pre_setup_points()
	CHECK_TICK
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

	Master.clear_profiler()

	return TRUE

/datum/controller/subsystem/ticker/proc/welcome_player(mob/player)
	var/list/channel_volume = player?.client?.prefs?.channel_volume
	if(!(channel_volume["[CHANNEL_STORYTELLER]"]))
		return
	var/volume_played = channel_volume["[CHANNEL_STORYTELLER]"] * (channel_volume["[CHANNEL_MASTER_VOLUME]"] * 0.01)
	SEND_SOUND(player, sound(SSstation.announcer.get_rand_welcome_sound(), volume = volume_played))

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	if(!CONFIG_GET(flag/disable_storyteller))
		SSgamemode.current_storyteller.round_started = TRUE
		/*if(!SSgamemode.halted_storyteller) //temp removal
			SSgamemode.current_storyteller.tick()*/ // we want this asap
	mode.post_setup()
	addtimer(CALLBACK(src, PROC_REF(fade_all_splashes)), 1 SECONDS) // extra second to make SURE all antags are setup

	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2adminchat("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]" : ""] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE

	for(var/obj/effect/landmark/start/mark in GLOB.start_landmarks_list)
		if(istype(mark)) //we can not runtime here. not in this important of a proc.
			mark.after_round_start()
		else
			stack_trace("[mark] [(isdatum(mark) ? mark.type : "non datum")] found in start landmarks list, which isn't a start landmark!")

	// handle persistence stuff that requires ckeys, in this case hardcore mode and temporal scarring
	var/list/simians = list()
	for(var/mob/living/carbon/human/iter_human in GLOB.player_list)
		if(issimianspecies(iter_human))
			simians += iter_human

		iter_human.increment_scar_slot()
		iter_human.load_persistent_scars()
		SSpersistence.load_modular_persistence(iter_human.get_organ_slot(ORGAN_SLOT_BRAIN))

		if(!iter_human.hardcore_survival_score)
			continue
		if(iter_human.mind?.special_role)
			to_chat(iter_human, span_notice("You will gain [round(iter_human.hardcore_survival_score) * 2] hardcore random points if you greentext this round!"))
		else
			to_chat(iter_human, span_notice("You will gain [round(iter_human.hardcore_survival_score)] hardcore random points if you survive this round!"))

	if(length(simians) >= 2 && prob(20 * simians))
		go_simian_mode(simians)
	SStitle.update_init_text()

/datum/controller/subsystem/ticker/proc/go_simian_mode(list/jumping_on_the_bed)
	var/obj/item/big_stick/ooh_stick_i_found = new()
	var/mob/living/carbon/human/grug_oog = pick(jumping_on_the_bed)
	grug_oog.put_in_hands(ooh_stick_i_found)
	for(var/mob/living/carbon/human/other_grug as anything in jumping_on_the_bed)
		to_chat(other_grug, span_warning("[grug_oog.real_name] is the Alpha! Listen to their orders, or mutiny against them, at your own peril."))

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
				persistent_client.roundend_monkecoin_bonus += 225
		for(var/processing_reward_jobs in jobs_to_reward)//just in case you really only want to reward a specific job
			if(living.job == processing_reward_jobs)
				persistent_client.roundend_monkecoin_bonus += 225

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
				for(var/mob/eye/blob/overmind as anything in GLOB.overminds)
					if(!overmind.antag_team || overmind.antag_team.highest_tile_count < overmind.antag_team.announcement_size)
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
		if(M.client.prefs?.channel_volume["[CHANNEL_LOBBYMUSIC]"])
			end_of_round_sound_ref.volume = calculate_mixed_volume(M.client, 100, CHANNEL_LOBBYMUSIC)
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

/datum/controller/subsystem/ticker/proc/gather_roundend_feedback()
	gather_antag_data()
	record_nuke_disk_location()
	var/json_file = file("[GLOB.log_directory]/round_end_data.json")
	// All but npcs sublists and ghost category contain only mobs with minds
	var/list/file_data = list(
		"escapees" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()),
		"abandoned" = list("humans" = list(), "silicons" = list(), "others" = list(), "npcs" = list()),
		"ghosts" = list(),
		"additional data" = list(),
	)
	var/num_survivors = 0 //Count of non-brain non-eye mobs with mind that are alive
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
			if(M.stat != DEAD && !isbrain(M) && !iseyemob(M))
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

	if(human_mob.mind && (length(human_mob.mind.antag_datums) > 0))
		for(var/datum/antagonist/antag_datums as anything in human_mob.mind.antag_datums)
			if(!antag_datums.hardcore_random_bonus) //don't give bonuses to dumb stuff like revs or hypnos
				continue
			if(initial(antag_datums.can_assign_self_objectives) && !antag_datums.can_assign_self_objectives)
				continue // You don't get a prize if you picked your own objective, you can't fail those

			var/greentexted = TRUE
			for(var/datum/objective/objective_datum as anything in antag_datums.objectives)
				if(!objective_datum.check_completion())
					greentexted = FALSE
					break

			if(greentexted)
				var/score = round(human_mob.hardcore_survival_score * 2)
				player_client?.give_award(/datum/award/score/hardcore_random, human_mob, score)
				log_admin("[player_client] gained [score] hardcore random points, including greentext bonus!")
				player_client?.prefs.adjust_metacoins(player_client.ckey, 500, "hardcore random greentext")
				return

	if(considered_escaped(human_mob.mind))
		player_client.give_award(/datum/award/score/hardcore_random, human_mob, round(human_mob.hardcore_survival_score))
		log_admin("[player_client] gained [round(human_mob.hardcore_survival_score)] hardcore random points.")

/datum/controller/subsystem/ticker/proc/declare_completion(was_forced = END_ROUND_AS_NORMAL)
	set waitfor = FALSE

	INVOKE_ASYNC(Tracy, TYPE_PROC_REF(/datum/tracy, flush))

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

	save_tokens()
	refund_cassette()
	distribute_rewards(rewards)
	sleep(5 SECONDS)
	ready_for_reboot = TRUE
	var/datum/discord_embed/embed = format_roundend_embed("<@&999008528595419278>")
	send2roundend_webhook(embed)
	SSplexora.roundended()
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
	Tracy.flush()
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

	//might want to make this a full section
	parts += "<div class='panel stationborder'><span class='header'>[("Storyteller: [SSgamemode.current_storyteller ? SSgamemode.current_storyteller.name : "N/A"]")]</span></div>"

	if(nanotrasen_rep_status)
		parts += nanotrasen_rep_report()

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
	parts += "[FOURSPACES]Map: [SSmapping.current_map?.return_map_name()]"
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
			for(var/entry in mode.roundend_threat_log)
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

///Builds the report from the on-station NT Reps, giving score and comments.
/datum/controller/subsystem/ticker/proc/nanotrasen_rep_report()
	var/list/parts = list()
	if(nanotrasen_rep_status == NT_REP_STATUS_DIED)
		nanotrasen_rep_score = 0
		nanotrasen_rep_comments = "Wait, what the hell, where's our representative?"
	parts += "<div class='panel stationborder'><span class='header'>Representative Report:</span></br>"
	parts += "Official Score: "
	for(var/i in 1 to min(nanotrasen_rep_score, MAX_NT_REP_SCORE))
		parts += "<i class='fa-solid fa-star' /></i>"
	for(var/i in 1 to (MAX_NT_REP_SCORE - nanotrasen_rep_score))
		parts += "<i class='fa-regular fa-star' /></i>"
	parts += "</br>"

	if(nanotrasen_rep_comments)
		parts += "<span class='subheader'>The Representative left a comment:</span></br>"
		parts += "[nanotrasen_rep_comments]"
	parts += "</div>"
	return parts

/datum/controller/subsystem/ticker/proc/law_report()
	var/list/parts = list()
	var/borg_spacer = FALSE //inserts an extra linebreak to separate AIs from independent borgs, and then multiple independent borgs.
	//Silicon laws report
	for (var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/aiPlayer = i
		var/datum/mind/aiMind = aiPlayer.deployed_shell?.mind || aiPlayer.mind
		if(aiMind)
			var/show_key = GLOB.roundend_hidden_ckeys[ckey(aiMind.key)]
			parts += "<b>[aiPlayer.name]</b>[show_key ? " (Played by: <b>[aiMind.key]</b>)" : null]'s laws [aiPlayer.stat != DEAD ? "at the end of the round" : "when it was [span_redtext("deactivated")]"] were:"
			parts += aiPlayer.laws.get_law_list(include_zeroth=TRUE)

		parts += "<b>Total law changes: [aiPlayer.law_change_counter]</b>"

		if (aiPlayer.connected_robots.len)
			var/borg_num = aiPlayer.connected_robots.len
			parts += "<br><b>[aiPlayer.real_name]</b>'s minions were:"
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				borg_num--
				if(robo.mind)
					var/show_key = GLOB.roundend_hidden_ckeys[ckey(robo.mind.key)]
					parts += "<b>[robo.name]</b>[show_key ? " (Played by: <b>[robo.mind.key]</b>)" : null][robo.stat == DEAD ? " [span_redtext("(Deactivated)")]" : ""][borg_num ?", ":""]"
		if(!borg_spacer)
			borg_spacer = TRUE

	for (var/mob/living/silicon/robot/robo in GLOB.silicon_mobs)
		if (!robo.connected_ai && robo.mind)
			var/show_key = GLOB.roundend_hidden_ckeys[ckey(robo.mind.key)]
			parts += "[borg_spacer?"<br>":""]<b>[robo.name]</b>[show_key ? " (Played by: <b>[robo.mind.key]</b>)" : null] [(robo.stat != DEAD)? "[span_greentext("survived")] as an AI-less borg!" : "was [span_redtext("unable to survive")] the rigors of being a cyborg without an AI."] Its laws were:"

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
		if(!human_player.hardcore_survival_score || !considered_escaped(human_player.mind) || human_player.stat == DEAD) ///gotta escape nerd
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
	var/text
	var/show_key = GLOB.roundend_hidden_ckeys[ckey(ply.key)]
	if(show_key)
		text = "<b>[ply.key]</b> was <b>[ply.name]</b>[jobtext] and"
	else
		text = "<b>[ply.name]</b>[jobtext] "
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

/datum/controller/subsystem/ticker/proc/cheevo_report()
	var/list/parts = list()
	if(length(GLOB.achievements_unlocked))
		parts += "<span class='header'>Achievement Get!</span><BR>"
		parts += "<span class='infoplain'>Total Achievements Earned: <B>[length(GLOB.achievements_unlocked)]!</B></span><BR>"
		parts += "<ul class='playerlist'>"
		for(var/datum/achievement_report/cheevo_report in GLOB.achievements_unlocked)
			var/show_key = GLOB.roundend_hidden_ckeys[cheevo_report.winner_key]
			parts += "<BR>[show_key ? "[cheevo_report.winner_key] was " : ""]<b>[cheevo_report.winner]</b>, who earned the [span_greentext("'[cheevo_report.cheevo]'")] achievement at [cheevo_report.award_location]!<BR>"
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

/datum/controller/subsystem/ticker/proc/save_tokens()
	rustg_file_write(json_encode(GLOB.saved_token_values), "[GLOB.log_directory]/tokens.json")

/datum/controller/subsystem/ticker/proc/calculate_rewards()
	. = list()
	for(var/client/client as anything in GLOB.clients)
		calculate_rewards_for_client(client, .)
	calculate_station_goal_bonus(.)

/datum/controller/subsystem/ticker/proc/calculate_station_goal_bonus(list/rewards)
	var/list/joined_player_list = unique_list(GLOB.joined_player_list)
	var/total_crew = length(joined_player_list)
	if(total_crew < 10) // prevent wrecking the economy on like MRP2
		return
	var/completed = FALSE
	for(var/datum/station_goal/station_goal as anything in GLOB.station_goals)
		if(station_goal.check_completion())
			completed = TRUE
			break
	if(!completed)
		return
	// Note: The math for this is complicated, but if we have an average crew member size of like, 50, each crew member will get
	// 1000. The 2nd paremter rounds up to that nearest number
	var/amount = CEILING(50000 / total_crew, 50) // nice even number
	for(var/ckey in joined_player_list)
		LAZYINITLIST(rewards[ckey])
		rewards[ckey] += list(list(amount, "Station Goal Completion Bonus"))

	message_admins("As a result of the station goal being completed, [total_crew] players were rewarded [amount] monkecoins each.")
	log_game("As a result of the station goal being completed, [total_crew] players were rewarded [amount] monkecoins each.")

/datum/controller/subsystem/ticker/proc/distribute_rewards(list/coin_rewards)
	var/hour = round((world.time - SSticker.round_start_time) / 36000)
	var/minute = round(((world.time - SSticker.round_start_time) - (hour * 36000)) / 600)
	var/added_xp = round(25 + (minute ** 0.85))
	for(var/ckey in coin_rewards)
		distribute_rewards_to_client(ckey, added_xp, coin_rewards[ckey])

/datum/controller/subsystem/ticker/proc/distribute_rewards_to_client(ckey, added_xp, list/rewards)
	var/client/client = GLOB.directory[ckey]
	if(!client)
		return
	var/total_amount = 0
	for(var/reward in rewards)
		var/amount = reward[1]
		var/reason = reward[2]
		total_amount += amount
		to_chat(client, span_rose(span_bold("[abs(amount)] Monkecoins have been [amount >= 0 ? "deposited to" : "withdrawn from"] your account! Reason: [reason]")))
	// don't do separate SQL queries for each reward, just add all the coins at once lol
	if(total_amount)
		client?.prefs?.adjust_metacoins(ckey, total_amount, reason = "roundend rewards", announces = FALSE)
	if(client?.mob?.mind?.assigned_role)
		add_jobxp(client, added_xp, client?.mob?.mind?.assigned_role?.title)

/datum/controller/subsystem/ticker/proc/calculate_rewards_for_client(client/client, list/queue)
	if(!istype(client) || QDELING(client) || isnewplayer(client?.mob))
		return
	var/ckey = client?.ckey
	if(!ckey)
		return
	var/datum/persistent_client/details = client.persistent_client

	var/round_end_bonus = 100
	var/dono_bonus

	// Patreon Flat Roundend Bonus
		// Twitch Flat Roundend Bonus
	if((details?.twitch?.has_access(ACCESS_TWITCH_SUB_TIER_1)))
		dono_bonus += DONATOR_ROUNDEND_BONUS
	if((details?.patreon?.has_access(ACCESS_ASSISTANT_RANK)))
		dono_bonus += DONATOR_ROUNDEND_BONUS
	if(details?.patreon?.has_access(ACCESS_NUKIE_RANK))
		dono_bonus += DONATOR_ROUNDEND_BONUS
	if(dono_bonus > 0)
		queue[ckey] += list(list(dono_bonus, "Donator Bonus! Thank you!"))

	LAZYINITLIST(queue[ckey])

	queue[ckey] += list(list(round_end_bonus, "Played a Round"))

	if(world.port == MRP2_PORT)
		queue[ckey] += list(list(500, "MRP2 Seeding Subsidies"))
	var/special_bonus = details?.roundend_monkecoin_bonus
	if(special_bonus)
		queue[ckey] += list(list(special_bonus, "Special Bonus"))
	if(!isnull(GLOB.mentor_datums[ckey]) || !isnull(GLOB.dementors[ckey]))
		if(details?.mob?.mind?.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			queue[ckey] += list(list(300, "Mentor Head of Staff Bonus"))
		else
			queue[ckey] += list(list(200, "Mentor Bonus"))

	var/list/applied_challenges = details?.applied_challenges
	if(LAZYLEN(applied_challenges))
		var/mob/living/client_mob = details?.mob
		if(!istype(client_mob) || QDELING(client_mob) || client_mob?.stat == DEAD)
			return
		var/total_payout = 0
		for(var/datum/challenge/listed_challenge as anything in applied_challenges)
			if(listed_challenge.failed)
				continue
			total_payout += listed_challenge.challenge_payout
		if(total_payout)
			queue[ckey] += list(list(total_payout, "Challenge Rewards"))

/datum/controller/subsystem/ticker/proc/refund_cassette()
	if(!length(GLOB.cassette_reviews))
		return

	for(var/_id, value in GLOB.cassette_reviews)
		var/datum/cassette_review/review = value
		if(!review || review.action_taken) // Skip if review doesn't exist or already handled (denied / approved)
			continue

		var/ownerckey = review.submitter_ckey // ckey of who made the cassette.
		if(!ownerckey)
			continue

		var/client/client = GLOB.directory[ownerckey] // Use directory for direct lookup (Client might be a differnet mob than when review was made.)
		if(client && !QDELETED(client?.prefs))
			var/prev_bal = client?.prefs?.metacoins
			var/adjusted = client?.prefs?.adjust_metacoins(
				client?.ckey,
				amount = 5000,
				reason = "No action taken on cassette:\[[review.cassette_data.name]\] before round end",
				announces = TRUE,
				donator_multiplier = FALSE,
			)
			if(!adjusted)
				message_admins("Balance not adjusted for Cassette:[review.cassette_data.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins]. Issue logged.")
				log_admin("Balance not adjusted for Cassette:[review.cassette_data.name], Balance for [client]; Previous:[prev_bal], Expected:[prev_bal + 5000], Current:[client?.prefs?.metacoins].")
			qdel(review)

#undef ROUND_START_MUSIC_LIST
#undef SS_TICKER_TRAIT
