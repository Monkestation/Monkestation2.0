/// Orbit radius in pixels. The ring grows past this if the weapons don't fit.
#define STARBORNE_ORBIT_RADIUS 20
/// How long one lap takes.
#define STARBORNE_ORBIT_TIME (4 SECONDS)
/// How many straight lines make up a lap.
#define STARBORNE_ORBIT_SEGMENTS 36
/// How long a thrown weapon sits where it landed before heading back.
#define STARBORNE_RETURN_DELAY (0.3 SECONDS)
/// How long weapons take to glide into place when the ring changes, flight back included.
#define STARBORNE_RETURN_TIME (0.5 SECONDS)
/// How many straight lines make up that glide.
#define STARBORNE_RETURN_STEPS 5
/// Where the first weapon on every ring is at a given REALTIMEOFDAY, in degrees clockwise from the top.
/// Real time and not world.time, bc animations play on the client and don't care if the server lags.
#define STARBORNE_CLOCK(time) (360 * MODULUS((time), STARBORNE_ORBIT_TIME) / STARBORNE_ORBIT_TIME)
/// How long a thrown weapon stays stuck in someone before tearing itself out.
#define STARBORNE_EMBED_TIME (2 SECONDS)

/// Makes a weapon circle whoever dropped or threw it. Like a heretic knife, but you can grab it.
/datum/element/starborne

/datum/element/starborne/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/weapon = target
	weapon.name = "starborne [weapon.name]"
	// visual jank yayyy
	var/mutable_appearance/stars = mutable_appearance('icons/obj/xenobiology/slime_rancher/visual_effects.dmi', "spacey")
	stars.blend_mode = BLEND_INSET_OVERLAY
	ADD_KEEP_TOGETHER(weapon, ELEMENT_TRAIT(type))
	weapon.add_overlay(stars)
	ADD_TRAIT(weapon, TRAIT_STARBORNE, ELEMENT_TRAIT(type))
	RegisterSignal(weapon, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(weapon, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(on_throw_landed))
	RegisterSignal(weapon, COMSIG_ITEM_GET_WORN_OVERLAYS, PROC_REF(on_worn_overlays))
	RegisterSignal(weapon, COMSIG_MOVABLE_STOPPED_ORBITING, PROC_REF(on_orbit_stop))
	weapon.update_slot_icon()

/datum/element/starborne/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_STARBORNE, ELEMENT_TRAIT(type))
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_THROW_LANDED, COMSIG_ITEM_GET_WORN_OVERLAYS, COMSIG_MOVABLE_STOPPED_ORBITING))
	return ..()

/// Draws the stars over the worn sprite.
/datum/element/starborne/proc/on_worn_overlays(obj/item/source, list/overlays, mutable_appearance/standing, isinhands)
	SIGNAL_HANDLER
	// stretching code shit copied from brimdust coatings
	var/sprite_width = isinhands ? source.inhand_x_dimension : source.worn_x_dimension
	var/sprite_height = isinhands ? source.inhand_y_dimension : source.worn_y_dimension
	var/mutable_appearance/stars
	if(sprite_width == ICON_SIZE_X && sprite_height == ICON_SIZE_Y)
		stars = mutable_appearance('icons/obj/xenobiology/slime_rancher/visual_effects.dmi', "spacey")
	else
		var/static/alist/tiled_stars = alist()
		var/icon/stars_icon = tiled_stars["[sprite_width]-[sprite_height]"]
		if(isnull(stars_icon))
			var/icon/tile = icon('icons/obj/xenobiology/slime_rancher/visual_effects.dmi', "spacey")
			stars_icon = icon('icons/obj/xenobiology/slime_rancher/visual_effects.dmi', "spacey")
			stars_icon.Crop(1, 1, sprite_width, sprite_height)
			for(var/column in 0 to ceil(sprite_width / ICON_SIZE_X) - 1)
				for(var/row in 0 to ceil(sprite_height / ICON_SIZE_Y) - 1)
					stars_icon.Blend(tile, ICON_OVERLAY, 1 + column * ICON_SIZE_X, 1 + row * ICON_SIZE_Y)
			tiled_stars["[sprite_width]-[sprite_height]"] = stars_icon
		stars = mutable_appearance(stars_icon)
	stars.blend_mode = BLEND_INSET_OVERLAY
	standing.appearance_flags |= KEEP_TOGETHER
	overlays += stars

/// Orbits whoever dropped it, unless it was thrown.
/datum/element/starborne/proc/on_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	// a throw drops the item first and only flies after, so wait a tick to tell them apart
	addtimer(CALLBACK(src, PROC_REF(orbit_dropper), source, user), 0)

/datum/element/starborne/proc/orbit_dropper(obj/item/weapon, mob/dropper)
	if(QDELETED(weapon) || QDELETED(dropper) || weapon.throwing)
		return
	if(!isturf(weapon.loc) || weapon.loc != dropper.loc)
		return
	start_orbit(weapon, dropper)

