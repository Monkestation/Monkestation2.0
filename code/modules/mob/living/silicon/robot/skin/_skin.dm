/datum/robot_skin
	/// The abstract type. Not used anywhere at the moment.
	var/abstract_type = /datum/robot_skin
	/// The name of the skin.
	var/name = "Unknown"
	/// The icon of the sprite.
	var/icon = 'icons/mob/silicon/robots.dmi'
	/// The icon state of the sprite.
	var/icon_state = "robot"
	/// The icon state of the sprite's cover panel.
	var/icon_state_cover = "ov"
	/// The icon state of the sprite's head lights.
	var/icon_state_light = "robot"
	/// The X offset of the sprite.
	var/base_pixel_x = 0
	/// The Y offset of the sprite.
	var/base_pixel_y = 0
	/// The X offset of any worn hats. Enables hat wearing if it is not null.
	var/hat_offset = null
	/// The X offset of any worn badges. Enables badge wearing if it is not null.
	var/badge_offset = null
	/// The X offsets for any buckled individuals.
	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	/// The Y offsets for any buckled people.
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	/// The traits that are given when using this skin.
	var/list/traits = list()
