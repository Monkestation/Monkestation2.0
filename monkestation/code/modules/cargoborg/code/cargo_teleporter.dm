GLOBAL_LIST_EMPTY(cargo_marks)

/obj/item/cargo_teleporter
	name = "cargo teleporter"
	desc = "An item that can set down a set number of markers, allowing them to teleport items within a tile to the set markers."
	icon = 'monkestation/code/modules/cargoborg/icons/cargo_teleporter.dmi'
	icon_state = "cargo_tele"
	w_class = WEIGHT_CLASS_SMALL
	/// The list of markers spawned by this item.
	var/list/marker_children = list()
	/// The maximum amount of fulton charges the teleporter can have.
	var/max_charges = 3
	/// The current amount of fulton charges the teleporter currently has.
	var/charges = 0
	/// The fulton we use to actually extract things.
	var/obj/item/extraction_pack/my_fulton
	/// The cooldown between teleport usages.
	COOLDOWN_DECLARE(use_cooldown)

/obj/item/cargo_teleporter/Initialize(mapload)
	. = ..()
	my_fulton = new(src)
	my_fulton.uses_left = INFINITY // No need to worry about the fulton deleting itself if it has infinite uses.

/obj/item/cargo_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Use")] in-hand to set down the markers!")
	. += span_notice("[EXAMINE_HINT("Alt-click")] to remove all markers!")
	. += span_notice("[EXAMINE_HINT("Ctrl-click")] to select a extraction beacon to fulton to!")
	. += span_notice("[EXAMINE_HINT("Right-click")] a thing to start fultoning it with a charge.")
	. += span_info("It has [charges]/[max_charges] charges remaining.")

/obj/item/cargo_teleporter/Destroy()
	QDEL_NULL(my_fulton)
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			destroy_children.parent_item = null
			qdel(destroy_children)
	return ..()

/obj/item/cargo_teleporter/attack_self(mob/user, modifiers)
	if(length(marker_children) >= 3)
		to_chat(user, span_warning("You may only have three spawned markers from [src]!"))
		return
	to_chat(user, span_notice("You place a cargo marker underneath you."))
	playsound(src, 'sound/machines/click.ogg', 50)
	var/obj/effect/decal/cleanable/cargo_mark/spawned_marker = new /obj/effect/decal/cleanable/cargo_mark(get_turf(src))
	spawned_marker.parent_item = src
	marker_children += spawned_marker

/obj/item/cargo_teleporter/item_ctrl_click(mob/user)
	if(!(src in user.held_items))
		return NONE
	if(my_fulton.choose_beacon(user))
		return CLICK_ACTION_SUCCESS
	return CLICK_ACTION_BLOCKING

/obj/item/cargo_teleporter/click_alt(mob/user)
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			qdel(destroy_children)
	return CLICK_ACTION_SUCCESS

/obj/item/cargo_teleporter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_warning("[src] is still on cooldown!"))
		return ITEM_INTERACT_BLOCKING
	var/choice = tgui_input_list(user, "Select which cargo mark to teleport the items to?", "Cargo Mark Selection", GLOB.cargo_marks)
	if(!choice)
		return NONE
	if(!user.Adjacent(interacting_with))
		return ITEM_INTERACT_BLOCKING // This prevents teleporting from range as we moved out of expected interaction range.
	var/turf/moving_turf = get_turf(choice)
	var/turf/target_turf = get_turf(interacting_with)
	for(var/check_content in target_turf.contents)
		if(isobserver(check_content))
			continue
		if(!ismovable(check_content))
			continue
		if(issyndicateblackbox(check_content))
			continue
		var/atom/movable/movable_content = check_content
		if(isliving(movable_content))
			continue
		if(length(movable_content.get_all_contents_type(/mob/living)))
			continue
		if(movable_content.anchored)
			continue
		do_teleport(movable_content, moving_turf)
	playsound(src, 'sound/magic/disable_tech.ogg', 35) // The sound isn't played in the loop above because it will spam sounds if there are lots of items to teleport.
	new /obj/effect/decal/cleanable/ash(target_turf)
	COOLDOWN_START(src, use_cooldown, 8 SECONDS)

/obj/item/cargo_teleporter/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/extraction_pack) && try_refill_charges(user, interacting_with, TRUE))
		return ITEM_INTERACT_SUCCESS
	if(charges <= 0)
		balloon_alert(user, "no charges left!")
		return ITEM_INTERACT_BLOCKING
	. = my_fulton.interact_with_atom(interacting_with, user, modifiers)
	if(. == ITEM_INTERACT_SUCCESS)
		charges--

/obj/item/cargo_teleporter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/extraction_pack))
		return NONE
	if(!try_refill_charges(user, tool))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/// Tries to refill the teleporter's fulton charges.
/obj/item/cargo_teleporter/proc/try_refill_charges(mob/living/refiller, obj/item/extraction_pack/refilling_pack, silent_if_failure = FALSE)
	if(charges >= max_charges)
		if(!silent_if_failure)
			balloon_alert(refiller, "charges full")
		return FALSE
	var/charges_to_refill = clamp(max_charges - charges, 0, refilling_pack.uses_left)
	charges += charges_to_refill
	refilling_pack.uses_left -= charges_to_refill
	balloon_alert(refiller, "added [charges_to_refill] charges")
	if(!refilling_pack.uses_left)
		qdel(refilling_pack)
	return TRUE

/datum/design/cargo_teleporter
	name = "Cargo Teleporter"
	desc = "A wonderful item that can set markers and teleport things to those markers."
	id = "cargotele"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/cargo_teleporter
	materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT*5, /datum/material/plastic = SMALL_MATERIAL_AMOUNT*5, /datum/material/uranium =  SMALL_MATERIAL_AMOUNT*5)
	category = list(RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_CARGO)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/effect/decal/cleanable/cargo_mark
	name = "cargo mark"
	desc = "A mark left behind by a cargo teleporter, which allows targeted teleportation. Can be removed by the cargo teleporter."
	icon = 'monkestation/code/modules/cargoborg/icons/cargo_teleporter.dmi'
	icon_state = "marker"
	///the reference to the item that spawned the cargo mark
	var/obj/item/cargo_teleporter/parent_item

	light_outer_range = 3
	light_color = COLOR_VIVID_YELLOW

/obj/effect/decal/cleanable/cargo_mark/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/cargo_teleporter))
		to_chat(user, span_notice("You remove [src] using [attacking_item]."))
		playsound(src, 'sound/machines/click.ogg', 50)
		qdel(src)
		return
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Destroy()
	if(parent_item)
		parent_item.marker_children -= src
	GLOB.cargo_marks -= src
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	var/area/src_area = get_area(src)
	name = "[src_area.name] ([rand(100000,999999)])"
	GLOB.cargo_marks += src
