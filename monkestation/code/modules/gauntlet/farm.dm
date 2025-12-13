GLOBAL_LIST_EMPTY(thanos_start)
GLOBAL_LIST_EMPTY(thanos_portal)

/area/centcom/thanos_farm
	name = "The Garden"
	icon = 'monkestation/icons/area/areas_centcom.dmi'
	icon_state = "thanos_garden"
	requires_power = FALSE
	area_flags = NOTELEPORT
	has_gravity = STANDARD_GRAVITY

/obj/effect/thanos_portal
	name = "bluespace rip"
	desc = "A mysterious rip, that seems to span time, reality, bluespace, and beyond."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	resistance_flags = INDESTRUCTIBLE
	density = TRUE
	light_power = 3

/obj/effect/thanos_portal/singularity_act()
	return

/obj/effect/thanos_portal/singularity_pull()
	return

/obj/effect/thanos_portal/Bumped(atom/movable/AM)
	if(!QDELETED(AM))
		if(isliving(AM))
			var/mob/living/living = AM
			if(living.client && !living.incapacitated())
				living.visible_message(
				span_notice("[living] starts climbing through [src]..."),
				span_notice("You begin climbing through [src]...")
				)
				if(!do_after(living, 30, target = living))
					return
		if(!istype(AM, /obj/effect))
			teleportify(AM)

/obj/effect/thanos_portal/proc/teleportify(atom/movable/AM)
	if(LAZYLEN(GLOB.thanos_portal))
		var/turf/thanos_portal_turf = get_turf(pick(GLOB.thanos_portal))
		AM.visible_message(span_danger("[AM] passes through [src]!"), null, null, null, AM)
		AM.forceMove(thanos_portal_turf)
		AM.visible_message(
		span_danger("[AM] materializes from the air!"),
		span_boldannounce("You pass through [src] and appear somewhere unfamiliar.")
		)
		do_sparks(5, TRUE, src)
		do_sparks(5, TRUE, AM)
		if(isliving(AM))
			var/mob/living/living = AM
			living.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/static)
			living.clear_fullscreen("flash", 5)