/// Starts weapon circling center, gliding in from (landing_x, landing_y) pixels away.
/datum/element/starborne/proc/start_orbit(obj/item/weapon, mob/center, landing_x = 0, landing_y = 0)
	if(!weapon.orbit(center, radius = 0, pre_rotation = FALSE))
		return
	var/list/icon_dimensions = get_icon_dimensions(weapon.icon)
	weapon.pixel_x = (ICON_SIZE_X - icon_dimensions["width"]) / 2
	weapon.pixel_y = (ICON_SIZE_Y - icon_dimensions["height"]) / 2
	weapon.plane = center.plane
	arrange(center, joining = weapon, landing_x = landing_x, landing_y = landing_y)

/// Puts the weapon back to normal and closes the gap it left.
/datum/element/starborne/proc/on_orbit_stop(obj/item/source, atom/center)
	SIGNAL_HANDLER
	source.layer = initial(source.layer)
	SET_PLANE_IMPLICIT(source, initial(source.plane))
	source.pixel_x = source.base_pixel_x
	source.pixel_y = source.base_pixel_y
	arrange(center, leaving = source)

/**
 * Lays out one ring for every starborne weapon circling center, minus skipped.
 * Wider sprites get a bigger slice.
 *
 * Returns alist("radius" = pixels, "angles" = list(weapon = degrees clockwise from the first weapon)).
 */
/datum/element/starborne/proc/ring_layout(atom/center, obj/item/skipped) as /alist
	var/list/arcs = list()
	var/total_arc = 0
	for(var/obj/item/weapon in center.orbiters?.orbiter_list)
		if(weapon == skipped || !HAS_TRAIT(weapon, TRAIT_STARBORNE))
			continue
		var/arc = get_icon_state_visible_bounds(weapon.icon, weapon.icon_state)["width"] + 4
		arcs[weapon] = arc
		total_arc += arc

	var/list/angles = list()
	var/angle = 0
	var/previous_arc
	for(var/obj/item/weapon as anything in arcs)
		var/arc = arcs[weapon]
		if(!isnull(previous_arc))
			angle += 180 * (previous_arc + arc) / total_arc
		angles[weapon] = angle
		previous_arc = arc
	return alist("radius" = max(STARBORNE_ORBIT_RADIUS, total_arc / (2 * PI)), "angles" = angles)

/// The transform that puts the visible middle of weapon (x, y) pixels from its tile's middle, turned by rotation.
/datum/element/starborne/proc/pose(obj/item/weapon, matrix/base, rotation, x, y)
	var/alist/bounds = get_icon_state_visible_bounds(weapon.icon, weapon.icon_state)
	var/matrix/posed = matrix(base)
	posed.Translate(-bounds["x"], -bounds["y"])
	posed.Turn(rotation)
	posed.Translate(x, y)
	return posed

/**
 * Glides every starborne weapon circling center into place on the ring, then gets them orbiting.
 *
 * * joining - a weapon that just showed up, coming in from (landing_x, landing_y) pixels away
 * * leaving - a weapon that's about to stop circling
 */
/datum/element/starborne/proc/arrange(atom/center, obj/item/joining, obj/item/leaving, landing_x = 0, landing_y = 0)
	var/alist/old_ring = ring_layout(center, joining)
	var/alist/new_ring = ring_layout(center, leaving)
	var/list/old_angles = old_ring["angles"]
	var/list/new_angles = new_ring["angles"]
	if(!length(new_angles))
		return
	var/old_radius = old_ring["radius"]
	var/new_radius = new_ring["radius"]
	var/end_clock = STARBORNE_CLOCK(REALTIMEOFDAY + STARBORNE_RETURN_TIME)
	var/step_time = STARBORNE_RETURN_TIME / STARBORNE_RETURN_STEPS
	for(var/obj/item/weapon as anything in new_angles)
		var/matrix/base = center.orbiters.orbiter_list[weapon]
		var/end_angle = MODULUS(end_clock + new_angles[weapon] + 180, 360) - 180
		var/slide = weapon == joining ? 0 : MODULUS(new_angles[weapon] - old_angles[weapon] + 180, 360) - 180
		var/animating = FALSE
		if(weapon == joining && (landing_x || landing_y))
			animate(weapon, transform = pose(weapon, base, 0, landing_x, landing_y), time = 0)
			animating = TRUE
		for(var/step in 1 to STARBORNE_RETURN_STEPS)
			var/progress = step / STARBORNE_RETURN_STEPS
			// flat at both ends, so nothing lurches at the start and everything's already at orbit speed by the end
			var/weight = progress * progress * (3 - 2 * progress)
			var/slot_angle = end_angle - (1 - progress) * 360 * STARBORNE_RETURN_TIME / STARBORNE_ORBIT_TIME
			var/rotation
			var/x
			var/y
			if(weapon == joining)
				rotation = slot_angle * weight
				x = landing_x + (sin(slot_angle) * new_radius - landing_x) * weight
				y = landing_y + (cos(slot_angle) * new_radius - landing_y) * weight
			else
				var/radius = old_radius + (new_radius - old_radius) * weight
				rotation = slot_angle - slide * (1 - weight)
				x = sin(rotation) * radius
				y = cos(rotation) * radius
			var/matrix/step_transform = pose(weapon, base, rotation, x, y)
			var/step_layer = y < 0 ? ABOVE_MOB_LAYER : initial(weapon.layer)
			if(animating)
				animate(transform = step_transform, layer = step_layer, time = step_time)
			else
				animate(weapon, transform = step_transform, layer = step_layer, time = step_time)
				animating = TRUE
	// unique timers compare their args as text, and a weapon as text is just its name. two rings led by a "starborne kitchen knife" would fight over one timer lmao
	addtimer(CALLBACK(src, PROC_REF(spin_ring), REF(new_angles[1])), STARBORNE_RETURN_TIME, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_CLIENT_TIME)

