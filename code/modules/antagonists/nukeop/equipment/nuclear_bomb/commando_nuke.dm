#define NUKE_ANNOUNCE_INTERVAL 2 MINUTES

/obj/machinery/nuclearbomb/commando
	name = "old nuclear fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed. The '1' key seems very worn... <i>the password can't possibly be 11111?</i>"
	icon = 'icons/obj/machines/nuke.dmi'
	icon_state = "old_nuclearbomb_base"
	anchored = FALSE
	density = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	use_power = NO_POWER_USE
	can_buckle = TRUE
	buckle_lying = 0
	drag_slowdown = 1.5
	max_integrity = 250
	r_code = "11111"

	base_icon_state = "old_nuclearbomb"
	/// Decrypt areas where the nuke gets a shortened timer for decrypting in.
	var/list/decrypt_areas = list()
	/// Areas the nuke cannot be armed in.
	var/list/forbidden_areas
	/// What the timer will be once the code is set. Default 15 minutes.
	var/timer = 900

	// partical holder
	var/obj/effect/abstract/particle_holder/damage_particles = null

	/// Next world time we announce. Ripped straight from malf AI code since my last method was stupid :D
	var/next_announce
	/// Announcement time for the research grant.
	var/grant_announce
	/// If the research grant has been given.
	var/grant_given = FALSE

	special_icons = TRUE
	armor_type = /datum/armor/commando_nuke
	COOLDOWN_DECLARE(arm_cooldown)

/datum/armor/commando_nuke
	bullet = 60
	laser = 50
	energy = 50
	bomb = 100
	acid = 100
	fire = 100

/obj/machinery/nuclearbomb/commando/Initialize(mapload)
	. = ..()
	forbidden_areas = typecacheof(list(
		/area/station/hallway,
		/area/station/maintenance,
		/area/station/engineering/shipbreaker_hut,
		/area/station/engineering/atmos,
		/area/station/engineering/atmospherics_engine,
		/area/station/solars))
	pick_decrypt_areas()

/obj/machinery/nuclearbomb/commando/process(seconds_per_tick)
	. = ..()
	update_appearance()
	if(atom_integrity <= 100 && (prob(25)))
		do_sparks(rand(1,2), FALSE, src)
	else if(atom_integrity <= 200 && (prob(20)))
		do_sparks(1, FALSE, src)
	if(!timing)
		return
	if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_DELTA && get_time_left() < 120)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	if(world.time >= next_announce)
		var/area/our_area = get_area(src)
		minor_announce("[get_time_left()] SECONDS UNTIL DECRYPTION COMPLETION. LOCATION: [our_area.get_original_area_name()].", "Nuclear Operations Command", sound_override = 'sound/misc/notice1.ogg', should_play_sound = TRUE, color_override = "red")
		next_announce += NUKE_ANNOUNCE_INTERVAL
	if(world.time >= grant_announce && !grant_given)
		priority_announce(
				text = "10,000 research points have been refunded.",
				title = "Emergency Research Grant",
				sender_override = "Nanotasen Science Directorate",
				sound = 'sound/misc/notice2.ogg',
				has_important_message = TRUE,
				color_override = "pink",
			)
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = 10000))
		grant_given = TRUE

/obj/machinery/nuclearbomb/commando/proc/update_damage()
	if(atom_integrity <= 100)
		if(!damage_particles)
			damage_particles = new(src, /particles/smoke/nuke)
	else
		QDEL_NULL(damage_particles)

/obj/machinery/nuclearbomb/commando/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(damage_particles)
		QDEL_NULL(damage_particles)
	SSshuttle.clearHostileEnvironment(src)
	return ..()

/obj/machinery/nuclearbomb/commando/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/wrench/combat) && !(user.istate & ISTATE_HARM))
		if(!weapon.tool_behaviour)
			return ..()
		if(!weapon.toolspeed)
			return
		if(atom_integrity == max_integrity)
			balloon_alert(user, "already repaired!")
			return

		balloon_alert(user, "repairing...")
		while(atom_integrity != max_integrity)
			if(!weapon.use_tool(src, user, 2 SECONDS, volume = 20, extra_checks = CALLBACK(weapon, TYPE_PROC_REF(/obj/item/wrench/combat, is_active))))
				return
			repair_damage(25)
			update_damage()

		balloon_alert(user, "repaired!")
	else
		return ..()


