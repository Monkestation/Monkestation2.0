
/obj/machinery/light
	var/constant_flickering = FALSE // Are we always flickering?
	var/flicker_timer = null
	var/roundstart_flicker = FALSE

/obj/machinery/light/Initialize(mapload)
	. = ..()
	if(roundstart_flicker)
		start_flickering()

/obj/machinery/light/proc/start_flickering()
	on = FALSE
	update(FALSE, TRUE, FALSE)

	constant_flickering = TRUE

	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_on)), rand(0.5 SECONDS, 1 SECONDS))

/obj/machinery/light/proc/stop_flickering()
	constant_flickering = FALSE

	if(flicker_timer)
		deltimer(flicker_timer)
		flicker_timer = null

	set_on(has_power())

/obj/machinery/light/proc/alter_flicker(enable = TRUE)
	if(!constant_flickering)
		return
	if(has_power())
		on = enable
		update(FALSE, TRUE)

/obj/machinery/light/proc/flicker_on()
	alter_flicker(TRUE)
	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_off)), rand(0.5 SECONDS, 1 SECONDS))

/obj/machinery/light/proc/flicker_off()
	alter_flicker(FALSE)
	flicker_timer = addtimer(CALLBACK(src, PROC_REF(flicker_on)), rand(0.5 SECONDS, 5 SECONDS))

/obj/machinery/light/multitool_act(mob/living/user, obj/item/multitool)
	if(!constant_flickering)
		balloon_alert(user, "ballast is already working!")
		return TRUE

	balloon_alert(user, "repairing the ballast...")
	if(do_after(user, 2 SECONDS, src))
		stop_flickering()
		balloon_alert(user, "ballast repaired!")
		return TRUE
	return ..()
