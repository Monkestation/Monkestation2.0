/obj/item/conveyor_sorter
	name = "conveyor sorter lister"
	desc = "A tool that is used to not only create the conveyor sorters, but give lists to the conveyor sorters."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "lister"
	///the list of conveyor sorters spawned by
	var/list/spawned_sorters = list()
	///the list of things that are currently within the sorting list
	var/list/current_sort = list()
	///This controls the maximum amount of sorters that can be spawned by one lister item.
	var/max_sorters = 4
	///This controls the maximum amount of items that can be added to the sorting list.
	var/max_items = 5
	/// This is used for the improved sorter, so that it can use the improved sorter type instead of the normal sorter type.
	var/conveyor_type = /obj/effect/decal/conveyor_sorter

/obj/item/conveyor_sorter/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/conveyor_sorter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "Place down sorter"
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Reset Sorting List"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/conveyor_sorter/Destroy()
	for(var/deleting_sorters in spawned_sorters)
		qdel(deleting_sorters)
	return ..()

/obj/item/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Use it inhand")]to place down a conveyor sorter, up to a limit of [EXAMINE_HINT(max_sorters)]")
	. += span_notice("This sorter can sort up to [EXAMINE_HINT(max_items)] items.")
	. += span_notice("Use [EXAMINE_HINT("Alt-Click")] to reset the sorting list.")
	. += span_notice("[EXAMINE_HINT("Click")] on things to attempt to add to the sorting list.")

/obj/item/conveyor_sorter/attack_self(mob/user, modifiers)
	if(length(spawned_sorters) >= max_sorters)
		to_chat(user, span_warning("You may only have [max_sorters] spawned conveyor sorters!"))
		return
	var/obj/effect/decal/conveyor_sorter/new_cs = new conveyor_type(get_turf(src))
	new_cs.parent_item = src
	new_cs.sorting_list = current_sort
	spawned_sorters += new_cs

/obj/item/conveyor_sorter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(interacting_with == src)
		return
	if(!user.can_perform_action(interacting_with, ALLOW_RESTING))
		return
	if(!ismovable(interacting_with))
		return
	if(istype(interacting_with, /obj/effect/decal/conveyor_sorter))
		return
	if(is_type_in_list(interacting_with, current_sort))
		balloon_alert(user, "[interacting_with] is already in the sorting list")
		return
	if(length(current_sort) >= max_items)
		balloon_alert(user, "the sorter's sorting list is at maximum capacity")
		return
	current_sort += interacting_with.type
	balloon_alert(user, "[interacting_with] has been added to the sorting list")
	return ITEM_INTERACT_SUCCESS

/obj/item/conveyor_sorter/click_alt(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	current_sort = list()
	return CLICK_ACTION_SUCCESS

/obj/effect/decal/conveyor_sorter
	name = "conveyor sorter"
	desc = "A mark that will sort items out based on what they are."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "sorter"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	///the list of items that will be sorted to the sorted direction
	var/list/sorting_list = list()
	//the direction that the items in the sorting list will be moved to
	dir = NORTH
	///the parent conveyor sorter lister item, used for deletion
	var/obj/item/conveyor_sorter/parent_item
	var/list/directions =  list("North", "East", "South", "West") //This is used for the tgui input list, so that the user can choose which direction to sort to.
	/// To prevent spam
	COOLDOWN_DECLARE(use_cooldown)

	light_outer_range = 3
	light_color = COLOR_RED_LIGHT

/obj/effect/decal/conveyor_sorter/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	register_context()

/obj/effect/decal/conveyor_sorter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Change sorting direction"
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Reset sorting List"
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Remove sorter"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/conveyor_sorter))
		context[SCREENTIP_CONTEXT_LMB] = "Update sorting list"
		return CONTEXTUAL_SCREENTIP_SET

/obj/effect/decal/conveyor_sorter/Destroy()
	if(parent_item)
		parent_item.spawned_sorters -= src
		parent_item = null
	return ..()

/obj/effect/decal/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Click")] with a conveyor sorter to set the sorting list.")
	. += span_notice("[EXAMINE_HINT("Click")] with a empty hand to change the sorting direction.")
	. += span_notice("[EXAMINE_HINT("Alt-Click")] with a empty hand to reset the sorting list.")
	. += span_notice("[EXAMINE_HINT("Ctrl-Click")] with a empty hand to remove.")