/obj/machinery/nuclearbomb/commando/disk_check(obj/item/disk/nuclear/inserted_disk)
	if(istype(inserted_disk, /obj/item/disk/nuclear/nukie))
		auth = inserted_disk
		calculate_timer()
		return TRUE

	if(inserted_disk.fake)
		say("Authentication failure; disk not recognised.")
		return FALSE

	auth = inserted_disk
	calculate_timer()
	return TRUE

/obj/machinery/nuclearbomb/commando/proc/pick_decrypt_areas()
	decrypt_areas = list()
	var/list/possible_areas = list()
	for(var/area/possible_area as anything in GLOB.the_station_areas)
		if(is_type_in_typecache(possible_area, forbidden_areas) || initial(possible_area.outdoors) || !GLOB.areas_by_type[possible_area])
			continue
		possible_areas |= GLOB.areas_by_type[possible_area]

	for(var/i in 1 to 3)
		decrypt_areas += pick_n_take(possible_areas)

/obj/machinery/nuclearbomb/commando/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	if(user.mind.has_antag_datum(/datum/antagonist/nukeop))
		var/list/area_list = list()
		for(var/area/added_area in decrypt_areas)
			area_list += added_area.get_original_area_name()
		. += span_syndradio("The designated decryption areas are: [english_list(area_list)].<br>")

/obj/machinery/nuclearbomb/commando/atom_destruction(damage_flag)
	new /obj/effect/gibspawner/nuke(drop_location())
	new /obj/effect/decal/cleanable/oil/streak(drop_location())
	new /obj/effect/decal/cleanable/nuke_debris/main(drop_location())
	do_sparks(5, FALSE, src)
	if(core)
		core.forceMove(get_turf(src))
		START_PROCESSING(SSobj, core)
		core = null
	if(timing || exploding)
		priority_announce(
				text = "The nuclear device has been deactivated. For the safety of our staff, we are expediting an emergency shuttle for the remaining members of the crew.",
				sound = 'sound/misc/notice2.ogg',
				has_important_message = TRUE,
				color_override = "blue",
		)
		if(SSsecurity_level.get_current_level_as_number() == SEC_LEVEL_DELTA)
			SSsecurity_level.set_level(SEC_LEVEL_RED)
		SSshuttle.admin_emergency_no_recall = TRUE
		if(!EMERGENCY_AT_LEAST_DOCKED)
			SSshuttle.emergency.request()
	return ..()

/obj/machinery/nuclearbomb/commando/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(damage_amount >= 10)
		do_sparks(rand(1,3), FALSE, src)
	update_damage()

/obj/machinery/nuclearbomb/commando/update_icon_state()
	. = ..()
	icon_state = get_icon_state_from_mode()


/obj/machinery/nuclearbomb/commando/proc/get_icon_state_from_mode()
	if(exploding)
		return "[base_icon_state]_exploding"
	if(timing)
		return "[base_icon_state]_timing"
	if(!safety && yes_code)
		return "[base_icon_state]_await_arm"
	if(!yes_code && auth)
		return "[base_icon_state]_unlocked"
	if(yes_code)
		return "[base_icon_state]_code_entered"
	return "[base_icon_state]_base"


/obj/machinery/nuclearbomb/commando/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_light", src, alpha = src.alpha)

