/obj/machinery/big_manipulator
	name = "big manipulator"
	desc = "Operates different objects. Truly, a groundbreaking innovation..."
	icon = 'icons/obj/machines/big_manipulator_parts/big_manipulator_core.dmi'
	icon_state = "core"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/big_manipulator
	greyscale_colors = "#d8ce13"
	greyscale_config = /datum/greyscale_config/big_manipulator

	/// Is the manipulator turned on?
	var/on = FALSE
	/// Was the next cycle already scheduled?
	var/next_cycle_scheduled = FALSE

	/// How quickly the manipulator will process it's actions.
	var/speed_multiplier = 1
	var/min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_1
	var/max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_1

	/// The object inside the manipulator.
	var/datum/weakref/held_object = null
	/// The chimp worker that uses the manipulator (handles USE cases).
	var/datum/weakref/monkey_worker = null
	/// Weakref to the ID that locked this manipulator.
	var/datum/weakref/id_lock = null
	/// Inserted manipulator task disk.
	var/obj/item/disk/manipulator/task_disk = null
	/// The manipulator's arm.
	var/obj/effect/big_manipulator_arm/manipulator_arm = null
	/// Is the power access wire cut? Disables the power button if `TRUE`.
	var/power_access_wire_cut = FALSE

	/// How many tasks total we can have.
	var/interaction_point_limit = MAX_TASKS_TIER_1

	/// A list of tasks for the manipulator.
	var/list/tasks = list()
	/// The task we're currently working on.
	var/datum/manipulator_task/current_task

	/// Is the manipulator in the process of stopping?
	var/stopping = FALSE
	/// Is the manipulator waiting for a turf signal to retry?
	var/waiting_for_signal = FALSE
	/// Turfs we registered enter/exit signals on while waiting.
	var/list/signal_turfs = list()

	/// Which tasking scenario we use for iterating tasks.
	var/tasking_strategy = TASKING_SEQUENTIAL
	/// Tasking strategy instance.
	var/datum/tasking_strategy/master_tasking

/// Attempts to find a suitable turf near the manipulator for creating a cargo task.
/obj/machinery/big_manipulator/proc/find_suitable_turf()
	var/turf/base = get_turf(src)
	for(var/turf/checked_turf in orange(base, 1))
		if(!isclosedturf(checked_turf))
			return checked_turf
	return null

/// Attempts to create a new task and assign it to the list.
/obj/machinery/big_manipulator/proc/create_new_task(mob/user, task_type, turf/new_turf)
	if(length(tasks) >= interaction_point_limit)
		balloon_alert(user, "task limit reached!")
		return FALSE

	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	var/manipulator_tier = locate_servo ? locate_servo.tier : 1

	var/datum/manipulator_task/new_task
	var/needs_turf = task_type in list(TASK_TYPE_PICKUP, TASK_TYPE_DROP, TASK_TYPE_THROW, TASK_TYPE_USE, TASK_TYPE_INTERACT)

	if(needs_turf)
		if(!new_turf)
			new_turf = find_suitable_turf()
		if(!new_turf)
			return FALSE

	switch(task_type)
		if(TASK_TYPE_PICKUP)
			new_task = new /datum/manipulator_task/cargo/pickup(new_turf, manipulator_tier)
		if(TASK_TYPE_DROP)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/drop(new_turf, manipulator_tier)
		if(TASK_TYPE_THROW)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/throw(new_turf, manipulator_tier)
		if(TASK_TYPE_USE)
			new_task = new /datum/manipulator_task/cargo/dropoff_base/use(new_turf, manipulator_tier)
		if(TASK_TYPE_INTERACT)
			new_task = new /datum/manipulator_task/cargo/interact(new_turf, manipulator_tier)
		if(TASK_TYPE_WAIT)
			new_task = new /datum/manipulator_task/simple/wait()

	if(QDELETED(new_task))
		return FALSE

	tasks += new_task

	if(istype(new_task, /datum/manipulator_task/cargo))
		var/datum/manipulator_task/cargo/cargo_task = new_task
		cargo_task.offset_dx = new_turf.x - x
		cargo_task.offset_dy = new_turf.y - y

	if((obj_flags & EMAGGED) && istype(new_task, /datum/manipulator_task/cargo))
		var/datum/manipulator_task/cargo/cargo_task = new_task
		cargo_task.type_filters += /mob/living

	return new_task

