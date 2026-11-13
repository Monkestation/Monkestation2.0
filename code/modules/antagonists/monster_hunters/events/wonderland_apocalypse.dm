/// The Wonderland apocalypse, if one has started.
GLOBAL_DATUM(wonderland_apocalypse, /datum/wonderland_apocalypse)

/datum/dimension_theme/wonderland
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	replace_floors = list(/turf/open/misc/grass/jungle/wonderland = 1)
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1), \
		/obj/machinery/holopad  = list(/obj/structure/flora/tree/jungle = 1 ), \
		/obj/machinery/atmospherics/components/unary/vent_scrubber = list(/obj/structure/flora/tree/dead = 1))
	/// Whether this patch is a chess board instead of a meadow.
	var/chess_board = FALSE

/datum/dimension_theme/wonderland/New()
	. = ..()
	chess_board = prob(20)

/datum/dimension_theme/wonderland/transform_floor(turf/open/floor/affected_floor)
	// overlapping patches would otherwise redo a board and stack its pieces
	if(istype(affected_floor, /turf/open/floor/black/wonderland) || istype(affected_floor, /turf/open/floor/white/wonderland))
		return FALSE
	if(chess_board)
		affected_floor.replace_floor(((affected_floor.x + affected_floor.y) % 2) ? /turf/open/floor/white/wonderland : /turf/open/floor/black/wonderland, flags = CHANGETURF_INHERIT_AIR)
		if(prob(4) && !affected_floor.is_blocked_turf(exclude_mobs = TRUE))
			var/piece = pick(
				/obj/structure/chess/whitepawn,
				/obj/structure/chess/whiterook,
				/obj/structure/chess/whiteknight,
				/obj/structure/chess/whitebishop,
				/obj/structure/chess/whitequeen,
				/obj/structure/chess/whiteking,
				/obj/structure/chess/blackpawn,
				/obj/structure/chess/blackrook,
				/obj/structure/chess/blackknight,
				/obj/structure/chess/blackbishop,
				/obj/structure/chess/blackqueen,
				/obj/structure/chess/blackking,
			)
			new piece(affected_floor)
		return TRUE
	. = ..()
	if(. && prob(8) && !affected_floor.is_blocked_turf(exclude_mobs = TRUE))
		var/flowers = pick(
			/obj/structure/flora/bush/flowers_yw/style_random,
			/obj/structure/flora/bush/flowers_br/style_random,
			/obj/structure/flora/bush/flowers_pp/style_random,
		)
		new flowers(affected_floor)

/turf/open/floor/black/wonderland

/turf/open/floor/white/wonderland

/turf/open/misc/grass/jungle/wonderland
	underfloor_accessibility = UNDERFLOOR_HIDDEN

/datum/wonderland_apocalypse
	/// Killer rabbits our rabbit holes have let out that are still alive.
	var/wave_rabbits = 0
	/// Timer id of the check for the shuttle docking.
	var/dock_timer

