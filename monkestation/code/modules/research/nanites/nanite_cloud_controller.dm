/obj/machinery/computer/nanite_cloud_controller
	name = "nanite programmer"
	desc = "Stores and controls nanite cloud backups."
	icon = 'monkestation/icons/obj/machines/research.dmi'
	icon_state = "nanite_cloud_controller"
	circuit = /obj/item/circuitboard/computer/nanite_cloud_controller
	icon_keyboard = null
	icon_screen = null

	var/obj/item/disk/nanite_program/disk
	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	var/current_view = 0 //0 is the main menu, any other number is the page of the backup with that ID
	var/new_backup_id = 1
	var/datum/techweb/linked_techweb		//The techweb we are linked to.
	var/detail_view = TRUE					//Is nanite program hub in detailed view mode
	var/categories = list(					//Which program categories there are for nanite program hub section of UI
		list(name = "Utility Nanites"),
		list(name = "Medical Nanites"),
		list(name = "Sensor Nanites"),
		list(name = "Augmentation Nanites"),
		list(name = "Suppression Nanites"),
		list(name = "Weaponized Nanites"),
		list(name = "Protocols"),
	)

	var/datum/nanite_program/current_program	//The nanite program currently in the programming (middle) section.

/obj/machinery/computer/nanite_cloud_controller/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)
	linked_techweb = SSresearch.science_tech
	AddComponent(/datum/component/gps, "Nanite Synchronization Signal")

/obj/machinery/computer/nanite_cloud_controller/Destroy()
	QDEL_LIST(cloud_backups) //rip backups
	eject()
	return ..()

/obj/machinery/computer/nanite_cloud_controller/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/disk/nanite_program))
		var/obj/item/disk/nanite_program/N = tool
		if (user.transferItemToLoc(N, src))
			to_chat(user, span_notice("You insert [N] into [src]."))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			if(disk)
				eject(user)
			disk = N
			return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/nanite_cloud_controller/click_alt(mob/user)
	if(disk && !issilicon(user))
		to_chat(user, span_notice("You take out [disk] from [src]."))
		eject(user)
		return CLICK_ACTION_SUCCESS

	return CLICK_ACTION_BLOCKING

