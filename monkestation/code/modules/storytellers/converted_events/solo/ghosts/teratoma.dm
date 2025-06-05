/// The maximum amount of teratomas for a single roll to shove into a pod.
#define MAX_TERATOMAS_TO_SPAWN 5

/datum/round_event_control/teratoma
	name = "Teratoma Crash"
	description = "Crashes a pod of up to 5 teratomas into the station."
	typepath = /datum/round_event/ghost_role/teratoma
	min_players = 35 // these are destructive
	track = EVENT_TRACK_MAJOR
	weight = 5
	tags = list(TAG_COMBAT, TAG_DESTRUCTIVE, TAG_OUTSIDER_ANTAG, TAG_EXTERNAL, TAG_ALIEN)
	earliest_start = 40 MINUTES
	checks_antag_cap = TRUE
	dont_spawn_near_roundend = TRUE

/datum/round_event/ghost_role/teratoma
	minimum_required = 1
	role_name = "teratoma crash"
	fakeable = FALSE //Nothing to fake here

/datum/round_event/ghost_role/teratoma/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to be part of a group of teratomas crashing into the station?",
		role = ROLE_TERATOMA,
		ignore_category = POLL_IGNORE_TERATOMA,
		alert_pic = /datum/antagonist/teratoma,
		role_name_text = "teratoma crash",
		chat_text_border_icon = /datum/antagonist/teratoma,
	)

	if(length(candidates) < 1)
		return NOT_ENOUGH_PLAYERS

	var/turf/maint_spawn = find_maintenance_spawn(atmos_sensitive = TRUE)
	if(!maint_spawn) // this shouldn't happen
		maint_spawn = get_safe_random_station_turf_equal_weight()
		if(!maint_spawn) // this REALLY shouldn't happen
			return MAP_ERROR

	var/pod_type = pick(/obj/structure/closet/supplypod/car_pod, /obj/structure/closet/supplypod/washer_pod)
	var/obj/structure/closet/supplypod/pod = new pod_type
	pod.stay_after_drop = TRUE
	while(length(candidates) > 0 && length(spawned_mobs) < MAX_TERATOMAS_TO_SPAWN)
		var/mob/dead/selected = pick_n_take(candidates)
		if(QDELETED(selected) || !selected.client)
			continue
		var/datum/mind/goober_mind = new(selected.key)
		goober_mind.active = TRUE

		var/mob/living/carbon/human/species/teratoma/goober = new(pod)
		goober_mind.transfer_to(goober)
		goober_mind.add_antag_datum(/datum/antagonist/teratoma)
		if(prob(20))
			goober.adjust_drunk_effect(rand(15, 25))
		// bomb immunity for just long enough for the pod to land
		ADD_TRAIT(goober, TRAIT_BOMBIMMUNE, type)
		addtimer(TRAIT_CALLBACK_REMOVE(goober, TRAIT_BOMBIMMUNE, type), 5 SECONDS)
		spawned_mobs += goober
	new /obj/effect/pod_landingzone(maint_spawn, pod)

	return SUCCESSFUL_SPAWN

#undef MAX_TERATOMAS_TO_SPAWN
