GLOBAL_LIST_EMPTY(cargo_marks)

/obj/item/cargo_teleporter
	name = "cargo teleporter"
	desc = "An item that can set down a set number of markers, allowing them to teleport items within a tile to the set markers."
	icon = 'monkestation/code/modules/cargoborg/icons/cargo_teleporter.dmi'
	icon_state = "cargo_tele"
	w_class = WEIGHT_CLASS_SMALL
	///the list of markers spawned by this item
	var/list/marker_children = list()
	COOLDOWN_DECLARE(use_cooldown)
	/// Maximum amount of fulton charges the teleporter can hold
	var/max_charges = 3
	/// Amount of charges remaining to be able to fulton somebody
	var/charges = 0
	/// The fulton we use to actually extract living things
	var/obj/item/extraction_pack/my_fulton

/obj/item/cargo_teleporter/Initialize(mapload)
	. = ..()
	my_fulton = new(src)

/obj/item/cargo_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("Attack itself to set down the markers!")
	. += span_notice("ALT-CLICK to remove all markers!")
	. += span_notice("You can RIGHT-CLICK a living thing to fulton it with a charge.")
	. += span_info("It has [charges] charges remaining.")

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
	to_chat(user, span_notice("You place a cargo marker below your feet."))
	var/obj/effect/decal/cleanable/cargo_mark/spawned_marker = new /obj/effect/decal/cleanable/cargo_mark(get_turf(src))
	playsound(src, 'sound/machines/click.ogg', 50)
	spawned_marker.parent_item = src
	marker_children += spawned_marker

/obj/item/cargo_teleporter/AltClick(mob/user)
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			qdel(destroy_children)

/obj/item/cargo_teleporter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
	if(target == src)
		return ..()
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_warning("[src] is still on cooldown!"))
		return
	var/choice = tgui_input_list(user, "Select which cargo mark to teleport the items to?", "Cargo Mark Selection", GLOB.cargo_marks)
	if(!choice)
		return ..()
	if(get_dist(user, target) > 1)
		return
	var/turf/moving_turf = get_turf(choice)
	var/turf/target_turf = get_turf(target)
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
		do_teleport(movable_content, moving_turf, asoundout = 'sound/magic/Disable_Tech.ogg')
	new /obj/effect/decal/cleanable/ash(target_turf)
	COOLDOWN_START(src, use_cooldown, 8 SECONDS)

//---- Allows the cargo teleporter to hold fultons as charges, in order to fulton people with right click

/obj/item/cargo_teleporter/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/extraction_pack))
		return
	if(charges >= max_charges)
		balloon_alert(user, "charges full")
		return
	var/obj/item/extraction_pack/attacking_fulton = attacking_item
	var/missing_charges = max_charges - charges
	if(missing_charges >= attacking_fulton.uses_left)
		charges += attacking_fulton.uses_left
		balloon_alert(user, "added [attacking_fulton.uses_left] charges")
		qdel(attacking_fulton)
		if(!my_fulton) // Fultons delete themselves when charges hit 0, so we might have to make a new one after we recharge
			my_fulton = new(src)
		return
	charges += missing_charges
	attacking_fulton.uses_left -= missing_charges
	balloon_alert(user, "added [missing_charges] charges")
	if(!my_fulton) // Fulton self delete
		my_fulton = new(src)

/obj/item/cargo_teleporter/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(charges <= 0)
		balloon_alert(user, "no charges left!")
		return
	if(!my_fulton.choose_beacon(user))
		return
	if(my_fulton.afterattack(target, user, proximity_flag, click_parameters) == AFTERATTACK_PROCESSED_ITEM)
		charges--

/datum/design/cargo_teleporter
	name = "Cargo Teleporter"
	desc = "A wonderful item that can set markers and teleport things to those markers."
	id = "cargotele"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/cargo_teleporter
	materials = list(/datum/material/iron = 500, /datum/material/plastic = 500, /datum/material/uranium =  500)
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

/obj/effect/decal/cleanable/cargo_mark/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/cargo_teleporter))
		to_chat(user, span_notice("You remove [src] using [W]."))
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
