/// Rooms with the size of a maint ruin, that get one of the maint room templates loaded in them once the dungeon is built
/datum/dungeon_room_theme/maintenance/ruin
	room_type = ROOM_TYPE_RUIN
	/// The room template that gets loaded inside the room
	var/datum/map_template/random_room/maint/ruin_template

/datum/dungeon_room_theme/maintenance/ruin/pre_initialize()
	. = ..()
	var/width_without_walls = dungeon_room_ref.width - 2
	var/height_without_walls = dungeon_room_ref.height - 2
	var/list/possible_templates = list()
	for(var/template_id in SSmapping.random_room_templates)
		var/datum/map_template/random_room/maint/template = SSmapping.random_room_templates[template_id]
		if(!istype(template) || template.template_width != width_without_walls || template.template_height != height_without_walls)
			continue
		possible_templates[template] = template.weight
	if(length(possible_templates))
		ruin_template = pick_weight(possible_templates)

/// Loads the ruin inside the walls of the room
/datum/dungeon_room_theme/maintenance/ruin/proc/load_ruin()
	if(!ruin_template)
		return FALSE
	return ruin_template.load(locate(dungeon_room_ref.x1 + 1, dungeon_room_ref.y1 + 1, dungeon_room_ref.z), centered = FALSE)
