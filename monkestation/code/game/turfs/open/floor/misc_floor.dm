/turf/open/floor/circuit/green/anim/update_icon_state()
	icon = on ? 'icons/turf/floors.dmi' : 'monkestation/icons/turf/floors.dmi'
	return ..()

/turf/open/floor/circuit/red/anim/update_icon_state()
	icon = on ? 'icons/turf/floors.dmi' : 'monkestation/icons/turf/floors.dmi'
	return ..()

/obj/item/stack/tile/sandy_dirt
	name = "sandy dirt tiles"
	singular_name = "sandy dirt tile"
	desc = "A flat tile of dirt."
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_sandy_dirt"
	inhand_icon_state = "tile-sepia"
	turf_type = /turf/open/floor/sandy_dirt
	merge_type = /obj/item/stack/tile/sandy_dirt

/turf/open/floor/sandy_dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

	floor_tile = /obj/item/stack/tile/sandy_dirt

/turf/open/floor/sandy_dirt/break_tile()
	. = ..()
	icon_state = "sand_damaged"

/obj/item/stack/tile/silk
	name = "silk floor tile"
	singular_name = "silk floor tile"
	desc = "Soft and luxurious."
	icon = 'monkestation/icons/obj/tiles.dmi'
	icon_state = "tile_silk"
	inhand_icon_state = "tile"
	turf_type = /turf/open/floor/silk
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/silk
	force = 0
	throwforce = 0

/turf/open/floor/silk
	name = "silk floor"
	desc = "Soft and luxurious."
	icon = 'monkestation/icons/turf/floors.dmi'
	icon_state = "silk"
	floor_tile = /obj/item/stack/tile/silk
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
