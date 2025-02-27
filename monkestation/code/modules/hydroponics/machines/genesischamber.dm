/obj/machinery/genesis_chamber
	name = "G.E.N.E.S.I.S Chamber"
	desc = "A piece of advanced technology that once turned on, will begin to produce strange seeds. The internal vortex core creates an anomalous environment for seed mutation."
	icon = 'monkestation/icons/obj/machines/genesis_chamber.dmi'
	icon_state = "genesis_chamber_off"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/genesis_chamber

	var/on = FALSE
	/// The current capacity of seeds inside of the chamber
	var/capacity = 0
	/// The maximum capacity the chamber can hold at T1
	var/max_capacity = 10
	/// Seconds it takes to create each seed at T1
	var/max_cooldown = 5 MINUTES
	/// Has a vortex core been inserted
	var/has_core = FALSE
	/// Number of seeds produced per cycle
	var/seeds_per_cycle = 1
	/// Time remaining until next seed is generated
	var/time_remaining = 0

/obj/machinery/genesis_chamber/Initialize(mapload)
	. = ..()
	if(mapload)
		update_appearance()

/obj/machinery/genesis_chamber/RefreshParts()
	. = ..()
	max_capacity = initial(max_capacity)
	for(var/datum/stock_part/matter_bin/bin in component_parts)
		max_capacity += max((bin.tier * 5) - 5, 0)

	max_cooldown = initial(max_cooldown)
	for(var/datum/stock_part/micro_laser/laser in component_parts)
		max_cooldown -= max((laser.tier - 1) * (1 MINUTES), 0 MINUTES)

	seeds_per_cycle = initial(seeds_per_cycle)
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		seeds_per_cycle += manipulator.tier - 1

	// Reset the cooldown if the machine is active
	if(on && has_core)
		if(TIMER_COOLDOWN_CHECK(src, "seed_generation"))
			S_TIMER_COOLDOWN_RESET(src, "seed_generation")
		S_TIMER_COOLDOWN_START(src, "seed_generation", max_cooldown)

/obj/machinery/genesis_chamber/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/machinery/genesis_chamber/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	if(obj_flags & EMAGGED)
		return

	if(panel_open)
		to_chat(user, span_warning("You can't use the [src] while the maintenance panel is open!"))
		return

	if(!has_core)
		to_chat(user, span_warning("The [src] needs a vortex anomaly core to function!"))
		return

	if(capacity < 1)
		calculate_time_remaining()
		to_chat(user, span_warning("You need to wait [DisplayTimeText(time_remaining)] until [seeds_per_cycle] seed[seeds_per_cycle == 1 ? " is" : "s are"] produced."))
		return

	if(QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH | ALLOW_RESTING))
		return

	for (var/i in 1 to capacity)
		if(capacity <= 0)
			break
		new /obj/item/seeds/random(drop_location())

	to_chat(user, span_notice("You collect [capacity] strange seeds from the chamber."))
	capacity = 0
	update_appearance()

/obj/machinery/genesis_chamber/proc/calculate_time_remaining()
	if(!on || !has_core || !TIMER_COOLDOWN_CHECK(src, "seed_generation"))
		time_remaining = max_cooldown
		return

	time_remaining = S_TIMER_COOLDOWN_TIMELEFT(src, "seed_generation")

