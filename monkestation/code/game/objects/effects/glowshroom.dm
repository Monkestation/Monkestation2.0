/obj/structure/glowshroom
	alpha = 150
	light_system = OVERLAY_LIGHT
	layer = ABOVE_OPEN_TURF_LAYER
	/// The world.time of the last successful glowshroom spread.
	/// Used for sorting processing to try to ensure all glowshrooms get a chance to proc.
	var/last_successful_spread = 0