/obj/effect/decal/conveyor_sorter/attack_hand(mob/living/user, list/modifiers)
	var/user_choice = tgui_input_list(user, "Choose which direction to sort to!", "Direction choice", directions)
	if(!user_choice)
		return ..()

	var/dir = text2dir(user_choice)
	if(!dir)
		return ..()

	setDir(dir)
	balloon_alert(user, "direction updated")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/effect/decal/conveyor_sorter/attackby(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/conveyor_sorter))
		var/obj/item/conveyor_sorter/cs_item = used_item
		sorting_list = cs_item.current_sort
		balloon_alert(user, "sorting list updated")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		return
	else
		return ..()

/obj/effect/decal/conveyor_sorter/click_alt(mob/user)
	balloon_alert(user, "sorting list reset")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	sorting_list = list()
	return CLICK_ACTION_SUCCESS

/obj/effect/decal/conveyor_sorter/click_ctrl(mob/user)
	qdel(src)

/obj/effect/decal/conveyor_sorter/proc/on_entered(datum/source, atom/movable/entering_atom)
	SIGNAL_HANDLER
	if(is_type_in_list(entering_atom, sorting_list) && !entering_atom.anchored && COOLDOWN_FINISHED(src, use_cooldown))
		COOLDOWN_START(src, use_cooldown, 1 SECONDS)
		entering_atom.Move(get_step(src, dir))

/datum/design/conveyor_sorter
	name = "Conveyor Sorter"
	desc = "A wonderful item that can set markers and forcefully move stuff to a direction."
	id = "conveysorter"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/conveyor_sorter
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5, /datum/material/plastic = SMALL_MATERIAL_AMOUNT*5)
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MISC
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/techweb_node/conveyor_sorter
	id = "conveyorsorter"
	display_name = "Conveyor Sorter"
	description = "Finally, the ability to automatically sort stuff."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list(
		"conveysorter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/obj/item/conveyor_sorter/improved
	name = "improved conveyor sorter lister"
	desc = "A tool that is used to not only create the conveyor sorters, but give lists to the conveyor sorters."
	icon_state = "lister_improved"
	max_sorters = 8
	max_items = 10
	conveyor_type = /obj/effect/decal/conveyor_sorter/improved

/obj/effect/decal/conveyor_sorter/improved
	name = "improved conveyor sorter"
	desc = "A mark that will sort items out based on what they are. This one can sort in multiple directions."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "sorter_improved"
	light_outer_range = 3
	light_color = COLOR_BLUE_LIGHT
	directions = list("North", "East", "South", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest")

/datum/design/conveyor_sorter/improved
	name = "Improved Conveyor Sorter"
	desc = "A wonderful item that can set markers and forcefully move stuff to a direction. With more capacity to sort more!"
	id = "conveyor_sorter_improved"
	build_path = /obj/item/conveyor_sorter/improved
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT*5,
		/datum/material/plastic = SMALL_MATERIAL_AMOUNT*5,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT*5,
		/datum/material/bluespace = SMALL_MATERIAL_AMOUNT*5,
	)


/datum/techweb_node/conveyor_sorter/improved
	id = "conveyor_sorter_improved"
	display_name = "Improved Conveyor Sorter"
	description = "An improved version of the conveyor sorter, this one allows for more control over sorting."
	prereq_ids = list("practical_bluespace", "conveyorsorter")
	design_ids = list(
		"conveyor_sorter_improved",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