/datum/wonderland_apocalypse/New()
	GLOB.wonderland_apocalypse = src
	SSgamemode.halted_storyteller = TRUE
	if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_LAMBDA)
		SSsecurity_level.set_level(SEC_LEVEL_LAMBDA)
	priority_announce(
		text = "Something has just torn through into your station, and our scanners are showing a meadow where you should be. " \
			+ Gibberish("Get to the shuttle.", chance = 15) + " " + Gibberish("Do not stop for anyth-", chance = 40) + \
			span_hearts_announcement("That is quite enough from them. \
				This station is mine now - every floor, every door, and everybody on it. \
				Court is in session, and you are all the accused. There will be no magic and no tricks in my court. \
				Now, has anybody seen the cake?" \
			),
		title = "Higher Dimensional Affairs",
		sound = 'sound/music/antag/monster_hunter.ogg',
		encode_text = FALSE,
		color_override = "purple"
	)
	if(EMERGENCY_IDLE_OR_RECALLED)
		addtimer(CALLBACK(SSshuttle, TYPE_PROC_REF(/datum/controller/subsystem/shuttle, call_evac_shuttle), "A hostile higher-dimensional entity has claimed the station as its own. Crew survival is no longer considered likely. Priority evacuation shuttle dispatched."), 25 SECONDS, TIMER_UNIQUE)
	SSshuttle.emergency_no_recall = TRUE
	for(var/turf/anomaly_turf as anything in pick_noise_station_turfs(16, 4))
		new /obj/effect/anomaly/dimensional/wonderland(anomaly_turf, null, FALSE)
	for(var/turf/rift_turf as anything in pick_noise_station_turfs(4, 4, list(/obj/effect/anomaly/dimensional/wonderland)))
		var/obj/structure/wonderland_rift/rift = new(rift_turf)
		notify_ghosts(
			"A rift to Wonderland has been torn open!",
			source = rift,
			action = NOTIFY_ORBIT,
			notify_flags = NOTIFY_CATEGORY_NOFLASH,
			header = "Wonderland Rift Opened",
		)
	for(var/mob/living/target as anything in GLOB.mob_living_list)
		if(QDELETED(target))
			continue
		var/area/centcom/target_area = get_area(target)
		if(istype(target_area) && target_area.grace)
			continue
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, apply_status_effect), /datum/status_effect/wonderland_district), rand(5 SECONDS, 10 SECONDS))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(apply_pressure_to_new_mob))
	SSweather.run_weather(/datum/weather/wonderland)
	var/list/white_rabbits = list()
	for(var/mob/living/basic/wonderland_rabbit/rabbit in GLOB.mob_living_list)
		white_rabbits += rabbit
	shuffle_inplace(white_rabbits)
	for(var/i in 1 to min(length(white_rabbits), 8))
		addtimer(CALLBACK(white_rabbits[i], TYPE_PROC_REF(/mob/living/basic/wonderland_rabbit, turn_killer)), rand(10 SECONDS, 60 SECONDS))
	addtimer(CALLBACK(src, PROC_REF(open_rabbit_holes)), 1 MINUTES, TIMER_LOOP)
	dock_timer = addtimer(CALLBACK(src, PROC_REF(check_shuttle_docked)), 10 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)
	seal_endings()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WONDERLAND_APOCALYPSE)

/// Only new rituals are refused, one already under way is left to finish so it cannot strand the shuttle
/datum/wonderland_apocalypse/proc/seal_endings()
	var/static/alist/decrees = alist(
		/datum/antagonist/wizard = list(
			"You, in the ridiculous hat - put the wand away. I have seen better magic from a pack of cards, and I had those beheaded.",
			"You have bent reality your whole life, and now it will not bend. The Grand Ritual is closed to you, and even your simplest spell will bite back.",
		),
		/datum/antagonist/cult = list(
			"You wanted the veil torn, and now it is. How ungrateful of you to look so disappointed at who came through.",
			"The Geometer's voice thins to nothing in your head. She cannot be summoned while this thing holds the station, and her magic will tear at you if you call on it.",
		),
		/datum/antagonist/clock_cultist = list(
			"Stop that ticking at once. Your rusty old engine may keep his own time elsewhere - here it is always six o'clock, and he is not invited to tea.",
			"The ticking you have marched to all this time skips, then stalls. The Ark will not open while this thing holds the station.",
		),
		/datum/antagonist/heretic = list(
			"Go on, peek through one of your little cracks in the world. Whatever used to whisper back is gone. There is only me now.",
			"You reach for the Mansus out of habit, and nothing reaches back. There will be no ascension while this thing holds the station.",
		),
		/datum/antagonist/bloodsucker = list(
			"A Masquerade in my court, and I was not invited? Masks off, Kindred. Without my word of acceptance you are nothing.",
			"The blood in your veins shrinks from her voice like prey. Every power you call on will cost you dearly now.",
		),
		/datum/antagonist/changeling = list(
			"I know what you are under that borrowed face. Pick one and keep it - I will not have my executioner guessing which head is yours.",
			"She is looking straight at you, and no face you own will change that. Your flesh will fight you every time you ask it to shift.",
		),
		/datum/antagonist/darkspawn = list(
			"You come from the nothing between places. My garden has grown over it now. There is nowhere left for you to crawl back to.",
			"You listen for the Void and hear birdsong. The Sacrament cannot be performed while this thing holds the station.",
		),
		/datum/antagonist/nightmare = list(
			"A nightmare, in my dream? I think not. Leave my lamps alone - I intend to see every moment of your trial.",
			"For the first time since you crawled out of it, the dark does not feel like yours.",
		),
	)
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		var/mob/target = antag.owner?.current
		if(QDELETED(target))
			continue
		for(var/antag_type, lines in decrees)
			if(istype(antag, antag_type))
				to_chat(target, span_hearts_decree(lines[1]), type = MESSAGE_TYPE_WARNING)
				to_chat(target, span_warning(lines[2]), type = MESSAGE_TYPE_WARNING)
				break