/// Gets the whole ring of the weapon with this ref orbiting for good, starting wherever the clock says they are.
/datum/element/starborne/proc/spin_ring(weapon_ref)
	var/obj/item/weapon = locate(weapon_ref)
	if(!istype(weapon))
		return
	// the weapons might've been handed to a new body mid-glide, so ask the weapon who it's circling
	var/atom/center = weapon.orbiting?.parent
	if(isnull(center))
		return
	var/alist/ring = ring_layout(center)
	var/radius = ring["radius"]
	var/list/angles = ring["angles"]
	var/clock = STARBORNE_CLOCK(REALTIMEOFDAY)
	var/segment_time = STARBORNE_ORBIT_TIME / STARBORNE_ORBIT_SEGMENTS
	for(var/obj/item/orbiter as anything in angles)
		var/matrix/base = center.orbiters.orbiter_list[orbiter]
		for(var/segment in 1 to STARBORNE_ORBIT_SEGMENTS)
			var/angle = clock + angles[orbiter] + segment * 360 / STARBORNE_ORBIT_SEGMENTS
			var/y = cos(angle) * radius
			var/matrix/segment_transform = pose(orbiter, base, angle, sin(angle) * radius, y)
			var/segment_layer = y < 0 ? ABOVE_MOB_LAYER : initial(orbiter.layer)
			if(segment == 1)
				animate(orbiter, transform = segment_transform, layer = segment_layer, time = segment_time, loop = -1)
			else
				animate(transform = segment_transform, layer = segment_layer, time = segment_time)

/// Sends the weapon back to the thrower, or tears it out if it's embedded.
/datum/element/starborne/proc/on_throw_landed(obj/item/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER
	var/mob/thrower = throwing_datum.thrower
	if(QDELETED(thrower))
		return
	if(source.get_embed()?.owner)
		addtimer(CALLBACK(src, PROC_REF(tear_free), source, thrower), STARBORNE_EMBED_TIME)
		return
	if(!isturf(source.loc))
		return
	addtimer(CALLBACK(src, PROC_REF(fly_back), source, thrower), STARBORNE_RETURN_DELAY)

/// Rips the weapon out of whoever it's stuck in, then flies back.
/datum/element/starborne/proc/tear_free(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon) || QDELETED(thrower))
		return
	var/datum/embedding/embed = weapon.get_embed()
	if(embed?.owner)
		embed.owner.visible_message(
			span_danger("[weapon] tears itself free from [embed.owner]'s [embed.owner_limb.plaintext_zone]!"),
			span_userdanger("[weapon] tears itself free from your [embed.owner_limb.plaintext_zone]!"),
		)
		if(!embed.is_harmless())
			embed.damaging_removal_effect(1)
		// the damage can take the whole limb off, and a severed limb already spits the weapon out
		if(embed.owner)
			embed.remove_embedding()
	fly_back(weapon, thrower)

/// Glides the weapon from where it landed into orbit around the thrower.
/datum/element/starborne/proc/fly_back(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon) || QDELETED(thrower) || weapon.throwing || weapon.orbiting || !isturf(weapon.loc))
		return
	var/turf/landed = weapon.loc
	var/turf/destination = get_turf(thrower)
	if(isnull(destination))
		return
	// the weapon actually teleports right away, the trip back is all animation
	start_orbit(weapon, thrower, (landed.x - destination.x) * ICON_SIZE_X, (landed.y - destination.y) * ICON_SIZE_Y)

#undef STARBORNE_ORBIT_RADIUS
#undef STARBORNE_ORBIT_TIME
#undef STARBORNE_ORBIT_SEGMENTS
#undef STARBORNE_RETURN_DELAY
#undef STARBORNE_RETURN_TIME
#undef STARBORNE_RETURN_STEPS
#undef STARBORNE_CLOCK
#undef STARBORNE_EMBED_TIME
