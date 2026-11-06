/datum/computer_file/program/revelation
	filename = "revelation"
	filedesc = "Revelation"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "hostile"
	extended_desc = "This virus can destroy hard drive of system it is executed on. It may be obfuscated to look like another non-malicious program. Once armed, it will destroy the system upon next execution."
	size = 13
	program_flags = PROGRAM_ON_SYNDINET_STORE
	tgui_id = "NtosRevelation"
	program_icon = "magnet"
	///Boolean on whether the PDA app is currently armed or not.
	var/armed = FALSE

/datum/computer_file/program/revelation/on_start(mob/living/user)
	. = ..()
	if(!.)
		return .
	if(armed)
		activate()

/datum/computer_file/program/revelation/proc/activate()
	if(!computer)
		return
	if(istype(computer, /obj/item/modular_computer/pda/silicon)) //If this is a borg's integrated tablet
		var/obj/item/modular_computer/pda/silicon/modularInterface = computer
		to_chat(modularInterface.silicon_owner, span_userdanger("SYSTEM PURGE DETECTED/"))
		addtimer(CALLBACK(modularInterface.silicon_owner, TYPE_PROC_REF(/mob/living/silicon, death)), 2 SECONDS, TIMER_UNIQUE)
		return

	var/obj/item/modular_computer/cached_computer = computer //this becomes null
	computer.take_damage(25, BRUTE, 0, 0)
	computer.visible_message(span_warning("\The [computer]'s screen brightly flashes and loud electrical buzzing is heard."))
	for(var/datum/computer_file/file as anything in computer.stored_files)
		computer.remove_file(file)
	cached_computer.shutdown_computer(loud = FALSE)

	if(cached_computer.internal_cell && prob(25))
		QDEL_NULL(cached_computer.internal_cell)
		cached_computer.visible_message(span_warning("\The [cached_computer]'s battery explodes in rain of sparks."))
		var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
		spark_system.start()

/datum/computer_file/program/revelation/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("PRG_arm")
			armed = !armed
			return TRUE
		if("PRG_activate")
			activate()
			return TRUE
		if("PRG_obfuscate")
			var/newname = params["new_name"]
			if(!newname)
				return
			filedesc = newname
			return TRUE

/datum/computer_file/program/revelation/clone()
	var/datum/computer_file/program/revelation/temp = ..()
	temp.armed = armed
	return temp

/datum/computer_file/program/revelation/ui_data(mob/user)
	var/list/data = list()

	data["filedesc"] = filedesc
	data["armed"] = armed

	return data