/obj/machinery/big_manipulator/Initialize(mapload)
	. = ..()
	create_manipulator_arm()
	process_upgrades()
	if(on)
		toggle_power_state(null)
	set_wires(new /datum/wires/big_manipulator(src))
	register_context()

	update_strategies()

/// Checks the component tiers, adjusting the properties of the manipulator.
/obj/machinery/big_manipulator/proc/process_upgrades()
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	if(!locate_servo)
		return

	var/manipulator_tier = locate_servo.tier
	switch(manipulator_tier)
		if(-INFINITY to 1)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_1
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_1
			interaction_point_limit = MAX_TASKS_TIER_1
			set_greyscale(COLOR_YELLOW)
			manipulator_arm?.set_greyscale(COLOR_YELLOW)
		if(2)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_2
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_2
			interaction_point_limit = MAX_TASKS_TIER_2
			set_greyscale(COLOR_ORANGE)
			manipulator_arm?.set_greyscale(COLOR_ORANGE)
		if(3)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_3
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_3
			interaction_point_limit = MAX_TASKS_TIER_3
			set_greyscale(COLOR_RED)
			manipulator_arm?.set_greyscale(COLOR_RED)
		if(4 to INFINITY)
			min_speed_multiplier = MIN_SPEED_MULTIPLIER_TIER_4
			max_speed_multiplier = MAX_SPEED_MULTIPLIER_TIER_4
			interaction_point_limit = MAX_TASKS_TIER_4
			set_greyscale(COLOR_PURPLE)
			manipulator_arm?.set_greyscale(COLOR_PURPLE)

	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * BASE_POWER_USAGE * manipulator_tier

	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		cargo_task.interaction_priorities = cargo_task.fill_priority_list(manipulator_tier)

/obj/machinery/big_manipulator/examine(mob/user)
	. = ..()
	var/mob/monkey_resolve = monkey_worker?.resolve()
	if(!isnull(monkey_resolve))
		. += "You can see a poor [monkey_resolve.name] buckled to [src]. You wonder if it's getting paid enough."

/obj/machinery/big_manipulator/attack_hand_secondary(mob/living/user, list/modifiers)
	try_press_on(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/big_manipulator/click_alt(mob/user)
	eject_task_disk(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/big_manipulator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	context[SCREENTIP_CONTEXT_RMB] = "Toggle"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Eject disk"

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Interact with wires" : "Open UI"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Una" : "A"]nchor"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	if(is_wire_tool(held_item) && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Interact with wires"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/big_manipulator/Destroy(force)
	if(task_disk)
		task_disk.forceMove(drop_location())
		task_disk = null
	unregister_task_turf_signals()
	QDEL_NULL(manipulator_arm)
	QDEL_LIST(tasks)
	id_lock = null
	return ..()

/obj/machinery/big_manipulator/Exited(atom/movable/gone, direction)
	. = ..()
	if(isnull(monkey_worker))
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker.resolve()
	if(gone != poor_monkey)
		return

	vis_contents -= poor_monkey
	poor_monkey.transform = matrix()
	monkey_worker = null


/// Removes an invalid task from the list.
/obj/machinery/big_manipulator/proc/remove_invalid_task(datum/manipulator_task/task)
	if(!task)
		return
	tasks -= task
	qdel(task)

/obj/machinery/big_manipulator/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE

	balloon_alert(user, "overloaded")
	obj_flags |= EMAGGED

	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		cargo_task.type_filters += /mob/living

	return TRUE

/obj/machinery/big_manipulator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 1 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/can_be_unfasten_wrench(mob/user, silent)
	if(on || stopping)
		to_chat(user, span_warning("[src] is activated!"))
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/big_manipulator/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			reset_task_turfs()
			validate_all_tasks()

/obj/machinery/big_manipulator/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "core", "core", tool)

/obj/machinery/big_manipulator/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/big_manipulator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.istate & ISTATE_HARM)
		return NONE

	if(istype(tool, /obj/item/disk/manipulator))
		if(on || stopping)
			balloon_alert(user, "turn it off first!")
			return ITEM_INTERACT_BLOCKING
		if(task_disk)
			task_disk.forceMove(drop_location())
			task_disk = null
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		task_disk = tool
		balloon_alert(user, "disk inserted")
		SStgui.update_uis(src)
		return ITEM_INTERACT_SUCCESS

	if(!panel_open || !is_wire_tool(tool))
		return NONE
	wires.interact(user)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/big_manipulator/RefreshParts()
	. = ..()
	process_upgrades()

