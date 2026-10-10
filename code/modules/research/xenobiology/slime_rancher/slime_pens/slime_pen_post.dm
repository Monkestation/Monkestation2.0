/// How long one side of a pen can be, in tiles
#define SLIME_PEN_MAX_SIZE 9
#define SLIME_PEN_DEPLOY_TIME 0.5 SECONDS

/// Radial menu of the four corners, gives back a diagonal dir (or null if they backed out)
/proc/pick_slime_pen_corner(mob/user, atom/menu_anchor)
	var/list/choices = list()
	var/list/by_label = list()
	for(var/corner in GLOB.diagonals)
		var/label = "[capitalize(dir2text(corner))] corner"
		choices[label] = image(
			icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi',
			icon_state = "post_picker",
			dir = corner,
		)
		by_label[label] = corner
	var/picked = show_radial_menu(user, menu_anchor, choices, require_near = TRUE, tooltips = TRUE)
	return by_label[picked]

/// A folded-up pen post, turns into an /obj/structure/slime_pen_post when you put it down
/obj/item/slime_pen_post
	name = "slime pen post"
	desc = "A collapsible corner post. Use it on an adjacent floor tile to choose its exact corner and deploy it there."
	icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi'
	icon_state = "corner"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT)

/obj/item/slime_pen_post/attack_self(mob/living/user, list/modifiers)
	deploy_to(get_step(user, user.dir), user)

/obj/item/slime_pen_post/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isfloorturf(interacting_with))
		return NONE
	deploy_to(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/slime_pen_post/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Click an adjacent floor tile")] to deploy it there, or use it in hand to deploy it ahead of you.")

/// Asks which corner, then plops a post down on the tile
/obj/item/slime_pen_post/proc/deploy_to(turf/deploy_location, mob/living/user)
	if(!isfloorturf(deploy_location) || !user.Adjacent(deploy_location))
		balloon_alert(user, "pick an adjacent floor!")
		return
	var/chosen_corner = pick_slime_pen_corner(user, src)
	if(isnull(chosen_corner) || QDELETED(src) || !user.is_holding(src))
		return
	setDir(chosen_corner)
	if(deploy_location.is_blocked_turf(TRUE, src))
		balloon_alert(user, "not enough room!")
		return
	balloon_alert(user, "deploying...")
	playsound(src, 'sound/items/ratchet.ogg', 50, TRUE)
	if(!do_after(user, 0.5 SECONDS, src) || QDELETED(src) || !user.is_holding(src))
		return
	if(deploy_location.is_blocked_turf(TRUE, src))
		balloon_alert(user, "space got blocked!")
		return
	var/obj/structure/slime_pen_post/post = new(deploy_location)
	post.setDir(chosen_corner)
	post.update_offsets()
	qdel(src)

/datum/design/slime_pen_post
	name = "Slime Pen Post"
	id = "slime_pen_post"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/slime_pen_post
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_XENOBIOLOGY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/// One corner of a slime pen, bolt down four in a rectangle and you've got a pen
/obj/structure/slime_pen_post
	name = "slime pen post"
	desc = "A corner post for a slime pen. Its plate marks the tile it belongs to, and the dotted guides point into the future pen."
	icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi'
	icon_state = "corner"
	dir = NORTHEAST
	density = FALSE
	anchored = FALSE
	max_integrity = 100
	move_resist = INFINITY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The pen we're part of, null til we link up
	var/datum/slime_pen/pen
	/// Fence color to give the pen when we link up, null means the default
	var/barrier_color
	/// The click target kept inside this post's tile.
	var/obj/structure/slime_pen_anchor/anchor
	/// The click-through line and unfinished fence preview.
	var/obj/effect/slime_pen_guide/guide
	/// Whether construction markers should be visible while this post is unlinked.
	var/construction_markers_visible = TRUE

/obj/structure/slime_pen_post/Initialize(mapload)
	. = ..()
	update_offsets()
	anchor = new(loc, src)
	guide = new(loc, src)
	update_construction_markers()

/obj/structure/slime_pen_post/Destroy(force)
	QDEL_NULL(pen)
	QDEL_NULL(anchor)
	QDEL_NULL(guide)
	return ..()

