#define NANITE_DEFAULT_STARTING_VOLUME 100
#define NANITE_DEFAULT_MAX_VOLUME 500
#define NANITE_DEFAULT_REGEN_RATE 0.5
#define NANITE_DEFAULT_SAFETY_THRESHOLD 50

///The default amount of nanite research points to generate per person per tick.
#define NANITE_BASE_RESEARCH 0.2
///The chance at a Nanite program randomly failing when it cannot sync
#define NANITE_FAILURE_CHANCE 8
///The max amount of nanite programs you can have in a cloud at once.
#define NANITE_PROGRAM_LIMIT 50
///The delay between sync attempts for nanites to the cloud, if it fails then it will start to corrupt.
#define NANITE_SYNC_DELAY (30 SECONDS)

/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	///The living person these nanites are attached onto
	var/mob/living/host_mob

	///amount of nanites in the system, used as fuel for nanite programs
	var/nanite_volume = NANITE_DEFAULT_STARTING_VOLUME
	///maximum amount of nanites someone can have
	var/max_nanites = NANITE_DEFAULT_MAX_VOLUME
	///nanites generated per second
	var/regen_rate = NANITE_DEFAULT_REGEN_RATE
	///how low nanites will get before they stop processing/triggering
	var/safety_threshold = NANITE_DEFAULT_SAFETY_THRESHOLD
	///0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/cloud_id = 0
	///How long until the next sync to cloud
	var/next_sync = 0
	///All nanite programs in the user
	var/list/datum/nanite_program/programs = list()

	///Separate list of protocol programs, to avoid looping through the whole programs list when checking for conflicts
	var/list/datum/nanite_program/protocol/protocols = list()
	///Timestamp to when the nanites were first inserted in the host, used in some protocols.
	var/start_time = 0
	///Prevents nanites from appearing on HUDs and health scans
	var/stealth = FALSE
	///if TRUE, displays program list when scanned by nanite scanners
	var/diagnostics = TRUE
	///The techweb these Nanites are synced to, to generate Nanite research points
	var/datum/techweb/linked_techweb

/datum/component/nanites/Initialize(
	datum/techweb/linked_techweb,
	nanite_volume = NANITE_DEFAULT_STARTING_VOLUME,
	cloud_id = 0,
)
	if(!isliving(parent) && !istype(parent, /datum/nanite_cloud_backup))
		return COMPONENT_INCOMPATIBLE

	src.linked_techweb = linked_techweb
	src.nanite_volume = nanite_volume
	src.cloud_id = cloud_id

	if(!isliving(parent))
		return

	host_mob = parent
	if(!(host_mob.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD))) //Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
		return COMPONENT_INCOMPATIBLE

	start_time = world.time

	host_mob.hud_set_nanite_indicator()
	START_PROCESSING(SSnanites, src)

	if(cloud_id)
		cloud_sync()

/datum/component/nanites/RegisterWithParent()
	RegisterSignal(parent, COMSIG_NANITE_IS_STEALTHY, PROC_REF(check_stealth))
	RegisterSignal(parent, COMSIG_NANITE_DELETE, PROC_REF(delete_nanites))
	RegisterSignal(parent, COMSIG_NANITE_UI_DATA, PROC_REF(nanite_ui_data))
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, PROC_REF(set_volume))
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, PROC_REF(adjust_nanites))
	RegisterSignal(parent, COMSIG_NANITE_SET_MAX_VOLUME, PROC_REF(set_max_volume))
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, PROC_REF(set_cloud))
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, PROC_REF(set_safety))
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, PROC_REF(set_regen))
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, PROC_REF(add_program))
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))
	RegisterSignal(parent, COMSIG_NANITE_SCAN, PROC_REF(nanite_scan))
	RegisterSignal(parent, COMSIG_NANITE_SYNC, PROC_REF(sync))
	if(isliving(parent))
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
		RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))
		RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
		RegisterSignal(parent, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_shock))
		RegisterSignal(parent, COMSIG_LIVING_MINOR_SHOCK, PROC_REF(on_minor_shock))
		RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(check_viable_biotype))
		RegisterSignal(parent, COMSIG_NANITE_SIGNAL, PROC_REF(receive_signal))
		RegisterSignal(parent, COMSIG_NANITE_COMM_SIGNAL, PROC_REF(receive_comm_signal))