/obj/machinery/big_manipulator/mouse_drop_dragged(atom/drop_point, mob/user, src_location, over_location, params)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker?.resolve()
	if(!poor_monkey)
		return

	balloon_alert(user, "trying to unbuckle...")
	if(!do_after(user, 3 SECONDS, src))
		balloon_alert(user, "interrupted")
		return

	balloon_alert(user, "unbuckled")
	poor_monkey.drop_all_held_items()
	poor_monkey.forceMove(drop_location())

/obj/machinery/big_manipulator/mouse_drop_receive(atom/monkey, mob/user, params)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return

	if(monkey_worker?.resolve())
		return

	if(!ismonkey(monkey))
		return

	var/mob/living/carbon/human/species/monkey/poor_monkey = monkey
	if(poor_monkey.mind)
		balloon_alert(user, "too smart!")
		return

	poor_monkey.balloon_alert(user, "trying to buckle...")
	if(!do_after(user, 3 SECONDS, poor_monkey))
		poor_monkey.balloon_alert(user, "interrupted")
		return

	balloon_alert(user, "buckled")
	monkey_worker = WEAKREF(poor_monkey)
	poor_monkey.drop_all_held_items()
	poor_monkey.forceMove(src)
	vis_contents += poor_monkey
	poor_monkey.dir = manipulator_arm.dir
	poor_monkey.transform = manipulator_arm.transform

/obj/machinery/big_manipulator/attackby(obj/item/some_item, mob/user, params)
	. = ..()
	if(!isidcard(some_item))
		return

	var/obj/item/card/id/clicked_by_this_id = some_item

	if(!id_lock)
		id_lock = WEAKREF(clicked_by_this_id)
		balloon_alert(user, "successfully locked")
		return
	var/obj/item/card/id/resolve_id = id_lock.resolve()
	if(clicked_by_this_id != resolve_id)
		balloon_alert(user, "locked by another id")
		return
	id_lock = null
	balloon_alert(user, "successfully unlocked")

/// Attaching the arm effect to the core.
/obj/machinery/big_manipulator/proc/create_manipulator_arm()
	manipulator_arm = new /obj/effect/big_manipulator_arm(src)
	manipulator_arm.dir = NORTH
	manipulator_arm.target_dir = NORTH
	vis_contents += manipulator_arm

/obj/machinery/big_manipulator/proc/toggle_power_state(mob/user)
	var/newly_on = !on

	if(!user)
		on = newly_on
		return

	if(newly_on)
		if(!powered())
			balloon_alert(user, "no power!")
			return

		if(!anchored)
			balloon_alert(user, "anchor first!")
			return

		validate_all_tasks()

		on = newly_on
		SStgui.update_uis(src)
		try_kickstart(user)

	else
		drop_held_atom()
		on = newly_on
		next_cycle_scheduled = FALSE
		if(current_task != null && !stopping)
			stopping = TRUE
			addtimer(CALLBACK(src, PROC_REF(complete_stopping_task)), 1 SECONDS)
		else
			stopping = FALSE
			unregister_task_turf_signals()
			waiting_for_signal = FALSE
		SStgui.update_uis(src)

/obj/machinery/big_manipulator/proc/reset_task_turfs()
	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		cargo_task.interaction_turf = locate(x + cargo_task.offset_dx, y + cargo_task.offset_dy, z)

/// Validates all cargo tasks, removing those on closed turfs.
/obj/machinery/big_manipulator/proc/validate_all_tasks()
	for(var/datum/manipulator_task/cargo/cargo_task in tasks)
		if(!cargo_task.is_valid())
			tasks -= cargo_task
			qdel(cargo_task)

/// Attempts to press the power button.
/obj/machinery/big_manipulator/proc/try_press_on(mob/living/carbon/human/user)
	if(power_access_wire_cut)
		balloon_alert(user, "unresponsive!")
		return

	if(stopping)
		balloon_alert(user, "stopping in progress!")
		return

	toggle_power_state(user)
	if(on)
		balloon_alert(user, "activated")
	else
		balloon_alert(user, "deactivated")