/obj/structure/slime_pen_post/examine(mob/user)
	. = ..()
	. += span_notice("This is tile ([x], [y])'s [dir2text(dir)] corner.")
	if(pen)
		. += span_notice("It's linked up. Click it to check on the slimes inside.")
	else if(anchored)
		. += span_notice("Click it once the other three posts are ready.")
	else
		. += span_notice("Right-click it to choose another corner, or wrench it to bolt it down.")
	if(anchor && !pen)
		. += span_notice("Its construction markers can be [EXAMINE_HINT("toggled with a multitool")].")

/// Scoots the sprite over to whichever corner our dir points at
/obj/structure/slime_pen_post/proc/update_offsets()
	// the post stands on the corner point of its tile, not in the middle of it
	pixel_w = (dir & EAST) ? 16 : -16
	// the whole pen sits 2px up off the tile line - dipping below it would draw the post's base over a wall to the south
	if(dir & NORTH)
		pixel_z = 32
		layer = BELOW_MOB_LAYER + 0.01
		SET_PLANE_IMPLICIT(src, GAME_PLANE)
	else
		pixel_z = 0
		layer = ABOVE_MOB_LAYER + 0.01
		SET_PLANE_IMPLICIT(src, GAME_PLANE_UPPER)
	anchor?.setDir(dir)
	guide?.setDir(dir)
	guide?.update_appearance(UPDATE_OVERLAYS)

/// Shows the tile plate and the fence preview while we aren't linked up yet
/obj/structure/slime_pen_post/proc/update_construction_markers()
	var/show_markers = construction_markers_visible && isnull(pen)
	if(anchor)
		anchor.alpha = show_markers ? 255 : 0
		anchor.mouse_opacity = show_markers ? MOUSE_OPACITY_ICON : MOUSE_OPACITY_TRANSPARENT
	if(guide)
		guide.alpha = show_markers ? 255 : 0

/obj/structure/slime_pen_post/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "corner_e", src)

/obj/structure/slime_pen_post/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	pick_post(user)?.use_post(user)
	return TRUE

