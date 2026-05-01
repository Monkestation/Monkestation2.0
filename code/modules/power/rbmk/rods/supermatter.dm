/obj/item/rbmk/fuel_rod/supermatter
	name = "supermatter fuel rod"
	desc = "A Syndicate-engineered RBMK fuel rod containing a sealed supermatter sliver. It hums with impossible energy."
	icon = 'icons/obj/fuel_rod.dmi'
	icon_state = "syndicate"

	rod_type = "supermatter"
	rod_color = "gold"

	// The supermatter rod should not behave like a normal fuel rod.
	// The cascade datum owns its actual reactor effects.
	fuel_amount = 100
	depletion_rate = 0

	base_heat_output = 0
	base_radiation_output = 0

	thermal_multiplier = 0
	flux_multiplier = 0
	radiation_multiplier = 0

	reactivity_sensitivity = 0

	active = TRUE

	/// Active cascade controller, if this rod has taken over a reactor.
	var/datum/supermatter_rod_cascade/cascade_controller = null

	/// Whether the sealed supermatter sliver is still contained.
	var/contained_sliver = TRUE


/obj/item/rbmk/fuel_rod/supermatter/Destroy()
	if(cascade_controller)
		stop_cascade(FALSE)

	return ..()


/obj/item/rbmk/fuel_rod/supermatter/process_rod(reactor_temperature = RBMK_AMBIENT_TEMP, reactor_flux = 0, core_feedback_factor = 1.0)
	return list(
		"heat" = 0,
		"flux" = 0,
		"radiation" = 0
	)


/obj/item/rbmk/fuel_rod/supermatter/proc/start_cascade(obj/machinery/rbmk/reactor/reactor)
	if(cascade_controller)
		return FALSE

	if(!reactor || QDELETED(reactor))
		return FALSE

	if(!contained_sliver)
		return FALSE

	cascade_controller = new /datum/supermatter_rod_cascade(src, reactor)
	return TRUE


/obj/item/rbmk/fuel_rod/supermatter/proc/stop_cascade(successfully_removed = TRUE)
	if(!cascade_controller)
		return

	var/datum/supermatter_rod_cascade/old_controller = cascade_controller
	cascade_controller = null

	old_controller.stop(successfully_removed)


/obj/item/rbmk/fuel_rod/supermatter/examine(mob/user)
	. = ..()

	if(cascade_controller)
		. += span_bolddanger("The rod is actively resonating with a supermatter cascade.")
	else if(contained_sliver)
		. += span_warning("A sealed supermatter sliver is locked inside the casing.")
	else
		. += span_notice("The containment chamber appears empty.")