/obj/machinery/big_manipulator/proc/_collect_filter_names(list/filters)
	var/list/names = list()
	for(var/atom/f as anything in filters)
		names += initial(f.name)
	return names

/obj/machinery/big_manipulator/proc/_collect_priorities(list/priorities)
	var/list/out = list()
	for(var/datum/manipulator_priority/pr in priorities)
		var/list/entry = list()
		entry["name"] = pr.name
		entry["active"] = pr.active
		out += list(entry)
	return out

/obj/machinery/big_manipulator/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("run_cycle")
			try_press_on(ui.user)
			return TRUE

		if("drop_held_atom")
			drop_held_atom()
			return TRUE

		if("create_task")
			create_new_task(ui.user, params["task_type"])
			maybe_wake()
			return TRUE

		if("reset_tasking_index")
			master_tasking.current_index = 1
			balloon_alert(ui.user, "tasking index reset")
			maybe_wake()
			return TRUE

		if("cycle_tasking_strategy")
			var/new_strategy = params["new_strategy"]
			if(new_strategy in list(TASKING_SEQUENTIAL, TASKING_STRICT))
				tasking_strategy = new_strategy
				update_strategies()
			maybe_wake()
			return TRUE

		if("adjust_interaction_speed")
			var/new_speed = text2num(params["new_speed"])
			if(isnull(new_speed))
				return FALSE
			speed_multiplier = clamp(new_speed, min_speed_multiplier, max_speed_multiplier)
			return TRUE

		if("unbuckle")
			var/mob/living/carbon/human/species/monkey/poor_monkey = monkey_worker?.resolve()
			if(poor_monkey)
				poor_monkey.drop_all_held_items()
				poor_monkey.forceMove(get_turf(src))
			monkey_worker = null
			return TRUE

		if("adjust_task_param")
			var/success = adjust_param_for_task(params["taskId"], params["param"], params["value"], ui.user)
			if(success)
				maybe_wake()
			return success

		if("disk_eject")
			return eject_task_disk(ui.user)

		if("disk_read")
			if(read_disk_tasks(ui.user))
				maybe_wake()
			return TRUE

		if("disk_write")
			return write_disk_tasks(ui.user)

		if("disk_clear")
			return clear_disk_tasks(ui.user)