/obj/structure/slime_pen_post/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	pick_post(user)?.choose_corner(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/slime_pen_post/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	var/obj/structure/slime_pen_post/chosen = pick_post(user)
	if(isnull(chosen))
		return ITEM_INTERACT_BLOCKING
	return chosen.wrench_post(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/structure/slime_pen_post/multitool_act(mob/living/user, obj/item/tool)
	var/obj/structure/slime_pen_post/chosen = pick_post(user)
	if(isnull(chosen))
		return ITEM_INTERACT_BLOCKING
	chosen.toggle_construction_markers(user)
	return ITEM_INTERACT_SUCCESS

/// Bolts or unbolts the post, takes longer if it's part of a pen
/obj/structure/slime_pen_post/proc/wrench_post(mob/living/user, obj/item/tool)
	var/wrench_time = QDELETED(pen) ? (0.5 SECONDS) : (2 SECONDS)
	if(default_unfasten_wrench(user, tool, wrench_time) != SUCCESSFUL_UNFASTEN)
		return FALSE
	QDEL_NULL(pen)
	return TRUE

/// Multitool it to hide or show the tile plate and fence preview
/obj/structure/slime_pen_post/proc/toggle_construction_markers(mob/user)
	if(pen)
		balloon_alert(user, "pen already linked!")
		return
	construction_markers_visible = !construction_markers_visible
	update_construction_markers()
	balloon_alert(user, "markers [construction_markers_visible ? "shown" : "hidden"]")

/// Moves an unbolted post to a different corner of its tile
/obj/structure/slime_pen_post/proc/choose_corner(mob/user, atom/menu_anchor = src)
	if(anchored)
		balloon_alert(user, "unwrench it first!")
		return
	var/chosen_corner = pick_slime_pen_corner(user, menu_anchor)
	if(isnull(chosen_corner) || QDELETED(src) || !user.Adjacent(src) || anchored)
		return
	setDir(chosen_corner)
	update_offsets()
	balloon_alert(user, "[dir2text(dir)] corner")

/// What a normal click does: open the pen UI, fold back up, or try to link up
/obj/structure/slime_pen_post/proc/use_post(mob/living/user)
	if(pen)
		ui_interact(user)
		return
	if(!anchored)
		var/obj/item/slime_pen_post/folded_post = new(drop_location())
		folded_post.setDir(dir)
		user.put_in_hands(folded_post)
		qdel(src)
		return
	try_link(user)

/// Every post sitting on this same corner, us included
/obj/structure/slime_pen_post/proc/posts_sharing_corner() as /list
	var/list/found = list(src)
	var/turf/here = get_turf(src)
	if(isnull(here))
		return found
	for(var/obj/structure/slime_pen_post/post in here)
		if(post != src && post.dir == dir)
			found += post
	var/our_east = (dir & EAST) ? 1 : 0
	var/our_north = (dir & NORTH) ? 1 : 0
	for(var/corner in GLOB.diagonals)
		if(corner == dir)
			continue
		var/turf/neighbor = locate(
			here.x + our_east - ((corner & EAST) ? 1 : 0),
			here.y + our_north - ((corner & NORTH) ? 1 : 0),
			here.z,
		)
		if(isnull(neighbor))
			continue
		for(var/obj/structure/slime_pen_post/post in neighbor)
			if(post.dir == corner)
				found += post
	return found

/// If a few posts share the corner, asks which one you actually meant
/obj/structure/slime_pen_post/proc/pick_post(mob/living/user) as /obj/structure/slime_pen_post
	var/list/candidates = posts_sharing_corner()
	if(length(candidates) == 1)
		return src
	var/list/choices = list()
	var/list/by_label = list()
	for(var/obj/structure/slime_pen_post/post as anything in candidates)
		var/fastening = post.anchored ? "bolted" : "loose"
		var/label = "[capitalize(dir2text(post.dir))] corner, tile ([post.x], [post.y]) - [fastening], [post.pen ? "linked" : "unlinked"]"
		if(by_label[label])
			label = "[label] #[length(choices) + 1]"
		choices[label] = image(icon = post.icon, icon_state = "post_picker", dir = post.dir)
		by_label[label] = post
	var/picked = show_radial_menu(user, src, choices, require_near = TRUE, tooltips = TRUE)
	var/obj/structure/slime_pen_post/chosen = by_label[picked]
	if(QDELETED(chosen) || !user.Adjacent(chosen) || !(chosen in posts_sharing_corner()))
		return null
	return chosen

// yee haw
/obj/structure/slime_pen_post/proc/find_partner(turf/from, direction, wanted_dir) as /obj/structure/slime_pen_post
	var/turf/scan = from
	for(var/step in 1 to SLIME_PEN_MAX_SIZE)
		for(var/obj/structure/slime_pen_post/post in scan)
			if(post != src && post.dir == wanted_dir && post.anchored && isnull(post.pen))
				return post
		scan = get_step(scan, direction)
		if(isnull(scan))
			return null
	return null

/// The one bit of this whole feature that assumes pens are rectangles. Returns the four posts, or null.
/obj/structure/slime_pen_post/proc/find_rectangle_layout() as /list
	var/turf/here = get_turf(src)
	if(isnull(here))
		return null
	var/inward_x = (dir & EAST) ? WEST : EAST
	var/inward_y = (dir & NORTH) ? SOUTH : NORTH
	var/obj/structure/slime_pen_post/across = find_partner(here, inward_x, (dir & (NORTH|SOUTH)) | inward_x)
	var/obj/structure/slime_pen_post/down = find_partner(here, inward_y, (dir & (EAST|WEST)) | inward_y)
	if(isnull(across) || isnull(down))
		return null
	var/turf/far = locate(across.x, down.y, here.z)
	if(isnull(far))
		return null
	for(var/obj/structure/slime_pen_post/post in far)
		if(post.dir == (inward_x | inward_y) && post.anchored && isnull(post.pen))
			return list(src, across, down, post)
	return null

/// Tells the user why there's no good post in one direction
/obj/structure/slime_pen_post/proc/report_partner_problem(mob/user, turf/from, direction, wanted_dir, position)
	var/saw_post = FALSE
	var/turf/scan = from
	for(var/step in 1 to SLIME_PEN_MAX_SIZE)
		for(var/obj/structure/slime_pen_post/post in scan)
			if(post == src)
				continue
			saw_post = TRUE
			if(post.dir != wanted_dir)
				continue
			if(!post.anchored)
				balloon_alert(user, "[position] post isn't bolted!")
				return
			if(post.pen)
				balloon_alert(user, "[position] post already linked!")
				return
		scan = get_step(scan, direction)
		if(isnull(scan))
			break
	if(saw_post)
		balloon_alert(user, "[position] post must face [dir2text(wanted_dir)]!")
	else
		balloon_alert(user, "need a [dir2text(wanted_dir)] post [position]!")

/// Tells the user which of the other three posts is messing things up
/obj/structure/slime_pen_post/proc/report_layout_problem(mob/user)
	var/turf/here = get_turf(src)
	if(isnull(here))
		return
	var/inward_x = (dir & EAST) ? WEST : EAST
	var/inward_y = (dir & NORTH) ? SOUTH : NORTH
	var/across_dir = (dir & (NORTH|SOUTH)) | inward_x
	var/down_dir = (dir & (EAST|WEST)) | inward_y
	var/obj/structure/slime_pen_post/across = find_partner(here, inward_x, across_dir)
	if(isnull(across))
		report_partner_problem(user, here, inward_x, across_dir, "[dir2text(inward_x)]-side")
		return
	var/obj/structure/slime_pen_post/down = find_partner(here, inward_y, down_dir)
	if(isnull(down))
		report_partner_problem(user, here, inward_y, down_dir, "[dir2text(inward_y)]-side")
		return
	var/turf/far = locate(across.x, down.y, here.z)
	var/far_dir = inward_x | inward_y
	var/saw_post = FALSE
	for(var/obj/structure/slime_pen_post/post in far)
		saw_post = TRUE
		if(post.dir != far_dir)
			continue
		if(!post.anchored)
			balloon_alert(user, "far post isn't bolted!")
			return
		if(post.pen)
			balloon_alert(user, "far post already linked!")
			return
	if(saw_post)
		balloon_alert(user, "far post must face [dir2text(far_dir)]!")
	else
		balloon_alert(user, "need a [dir2text(far_dir)] far post!")

/// Makes a /datum/slime_pen out of the four posts, if they make a rectangle with nothing in the way
/obj/structure/slime_pen_post/proc/try_link(mob/user)
	if(!anchored)
		balloon_alert(user, "bolt it down first!")
		return FALSE
	if(pen)
		return FALSE
	var/list/posts = find_rectangle_layout()
	if(isnull(posts))
		report_layout_problem(user)
		return FALSE
	var/list/xs = list()
	var/list/ys = list()
	for(var/obj/structure/slime_pen_post/post as anything in posts)
		xs += post.x
		ys += post.y
	var/list/interior = block(locate(min(xs), min(ys), z), locate(max(xs), max(ys), z))
	for(var/turf/spot as anything in interior)
		if(spot.density)
			balloon_alert(user, "something's in the way!")
			return FALSE
		for(var/datum/slime_pen/other as anything in GLOB.slime_pens)
			if(spot in other.turfs)
				balloon_alert(user, "overlaps another pen!")
				return FALSE
	new /datum/slime_pen(interior, posts)
	return TRUE

/obj/structure/slime_pen_post/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(pen))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimePen", "Slime Pen")
		ui.open()

/obj/structure/slime_pen_post/ui_data(mob/user)
	return pen?.ui_data(user)

/obj/structure/slime_pen_post/ui_static_data(mob/user)
	return pen?.ui_static_data(user)

/obj/structure/slime_pen_post/ui_act(action, list/params)
	. = ..()
	if(. || isnull(pen))
		return TRUE
	switch(action)
		if("set_color")
			pen.set_barrier_color(sanitize_hexcolor(params["color"], default = SLIME_PEN_DEFAULT_COLOR))
			return TRUE

// for mappers
/obj/structure/slime_pen_post/premade
	anchored = TRUE
	icon_state = MAP_SWITCH("corner", "corner_map")

/obj/structure/slime_pen_post/premade/Initialize(mapload)
	. = ..()
	QDEL_NULL(anchor)
	QDEL_NULL(guide)
	if(!ISDIAGONALDIR(dir))
		log_mapping("mapped slime pen post at [AREACOORD(src)] faces [dir2text(dir)], which isn't a corner")
		CRASH("mapped slime pen post at [AREACOORD(src)] faces [dir2text(dir)], which isn't a corner")
	return INITIALIZE_HINT_LATELOAD

/obj/structure/slime_pen_post/premade/LateInitialize()
	if(isnull(pen))
		try_link()

/// Clickable plate on the post's tile, bc the post's sprite is way out on the corner
/obj/structure/slime_pen_anchor
	name = "slime pen tile plate"
	desc = "This plate marks the tile owned by its corner post."
	icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi'
	icon_state = "post_anchor"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The exact post this plate controls.
	var/obj/structure/slime_pen_post/post

/obj/structure/slime_pen_anchor/Initialize(mapload, obj/structure/slime_pen_post/post)
	. = ..()
	if(isnull(post))
		return INITIALIZE_HINT_QDEL
	src.post = post
	setDir(post.dir)

/obj/structure/slime_pen_anchor/Destroy(force)
	post = null
	return ..()

/obj/structure/slime_pen_anchor/examine(mob/user)
	. = ..()
	if(post)
		. += post.examine(user)

/obj/structure/slime_pen_anchor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || QDELETED(post) || !user.Adjacent(src))
		return
	post.use_post(user)
	return TRUE