/datum/wonderland_apocalypse/proc/open_rabbit_holes()
	if(wave_rabbits >= 20)
		return
	var/list/victims = list()
	for(var/mob/living/player as anything in GLOB.alive_player_list)
		var/turf/player_turf = get_turf(player)
		if(!player_turf || !is_station_level(player_turf.z) || (FACTION_RABBITS in player.faction))
			continue
		victims += player
	for(var/i in 1 to min(2, length(victims)))
		var/mob/living/victim = pick_n_take(victims)
		var/turf/hole_turf = pick_open_turf(view(4, victim) - range(1, victim))
		if(!hole_turf)
			continue
		new /obj/effect/temp_visual/wonderland_hole(hole_turf)
		for(var/j in 1 to 2)
			var/mob/living/basic/killer_rabbit/rabbit = new(hole_turf)
			wave_rabbits++
			RegisterSignal(rabbit, COMSIG_QDELETING, PROC_REF(wave_rabbit_gone))
			climb_out_of_rabbit_hole(rabbit)

/datum/wonderland_apocalypse/proc/wave_rabbit_gone(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	wave_rabbits--

/datum/wonderland_apocalypse/proc/pick_open_turf(list/turfs)
	var/list/open_turfs = list()
	for(var/turf/open/candidate in turfs)
		if(isgroundlessturf(candidate) || !istype(get_area(candidate), /area/station) || candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue
		open_turfs += candidate
	return pick(open_turfs)

/// There is no docking signal, so we poll
/datum/wonderland_apocalypse/proc/check_shuttle_docked()
	if(!EMERGENCY_AT_LEAST_DOCKED || EMERGENCY_ESCAPED_OR_ENDGAMED)
		return
	if(open_gate())
		deltimer(dock_timer)

/datum/wonderland_apocalypse/proc/open_gate()
	var/turf/gate_turf = pick_open_turf(RANGE_TURFS(12, SSshuttle.emergency)) || pick(pick_noise_station_turfs(1, 4))
	if(!gate_turf)
		return FALSE
	var/obj/structure/wonderland_rift/gate/gate = new(gate_turf)
	priority_announce(
		text = span_hearts_announcement("You are keeping me waiting, and I do not wait. Open the gate. Let the rest of my court in."),
		title = "Higher Dimensional Affairs",
		sound = 'sound/music/antag/monster_hunter.ogg',
		encode_text = FALSE,
		color_override = "purple"
	)
	notify_ghosts(
		"A gate to Wonderland has opened. Every ghost may come through, once.",
		source = gate,
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "Wonderland Gate Opened",
	)
	return TRUE

/datum/wonderland_apocalypse/proc/apply_pressure_to_new_mob(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if(!istype(target) || QDELING(target))
		return
	var/area/centcom/target_area = get_area(target)
	if(istype(target_area) && target_area.grace)
		return
	target.apply_status_effect(/datum/status_effect/wonderland_district)

/obj/effect/anomaly/dimensional/wonderland
	anomaly_core = null
	range = 5
	immortal = TRUE
	relocations_left = -1

/obj/effect/anomaly/dimensional/wonderland/Initialize(mapload, new_lifespan)
	INVOKE_ASYNC(src, PROC_REF(prepare_area), /datum/dimension_theme/wonderland)
	return ..()

/obj/effect/anomaly/dimensional/wonderland/relocate()
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)
	src.forceMove(new_turf)
	prepare_area(new_theme_path = /datum/dimension_theme/wonderland)

/obj/effect/anomaly/dimensional/wonderland/rift
	lifespan = 90 SECONDS
	immortal = FALSE

/obj/effect/anomaly/dimensional/wonderland/rift/relocate()
	return

/obj/effect/anomaly/dimensional/wonderland/rift/detonate()
	return

/obj/structure/wonderland_rift
	name = "\improper Wonderland rift"
	desc = "A tear in the world with a sunny meadow on the other side. Something very large is on its way through."
	icon = 'icons/mob/infils.dmi'
	icon_state = "cyborg_rift"
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	armor_type = /datum/armor/wonderland_rift
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Have we already spawned an enemy?
	var/enemy_spawned = FALSE

/datum/armor/wonderland_rift
	melee = 100
	energy = 100
	bomb = 100
	fire = 100
	acid = 100

/obj/structure/wonderland_rift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	summon_rabbit(user)
	if(enemy_spawned)
		qdel(src)


/obj/structure/wonderland_rift/proc/summon_rabbit(mob/user)
	var/spawn_check = tgui_alert(user, "Become a Jabberwocky?", "Wonderland Rift", list("Yes", "No"))
	if(spawn_check != "Yes" || QDELETED(src) || QDELETED(user) || enemy_spawned)
		return FALSE
	enemy_spawned = TRUE
	var/turf/rift_turf = get_turf(src)
	new /obj/effect/temp_visual/jabberwocky_hole(rift_turf)
	var/mob/living/basic/red_rabbit/evil_rabbit = new(rift_turf)
	evil_rabbit.alpha = 0
	animate(evil_rabbit, time = 1.1 SECONDS)
	animate(alpha = 255, time = 0.4 SECONDS)
	evil_rabbit.PossessByPlayer(user.key)
	to_chat(evil_rabbit, span_boldwarning("You are a jabberwocky. Destroy everything, spare no one."))
	to_chat(evil_rabbit, span_hearts_tantrum("Bring me every last head!"))
	return TRUE

/obj/structure/wonderland_rift/gate
	name = "\improper Wonderland gate"
	desc = "A tear wide enough for a whole court to walk through. They are walking through."
	/// Ckeys that have already come through, each ghost gets one turn.
	var/list/used_ckeys

/obj/structure/wonderland_rift/gate/Initialize(mapload)
	. = ..()
	transform *= 2

/obj/structure/wonderland_rift/gate/summon_rabbit(mob/user)
	var/user_ckey = user.ckey
	if(user_ckey in used_ckeys)
		to_chat(user, span_hearts_decree("You have had your turn. Wait in the corner like everyone else."))
		return FALSE
	. = ..()
	if(!.)
		return
	LAZYADD(used_ckeys, user_ckey)
	enemy_spawned = FALSE

/datum/status_effect/wonderland_district
	id = "wonderland_district"
	alert_type = /atom/movable/screen/alert/status_effect/wonderland_district
	tick_interval = STATUS_EFFECT_NO_TICK
	/// List of /datum/action instance that we've registered `COMSIG_ACTION_TRIGGER` on.
	var/list/datum/action/registered_actions
	/// Message given to the user when the status effect is given.
	var/apply_message = "You feel an ominous pressure fill the air around you..."
	/// The "cause" used for logging damage from recoil.
	var/effect_name = "Wonderland"
	/// Typecache of spells to NOT trigger the effect on.
	var/static/list/spell_whitelist_typecache
	/// Typecache of non-spell actions to trigger the effect on.
	var/static/list/register_action_typecache

/datum/status_effect/wonderland_district/New(list/arguments)
	. = ..()
	spell_whitelist_typecache ||= typecacheof(list(
		/datum/action/cooldown/spell/florida_regeneration,
		/datum/action/cooldown/spell/florida_cuff_break,
		/datum/action/cooldown/spell/florida_doorbuster,
	))
	register_action_typecache ||= zebra_typecacheof(list(
		/datum/action/innate/cult = TRUE,
		/datum/action/innate/cult/comm = FALSE,
		/datum/action/innate/clockcult/quick_bind = TRUE,
		/datum/action/cooldown/bloodsucker = TRUE,
		/datum/action/changeling = TRUE,
	))

/datum/status_effect/wonderland_district/on_apply()
	if(FACTION_RABBITS in owner?.faction)
		return FALSE
	if(apply_message)
		to_chat(owner, span_warning(apply_message))
		to_chat(owner, span_hearts_decree("Guilty, every one of you. Of what, I shall decide later."))
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))
	RegisterSignal(owner, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(after_spell_cast))
	RegisterSignal(owner, COMSIG_MOB_GRANTED_ACTION, PROC_REF(owner_granted_action))
	RegisterSignal(owner, COMSIG_MOB_REMOVED_ACTION, PROC_REF(owner_removed_action))
	for(var/datum/action/action as anything in owner.actions)
		owner_granted_action(owner, action)

	return TRUE