/datum/component/nanites/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_NANITE_IS_STEALTHY,
		COMSIG_NANITE_DELETE,
		COMSIG_NANITE_UI_DATA,
		COMSIG_NANITE_SET_VOLUME,
		COMSIG_NANITE_ADJUST_VOLUME,
		COMSIG_NANITE_SET_MAX_VOLUME,
		COMSIG_NANITE_SET_CLOUD,
		COMSIG_NANITE_SET_SAFETY,
		COMSIG_NANITE_SET_REGEN,
		COMSIG_NANITE_ADD_PROGRAM,
		COMSIG_LIVING_HEALTHSCAN,
		COMSIG_NANITE_SCAN,
		COMSIG_NANITE_SYNC,
		COMSIG_ATOM_EMP_ACT,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_ELECTROCUTE_ACT,
		COMSIG_LIVING_MINOR_SHOCK,
		COMSIG_MOVABLE_HEAR,
		COMSIG_SPECIES_GAIN,
		COMSIG_NANITE_SIGNAL,
		COMSIG_NANITE_COMM_SIGNAL,
	))

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	QDEL_LIST(programs)
	if(host_mob)
		host_mob.hud_set_nanite_indicator(remove = TRUE)
		set_nanite_bar(remove = TRUE)
	host_mob = null
	linked_techweb = null
	return ..()

/datum/component/nanites/InheritComponent(datum/component/nanites/new_nanites, i_am_original, amount, cloud)
	if(new_nanites)
		adjust_nanites(null, new_nanites.nanite_volume)
	else
		adjust_nanites(null, amount) //just add to the nanite volume

/datum/component/nanites/process()
	if(!HAS_TRAIT(host_mob, TRAIT_STASIS))
		adjust_nanites(null, regen_rate)
		add_research()
		for(var/datum/nanite_program/active_programs as anything in programs)
			active_programs.on_process()
		if(cloud_id && world.time > next_sync)
			cloud_sync()
			next_sync = world.time + NANITE_SYNC_DELAY
	set_nanite_bar()

/datum/component/nanites/proc/delete_nanites(mob/source)
	SIGNAL_HANDLER

	qdel(src)

///Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/signal_source, datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	SIGNAL_HANDLER

	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/datum/nanite_program/nanite_program as anything in programs)
		for(var/datum/nanite_program/adding_program as anything in programs_to_add)
			if(nanite_program.type == adding_program.type)
				programs_to_remove -= nanite_program
				programs_to_add -= adding_program
				adding_program.copy_programming(nanite_program, copy_activation)
				break
	if(full_overwrite)
		QDEL_LIST(programs_to_remove)
		cloud_id = source.cloud_id
		safety_threshold = source.safety_threshold
	for(var/datum/nanite_program/adding_program as anything in programs_to_add)
		add_program(null, adding_program.copy())

/datum/component/nanites/proc/cloud_sync()
	if(!cloud_id)
		return attempt_corrupt()
	var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
	if(!backup)
		return attempt_corrupt()
	var/datum/component/nanites/cloud_copy = backup.nanites
	if(!cloud_copy)
		return attempt_corrupt()
	sync(null, cloud_copy)

///Rolls for a chance to corrupt your nanites.
/datum/component/nanites/proc/attempt_corrupt()
	if(prob(NANITE_FAILURE_CHANCE) && programs.len)
		var/datum/nanite_program/random_program = pick(programs)
		random_program.software_error()

/datum/component/nanites/proc/add_program(datum/source, datum/nanite_program/new_program, datum/nanite_program/source_program)
	SIGNAL_HANDLER

	if(istype(new_program, /datum/nanite_program/protocol))
		var/datum/nanite_program/protocol/protocol_nanite = new_program
		for(var/datum/nanite_program/protocol/other_protocols as anything in protocols)
			//skip over the same type so it continues on to delete it later.
			if(other_protocols.type != new_program.type)
				continue
			if(other_protocols.protocol_class != protocol_nanite.protocol_class)
				continue
			return COMPONENT_PROGRAM_NOT_INSTALLED

	for(var/datum/nanite_program/all_program as anything in programs)
		if(!all_program.unique || all_program.type != new_program.type)
			continue
		qdel(all_program)

	if(programs.len >= NANITE_PROGRAM_LIMIT)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)
	return COMPONENT_PROGRAM_INSTALLED

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force && safety_threshold && (nanite_volume - amount < safety_threshold))
		return FALSE
	adjust_nanites(null, -amount)
	return (nanite_volume > 0)

