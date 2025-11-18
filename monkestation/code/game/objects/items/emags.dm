/obj/item/card/emag
	var/microwaved = FALSE
	var/microwaved_uses_left = -1

/obj/item/card/emag/microwave_act(obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	if(microwaved)
		microwave_source.spark()
		sleep(0.6 SECONDS)
		// explode the microwave,
		explosion(microwave_source, heavy_impact_range = 0, light_impact_range = 2, flame_range = 1, smoke = TRUE)
		microwave_source.broken = 2
		microwave_source.update_appearance()
		return qdel(src)

	desc += " Some of the components look a little crispy."
	icon_state = "[initial(icon_state)]_burnt"

	microwaved_uses_left = 5
	microwaved = TRUE
	return ..() | COMPONENT_MICROWAVE_SUCCESS

/obj/item/card/emag/examine_more(mob/user)
	. = ..()
	. += span_notice("I wonder what happens if you microwave it... surely that's not a good idea.")