/obj/machinery/nuclearbomb/commando/ui_process(action, params)
	playsound(src, SFX_TERMINAL_TYPE, 20, FALSE)
	switch(action)
		if("eject_disk")
			if(auth && auth.loc == src)
				playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
				playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
				auth.forceMove(get_turf(src))
				auth = null
				. = TRUE
			else
				var/obj/item/I = usr.is_holding_item_of_type(/obj/item/disk/nuclear)
				if(I && disk_check(I) && usr.transferItemToLoc(I, src))
					playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
					playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
					auth = I
					calculate_timer()
					. = TRUE
			update_ui_mode()
		if("keypad")
			if(auth)
				var/digit = params["digit"]
				switch(digit)
					if("C")
						if(auth && ui_mode == NUKEUI_AWAIT_ARM)
							toggle_nuke_safety()
							yes_code = FALSE
							if(anchored)
								set_anchor()
							playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
							update_ui_mode()
						else
							playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
						numeric_input = ""
						. = TRUE
					if("E")
						switch(ui_mode)
							if(NUKEUI_AWAIT_CODE)
								if(numeric_input == r_code)
									process_code(usr)
									playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
									. = TRUE
								else
									playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
									numeric_input = "ERROR"
							if(NUKEUI_AWAIT_TIMER)
								calculate_timer()
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
								toggle_nuke_safety()
								. = TRUE
							else
								playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
						update_ui_mode()
					if("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
						if(numeric_input != "ERROR" && ui_mode != NUKEUI_AWAIT_TIMER || NUKEUI_AWAIT_ARM)
							numeric_input += digit
							if(length(numeric_input) > 5)
								numeric_input = "ERROR"
							else
								playsound(src, 'sound/machines/nuke/general_beep.ogg', 50, FALSE)
							. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		if("arm")
			if(auth && yes_code && !safety && !exploded && COOLDOWN_FINISHED(src, arm_cooldown))
				playsound(src, 'sound/machines/nuke/confirm_beep.ogg', 50, FALSE)
				COOLDOWN_START(src, arm_cooldown, 30 SECONDS)
				toggle_nuke_armed()
				update_ui_mode()
				. = TRUE
			else
				playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)

/obj/machinery/nuclearbomb/commando/proc/process_code(mob/user)
	var/area/our_area = get_area(src)
	if(isinspace() || istype(our_area, /area/shuttle))
		to_chat(user, span_warning("Location too unstable!"))
		return
	if(is_type_in_typecache(our_area, forbidden_areas))
		to_chat(user, span_warning("Connection could not be established, find an area with better connection! Large open spaces and radiation shielded areas such as maintenance are more likely to have a bad connection."))
		return
	yes_code = TRUE
	numeric_input = ""
	set_anchor(user)

/obj/machinery/nuclearbomb/commando/proc/calculate_timer()
	if(timing)
		return
	timer = 900
	var/area/arm_location = get_area(src)
	if(arm_location in decrypt_areas)
		timer -= 480 //8 minutes
	if(istype(auth, /obj/item/disk/nuclear) && !auth.fake)
		timer -= 300

	timer_set = timer

/obj/machinery/nuclearbomb/commando/set_anchor(mob/anchorer)
	set_anchored(!anchored)
	if(anchored)
		playsound(src, 'sound/machines/boltsdown.ogg', 45)
	else
		playsound(src, 'sound/machines/boltsup.ogg', 45)

/obj/machinery/nuclearbomb/commando/ui_data(mob/user)
	var/list/data = list()
	data["disk_present"] = auth

	var/hidden_code = (ui_mode == NUKEUI_AWAIT_CODE && numeric_input != "ERROR")

	var/current_code = ""
	if(hidden_code)
		while(length(current_code) < length(numeric_input))
			current_code = "[current_code]*"
	else
		current_code = numeric_input
	while(length(current_code) < 5)
		current_code = "[current_code]-"

	var/first_status
	var/second_status
	switch(ui_mode)
		if(NUKEUI_AWAIT_DISK)
			first_status = "DEVICE LOCKED"
			if(timing)
				second_status = "TIME: [get_time_left()]"
			else
				second_status = "AWAIT DISK"
		if(NUKEUI_AWAIT_CODE)
			first_status = "INPUT CODE"
			second_status = "CODE: [current_code]"
		if(NUKEUI_AWAIT_TIMER)
			first_status = "DECRYPT TIME"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_AWAIT_ARM)
			first_status = "DEVICE READY"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_TIMING)
			first_status = "DEVICE ARMED"
			second_status = "TIME: [get_time_left()]"
		if(NUKEUI_EXPLODED)
			first_status = "DEVICE DEPLOYED"
			second_status = "THANK YOU"

	data["status1"] = first_status
	data["status2"] = second_status
	data["anchored"] = anchored

	return data

/obj/machinery/nuclearbomb/commando/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NuclearBombCommando", name)
		ui.open()

