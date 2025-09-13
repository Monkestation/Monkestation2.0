/obj/machinery/nanite_programmer
	name = "nanite programmer"
	desc = "A device that can edit nanite program disks to adjust their functionality."
	icon = 'monkestation/icons/obj/machines/nanites/nanite_machines.dmi'
	icon_state = "nanite_programmer"
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/nanite_programmer

	///The delay between 'when you code it' replies.
	COOLDOWN_DECLARE(wyci_delay)
	///The disk inserted into the machine that we hold and get the program of.
	var/obj/item/disk/nanite_program/disk
	///The program on the nanite disk that we are currently editing.
	var/datum/nanite_program/program

/obj/machinery/nanite_programmer/Initialize(mapload)
	. = ..()
	become_hearing_sensitive()

/obj/machinery/nanite_programmer/attackby(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/disk/nanite_program))
		return ..()
	if(!user.transferItemToLoc(weapon, src))
		return
	if(disk)
		balloon_alert(user, "disk swapped")
		eject(user)
	else
		balloon_alert(user, "disk inserted")
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
	disk = weapon
	program = disk.program

/obj/machinery/nanite_programmer/attack_hand_secondary(mob/user, list/modifiers)
	if(disk && user.can_perform_action(src, ALLOW_SILICON_REACH))
		balloon_alert(user, "disk ejected")
		eject(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/nanite_programmer/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	. = ..()
	if(!COOLDOWN_FINISHED(src, wyci_delay))
		return
	var/static/regex/when = regex("(?:^\\W*when|when\\W*$)", "i") //starts or ends with when
	if(findtext(raw_message, when) && !istype(speaker, /obj/machinery/nanite_programmer))
		say("When you code it!!")
		COOLDOWN_START(src, wyci_delay, 5 SECONDS)

/obj/machinery/nanite_programmer/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_programmer/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/nanite_programmer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteProgrammer", name)
		ui.open()

/obj/machinery/nanite_programmer/ui_data()
	var/list/data = list()
	data["has_disk"] = istype(disk)
	data["has_program"] = istype(program)
	if(program)
		data["name"] = program.name
		data["desc"] = program.desc
		data["use_rate"] = program.use_rate
		data["can_trigger"] = program.can_trigger
		data["trigger_cost"] = program.trigger_cost
		data["trigger_cooldown"] = program.trigger_cooldown / 10

		data["activated"] = program.activated
		data["activation_code"] = program.activation_code
		data["deactivation_code"] = program.deactivation_code
		data["kill_code"] = program.kill_code
		data["trigger_code"] = program.trigger_code
		data["timer_restart"] = program.timer_restart / 10
		data["timer_shutdown"] = program.timer_shutdown / 10
		data["timer_trigger"] = program.timer_trigger / 10
		data["timer_trigger_delay"] = program.timer_trigger_delay / 10

		var/list/extra_settings = program.get_extra_settings_frontend()
		data["extra_settings"] = extra_settings
		if(LAZYLEN(extra_settings))
			data["has_extra_settings"] = TRUE

	return data

/obj/machinery/nanite_programmer/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			eject(usr)
			return TRUE
		if("toggle_active")
			playsound(src, "terminal_type", 25, FALSE)
			program.activated = !program.activated //we don't use the activation procs since we aren't in a mob
			return TRUE
		if("set_code")
			var/new_code = text2num(params["code"])
			playsound(src, "terminal_type", 25, FALSE)
			var/target_code = params["target_code"]
			switch(target_code)
				if("activation")
					program.activation_code = clamp(round(new_code, 1),0,9999)
				if("deactivation")
					program.deactivation_code = clamp(round(new_code, 1),0,9999)
				if("kill")
					program.kill_code = clamp(round(new_code, 1),0,9999)
				if("trigger")
					program.trigger_code = clamp(round(new_code, 1),0,9999)
			return TRUE
		if("set_extra_setting")
			program.set_extra_setting(params["target_setting"], params["value"])
			playsound(src, "terminal_type", 25, FALSE)
			return TRUE
		if("set_restart_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_restart = timer
			return TRUE
		if("set_shutdown_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_shutdown = timer
			return TRUE
		if("set_trigger_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_trigger = timer
			return TRUE
		if("set_timer_trigger_delay")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				program.timer_trigger_delay = timer
			return TRUE

/obj/machinery/nanite_programmer/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) || !user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null
	program = null
