/// How far the weapon orbits from its owner, in pixels.
#define STARBORNE_ORBIT_RADIUS 20
/// How long one lap around the owner takes.
#define STARBORNE_ORBIT_TIME (4 SECONDS)
/// How long a thrown weapon sits where it landed before it heads back.
#define STARBORNE_RETURN_DELAY (0.3 SECONDS)
/// How long the glide back to the thrower takes.
#define STARBORNE_RETURN_TIME (0.5 SECONDS)
/// How long a thrown weapon stays embedded in someone before it tears itself out.
#define STARBORNE_EMBED_TIME (2 SECONDS)

/// A weapon with this circles whoever dropped or threw it, similar to a heretic knife but you can grab it.
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
	weapon.update_slot_icon()

/datum/element/starborne/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_STARBORNE, ELEMENT_TRAIT(type))
	UnregisterSignal(source, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_THROW_LANDED, COMSIG_ITEM_GET_WORN_OVERLAYS))
	return ..()

/// Draws the star pattern over the worn sprite.
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
	// a throw drops the item first and only starts flying after. wait a tick so we can tell the two apart
	addtimer(CALLBACK(src, PROC_REF(orbit_dropper), source, user), 0)

/datum/element/starborne/proc/orbit_dropper(obj/item/weapon, mob/dropper)
	if(QDELETED(weapon) || QDELETED(dropper) || weapon.throwing)
		return
	if(!isturf(weapon.loc) || weapon.loc != dropper.loc)
		return
	start_orbit(weapon, dropper)

/// Circles center, passing behind and in front of them.
/datum/element/starborne/proc/start_orbit(obj/item/weapon, mob/center)
	if(!weapon.orbit(center, radius = STARBORNE_ORBIT_RADIUS, clockwise = TRUE, rotation_speed = STARBORNE_ORBIT_TIME, pre_rotation = FALSE))
		return
	// layering stuff so like it actually goes behind and in front of the mob based on the orbit. probably. hopefully.
	var/behind_layer = weapon.layer
	animate(weapon, layer = ABOVE_MOB_LAYER, time = STARBORNE_ORBIT_TIME / 4, easing = JUMP_EASING, loop = -1, flags = ANIMATION_PARALLEL)
	animate(layer = behind_layer, time = STARBORNE_ORBIT_TIME / 2, easing = JUMP_EASING)
	animate(layer = behind_layer, time = STARBORNE_ORBIT_TIME / 4)

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

/// Glides the weapon from where it landed to the thrower.
/datum/element/starborne/proc/fly_back(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon) || QDELETED(thrower) || weapon.throwing || weapon.orbiting || !isturf(weapon.loc))
		return
	var/turf/landed = weapon.loc
	var/turf/destination = get_turf(thrower)
	if(isnull(destination))
		return
	// the weapon really teleports right now, the trip back is nothing but pixel offsets
	weapon.abstract_move(destination)
	weapon.pixel_w = (landed.x - destination.x) * ICON_SIZE_X
	weapon.pixel_z = (landed.y - destination.y) * ICON_SIZE_Y
	animate(weapon, pixel_w = 0, pixel_z = STARBORNE_ORBIT_RADIUS, time = STARBORNE_RETURN_TIME, easing = CUBIC_EASING|EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(finish_return), weapon, thrower), STARBORNE_RETURN_TIME)

/// Starts orbiting the thrower again once the glide is over.
/datum/element/starborne/proc/finish_return(obj/item/weapon, mob/thrower)
	if(QDELETED(weapon))
		return
	weapon.pixel_z = 0
	if(QDELETED(thrower) || weapon.throwing || !isturf(weapon.loc))
		return
	start_orbit(weapon, thrower)

#undef STARBORNE_ORBIT_RADIUS
#undef STARBORNE_ORBIT_TIME
#undef STARBORNE_RETURN_DELAY
#undef STARBORNE_RETURN_TIME
#undef STARBORNE_EMBED_TIME
