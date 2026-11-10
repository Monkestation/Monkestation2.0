/**
 * A station trait which enables a temporary job
 * Generally speaking these should always all be mutually exclusive, don't have too many at once
 */
/datum/station_trait/job
	sign_up_button = TRUE
	abstract_type = /datum/station_trait/job
	/// What tooltip to show on the button
	var/button_desc = "Sign up to gain some kind of unusual job, not available in most rounds."
	/// How many positions to spawn?
	var/position_amount = 1
	/// Type of job to enable
	var/datum/job/job_to_add = /datum/job/clown
	/// Who signed up to this in the lobby
	var/list/lobby_candidates

/datum/station_trait/job/New()
	. = ..()
	blacklist += subtypesof(/datum/station_trait/job) - type // All but ourselves

/datum/station_trait/job/setup_lobby_button(atom/movable/screen/lobby/button/sign_up/lobby_button)
	RegisterSignal(lobby_button, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_lobby_button_update_overlays))
	lobby_button.desc = button_desc
	return ..()

/datum/station_trait/job/on_lobby_button_click(atom/movable/screen/lobby/button/sign_up/lobby_button, location, control, params, mob/dead/new_player/user)
	if (LAZYFIND(lobby_candidates, user))
		LAZYREMOVE(lobby_candidates, user)
	else
		LAZYADD(lobby_candidates, user)

/datum/station_trait/job/on_lobby_button_destroyed(atom/movable/screen/lobby/button/sign_up/lobby_button)
	. = ..()
	LAZYREMOVE(lobby_candidates, lobby_button.get_mob())

/datum/station_trait/job/on_lobby_button_update_icon(atom/movable/screen/lobby/button/sign_up/lobby_button, updates)
	if (LAZYFIND(lobby_candidates, lobby_button.get_mob()))
		lobby_button.base_icon_state = "signup_on"
	else
		lobby_button.base_icon_state = "signup"

/// Add an overlay based on whether you are actively signed up for this role
/datum/station_trait/job/proc/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	SIGNAL_HANDLER
	overlays += LAZYFIND(lobby_candidates, lobby_button.get_mob()) ? "tick" : "cross"

/// Called before we start assigning roles, assign ours first
/datum/station_trait/job/proc/pre_jobs_assigned()
	var/datum/job/our_job = SSjob.GetJobType(job_to_add)
	our_job.total_positions = position_amount
	our_job.spawn_positions = position_amount

	var/list/eligible_candidates = list()
	for (var/mob/dead/new_player/signee as anything in lobby_candidates)
		if (QDELETED(signee) || !(signee in SSjob.unassigned))
			continue
		if (SSjob.check_job_eligibility(signee, our_job, "STJ") != JOB_AVAILABLE)
			continue
		eligible_candidates += signee

	while(length(eligible_candidates) && our_job.current_positions < position_amount)
		var/mob/dead/new_player/picked_player = pick_n_take(eligible_candidates)
		SSjob.handle_temp_assignments(picked_player, our_job)

	our_job.spawn_positions = our_job.current_positions

/datum/station_trait/job/can_display_lobby_button(client/player)
	var/datum/job/our_job = SSjob.GetJobType(job_to_add)
	return our_job.player_old_enough(player) && ..()

/datum/station_trait/job/on_round_start()
	. = ..()
	sign_up_button = FALSE
	lobby_candidates = null

/// Adds a gorilla to the cargo department, replacing the sloth and the mech
/datum/station_trait/job/cargorilla
	name = "Cargo Gorilla"
	button_desc = "Sign up to become the Cargo Gorilla, a peaceful shepherd of boxes."
	weight = 1
	show_in_report = FALSE // Selective attention test. Did you spot the gorilla?
	job_to_add = /datum/job/cargo_gorilla

/datum/station_trait/job/cargorilla/New()
	. = ..()
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(replace_cargo))

/datum/station_trait/job/cargorilla/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	. = ..()
	overlays += LAZYFIND(lobby_candidates, lobby_button.get_mob()) ? "gorilla_on" : "gorilla_off"

/// Remove the cargo equipment and personnel that are being replaced by a gorilla.
/datum/station_trait/job/cargorilla/proc/replace_cargo(datum/source)
	SIGNAL_HANDLER
	var/mob/living/basic/sloth/cargo_sloth = GLOB.cargo_sloth
	if(isnull(cargo_sloth))
		lobby_candidates = list()
		destroy_lobby_buttons() // Sorry folks
		sign_up_button = FALSE
		return

	// hmm our sloth looks funny today
	qdel(cargo_sloth)
	// monkey carries the crates, the age of robot is over
	if(GLOB.cargo_ripley)
		qdel(GLOB.cargo_ripley)

/datum/station_trait/job/pun_pun
	name = "Pun Pun is a Crewmember"
	button_desc = "Ook ook ah ah, sign up to play as the bartender's monkey."
	weight = 0 //Unrollable by default, available all day during monkey day.
	report_message = "We've evaluated the bartender's monkey to have the mental capacity of the average crewmember. As such, we made them one."
	show_in_report = TRUE
	job_to_add = /datum/job/pun_pun

/datum/station_trait/job/pun_pun/New()
	. = ..()
	//Make sure we don't have two Pun Puns if loaded before the start of the round.
	if(SSticker.HasRoundStarted() || !GLOB.the_one_and_only_punpun)
		return
	new /obj/effect/landmark/start/pun_pun(GLOB.the_one_and_only_punpun.loc)
	qdel(GLOB.the_one_and_only_punpun)

/datum/station_trait/job/pun_pun/on_lobby_button_update_overlays(atom/movable/screen/lobby/button/sign_up/lobby_button, list/overlays)
	. = ..()
	overlays += LAZYFIND(lobby_candidates, lobby_button.get_mob()) ? "pun_pun_on" : "pun_pun_off"