/obj/machinery/big_manipulator/proc/eject_task_disk(mob/user)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return FALSE
	if(!task_disk)
		return FALSE
	var/obj/item/disk/manipulator/ejectable_disk = task_disk
	task_disk = null
	if(istype(user) && user.put_in_hands(ejectable_disk))
		balloon_alert(user, "disk ejected")
	else
		ejectable_disk.forceMove(drop_location())
		balloon_alert(user, "disk dropped")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/big_manipulator/proc/clear_disk_tasks(mob/user)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return FALSE
	if(!task_disk)
		return FALSE
	if(task_disk.read_only)
		balloon_alert(user, "disk protected")
		return FALSE
	task_disk.set_tasks(list())
	balloon_alert(user, "cleared")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/big_manipulator/proc/write_disk_tasks(mob/user)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return FALSE
	if(!task_disk)
		return FALSE
	if(task_disk.read_only)
		balloon_alert(user, "disk protected")
		return FALSE

	var/list/out = list()
	for(var/datum/manipulator_task/task as anything in tasks)
		out += list(task.serialize())

	task_disk.set_tasks(out)
	balloon_alert(user, "written")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/big_manipulator/proc/read_disk_tasks(mob/user)
	if(on || stopping)
		balloon_alert(user, "turn it off first!")
		return FALSE
	if(!task_disk)
		return FALSE

	QDEL_LIST(tasks)
	tasks = list()
	current_task = null

	var/turf/base = get_turf(src)
	var/datum/stock_part/manipulator/locate_servo = locate() in component_parts
	var/manipulator_tier = locate_servo ? locate_servo.tier : 1

	for(var/list/task_data as anything in task_disk.tasks_data)
		if(length(tasks) >= interaction_point_limit)
			break
		if(!islist(task_data))
			continue
		var/task_type = task_data["type"]
		if(!ispath(task_type, /datum/manipulator_task))
			continue
		var/datum/manipulator_task/new_task
		if(ispath(task_type, /datum/manipulator_task/cargo))
			if(!base)
				continue
			var/list/offset = task_data["offset"]
			if(!islist(offset))
				continue
			var/dx = offset["dx"]
			var/dy = offset["dy"]
			if(!isnum(dx) || !isnum(dy))
				continue
			if(dx < -1 || dx > 1 || dy < -1 || dy > 1)
				continue
			if(dx == 0 && dy == 0)
				continue
			var/turf/target_turf = locate(base.x + dx, base.y + dy, base.z)
			if(!target_turf || isclosedturf(target_turf))
				continue
			new_task = new task_type(target_turf, manipulator_tier, serialized_data = task_data)
			if(istype(new_task, /datum/manipulator_task/cargo))
				var/datum/manipulator_task/cargo/c = new_task
				c.offset_dx = dx
				c.offset_dy = dy
		else
			new_task = new task_type(serialized_data = task_data)
		if(!new_task || QDELETED(new_task))
			continue
		tasks += new_task

	process_upgrades()
	validate_all_tasks()
	balloon_alert(user, "loaded")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/big_manipulator/proc/adjust_param_for_task(task_ref, param, value, mob/user)
	if(!param)
		return FALSE

	var/datum/manipulator_task/target_task = locate(task_ref) in tasks
	if(!target_task)
		return FALSE

	switch(param)
		if("set_name")
			if(!value)
				return FALSE
			target_task.name = sanitize_name(value, allow_numbers = TRUE)
			return TRUE

		if("set_wait_time")
			if(!istype(target_task, /datum/manipulator_task/simple/wait))
				return FALSE
			var/datum/manipulator_task/simple/wait/t = target_task
			t.time_seconds = clamp(text2num(value), 1, 60)
			return TRUE

		if("remove_task")
			tasks.Remove(target_task)
			qdel(target_task)
			return TRUE

		if("move_up")
			var/idx = tasks.Find(target_task)
			if(idx <= 1)
				return FALSE
			tasks.Swap(idx, idx - 1)
			return TRUE

		if("move_down")
			var/idx = tasks.Find(target_task)
			if(idx >= length(tasks))
				return FALSE
			tasks.Swap(idx, idx + 1)
			return TRUE

		if("move_to")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/cargo_task = target_task
			var/button_number = text2num(value["buttonNumber"])
			if(button_number < 1 || button_number > 9)
				return
			var/dx = ((button_number - 1) % 3) - 1
			var/dy = 1 - round((button_number - 1) / 3)
			var/turf/new_turf = locate(x + dx, y + dy, z)
			if(!new_turf || isclosedturf(new_turf))
				return FALSE
			cargo_task.interaction_turf = new_turf
			cargo_task.offset_dx = dx
			cargo_task.offset_dy = dy
			return TRUE

		if("toggle_filter_skip")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.should_use_filters = !ct.should_use_filters
			return TRUE

		if("reset_atom_filters")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.atom_filters = list()
			return TRUE

		if("add_atom_filter_from_held")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			var/obj/item/held_item = user.get_active_held_item()
			if(!held_item)
				return FALSE
			for(var/filter_path in ct.atom_filters)
				if(istype(held_item, filter_path))
					return FALSE
			ct.atom_filters += held_item.type
			return TRUE

		if("delete_filter")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.atom_filters.Cut(value, value + 1)
			return TRUE

		if("cycle_filtering_mode")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use) || istype(target_task, /datum/manipulator_task/cargo/interact))
				return FALSE
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/ct = target_task
			ct.filtering_mode = cycle_value(ct.filtering_mode, obj_flags & EMAGGED ? list(TAKE_ITEMS, TAKE_CLOSETS, TAKE_HUMANS) : list(TAKE_ITEMS, TAKE_CLOSETS))
			return TRUE

		if("toggle_priority")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/current_task = target_task
			return current_task.tick_priority_by_index(value)

		if("priority_move_up")
			if(!istype(target_task, /datum/manipulator_task/cargo))
				return FALSE
			var/datum/manipulator_task/cargo/current_task = target_task
			return current_task.move_priority_up_by_index(value)

		if("cycle_pickup_eagerness")
			if(!istype(target_task, /datum/manipulator_task/cargo/pickup))
				return FALSE
			var/datum/manipulator_task/cargo/pickup/cycle_target_task = target_task
			cycle_target_task.pickup_eagerness = cycle_value(cycle_target_task.pickup_eagerness, list(PICKUP_CAN_WAIT, PICKUP_EAGER))
			return TRUE

		if("cycle_overflow_status")
			if(!istype(target_task, /datum/manipulator_task/cargo/dropoff_base/drop))
				return FALSE
			var/datum/manipulator_task/cargo/dropoff_base/drop/cycle_target_task = target_task
			cycle_target_task.overflow_status = cycle_value(cycle_target_task.overflow_status, list(POINT_OVERFLOW_ALLOWED, POINT_OVERFLOW_FILTERS, POINT_OVERFLOW_HELD, POINT_OVERFLOW_FORBIDDEN))
			return TRUE

		if("cycle_throw_range")
			if(!istype(target_task, /datum/manipulator_task/cargo/dropoff_base/throw))
				return FALSE
			var/datum/manipulator_task/cargo/dropoff_base/throw/cycle_target_task = target_task
			cycle_target_task.throw_range = cycle_value(cycle_target_task.throw_range, list(1, 2, 3, 4, 5, 6, 7))
			return TRUE

		if("cycle_worker_interaction")
			var/list/vals = list(WORKER_NORMAL_USE, WORKER_SINGLE_USE, WORKER_EMPTY_USE)
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/cycle_target_task = target_task
				cycle_target_task.worker_interaction = cycle_value(cycle_target_task.worker_interaction, vals)
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/cycle_target_task = target_task
				cycle_target_task.worker_interaction = cycle_value(cycle_target_task.worker_interaction, vals)
				return TRUE
			return FALSE

		if("cycle_post_interaction")
			var/list/vals = list(POST_INTERACTION_DROP_AT_POINT, POST_INTERACTION_DROP_AT_MACHINE, POST_INTERACTION_DROP_NEXT_FITTING, POST_INTERACTION_WAIT)
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/cycle_target_task = target_task
				cycle_target_task.use_post_interaction = cycle_value(cycle_target_task.use_post_interaction, vals)
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/cycle_target_task = target_task
				cycle_target_task.use_post_interaction = cycle_value(cycle_target_task.use_post_interaction, vals)
				return TRUE
			return FALSE

		if("toggle_worker_rmb")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/cycle_target_task = target_task
				cycle_target_task.worker_use_rmb = !cycle_target_task.worker_use_rmb
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/cycle_target_task = target_task
				cycle_target_task.worker_use_rmb = !cycle_target_task.worker_use_rmb
				return TRUE
			return FALSE

		if("toggle_worker_combat")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/cycle_target_task = target_task
				cycle_target_task.worker_combat_mode = !cycle_target_task.worker_combat_mode
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/cycle_target_task = target_task
				cycle_target_task.worker_combat_mode = !cycle_target_task.worker_combat_mode
				return TRUE
			return FALSE

		if("toggle_skip_anchored")
			if(istype(target_task, /datum/manipulator_task/cargo/dropoff_base/use))
				var/datum/manipulator_task/cargo/dropoff_base/use/unanchor_target = target_task
				unanchor_target.skip_anchored = !unanchor_target.skip_anchored
				return TRUE
			if(istype(target_task, /datum/manipulator_task/cargo/interact))
				var/datum/manipulator_task/cargo/interact/unanchor_target = target_task
				unanchor_target.skip_anchored = !unanchor_target.skip_anchored
				return TRUE
			return FALSE