/obj/machinery/nuclearbomb/commando/arm_nuke(mob/armer)
	var/turf/our_turf = get_turf(src)
	START_PROCESSING(SSobj, src)
	message_admins("\The [src] was armed at [ADMIN_VERBOSEJMP(our_turf)] by [armer ? ADMIN_LOOKUPFLW(armer) : "an unknown user"].")
	armer.log_message("armed \the [src].", LOG_GAME)
	armer.add_mob_memory(/datum/memory/bomb_planted/nuke, antagonist = src)

	previous_level = SSsecurity_level.get_current_level_as_number()
	detonation_timer = world.time + (timer_set * 10)
	for(var/obj/item/pinpointer/nuke/nuke_pointer in GLOB.pinpointer_list)
		nuke_pointer.switch_mode_to(TRACK_COMMANDO_NUKE)

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NUKE_DEVICE_ARMED, src)

	countdown.start()

	if(is_station_level(our_turf.z))
		var/area/our_area = get_area(src)
		SSsecurity_level.set_level(SEC_LEVEL_RED)
		SSshuttle.registerHostileEnvironment(src)
		priority_announce(
			text = "An unauthorized nuclear device is currently being decrypted for detonation in the [our_area.get_original_area_name()]. Crew are advised to halt the decryption through immediate rapid deconstruction of the device.",
			title = "Priority Alert",
			sound = 'sound/misc/notice2.ogg',
			has_important_message = TRUE,
			color_override = "red",
		)
		next_announce = world.time + NUKE_ANNOUNCE_INTERVAL
		grant_announce = world.time + 30 SECONDS
	notify_ghosts(
		"A nuclear device has been armed in [get_area_name(src)]!",
		source = src,
		header = "Nuke Armed",
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_DEFAULT,
	)
	update_appearance()

/obj/machinery/nuclearbomb/commando/disarm_nuke(mob/disarmer, change_level_back = FALSE)
	. = ..()
	SSshuttle.clearHostileEnvironment(src)
	if(SSsecurity_level.get_current_level_as_number() <= SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(previous_level)

#undef NUKE_ANNOUNCE_INTERVAL

/obj/item/nuke_recaller
	name = "nuke relocator"
	desc = "A one time use designator for calling a Syndicate relocation pod to relocate the nuke to your current location."
	desc_controls = "Alt-Click the device to toggle the safety."
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	icon = 'icons/obj/device.dmi'
	icon_state = "relocator_1"
	inhand_icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	w_class = WEIGHT_CLASS_SMALL
	var/used = FALSE
	var/safety = TRUE
	var/obj/structure/closet/supplypod/nuke_relocation/tracked_pod

/obj/item/nuke_recaller/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/nuke_recaller/click_alt(mob/living/user)
	toggle_safety(user)
	return CLICK_ACTION_SUCCESS

/obj/item/nuke_recaller/proc/toggle_safety(mob/living/user)
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	safety = !safety
	update_appearance(UPDATE_OVERLAYS)
	balloon_alert(user, "safety [safety ? "on" : "off"]!")

/obj/item/nuke_recaller/update_overlays()
	. = ..()
	. +=  mutable_appearance(icon, "safety_[safety]")

/obj/item/nuke_recaller/proc/check_usability(mob/user)
	if(safety)
		balloon_alert(user, "safety on!")
		return FALSE
	if(used)
		balloon_alert(user, "out of charge!")
		return FALSE
	return TRUE

/obj/item/nuke_recaller/attack_self(mob/user)
	if(!(check_usability(user)))
		return
	var/obj/machinery/nuclearbomb/commando/nuke = locate() in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/nuclearbomb/commando)
	if(nuke)
		var/obj/structure/closet/supplypod/nuke_relocation/new_pod = new()
		new /obj/effect/pod_landingzone(get_turf(nuke), new_pod)
		tracked_pod = new_pod
		new_pod.return_to_turf = get_turf(src)
		playsound(src, 'sound/machines/chime.ogg', 30, TRUE)
		used = TRUE
		say("Landing zone designated! ETA: 10 SECONDS")
		icon_state = "relocator_0"
		update_appearance()
		START_PROCESSING(SSobj, src)
	else
		balloon_alert(user, "unable to locate!")

/obj/item/nuke_recaller/process(seconds_per_tick)
	var/obj/machinery/nuclearbomb/commando/found_nuke = locate() in get_turf(tracked_pod)
	if(!tracked_pod.opened)
		return
	if(!found_nuke)
		return
	if(found_nuke.anchored)
		return
	tracked_pod.startExitSequence(tracked_pod)
	STOP_PROCESSING(SSobj, src)
	say("Pod in transit to LZ!")

/obj/item/nuke_recaller/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
