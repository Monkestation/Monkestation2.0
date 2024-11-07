///A subsystem to manage the global effects of clock cult
//#define SERVANT_CAPACITY_TO_GIVE 2 //how many extra servant slots do we give on first charged crystal
SUBSYSTEM_DEF(the_ark)
	name = "The Clockwork Ark"
	wait = 1 SECOND
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME

	///The list of anchoring crystals, value is 0 is uncharged and 1 if charged
	var/list/anchoring_crystals
	///How many charged anchoring crystals are there
	var/charged_anchoring_crystals = 0
	///Dimension theme used for transforming turfs
	var/datum/dimension_theme/clockwork/clock_dimension_theme
	///Assoc list of the original names of areas that are valid to summon anchoring crystals keyed to its area
	var/list/valid_crystal_areas
	///The pool of hallucinations we can trigger
	var/list/hallucination_pool

/datum/controller/subsystem/the_ark/Initialize()
	anchoring_crystals = list()
	clock_dimension_theme = new(is_cult = TRUE)
	hallucination_pool = list(
		/datum/hallucination/fake_item/clockwork_slab = 2,
		/datum/hallucination/nearby_fake_item/clockwork_slab = 2,
		/datum/hallucination/hazard/clockwork_skewer = 1,
		/datum/hallucination/delusion/preset/clock_cultists = 1,
		/datum/hallucination/fake_sound/weird/clockcult_kindle = 2,
		/datum/hallucination/fake_sound/weird/clockcult_warp = 2,
	)
	initialized = TRUE

/datum/controller/subsystem/the_ark/fire(resumed)
	if(charged_anchoring_crystals)
		handle_charged_crystals()

/datum/controller/subsystem/the_ark/proc/handle_charged_crystals()
	if(prob(charged_anchoring_crystals))
		var/mob/living/selected_player = pick(GLOB.alive_player_list)
		if(prob(50))
			selected_player.cause_hallucination(pick_weight(hallucination_pool), "The Clockwork Ark")
		else
			to_chat(selected_player, span_notice(pick(list("You hear a faint ticking in the back of your mind", "You smell something metallic", \
				"You see a flash of light out of the corner of your eye", "You feel an otherworldly presence", "You feel like your forgetting something"))))

	if(charged_anchoring_crystals >= 2)
		return

/datum/controller/subsystem/the_ark/proc/on_crystal_charged(obj/structure/destructible/clockwork/anchoring_crystal/charged_crystal)
	charged_anchoring_crystals++
	anchoring_crystals[charged_crystal] = 1
	SEND_SIGNAL(src, COMSIG_ANCHORING_CRYSTAL_CHARGED, charged_crystal)
	var/datum/scripture/create_structure/anchoring_crystal/crystal_script
	addtimer(CALLBACK(src, PROC_REF(clear_shuttle_interference), charged_crystal), \
			(ANCHORING_CRYSTAL_COOLDOWN - (ANCHORING_CRYSTAL_CHARGE_DURATION SECONDS)) + initial(crystal_script.invocation_time))

	/*if(1) //add 2 more max servants and increase replica fabricator build speed
		GLOB.main_clock_cult.max_human_servants += SERVANT_CAPACITY_TO_GIVE*/
	if(charged_anchoring_crystals == ANCHORING_CRYSTALS_TO_SUMMON + 1) //create a steam helios on reebe
		if(length(GLOB.abscond_markers))
			var/turf/created_at = get_turf(pick(GLOB.abscond_markers))
			new /obj/vehicle/sealed/mecha/steam_helios(created_at)
			new /obj/effect/temp_visual/steam(created_at)
		else if(GLOB.clock_ark)
			new /obj/vehicle/sealed/mecha/steam_helios(get_turf(GLOB.clock_ark))
		else
			message_admins("No valid location for Steam Helios creation.")

///fully disables the shuttle similar to the admin verb
/datum/controller/subsystem/the_ark/proc/block_shuttle(datum/blocker)
	if(SSshuttle.admin_emergency_disabled || SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		return

	SSshuttle.last_mode = SSshuttle.emergency.mode
	SSshuttle.last_call_time = SSshuttle.emergency.timeLeft(1)
	SSshuttle.emergency_no_recall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED

///renables the shuttle
/datum/controller/subsystem/the_ark/proc/clear_shuttle_interference(datum/unblocker)
	if(SSshuttle.admin_emergency_disabled || SSshuttle.emergency.mode != SHUTTLE_DISABLED || (unblocker && istype(unblocker, /obj/structure/destructible/clockwork/anchoring_crystal)))
		return

	SSshuttle.emergency_no_recall = FALSE
	if(SSshuttle.last_mode == SHUTTLE_DISABLED)
		SSshuttle.last_mode = SHUTTLE_IDLE

	SSshuttle.emergency.mode = SSshuttle.last_mode
	if(SSshuttle.last_call_time < 10 SECONDS && SSshuttle.last_mode != SHUTTLE_IDLE)
		SSshuttle.last_call_time = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.last_call_time)
	priority_announce("Emergency shuttle uplink connection regained.", "Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

///returns how many charged anchor crystals there are
/datum/controller/subsystem/the_ark/proc/get_charged_anchor_crystals()
	var/charged_count = 0
	for(var/crystal in SSthe_ark.anchoring_crystals)
		charged_count += SSthe_ark.anchoring_crystals[crystal]
	return charged_count

//#undef SERVANT_CAPACITY_TO_GIVE