/obj/machinery/computer/nanite_cloud_controller/proc/eject(mob/living/user)
	if(!disk)
		return
	if(!istype(user) || !Adjacent(user) ||!user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/computer/nanite_cloud_controller/proc/get_backup(cloud_id)
	for(var/I in cloud_backups)
		var/datum/nanite_cloud_backup/backup = I
		if(backup.cloud_id == cloud_id)
			return backup

/obj/machinery/computer/nanite_cloud_controller/proc/generate_backup(cloud_id, mob/user)
	if(SSnanites.get_cloud_backup(cloud_id, TRUE))
		to_chat(user, span_warning("Cloud ID already registered."))
		return

	var/datum/nanite_cloud_backup/backup = new(src)
	var/datum/component/nanites/cloud_copy = backup.AddComponent(/datum/component/nanites)
	cloud_copy.cloud_id = cloud_id
	backup.cloud_id = cloud_id
	backup.nanites = cloud_copy
	investigate_log("[key_name(user)] created a new nanite cloud backup with id #[cloud_id]", INVESTIGATE_NANITES)

/obj/machinery/computer/nanite_cloud_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteCloudControl", name)
		ui.open()

/obj/machinery/computer/nanite_cloud_controller/ui_data()
	var/list/data = list()

	if(disk)
		data["has_disk"] = TRUE
	else
		data["has_disk"] = FALSE
	data["has_program"] = istype(current_program)
	if(current_program)
		data["name"] = current_program.name
		data["desc"] = current_program.desc
		data["use_rate"] = current_program.use_rate
		data["can_trigger"] = current_program.can_trigger
		data["trigger_cost"] = current_program.trigger_cost
		data["trigger_cooldown"] = current_program.trigger_cooldown / 10

		data["activated"] = current_program.activated
		data["activation_code"] = current_program.activation_code
		data["deactivation_code"] = current_program.deactivation_code
		data["kill_code"] = current_program.kill_code
		data["trigger_code"] = current_program.trigger_code
		data["timer_restart"] = current_program.timer_restart / 10
		data["timer_shutdown"] = current_program.timer_shutdown / 10
		data["timer_trigger"] = current_program.timer_trigger / 10
		data["timer_trigger_delay"] = current_program.timer_trigger_delay / 10

		var/list/extra_settings = current_program.get_extra_settings_frontend()
		data["extra_settings"] = extra_settings
		if(LAZYLEN(extra_settings))
			data["has_extra_settings"] = TRUE
		if(istype(current_program, /datum/nanite_program/sensor))
			var/datum/nanite_program/sensor/sensor = current_program
			if(sensor.can_rule)
				data["can_rule"] = TRUE
		else
			data["can_rule"] = FALSE


	data["new_backup_id"] = new_backup_id

	data["current_view"] = current_view
	if(current_view)
		var/datum/nanite_cloud_backup/backup = get_backup(current_view)
		if(backup)
			var/datum/component/nanites/nanites = backup.nanites
			data["cloud_backup"] = TRUE
			var/list/cloud_programs = list()
			var/id = 1
			for(var/datum/nanite_program/P in nanites.programs)
				var/list/cloud_program = list()
				cloud_program["name"] = P.name
				cloud_program["desc"] = P.desc
				cloud_program["id"] = id
				cloud_program["use_rate"] = P.use_rate
				cloud_program["can_trigger"] = P.can_trigger
				cloud_program["trigger_cost"] = P.trigger_cost
				cloud_program["trigger_cooldown"] = P.trigger_cooldown / 10
				cloud_program["activated"] = P.activated
				cloud_program["timer_restart"] = P.timer_restart / 10
				cloud_program["timer_shutdown"] = P.timer_shutdown / 10
				cloud_program["timer_trigger"] = P.timer_trigger / 10
				cloud_program["timer_trigger_delay"] = P.timer_trigger_delay / 10

				cloud_program["activation_code"] = P.activation_code
				cloud_program["deactivation_code"] = P.deactivation_code
				cloud_program["kill_code"] = P.kill_code
				cloud_program["trigger_code"] = P.trigger_code
				var/list/rules = list()
				var/rule_id = 1
				for(var/X in P.rules)
					var/datum/nanite_rule/nanite_rule = X
					var/list/rule = list()
					rule["display"] = nanite_rule.display()
					rule["program_id"] = id
					rule["id"] = rule_id
					rules += list(rule)
					rule_id++
				cloud_program["rules"] = rules
				if(LAZYLEN(rules))
					cloud_program["has_rules"] = TRUE
				cloud_program["all_rules_required"] = P.all_rules_required

				var/list/extra_settings = P.get_extra_settings_frontend()
				cloud_program["extra_settings"] = extra_settings
				if(LAZYLEN(extra_settings))
					cloud_program["has_extra_settings"] = TRUE
				id++
				cloud_programs += list(cloud_program)
			data["cloud_programs"] = cloud_programs
	else
		var/list/backup_list = list()
		for(var/X in cloud_backups)
			var/datum/nanite_cloud_backup/backup = X
			var/list/cloud_backup = list()
			cloud_backup["cloud_id"] = backup.cloud_id
			backup_list += list(cloud_backup)
		data["cloud_backups"] = backup_list

	data["detail_view"] = detail_view

	return data

/obj/machinery/computer/nanite_cloud_controller/ui_static_data(mob/user)
	var/list/data = list()
	data["programs"] = list()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/nanites/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		var/cat_name = D.category[1] //just put them in the first category fuck it
		if(isnull(data["programs"][cat_name]))
			data["programs"][cat_name] = list()
		var/list/program_design = list()
		program_design["id"] = D.id
		program_design["name"] = D.name
		program_design["desc"] = D.desc
		data["programs"][cat_name] += list(program_design)

	if(!length(data["programs"]))
		data["programs"] = null

	return data

/obj/machinery/computer/nanite_cloud_controller/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			eject(usr)
			. = TRUE
		if("set_view")
			current_view = text2num(params["view"])
			. = TRUE
		if("update_new_backup_value")
			var/backup_value = text2num(params["value"])
			new_backup_id = backup_value
		if("create_backup")
			var/cloud_id = new_backup_id
			if(!isnull(cloud_id))
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
				cloud_id = clamp(round(cloud_id, 1), 1, 100)
				generate_backup(cloud_id, usr)
			. = TRUE
		if("delete_backup")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
				qdel(backup)
				investigate_log("[key_name(usr)] deleted the nanite cloud backup #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("upload_program")
			if(current_program)
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
					var/datum/component/nanites/nanites = backup.nanites
					nanites.add_program(null, current_program.copy())
					investigate_log("[key_name(usr)] uploaded program [current_program.name] to cloud #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("remove_program")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
				var/datum/component/nanites/nanites = backup.nanites
				var/datum/nanite_program/P = nanites.programs[text2num(params["program_id"])]
				investigate_log("[key_name(usr)] deleted program [P.name] from cloud #[current_view]", INVESTIGATE_NANITES)
				nanites.programs -= P
				qdel(P)
			. = TRUE
		if("add_rule")
			if(current_program && istype(current_program, /datum/nanite_program/sensor))
				var/datum/nanite_program/sensor/rule_template = current_program
				if(!rule_template.can_rule)
					return
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
					var/datum/component/nanites/nanites = backup.nanites
					var/datum/nanite_program/P = nanites.programs[text2num(params["program_id"])]
					var/datum/nanite_rule/rule = rule_template.make_rule(P)
					if(rule)
						investigate_log("[key_name(usr)] added rule [rule.display()] to program [P.name] in cloud #[current_view]", INVESTIGATE_NANITES)
			. = TRUE
		if("remove_rule")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
				var/datum/component/nanites/nanites = backup.nanites
				var/datum/nanite_program/P = nanites.programs[text2num(params["program_id"])]
				var/datum/nanite_rule/rule = P.rules[text2num(params["rule_id"])]
				if(rule)
					investigate_log("[key_name(usr)] removed rule [rule.display()] from program [P.name] in cloud #[current_view]", INVESTIGATE_NANITES)
					rule.remove()
			. = TRUE
		if("toggle_rule_logic")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(backup)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
				var/datum/component/nanites/nanites = backup.nanites
				var/datum/nanite_program/P = nanites.programs[text2num(params["program_id"])]
				P.all_rules_required = !P.all_rules_required
				investigate_log("[key_name(usr)] edited rule logic for program [P.name] into [P.all_rules_required ? "All" : "Any"] in cloud #[current_view]", INVESTIGATE_NANITES)
				. = TRUE

		if("download")
			var/datum/design/nanites/downloaded = linked_techweb.isDesignResearchedID(params["program_id"]) //check if it's a valid design
			if(!istype(downloaded))
				return
			if(current_program)
				qdel(current_program)
			current_program = new downloaded.program_type
			playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
			. = TRUE
		if("refresh")
			update_static_data(usr)
			. = TRUE
		if("toggle_details")
			detail_view = !detail_view
			. = TRUE

		if("toggle_active")
			playsound(src, "terminal_type", 25, FALSE)
			current_program.activated = !current_program.activated //we don't use the activation procs since we aren't in a mob
			investigate_log("[key_name(usr)] edited [current_program.name]'s initial activation status into [current_program.activated ? "Activated" : "Deactivated"]", INVESTIGATE_NANITES)
			. = TRUE
		if("set_code")
			var/new_code = text2num(params["code"])
			playsound(src, "terminal_type", 25, FALSE)
			var/target_code = params["target_code"]
			switch(target_code)
				if("activation")
					current_program.activation_code = clamp(round(new_code, 1),0,9999)
					investigate_log("[key_name(usr)] edited [current_program.name]'s activation code into [current_program.activation_code]", INVESTIGATE_NANITES)
				if("deactivation")
					current_program.deactivation_code = clamp(round(new_code, 1),0,9999)
					investigate_log("[key_name(usr)] edited [current_program.name]'s deactivation code into [current_program.deactivation_code]", INVESTIGATE_NANITES)
				if("kill")
					current_program.kill_code = clamp(round(new_code, 1),0,9999)
					investigate_log("[key_name(usr)] edited [current_program.name]'s kill code into [current_program.kill_code]", INVESTIGATE_NANITES)
				if("trigger")
					current_program.trigger_code = clamp(round(new_code, 1),0,9999)
					investigate_log("[key_name(usr)] edited [current_program.name]'s trigger code into [current_program.trigger_code]", INVESTIGATE_NANITES)
			. = TRUE
		if("set_extra_setting")
			current_program.set_extra_setting(params["target_setting"], params["value"])
			investigate_log("[key_name(usr)] edited [current_program.name]'s extra setting '[params["target_setting"]]' into [params["value"]]", INVESTIGATE_NANITES)
			playsound(src, "terminal_type", 25, FALSE)
			. = TRUE
		if("set_restart_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				current_program.timer_restart = timer
				investigate_log("[key_name(usr)] edited [current_program.name]'s restart timer into [timer/10] s", INVESTIGATE_NANITES)
			. = TRUE
		if("set_shutdown_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				current_program.timer_shutdown = timer
				investigate_log("[key_name(usr)] edited [current_program.name]'s shutdown timer into [timer/10] s", INVESTIGATE_NANITES)
			. = TRUE
		if("set_trigger_timer")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				current_program.timer_trigger = timer
				investigate_log("[key_name(usr)] edited [current_program.name]'s trigger timer into [timer/10] s", INVESTIGATE_NANITES)
			. = TRUE
		if("set_timer_trigger_delay")
			var/timer = text2num(params["delay"])
			if(!isnull(timer))
				playsound(src, "terminal_type", 25, FALSE)
				timer = clamp(round(timer, 1), 0, 3600)
				timer *= 10 //convert to deciseconds
				current_program.timer_trigger_delay = timer
				investigate_log("[key_name(usr)] edited [current_program.name]'s trigger delay timer into [timer/10] s", INVESTIGATE_NANITES)
			. = TRUE
		if("store_backup")
			if(disk)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					disk.backup = list()
					var/datum/component/nanites/nanites = backup.nanites
					for(var/datum/nanite_program/program in nanites.programs)
						disk.backup += program.copy()	// Thank you ancient nanite coder for having a program copy function already made for me.
			. = TRUE
		if("load_backup")
			if(disk)
				playsound(src, 'sound/machines/terminal_prompt.ogg', 25, FALSE)
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					var/datum/component/nanites/nanites = backup.nanites
					nanites.programs = list()
					for(var/datum/nanite_program/program in disk.backup)
						nanites.programs += program.copy()
			. = TRUE

/datum/nanite_cloud_backup
	var/cloud_id = 0
	var/datum/component/nanites/nanites
	var/obj/machinery/computer/nanite_cloud_controller/storage

/datum/nanite_cloud_backup/New(obj/machinery/computer/nanite_cloud_controller/_storage)
	storage = _storage
	storage.cloud_backups += src
	SSnanites.cloud_backups += src

/datum/nanite_cloud_backup/Destroy()
	storage.cloud_backups -= src
	SSnanites.cloud_backups -= src
	return ..()

/obj/machinery/computer/nanite_cloud_controller/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range)
	. = ..()
	var/static/regex/when = regex("(?:^\\W*when|when\\W*$)", "i") //starts or ends with when
	if(findtext(raw_message, when) && !istype(speaker, /obj/machinery/computer/nanite_cloud_controller))
		say("When you code it!!")
