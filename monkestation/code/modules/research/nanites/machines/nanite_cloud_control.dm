/obj/machinery/computer/nanite_cloud_controller
	name = "nanite cloud controller"
	desc = "Stores and controls nanite cloud backups."
	icon = 'monkestation/icons/obj/machines/nanites/nanite_machines.dmi'
	icon_state = "nanite_cloud_controller"
	circuit = /obj/item/circuitboard/computer/nanite_cloud_controller
	brightness_on = FALSE
	icon_keyboard = null
	icon_screen = null

	///The disk currently inserted into the cloud control.
	var/obj/item/disk/nanite_program/disk
	///The list of all cloud backups that we are a host to.
	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	///The current page we're viewing, 0 is the main menu, all others is their respective cloud backup ID.
	var/current_view = 0
	///The currently set Backup ID, if we create a new cloud backup it will take this ID if possible.
	var/new_backup_id = 1
	///The techweb we're linked to, required for the machine to work.
	var/datum/techweb/linked_techweb

/obj/machinery/computer/nanite_cloud_controller/Destroy()
	QDEL_LIST(cloud_backups) //rip backups
	linked_techweb = null
	eject()
	return ..()

/obj/machinery/computer/nanite_cloud_controller/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

/obj/machinery/computer/nanite_cloud_controller/attackby(obj/item/weapon, mob/user, params)
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

/obj/machinery/computer/nanite_cloud_controller/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		linked_techweb = tool.buffer
	return TRUE