/datum/status_effect/wonderland_district/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_ENTER_AREA, COMSIG_MOB_AFTER_SPELL_CAST, COMSIG_MOB_GRANTED_ACTION, COMSIG_MOB_REMOVED_ACTION))
	for(var/datum/action/action as anything in registered_actions)
		UnregisterSignal(action, COMSIG_ACTION_TRIGGER)
	LAZYNULL(registered_actions)
	REMOVE_TRAITS_IN(owner, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/wonderland_district/proc/on_enter_area(datum/source, area/centcom/new_area)
	SIGNAL_HANDLER
	if(istype(new_area) && new_area.grace)
		qdel(src)

/datum/status_effect/wonderland_district/proc/owner_granted_action(datum/source, datum/action/action)
	SIGNAL_HANDLER
	if(!(action in registered_actions) && is_type_in_typecache(action, register_action_typecache))
		RegisterSignal(action, COMSIG_ACTION_TRIGGER, PROC_REF(on_action_triggered))
		LAZYADD(registered_actions, action)

/datum/status_effect/wonderland_district/proc/owner_removed_action(datum/source, datum/action/action)
	SIGNAL_HANDLER
	UnregisterSignal(action, COMSIG_ACTION_TRIGGER)
	LAZYREMOVE(registered_actions, action)

/datum/status_effect/wonderland_district/proc/after_spell_cast(datum/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER
	if(!istype(spell) || QDELING(spell) || !spell.antimagic_flags || is_type_in_typecache(spell, spell_whitelist_typecache)) // don't affect non-magic spells.
		return
	recoil(
		span_warning("[owner] doubles over in pain, violently coughing up blood!"),
		span_userdanger("An overwhelming pressure fills your body as you cast [spell.name || "magic"], filling you with excruciating pain down to the very core of your being!"),
		spell.name || spell.type
	)

/datum/status_effect/wonderland_district/proc/on_action_triggered(datum/source, datum/action/action)
	SIGNAL_HANDLER
	recoil(
		span_warning("[owner] doubles over in pain, violently coughing up blood!"),
		span_userdanger("An overwhelming pressure fills your body as you use [action.name || "your ability"], filling you with excruciating pain down to the very core of your being!"),
		action.name || action.type
	)

/datum/status_effect/wonderland_district/proc/recoil(vis_msg, self_msg, logged_cause)
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living, emote), "scream")
	if(vis_msg)
		owner.visible_message(vis_msg, self_msg)
		to_chat(owner, span_hearts_decree(pick(
			"Who said you could?",
			"Sit down.",
			"Not without my leave.",
		)))
	owner.take_overall_damage(brute = rand(5, 15))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.vomit(lost_nutrition = 0, blood = TRUE, stun = FALSE, distance = prob(20) + 1, message = FALSE, force = TRUE)
	owner.log_message("suffered recoil from using [logged_cause] due to the effects of [effect_name].", LOG_VICTIM)

