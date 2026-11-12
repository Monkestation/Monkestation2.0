/// Station side

/area/station/bitrunning
	name = "Bitrunning"

/area/station/bitrunning/den
	name = "Bitrunning Den"
	desc = "Office of bitrunners, houses their equipment."
	icon_state = "bit_den"

/// VDOM

/area/virtual_domain
	name = "Virtual Domain"
	icon = 'icons/area/areas_station.dmi'
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA
	has_gravity = STANDARD_GRAVITY

/area/virtual_domain/powered
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/virtual_domain/powered_lighting
	name = "Virtual Domain Ruins"
	icon_state = "bit_ruin"
	requires_power = FALSE

/// Safehouse

/area/virtual_domain/safehouse
	name = "Virtual Domain Safehouse"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"
	requires_power = FALSE
	sound_environment = SOUND_ENVIRONMENT_ROOM

/// Custom subtypes

/area/lavaland/surface/outdoors/virtual_domain
	name = "Virtual Domain Lava Ruins"
	icon_state = "bit_ruin"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA

/area/lavaland/surface/outdoors/virtual_domain/protected_space
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"

/area/lavaland/surface/outdoors/virtual_domain/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/lavaland/surface/outdoors/virtual_domain/fullbright/protected_space
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"

/area/icemoon/underground/explored/virtual_domain
	name = "Virtual Domain Ice Ruins"
	icon_state = "bit_ice"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA

/area/ruin/space/has_grav/powered/virtual_domain
	name = "Virtual Domain Space Ruins"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "bit_space"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA

/area/ruin/space/has_grav/powered/virtual_domain/protected_space
	name = "Virtual Domain Safe Zone"
	area_flags = NOTELEPORT | ABDUCTOR_PROOF | EVENT_PROTECTED | HIDDEN_AREA
	area_flags_mapping = UNIQUE_AREA | VIRTUAL_AREA | VIRTUAL_SAFE_AREA
	icon_state = "bit_safe"

/// A hash lookup list of all the virtual area types
GLOBAL_LIST_INIT_TYPED(virtual_areas, /area, populate_virtual_areas())

/// Constructs the list of virtual areas
/proc/populate_virtual_areas()
	RETURN_TYPE(/list/area)
	var/list/area/virtual_areas = list()
	for(var/area/area_type as anything in subtypesof(/area))
		if (area_type::area_flags_mapping & VIRTUAL_AREA)
			virtual_areas[area_type] = TRUE
	return virtual_areas
