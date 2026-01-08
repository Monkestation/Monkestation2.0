/*
 * False Walls
 */
/obj/structure/falsewall
	anchored = TRUE
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	layer = LOW_OBJ_LAYER
	density = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS
	can_be_unanchored = FALSE
	///This variable is used to preserve real_wall if the false wall is deleted via being bolted down instead of actually destroyed.
	var/bolting_back_down = FALSE
	var/mineral = /obj/item/stack/sheet/iron
	var/mineral_amount = 2
	var/walltype = /turf/closed/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE
	var/turf/real_wall

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	var/obj/item/stack/initialized_mineral = new mineral // Okay this kinda sucks.
	set_custom_materials(initialized_mineral.mats_per_unit, mineral_amount)
	qdel(initialized_mineral)
	air_update_turf(TRUE, TRUE)
	place_real_wall()
	desc = real_wall.desc
	name = real_wall.name
	max_integrity = real_wall.max_integrity
	icon = real_wall.icon
	icon_state = real_wall.icon_state
	base_icon_state = real_wall.base_icon_state
	smoothing_flags = real_wall.smoothing_flags
	smoothing_groups = real_wall.smoothing_groups.Copy()
	canSmoothWith = real_wall.canSmoothWith.Copy()
	resistance_flags = real_wall.resistance_flags

/obj/structure/falsewall/Destroy()
	if(!QDELETED(real_wall) && !bolting_back_down)
		real_wall.ScrapeAway()
		var/turf/underneath = get_turf(src)
		if(!isfloorturf(underneath)) //These can only be built on floors anyway, but the linter screams at me because space is left behind when they are forcibly deleted under some arcane conditions I can't replicate.
			underneath.PlaceOnTop(/turf/open/floor/plating)
	real_wall = null
	return ..()

/obj/structure/falsewall/attack_hand(mob/user, list/modifiers)
	if(opening)
		return
	. = ..()
	if(.)
		return

	opening = TRUE
	update_appearance()
	if(!density)
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
	else
		real_wall.ScrapeAway() //Remove the real wall when we start to open
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/falsewall, toggle_open)), 0.5 SECONDS)

/obj/structure/falsewall/proc/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		opening = FALSE
		update_appearance()
		if(density)
			place_real_wall()

/obj/structure/falsewall/proc/place_real_wall()
	var/turf/our_turf = get_turf(src) //Get the turf the false wall is on and temporarily store it
	real_wall = our_turf.PlaceOnTop(walltype) //Place the real wall where the false wall is

/obj/structure/falsewall/update_icon(updates=ALL)//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	. = ..()
	if(!density || !(updates & UPDATE_SMOOTHING))
		return

	if(opening)
		smoothing_flags = NONE
		clear_smooth_overlays()
	else
		smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
		QUEUE_SMOOTH(src)

/obj/structure/falsewall/update_icon_state()
	if(opening)
		icon_state = "fwall_[density ? "opening" : "closing"]"
		return ..()
	icon_state = density ? "[base_icon_state]-[smoothing_junction]" : "fwall_open"
	return ..()

/obj/structure/falsewall/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(opening)
		to_chat(user, span_warning("You must wait until the door has stopped moving!"))
	else if(!density)
		to_chat(user, span_warning("You can't reach, close it first!"))
	else
		return ..()
	return ITEM_INTERACT_SUCCESS

/obj/structure/falsewall/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	user.visible_message(span_notice("[user] tightens some bolts on the wall."), span_notice("You tighten the bolts on the wall."))
	bolting_back_down = TRUE
	qdel(src)
	return ITEM_INTERACT_SUCCESS


/obj/structure/falsewall/welder_act(mob/living/user, obj/item/tool)
	if(tool.use_tool(src, user, 0 SECONDS, volume=50))
		dismantle(user, TRUE)
		return ITEM_INTERACT_SUCCESS
	return

/obj/structure/falsewall/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!opening)
		return ..()
	to_chat(user, span_warning("You must wait until the door has stopped moving!"))
	return

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled=TRUE, obj/item/tool = null)
	user.visible_message(span_notice("[user] dismantles the false wall."), span_notice("You dismantle the false wall."))
	if(tool)
		tool.play_tool_sound(src, 100)
	else
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/obj/structure/falsewall/get_dumping_location()
	return null

