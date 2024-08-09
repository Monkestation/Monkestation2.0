/obj/structure/glowshroom
	icon = 'monkestation/icons/obj/flora/glowshroom.dmi'
	icon_state = "glowshroom1"
	layer = ABOVE_OPEN_TURF_LAYER
	/// The world.time of the last successful glowshroom spread.
	/// Used for sorting processing to try to ensure all glowshrooms get a chance to proc.
	var/last_successful_spread = 0
	/// The variant of the icon (1-4 for floor, 1-3 for wall)
	var/icon_variant

/obj/structure/glowshroom/update_icon_state()
	if(isnull(icon_variant))
		icon_variant = rand(1, floor ? 4 : 3)
	base_icon_state = floor ? "glowshroom" : "glowshroom_wall"
	icon_state = "[base_icon_state][icon_variant]"
	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
	add_atom_colour(light_color, FIXED_COLOUR_PRIORITY)
	return ..()

/obj/structure/glowshroom/glowcap
	icon_state = "glowshroom1"

/obj/structure/glowshroom/shadowshroom
	icon_state = "glowshroom1"