/datum/component/nanites/proc/adjust_nanites(datum/source, amount)
	SIGNAL_HANDLER

	nanite_volume = clamp(nanite_volume + amount, 0, max_nanites)
	if(nanite_volume <= 0) //oops we ran out
		INVOKE_ASYNC(src, PROC_REF(delete_nanites))

/datum/component/nanites/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	nanite_volume *= (rand(60, 90) * 0.01) //Lose 10-40% of nanites
	adjust_nanites(null, -(rand(5, 50))) //Lose 5-50 flat nanite volume
	if(prob(40 / severity))
		cloud_id = 0
	for(var/datum/nanite_program/all_program as anything in programs)
		all_program.on_emp(severity)


/datum/component/nanites/proc/on_shock(datum/source, shock_damage, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER

	if(flags & SHOCK_ILLUSION || shock_damage < 1)
		return

	if(!HAS_TRAIT_NOT_FROM(host_mob, TRAIT_SHOCKIMMUNE, TRAIT_NANITES))//Another shock protection must protect nanites too, but nanites protect only host
		nanite_volume *= (rand(45, 80) * 0.01) //Lose 20-55% of nanites
		adjust_nanites(null, -(rand(5, 50))) //Lose 5-50 flat nanite volume
		for(var/X in programs)
			var/datum/nanite_program/NP = X
			NP.on_shock(shock_damage)

/datum/component/nanites/proc/on_minor_shock(datum/source)
	SIGNAL_HANDLER

	adjust_nanites(null, -(rand(5, 15))) //Lose 5-15 flat nanite volume
	for(var/datum/nanite_program/all_program as anything in programs)
		all_program.on_minor_shock()

/datum/component/nanites/proc/check_stealth(datum/source)
	SIGNAL_HANDLER

	return stealth

/datum/component/nanites/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	for(var/datum/nanite_program/all_program as anything in programs)
		all_program.on_death(gibbed)

/datum/component/nanites/proc/on_revive(datum/source, full_heal, admin_revive)
	SIGNAL_HANDLER

	for(var/datum/nanite_program/all_program as anything in programs)
		all_program.on_revive(full_heal, admin_revive)

/datum/component/nanites/proc/receive_signal(datum/source, code, signal_source = "an unidentified source")
	SIGNAL_HANDLER

	for(var/datum/nanite_program/all_program as anything in programs)
		all_program.receive_signal(code, signal_source)

/datum/component/nanites/proc/receive_comm_signal(datum/source, comm_code, comm_message, comm_source = "an unidentified source")
	SIGNAL_HANDLER

	for(var/datum/nanite_program/comm/comm_program in programs)
		comm_program.receive_comm_signal(comm_code, comm_message, comm_source)

/datum/component/nanites/proc/check_viable_biotype()
	SIGNAL_HANDLER

	if(!(host_mob.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
		qdel(src) //bodytype no longer sustains nanites

/datum/component/nanites/proc/set_volume(datum/source, amount)
	SIGNAL_HANDLER

	nanite_volume = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_max_volume(datum/source, amount)
	SIGNAL_HANDLER

	max_nanites = max(1, max_nanites)

/datum/component/nanites/proc/set_cloud(datum/source, amount)
	SIGNAL_HANDLER

	cloud_id = clamp(amount, 0, 100)

/datum/component/nanites/proc/set_safety(datum/source, amount)
	SIGNAL_HANDLER

	safety_threshold = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_regen(datum/source, amount)
	SIGNAL_HANDLER

	regen_rate = amount

/datum/component/nanites/proc/get_data(list/nanite_data)
	nanite_data["nanite_volume"] = nanite_volume
	nanite_data["max_nanites"] = max_nanites
	nanite_data["cloud_id"] = cloud_id
	nanite_data["regen_rate"] = regen_rate
	nanite_data["safety_threshold"] = safety_threshold
	nanite_data["stealth"] = stealth

///Adds nanite research points to the linked techweb based on the host's status.
/datum/component/nanites/proc/add_research()
	if(host_mob.stat == DEAD)
		return
	var/research_value = NANITE_BASE_RESEARCH
	if(!ishuman(host_mob))
		research_value *= 0.5
	linked_techweb.add_point_list(list(TECHWEB_POINT_TYPE_NANITES = research_value))

/datum/component/nanites/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode)
	SIGNAL_HANDLER
	nanite_scan(source, user, full_scan = FALSE)

/datum/component/nanites/proc/nanite_scan(datum/source, mob/user, full_scan)
	SIGNAL_HANDLER

	if(full_scan)
		to_chat(user, span_boldnotice("Nanites Detected"))
		to_chat(user, span_info("Saturation: [nanite_volume]/[max_nanites]"))
		to_chat(user, span_info("Safety Threshold: [safety_threshold]"))
		to_chat(user, span_info("Cloud ID: [cloud_id ? cloud_id : "None"]"))
		to_chat(user, span_info("================"))
		to_chat(user, span_info("Program List:"))
		if(diagnostics)
			for(var/datum/nanite_program/NP as anything in programs)
				to_chat(user, span_info("<b>[NP.name]</b> | [NP.activated ? "Active" : "Inactive"]"))
			return TRUE
		to_chat(user, span_alert("Diagnostics Disabled"))
		return TRUE

	if(stealth)
		return TRUE

	to_chat(user, span_boldnotice("Nanites Detected"))
	to_chat(user, span_notice("Saturation: [nanite_volume]/[max_nanites]"))

/datum/component/nanites/proc/nanite_ui_data(datum/source, list/data, scan_level)
	SIGNAL_HANDLER

	data["has_nanites"] = TRUE
	data["nanite_volume"] = nanite_volume
	data["regen_rate"] = regen_rate
	data["safety_threshold"] = safety_threshold
	data["cloud_id"] = cloud_id
	var/list/mob_programs = list()
	var/id = 1
	for(var/datum/nanite_program/program as anything in programs)
		var/list/mob_program = list()
		mob_program["name"] = program.name
		mob_program["desc"] = program.desc
		mob_program["id"] = id

		if(scan_level >= 2)
			mob_program["activated"] = program.activated
			mob_program["use_rate"] = program.use_rate
			mob_program["can_trigger"] = program.can_trigger
			mob_program["trigger_cost"] = program.trigger_cost
			mob_program["trigger_cooldown"] = program.trigger_cooldown / 10

		if(scan_level >= 3)
			mob_program["timer_restart"] = program.timer_restart / 10
			mob_program["timer_shutdown"] = program.timer_shutdown / 10
			mob_program["timer_trigger"] = program.timer_trigger / 10
			mob_program["timer_trigger_delay"] = program.timer_trigger_delay / 10
			var/list/extra_settings = program.get_extra_settings_frontend()
			mob_program["extra_settings"] = extra_settings
			if(LAZYLEN(extra_settings))
				mob_program["has_extra_settings"] = TRUE
			else
				mob_program["has_extra_settings"] = FALSE

		if(scan_level >= 4)
			mob_program["activation_code"] = program.activation_code
			mob_program["deactivation_code"] = program.deactivation_code
			mob_program["kill_code"] = program.kill_code
			mob_program["trigger_code"] = program.trigger_code
			var/list/rules = list()
			var/rule_id = 1
			for(var/datum/nanite_rule/nanite_rule as anything in program.rules)
				var/list/rule = list()
				rule["display"] = nanite_rule.display()
				rule["program_id"] = id
				rule["id"] = rule_id
				rules += list(rule)
				rule_id++
			mob_program["rules"] = rules
			if(LAZYLEN(rules))
				mob_program["has_rules"] = TRUE
		id++
		mob_programs += list(mob_program)
	data["mob_programs"] = mob_programs

#undef NANITE_DEFAULT_STARTING_VOLUME
#undef NANITE_DEFAULT_MAX_VOLUME
#undef NANITE_DEFAULT_REGEN_RATE
#undef NANITE_DEFAULT_SAFETY_THRESHOLD

#undef NANITE_BASE_RESEARCH
#undef NANITE_FAILURE_CHANCE
#undef NANITE_PROGRAM_LIMIT
#undef NANITE_SYNC_DELAY
