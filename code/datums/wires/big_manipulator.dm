/datum/wires/big_manipulator
	holder_type = /obj/machinery/big_manipulator
	proper_name = "Big Manipulator"

/datum/wires/big_manipulator/New(atom/holder)
	wires = list(
		WIRE_ON,
		WIRE_DROP,
		WIRE_ITEM_TYPE,
		WIRE_CHANGE_MODE,
		WIRE_ONE_PRIORITY_BUTTON,
		WIRE_THROW_RANGE
	)
	return ..()

/datum/wires/big_manipulator/interactable(mob/user)
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	return holder_manipulator.panel_open ? ..() : FALSE

/datum/wires/big_manipulator/get_status()
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	var/list/status = list()
	status += "The big light bulb [holder_manipulator.power_access_wire_cut ? "is off" : "is glowing [holder_manipulator.on ? "green" : "red"]"]."
	status += "The small light bulb [holder_manipulator.held_object ? "is glowing bright green" : "is off"]."
	status += "The number on the display shows [length(holder_manipulator.tasks)]."
	return status

/datum/wires/big_manipulator/on_pulse(wire)
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	switch(wire)
		if(WIRE_ON)
			holder_manipulator.try_press_on(usr)
		if(WIRE_DROP)
			holder_manipulator.drop_held_atom()
		if(WIRE_ITEM_TYPE)
			for(var/datum/manipulator_task/cargo/task in holder_manipulator.tasks)
				task.filtering_mode = holder_manipulator.cycle_value(task.filtering_mode, list(TAKE_ITEMS, TAKE_CLOSETS))
		if(WIRE_CHANGE_MODE)
			holder_manipulator.tasking_strategy = holder_manipulator.tasking_strategy == TASKING_SEQUENTIAL ? TASKING_STRICT : TASKING_SEQUENTIAL
			holder_manipulator.update_strategies()
		if(WIRE_ONE_PRIORITY_BUTTON)
			for(var/datum/manipulator_task/cargo/task in holder_manipulator.tasks)
				var/found_active = FALSE
				for(var/datum/manipulator_priority/prio in task.interaction_priorities)
					if(prio.active && !found_active)
						found_active = TRUE
					else
						prio.active = FALSE
		if(WIRE_THROW_RANGE)
			for(var/datum/manipulator_task/cargo/dropoff_base/throw/task in holder_manipulator.tasks)
				task.throw_range = holder_manipulator.cycle_value(task.throw_range, list(1, 2, 3, 4, 5, 6, 7))

/datum/wires/big_manipulator/on_cut(wire, mend, source)
	var/obj/machinery/big_manipulator/holder_manipulator = holder
	switch(wire)
		if(WIRE_ON)
			holder_manipulator.power_access_wire_cut = !mend
		if(WIRE_ITEM_TYPE)
			if(!mend)
				holder_manipulator.item_type_wire_cut = TRUE
				for(var/datum/manipulator_task/cargo/task in holder_manipulator.tasks)
					task.saved_filtering_mode = task.filtering_mode
					task.filtering_mode = pick(TAKE_ITEMS, TAKE_CLOSETS, TAKE_HUMANS)
			else
				holder_manipulator.item_type_wire_cut = FALSE
				for(var/datum/manipulator_task/cargo/task in holder_manipulator.tasks)
					if(!isnull(task.saved_filtering_mode))
						task.filtering_mode = task.saved_filtering_mode
						task.saved_filtering_mode = null
		if(WIRE_CHANGE_MODE)
			holder_manipulator.tasking_strategy = mend ? TASKING_SEQUENTIAL : TASKING_STRICT
			holder_manipulator.update_strategies()
		if(WIRE_ONE_PRIORITY_BUTTON)
			for(var/datum/manipulator_task/cargo/task in holder_manipulator.tasks)
				for(var/datum/manipulator_priority/prio in task.interaction_priorities)
					prio.active = !!mend
		if(WIRE_THROW_RANGE)
			for(var/datum/manipulator_task/cargo/dropoff_base/throw/task in holder_manipulator.tasks)
				task.throw_range = mend ? 1 : 7