// subtype used for the temporary effect of the bloodsilver bullet
/datum/status_effect/wonderland_district/bloodsilver
	id = "wonderland_district_bloodsilver"
	alert_type = null
	apply_message = null
	effect_name = "bloodsilver debuff"

/datum/status_effect/wonderland_district/bloodsilver/on_apply()
	if(owner.has_status_effect(/datum/status_effect/wonderland_district)) // avoid stacking with actual wonderland
		return FALSE
	return ..()

/datum/status_effect/wonderland_district/bloodsilver/on_enter_area(datum/source, area/centcom/new_area)
	return

/atom/movable/screen/alert/status_effect/wonderland_district
	name = "Wonderland Manifestation"
	desc = "The veil between fantasy and reality has been shattered!"
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "wonderland"

#ifdef TESTING
ADMIN_VERB(start_wonderland_apocalypse, R_DEBUG, FALSE, "Start Wonderland Apocalypse", "Starts the monster hunter finale right now.", ADMIN_CATEGORY_DEBUG)
	if(GLOB.wonderland_apocalypse)
		to_chat(user, span_warning("The Wonderland apocalypse has already started."), confidential = TRUE)
		return
	message_admins("[key_name_admin(user)] started the Wonderland apocalypse.")
	log_admin("[key_name(user)] started the Wonderland apocalypse.")
	new /datum/wonderland_apocalypse
#endif