/obj/structure/falsewall/examine_status(mob/user) //So you can't detect falsewalls by examine.
	to_chat(user, span_notice("The outer plating is <b>welded</b> firmly in place."))
	return null

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	walltype = /turf/closed/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel
	smoothing_flags = SMOOTH_BITMASK

/obj/structure/falsewall/reinforced/examine_status(mob/user)
	to_chat(user, span_notice("The outer <b>grille</b> is fully intact."))
	return null

/obj/structure/falsewall/reinforced/attackby(obj/item/tool, mob/user)
	..()
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		dismantle(user, TRUE, tool)

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/closed/wall/mineral/uranium

	/// Mutex to prevent infinite recursion when propagating radiation pulses
	var/active = null

	/// The last time a radiation pulse was performed
	var/last_event = 0

/obj/structure/falsewall/uranium/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PROPAGATE_RAD_PULSE, PROC_REF(radiate))

/obj/structure/falsewall/uranium/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/proc/radiate()
	SIGNAL_HANDLER
	if(active)
		return
	if(world.time <= last_event + 1.5 SECONDS)
		return
	active = TRUE
	radiation_pulse(
		src,
		max_range = 3,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)
	propagate_radiation_pulse()
	last_event = world.time
	active = FALSE
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/closed/wall/mineral/gold

/obj/structure/falsewall/silver
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/closed/wall/mineral/silver

/obj/structure/falsewall/diamond
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/closed/wall/mineral/diamond

/obj/structure/falsewall/plasma
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/closed/wall/mineral/plasma

/obj/structure/falsewall/bananium
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/closed/wall/mineral/bananium


/obj/structure/falsewall/sandstone
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/sandstone

/obj/structure/falsewall/wood
	mineral = /obj/item/stack/sheet/mineral/wood
	walltype = /turf/closed/wall/mineral/wood

/obj/structure/falsewall/bamboo
	mineral = /obj/item/stack/sheet/mineral/bamboo
	walltype = /turf/closed/wall/mineral/bamboo

/obj/structure/falsewall/iron
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/closed/wall/mineral/iron

/obj/structure/falsewall/abductor
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/closed/wall/mineral/abductor

/obj/structure/falsewall/titanium
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/closed/wall/mineral/titanium

/obj/structure/falsewall/plastitanium
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/closed/wall/mineral/plastitanium

/obj/structure/falsewall/material
	walltype = /turf/closed/wall/material
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/falsewall/material/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		for(var/material in custom_materials)
			var/datum/material/material_datum = material
			new material_datum.sheet_type(loc, FLOOR(custom_materials[material_datum] / SHEET_MATERIAL_AMOUNT, 1))
	qdel(src)

/obj/structure/falsewall/material/mat_update_desc(mat)
	desc = "A huge chunk of [mat] used to separate rooms."

/obj/structure/falsewall/material/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		var/mat_opacity = TRUE
		for(var/datum/material/mat in custom_materials)
			if(mat.alpha < 255)
				mat_opacity = FALSE
				break
		set_opacity(density && mat_opacity)
		opening = FALSE
		update_appearance()
		if(density)
			place_real_wall()

/obj/structure/falsewall/material/place_real_wall()
	var/turf/our_turf = get_turf(src) //Get the turf the false wall is on and temporarily store it
	real_wall = our_turf.PlaceOnTop(walltype) //Place the real wall where the false wall is
	real_wall.set_custom_materials(custom_materials)

/obj/structure/falsewall/material/set_custom_materials(list/materials, multiplier)
	. = ..()
	real_wall?.set_custom_materials(custom_materials)

/obj/structure/falsewall/material/update_icon(updates)
	. = ..()
	for(var/datum/material/mat in custom_materials)
		if(mat.alpha < 255)
			update_transparency_underlays()
			return

/obj/structure/falsewall/material/proc/update_transparency_underlays()
	underlays.Cut()
	var/girder_icon_state = "displaced"
	if(opening)
		girder_icon_state += "_[density ? "opening" : "closing"]"
	else if(!density)
		girder_icon_state += "_open"
	var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', girder_icon_state, layer = LOW_OBJ_LAYER-0.01)
	girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
	underlays += girder_underlay