/obj/structure/slime_pen_anchor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!QDELETED(post) && user.Adjacent(src))
		post.choose_corner(user, src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/slime_pen_anchor/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(QDELETED(post) || !user.Adjacent(src))
		return ITEM_INTERACT_BLOCKING
	return post.wrench_post(user, tool) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/structure/slime_pen_anchor/multitool_act(mob/living/user, obj/item/tool)
	if(QDELETED(post) || !user.Adjacent(src))
		return ITEM_INTERACT_BLOCKING
	post.toggle_construction_markers(user)
	return ITEM_INTERACT_SUCCESS

/// Dotted preview of where the fence will go
/obj/effect/slime_pen_guide
	icon = 'icons/obj/xenobiology/slime_rancher/slime_pen.dmi'
	icon_state = "post_marker"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The post whose construction state this preview follows.
	var/obj/structure/slime_pen_post/post

/obj/effect/slime_pen_guide/Initialize(mapload, obj/structure/slime_pen_post/post)
	. = ..()
	if(isnull(post))
		return INITIALIZE_HINT_QDEL
	src.post = post
	setDir(post.dir)
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/slime_pen_guide/Destroy(force)
	post = null
	return ..()

/obj/effect/slime_pen_guide/update_overlays()
	. = ..()
	if(!post?.pen)
		var/mutable_appearance/fence_preview = mutable_appearance(icon, "post_guide")
		fence_preview.dir = dir
		. += fence_preview

/// Map this on top of a premade post to set its fence color
/obj/effect/mapping_helpers/slime_pen_color
	desc = "You shouldn't see this. Report it please."
	layer = ABOVE_OBJ_LAYER

/obj/effect/mapping_helpers/slime_pen_color/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_mapping("[src] spawned outside of mapload!")
	if(!color)
		log_mapping("[src] doesn't have a color set!")
	var/obj/structure/slime_pen_post/premade/post = locate() in loc
	if(post)
		post.barrier_color = color
	else
		log_mapping("[src] needs to be mapped in on top of a pen!")
	return INITIALIZE_HINT_QDEL

/obj/effect/mapping_helpers/slime_pen_color/green
	name = "slime pen color helper (green)"
	color = "#9FED58"

/obj/effect/mapping_helpers/slime_pen_color/blue
	name = "slime pen color helper (blue)"
	color = "#52B4E9"

/obj/effect/mapping_helpers/slime_pen_color/purple
	name = "slime pen color helper (purple)"
	color = "#D381C9"

#undef SLIME_PEN_MAX_SIZE
#undef SLIME_PEN_DEPLOY_TIME