/// Cycles the given value in the given list.
/obj/machinery/big_manipulator/proc/cycle_value(current_value, list/possible_values)
	var/current_index = possible_values.Find(current_value)
	if(current_index == 0)
		return possible_values[1]
	return possible_values[(current_index % length(possible_values)) + 1]

/// Retries the task loop if we're waiting for a signal and the machine is on.
/obj/machinery/big_manipulator/proc/maybe_wake()
	if(on && !stopping && waiting_for_signal)
		something_happened()

/obj/machinery/big_manipulator/proc/update_strategies()
	master_tasking = create_strategy(tasking_strategy)

/obj/machinery/big_manipulator/proc/create_strategy(strategy_mode)
	switch(strategy_mode)
		if(TASKING_SEQUENTIAL)
			return new /datum/tasking_strategy/sequential()
		if(TASKING_STRICT)
			return new /datum/tasking_strategy/strict()
	return new /datum/tasking_strategy/sequential()

/obj/machinery/big_manipulator/ui_interact(mob/user, datum/tgui/ui)
	if(id_lock)
		to_chat(user, span_warning("[src] is locked behind ID authentication!"))
		ui?.close()
		return
	if(!anchored)
		to_chat(user, span_warning("[src] isn't attached to the ground!"))
		ui?.close()
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BigManipulator")
		ui.open()