/obj/machinery/computer/nanite_cloud_controller/attack_hand_secondary(mob/user, list/modifiers)
	if(disk && user.can_perform_action(src, ALLOW_SILICON_REACH))
		balloon_alert(user, "disk ejected")
		eject(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/machinery/computer/nanite_cloud_controller/proc/eject(mob/living/user)
	if(!disk || !user)
		return
	if(!istype(user) || !Adjacent(user) ||!user.put_in_active_hand(disk))
		disk.forceMove(drop_location())
	disk = null

/obj/machinery/computer/nanite_cloud_controller/proc/get_backup(cloud_id)
	for(var/datum/nanite_cloud_backup/backup as anything in cloud_backups)
		if(backup.cloud_id == cloud_id)
			return backup

/obj/machinery/computer/nanite_cloud_controller/proc/generate_backup(cloud_id, mob/user)
	if(SSnanites.get_cloud_backup(cloud_id, TRUE))
		to_chat(user, span_warning("Cloud ID already registered."))
		return

	var/datum/nanite_cloud_backup/backup = new(src, cloud_id)
	var/datum/component/nanites/cloud_copy = backup.AddComponent(/datum/component/nanites, linked_techweb)
	backup.set_nanites(cloud_copy)
	log_game("[key_name(user)] created a new nanite cloud backup with id #[cloud_id]")

/obj/machinery/computer/nanite_cloud_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NaniteCloudControl", name)
		ui.open()

/obj/machinery/computer/nanite_cloud_controller/ui_data()
	var/list/data = list()

	data["can_rule"] = FALSE
	if(disk)
		data["has_disk"] = TRUE
		var/list/disk_data = list()
		var/datum/nanite_program/current_program = disk.program
		if(current_program)
			data["has_program"] = TRUE
			disk_data["name"] = current_program.name
			disk_data["desc"] = current_program.desc
			disk_data["use_rate"] = current_program.use_rate
			disk_data["can_trigger"] = current_program.can_trigger
			disk_data["trigger_cost"] = current_program.trigger_cost
			disk_data["trigger_cooldown"] = current_program.trigger_cooldown / 10

			disk_data["activated"] = current_program.activated
			disk_data["activation_code"] = current_program.activation_code
			disk_data["deactivation_code"] = current_program.deactivation_code
			disk_data["kill_code"] = current_program.kill_code
			disk_data["trigger_code"] = current_program.trigger_code
			disk_data["timer_restart"] = current_program.timer_restart / 10
			disk_data["timer_shutdown"] = current_program.timer_shutdown / 10
			disk_data["timer_trigger"] = current_program.timer_trigger / 10
			disk_data["timer_trigger_delay"] = current_program.timer_trigger_delay / 10

			var/list/extra_settings = current_program.get_extra_settings_frontend()
			disk_data["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				disk_data["has_extra_settings"] = TRUE
			if(istype(current_program, /datum/nanite_program/sensor))
				var/datum/nanite_program/sensor/sensor = current_program
				data["can_rule"] = sensor.can_rule
		data["disk_data"] = disk_data
	else
		data["has_disk"] = FALSE

	data["new_backup_id"] = new_backup_id

	data["current_view"] = current_view
	if(current_view)
		var/datum/nanite_cloud_backup/backup = get_backup(current_view)
		if(backup)
			var/datum/component/nanites/nanites = backup.nanites
			data["cloud_backup"] = TRUE
			var/list/cloud_programs = list()
			var/id = 1
			for(var/datum/nanite_program/cloud_program as anything in nanites.programs)
				var/list/cloud_program_data = list()
				cloud_program_data["name"] = cloud_program.name
				cloud_program_data["desc"] = cloud_program.desc
				cloud_program_data["id"] = id
				cloud_program_data["use_rate"] = cloud_program.use_rate
				cloud_program_data["can_trigger"] = cloud_program.can_trigger
				cloud_program_data["trigger_cost"] = cloud_program.trigger_cost
				cloud_program_data["trigger_cooldown"] = cloud_program.trigger_cooldown / 10
				cloud_program_data["activated"] = cloud_program.activated
				cloud_program_data["timer_restart"] = cloud_program.timer_restart / 10
				cloud_program_data["timer_shutdown"] = cloud_program.timer_shutdown / 10
				cloud_program_data["timer_trigger"] = cloud_program.timer_trigger / 10
				cloud_program_data["timer_trigger_delay"] = cloud_program.timer_trigger_delay / 10

				cloud_program_data["activation_code"] = cloud_program.activation_code
				cloud_program_data["deactivation_code"] = cloud_program.deactivation_code
				cloud_program_data["kill_code"] = cloud_program.kill_code
				cloud_program_data["trigger_code"] = cloud_program.trigger_code
				var/list/rules = list()
				var/rule_id = 1
				for(var/datum/nanite_rule/nanite_rule as anything in cloud_program.rules)
					var/list/rule = list()
					rule["display"] = nanite_rule.display()
					rule["program_id"] = id
					rule["id"] = rule_id
					rules += list(rule)
					rule_id++
				cloud_program_data["rules"] = rules
				if(LAZYLEN(rules))
					cloud_program_data["has_rules"] = TRUE
				cloud_program_data["all_rules_required"] = cloud_program.all_rules_required

				var/list/extra_settings = cloud_program.get_extra_settings_frontend()
				cloud_program_data["extra_settings"] = extra_settings
				if(LAZYLEN(extra_settings))
					cloud_program_data["has_extra_settings"] = TRUE
				id++
				cloud_programs += list(cloud_program_data)
			data["cloud_programs"] = cloud_programs
	else
		var/list/backup_list = list()
		for(var/datum/nanite_cloud_backup/backup as anything in cloud_backups)
			var/list/cloud_backup = list()
			cloud_backup["cloud_id"] = backup.cloud_id
			backup_list += list(cloud_backup)
		data["cloud_backups"] = backup_list
	return data

/obj/machinery/computer/nanite_cloud_controller/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			eject(usr)
			return TRUE
		if("set_view")
			current_view = text2num(params["view"])
			return TRUE
		if("update_new_backup_value")
			var/backup_value = text2num(params["value"])
			new_backup_id = backup_value
			return TRUE
		if("create_backup")
			var/cloud_id = new_backup_id
			if(!isnull(cloud_id))
				playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
				cloud_id = clamp(round(cloud_id, 1),1,100)
				generate_backup(cloud_id, usr)
			return TRUE
		if("delete_backup")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(!backup)
				return TRUE
			playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
			qdel(backup)
			log_game("[key_name(usr)] deleted the nanite cloud backup #[current_view]")
			return TRUE
		if("upload_program")
			if(disk && disk.program)
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(!backup)
					return TRUE
				playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
				var/datum/component/nanites/nanites = backup.nanites
				nanites.add_program(null, disk.program.copy())
				log_game("[key_name(usr)] uploaded program [disk.program.name] to cloud #[current_view]")
			return TRUE
		if("remove_program")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(!backup)
				return TRUE
			playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
			var/datum/component/nanites/nanites = backup.nanites
			var/datum/nanite_program/cloud_program = nanites.programs[text2num(params["program_id"])]
			log_game("[key_name(usr)] deleted program [cloud_program.name] from cloud #[current_view]")
			qdel(cloud_program)
			return TRUE
		if("add_rule")
			if(disk && disk.program && istype(disk.program, /datum/nanite_program/sensor))
				var/datum/nanite_program/sensor/rule_template = disk.program
				if(!rule_template.can_rule)
					return
				var/datum/nanite_cloud_backup/backup = get_backup(current_view)
				if(backup)
					playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, 0)
					var/datum/component/nanites/nanites = backup.nanites
					var/datum/nanite_program/ruled_program = nanites.programs[text2num(params["program_id"])]
					var/datum/nanite_rule/rule = rule_template.make_rule(ruled_program)
					log_game("[key_name(usr)] added rule [rule.display()] to program [ruled_program.name] in cloud #[current_view]")
			return TRUE
		if("remove_rule")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(!backup)
				return TRUE
			playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, 0)
			var/datum/component/nanites/nanites = backup.nanites
			var/datum/nanite_program/ruleless_program = nanites.programs[text2num(params["program_id"])]
			var/datum/nanite_rule/rule = ruleless_program.rules[text2num(params["rule_id"])]
			rule.remove()
			log_game("[key_name(usr)] removed rule [rule.display()] from program [ruleless_program.name] in cloud #[current_view]")
			return TRUE
		if("toggle_rule_logic")
			var/datum/nanite_cloud_backup/backup = get_backup(current_view)
			if(!backup)
				return TRUE
			playsound(src, 'sound/machines/terminal/terminal_prompt.ogg', 50, FALSE)
			var/datum/component/nanites/nanites = backup.nanites
			var/datum/nanite_program/logical_program = nanites.programs[text2num(params["program_id"])]
			logical_program.all_rules_required = !logical_program.all_rules_required
			log_game("[key_name(usr)] edited rule logic for program [logical_program.name] into [logical_program.all_rules_required ? "All" : "Any"] in cloud #[current_view]")
			return TRUE
