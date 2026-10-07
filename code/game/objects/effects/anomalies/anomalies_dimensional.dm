
/obj/effect/anomaly/dimensional
	name = "dimensional anomaly"
	icon_state = "dimensional"
	anomaly_core = /obj/item/assembly/signaler/anomaly/dimensional
	immortal = TRUE
	immobile = TRUE
	/// Range of effect, if left alone anomaly will convert a 2(range)+1 squared area.
	var/range = 3
	/// List of turfs this anomaly will try to transform before relocating
	var/list/turf/target_turfs = new()
	/// Current anomaly 'theme', dictates what tiles to create.
	var/datum/dimension_theme/theme
	/// Effect displaying on the anomaly to represent the theme.
	var/mutable_appearance/theme_icon
	/// How many remaining times this anomaly will relocate, before its detonation.
	var/relocations_left

/obj/effect/anomaly/dimensional/Initialize(mapload, new_lifespan)
	. = ..()
	if(!isnum(relocations_left))
		relocations_left = rand(3, 5)

	add_overlay(mutable_appearance('icons/effects/effects.dmi', "dimensional_overlay"))

	animate(src, transform = matrix()*0.85, time = 3, loop = -1)
	animate(transform = matrix(), time = 3, loop = -1)

/obj/effect/anomaly/dimensional/anomalyEffect(seconds_per_tick)
	. = ..()
	transmute_area()

/obj/effect/anomaly/dimensional/detonate()
	. = ..()
	if(!theme)
		return
	visible_message(span_bolddanger("[src] explodes, distorting the space around it in surreal ways!"))
	var/detonate_range = range + rand(5, 7)
	var/list/turf/target_turfs = spiral_range_turfs(detonate_range, src)
	for(var/turf/target in target_turfs)
		if(prob(15) || QDELING(target)) // the prob is so it looks more erratic
			continue
		theme.apply_theme(target)

/**
 * Transforms a turf in our prepared area.
 */
/obj/effect/anomaly/dimensional/proc/transmute_area()
	if (!theme)
		prepare_area()
	if (!target_turfs.len)
		relocate()
		return

	var/turf/affected_turf = target_turfs[1]
	new /obj/effect/temp_visual/transmute_tile_flash(affected_turf)
	theme.apply_theme(affected_turf)
	target_turfs.Remove(affected_turf)

/**
 * Prepare a new area for transformation into a new theme.
 * Optionally pass in the typepath of an anomaly theme to use that one.
 */
/obj/effect/anomaly/dimensional/proc/prepare_area(new_theme_path)
	if (!new_theme_path)
		new_theme_path = pick(subtypesof(/datum/dimension_theme))
	theme = new new_theme_path()
	apply_theme_icon()

	target_turfs = new()
	var/list/turfs = spiral_range_turfs(range, src)
	for (var/turf/turf in turfs)
		if (theme.can_convert(turf))
			target_turfs.Add(turf)

/**
 * Applies an overlay icon based on the current theme.
 */
/obj/effect/anomaly/dimensional/proc/apply_theme_icon()
	overlays -= theme_icon
	theme_icon = mutable_appearance(theme.icon, theme.icon_state, FLOAT_LAYER - 1, appearance_flags = appearance_flags | RESET_TRANSFORM)
	theme_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays += theme_icon

/**
 * Moves the anomaly somewhere else and announces it.
 */
/obj/effect/anomaly/dimensional/proc/relocate()
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)

	priority_announce("Dimensional instability relocated. Expected location: [new_area.name].", "Anomaly Alert")
	forceMove(new_turf)
	prepare_area()

	relocations_left--

	if(relocations_left <= 0)
		detonate()
		qdel(src)

/obj/effect/temp_visual/transmute_tile_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 3