/obj/machinery/big_manipulator/ui_data(mob/user)
	. = list(
		"active" = on,
		"stopping" = stopping,
		"current_task" = current_task ? REF(current_task) : null,
		"speed_multiplier" = speed_multiplier,
		"min_speed_multiplier" = min_speed_multiplier,
		"max_speed_multiplier" = max_speed_multiplier,
		"manipulator_position" = "[x],[y]",
		"tasking_strategy" = tasking_strategy,
		"has_monkey" = !isnull(monkey_worker),
		"disk_inserted" = !isnull(task_disk),
		"disk_read_only" = task_disk?.read_only || FALSE,
		"disk_task_count" = length(task_disk?.tasks_data || list()),
	)

	.["tasks_data"] = list()
	for(var/datum/manipulator_task/task as anything in tasks)
		var/task_type = ""
		if(istype(task, /datum/manipulator_task/cargo/pickup))
			task_type = "pickup"
		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/drop))
			task_type = "drop"
		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/throw))
			task_type = "throw"
		else if(istype(task, /datum/manipulator_task/cargo/dropoff_base/use))
			task_type = "use"
		else if(istype(task, /datum/manipulator_task/cargo/interact))
			task_type = "interact"
		else if(istype(task, /datum/manipulator_task/simple/wait))
			task_type = "wait"

		var/list/task_data = list(
			"name" = task.name,
			"id" = "[REF(task)]",
			"task_type" = task_type,
		)
		if(istype(task, /datum/manipulator_task/cargo))
			var/datum/manipulator_task/cargo/task_cargo = task
			if(task_cargo.interaction_turf)
				task_data["turf"] = "[task_cargo.interaction_turf.x - x],[task_cargo.interaction_turf.y - y]"
			task_data["filters_status"] = task_cargo.should_use_filters
			task_data["filtering_mode"] = task_cargo.filtering_mode
			task_data["settings_list"] = list()
			for(var/datum/manipulator_priority/priority as anything in task_cargo.interaction_priorities)
				task_data["settings_list"] += list(list(
					"name" = priority.name,
					"active" = priority.active,
				))
			task_data["item_filters"] = list()
			for(var/atom/movable/filter_atom as anything in task_cargo.atom_filters)
				task_data["item_filters"] += "[filter_atom]"

		if(istype(task, /datum/manipulator_task/cargo/pickup))
			var/datum/manipulator_task/cargo/pickup/task_pickup = task
			task_data["pickup_eagerness"] = task_pickup.pickup_eagerness

		if(istype(task, /datum/manipulator_task/cargo/dropoff_base/drop))
			var/datum/manipulator_task/cargo/dropoff_base/drop/task_drop = task
			task_data["overflow_status"] = task_drop.overflow_status

		if(istype(task, /datum/manipulator_task/cargo/dropoff_base/throw))
			var/datum/manipulator_task/cargo/dropoff_base/throw/task_throw = task
			task_data["throw_range"] = task_throw.throw_range

		if(istype(task, /datum/manipulator_task/cargo/dropoff_base/use))
			var/datum/manipulator_task/cargo/dropoff_base/use/task_use = task
			task_data["worker_interaction"] = task_use.worker_interaction
			task_data["use_post_interaction"] = task_use.use_post_interaction
			task_data["worker_use_rmb"] = task_use.worker_use_rmb
			task_data["worker_combat_mode"] = task_use.worker_combat_mode
			task_data["skip_anchored"] = task_use.skip_anchored

		if(istype(task, /datum/manipulator_task/cargo/interact))
			var/datum/manipulator_task/cargo/interact/task_interact = task
			task_data["worker_interaction"] = task_interact.worker_interaction
			task_data["use_post_interaction"] = task_interact.use_post_interaction
			task_data["worker_use_rmb"] = task_interact.worker_use_rmb
			task_data["worker_combat_mode"] = task_interact.worker_combat_mode
			task_data["skip_anchored"] = task_interact.skip_anchored

		if(istype(task, /datum/manipulator_task/simple/wait))
			var/datum/manipulator_task/simple/wait/task_wait = task
			task_data["time"] = task_wait.time_seconds

		.["tasks_data"] += list(task_data)
