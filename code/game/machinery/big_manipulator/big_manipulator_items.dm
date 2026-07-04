/obj/item/circuitboard/machine/big_manipulator
	name = "Big Manipulator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/big_manipulator
	req_components = list(
		/datum/stock_part/manipulator = 1,
	)

/obj/item/disk/manipulator
	name = "manipulator task disk"
	desc = "A floppy disk containing manipulator tasks."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk1"
	var/list/tasks_data = list()
	var/read_only = FALSE

/obj/item/disk/manipulator/proc/set_tasks(list/new_tasks_data)
	if(read_only)
		return FALSE
	tasks_data = islist(new_tasks_data) ? new_tasks_data : list()
	return TRUE

/obj/item/disk/manipulator/proc/get_tasks()
	return tasks_data?.Copy() || list()

/obj/item/disk/manipulator/examine(mob/user)
	. = ..()
	. += span_notice("It has [length(tasks_data)] task data chunk\s stored.")