/obj/machinery/genesis_chamber/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/signaler/anomaly/vortex))
		if(has_core)
			to_chat(user, span_warning("The [src] already has a vortex anomaly core!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		has_core = TRUE
		to_chat(user, span_notice("You insert the vortex anomaly core into [src]."))
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		return
	return ..()

/obj/machinery/genesis_chamber/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(obj_flags & EMAGGED)
		return

	if(panel_open)
		return

	if(!has_core)
		to_chat(user, span_warning("The [src] needs a vortex anomaly core to function!"))
		return

	on = !on

	if(on)
		to_chat(user, span_notice("You turn on [src]."))
		playsound(loc, 'sound/machines/chime.ogg', 40, TRUE)
		say("Activating... Seeds will be produced in [DisplayTimeText(max_cooldown)].")
		S_TIMER_COOLDOWN_START(src, "seed_generation", max_cooldown)
		START_PROCESSING(SSprocessing, src)
	else
		to_chat(user, span_notice("You turn off [src]."))
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		say("Deactivating...")
		STOP_PROCESSING(SSprocessing, src)
		if(TIMER_COOLDOWN_CHECK(src, "seed_generation"))
			TIMER_COOLDOWN_END(src, "seed_generation")
		time_remaining = max_cooldown

	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/genesis_chamber/process()
	if(!on || !has_core)
		return PROCESS_KILL

	if(capacity >= max_capacity)
		on = FALSE
		say("Maximum capacity reached. Shutting down.")
		playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
		update_appearance()
		return PROCESS_KILL

	if(!TIMER_COOLDOWN_CHECK(src, "seed_generation"))
		generate_seed()
		S_TIMER_COOLDOWN_START(src, "seed_generation", max_cooldown)

	return TRUE

/obj/machinery/genesis_chamber/proc/generate_seed()
	if(!on || !has_core || capacity >= max_capacity)
		return

	// Calculate how many seeds to produce this cycle
	var/seeds_to_produce = min(seeds_per_cycle, max_capacity - capacity)

	if(seeds_to_produce <= 0)
		return

	capacity += seeds_to_produce

	if(seeds_to_produce == 1)
		say("Seed generated. Current capacity: [capacity]/[max_capacity]")
	else
		say("[seeds_to_produce] seeds generated. Current capacity: [capacity]/[max_capacity]")

	playsound(src, 'sound/machines/synth_yes.ogg', 30, TRUE)
	update_appearance()

/obj/machinery/genesis_chamber/examine(mob/user)
	. = ..()
	if(!has_core)
		. += "It is missing a <b>vortex anomaly core</b>."
	else if(!on)
		. += "It is currently <b>Deactivated</b> and has <b>[capacity]</b> strange seeds stored."
	else
		. += "It is currently <b>Activated</b> and has <b>[capacity]</b> strange seeds stored."
		calculate_time_remaining()
		. += "It'll take <b>[DisplayTimeText(time_remaining)]</b> until more seeds are created."
	. += "It can currently hold <b>[max_capacity] seed\s</b> and produces <b>[seeds_per_cycle] seed\s</b> every <b>[DisplayTimeText(max_cooldown)]</b>."

/obj/machinery/genesis_chamber/update_icon_state()
	. = ..()
	if (capacity >= 1)
		icon_state = "genesis_chamber_seed_[on ? "on" : "off"]"
		return
	icon_state = "genesis_chamber_[on ? "on" : "off"]"

	return

/obj/machinery/genesis_chamber/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return

	// Check if emagged first - if so, immediately explode when screwdriver is used
	if(obj_flags & EMAGGED)
		to_chat(user, span_danger("The [src] makes a concerning noise as you open the maintenance panel!"))
		say("CRITICAL ERROR: Containment breach detected!")
		overload_explosion()
		return TRUE

	// Check if machine is on - prevent opening if it is
	if(on)
		to_chat(user, span_warning("You can't open the maintenance panel while the [src] is running!"))
		return TRUE

	// Dump seeds when opening the panel
	if(!panel_open && capacity > 0)
		dump_seeds(capacity)

	return default_deconstruction_screwdriver(user, "genesis_chamber_open", "genesis_chamber_off", tool)

/obj/machinery/genesis_chamber/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		// Drop the vortex core if present when deconstructed
		if(has_core)
			new /obj/item/assembly/signaler/anomaly/vortex(drop_location())
		return TRUE
	return FALSE

/obj/machinery/genesis_chamber/proc/start_shaking(intensity = 1)
	var/static/list/transforms
	if(!transforms)
		var/matrix/M1 = matrix()
		var/matrix/M2 = matrix()
		var/matrix/M3 = matrix()
		var/matrix/M4 = matrix()
		M1.Translate(-1 * intensity, 0)
		M2.Translate(0, 1 * intensity)
		M3.Translate(1 * intensity, 0)
		M4.Translate(0, -1 * intensity)
		transforms = list(M1, M2, M3, M4)

	animate(src, transform=transforms[1], time=0.4, loop=-1)
	animate(transform=transforms[2], time=0.2)
	animate(transform=transforms[3], time=0.4)
	animate(transform=transforms[4], time=0.6)

/obj/machinery/genesis_chamber/proc/stop_shaking()
	update_appearance()
	animate(src, transform = matrix())

/obj/machinery/genesis_chamber/proc/dump_seeds(amount = capacity)
	var/turf/drop_loc = get_turf(src)
	for(var/i in 1 to min(amount, capacity))
		if(capacity <= 0)
			break
		var/obj/item/seeds/random/seed = new(drop_loc)
		capacity--
		step(seed, pick(GLOB.alldirs))
	update_appearance()

/obj/machinery/genesis_chamber/proc/overload_explosion()
	visible_message(span_danger("The [src] violently explodes!"))
	explosion(src, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 5, flame_range = 7, flash_range = 4)
	qdel(src)

/obj/machinery/genesis_chamber/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE

	if (panel_open == TRUE)
		to_chat(user, span_warning("You can't emag the [src] while the maintenance panel is open!"))
		return FALSE

	obj_flags |= EMAGGED
	balloon_alert(user, "system overridden")

	// Double capacity
	max_capacity = ceil(max_capacity * 1.5)
	capacity = max_capacity

	dump_seeds(capacity)

	// Start aggressive shaking
	start_shaking(3)

	playsound(src, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
	say("CRITICAL ERROR: Safeties disabled! Maximum production in effect. Containment failure imminent!")

	addtimer(CALLBACK(src, PROC_REF(overload_explosion)), 6 SECONDS)

	return TRUE
