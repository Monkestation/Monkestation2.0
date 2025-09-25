GLOBAL_DATUM(ore_silo_default, /obj/machinery/ore_silo)
GLOBAL_LIST_EMPTY(silo_access_logs)

/obj/machinery/ore_silo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the station's mineral distribution needs."
	icon = 'icons/obj/mining.dmi'
	icon_state = "silo"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ore_silo

	/// The machine UI's page of logs showing ore history.
	var/log_page = 1
	/// By default, an ore silo requires you to be wearing an ID to pull materials from it.
	var/ID_required = TRUE
	/// List of all connected components that are on hold from accessing materials.
	var/list/holds = list()
	/// List of all components that are sharing ores with this silo.
	var/list/datum/component/remote_materials/ore_connected_machines = list()
	/// Material Container
	var/datum/component/material_container/materials
	/// A list of names of bank account IDs that are banned from using this ore silo.
	var/list/banned_users = list()
	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	///The channels we announce over
	var/list/radio_channels = list(
		RADIO_CHANNEL_COMMON = NONE,
		RADIO_CHANNEL_COMMAND = NONE,
		RADIO_CHANNEL_SUPPLY = NONE,
		RADIO_CHANNEL_SECURITY = NONE,
	)
	var/static/alist/announcement_messages = alist(
		BAN_ATTEMPT_FAILURE_NO_ACCESS = "ACCESS ENFORCEMENT FAILURE: $SILO_USER_NAME lacks supply command authority.",
		BAN_ATTEMPT_FAILURE_CHALLENGING_DA_CHIEF = "ACCESS ENFORCEMENT FAILURE: $SILO_USER_NAME attempting subversion of supply command authority.",
		BAN_ATTEMPT_FAILURE_SOULLESS_MACHINE = "$SILO_USER_NAME INTERFACE_EXCEPTION -> BANNED_USERS+=\[$TARGET_NAME\] => NO_OP",
		BAN_CONFIRMATION = "ACCESS ENFORCEMENT CONFIRMATION\[$SILO_USER_NAME\]: $TARGET_NAME banned from ore silo access.",
		UNBAN_CONFIRMATION = "ACCESS ENFORCEMENT CONFIRMATION\[$SILO_USER_NAME\]: $TARGET_NAME unbanned from ore silo access.",
		FAILED_OPERATION_SUSPICIOUS = "NULL_ACCOUNT_RESOLVE_PTR_#?",
		FAILED_OPERATION_NO_BANK_ID = "ACCESS ENFORCEMENT FAILURE: No account ID found. Please contact a banker.",
		UNRESTRICT_FAILURE_NO_ACCESS = "ID ACCESS REQUIREMENT ENFORCED: $SILO_USER_NAME lacks supply command authority; ID ACCESS REQUIREMENT REMOVAL FAILED.",
		UNRESTRICT_FAILURE_SOULLESS_MACHINE = "$SILO_USER_NAME INTERFACE_EXCEPTION -> ID_ACCESS_REQUIREMENT = !ID_ACCESS_REQUIREMENT => NO_OP",
		RESTRICT_CONFIRMATION = "ID ACCESS REQUIREMENT ROUTINE STARTED: $SILO_USER_NAME has enforced ID read requirement for this ore silo.",
		UNRESTRICT_CONFIRMATION = "ID ACCESS REQUIREMENT ROUTINE SUSPENDED: $SILO_USER_NAME has removed ID read requirement for this ore silo.",
		RESTRICT_FAILURE = "ID ACCESS REQUIREMENT ROUTINE FAILED TO START: $SILO_USER_NAME()"
	)

/obj/machinery/ore_silo/Initialize(mapload)
	. = ..()
	materials = AddComponent( \
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		INFINITY, \
		container_signals = list( \
			COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/ore_silo, on_item_consumed), \
			COMSIG_MATCONTAINER_SHEETS_RETRIEVED = TYPE_PROC_REF(/obj/machinery/ore_silo, log_sheets_ejected), \
		), \
		allowed_items = /obj/item/stack \
	)
	if (!GLOB.ore_silo_default && mapload && is_station_level(z))
		GLOB.ore_silo_default = src

/obj/machinery/ore_silo/Destroy()
	if (GLOB.ore_silo_default == src)
		GLOB.ore_silo_default = null

	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		mats.disconnect_from(src)

	ore_connected_machines = null
	materials = null

	return ..()

/obj/machinery/ore_silo/proc/on_item_consumed(datum/component/material_container/container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	silo_log(context, "deposited", amount_inserted, item_inserted.name, mats_consumed)

	SEND_SIGNAL(context, COMSIG_SILO_ITEM_CONSUMED, container, item_inserted, last_inserted_id, mats_consumed, amount_inserted)

/obj/machinery/ore_silo/proc/log_sheets_ejected(datum/component/material_container/container, obj/item/stack/sheet/sheets, atom/context)
	SIGNAL_HANDLER

	silo_log(context, "ejected", -sheets.amount, "[sheets.singular_name]", sheets.custom_materials)

/obj/machinery/ore_silo/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/multitool_act(mob/living/user, obj/item/multitool/I)
	I.set_buffer(src)
	balloon_alert(user, "saved to multitool buffer")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/ore_silo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreSilo")
		ui.open()

/obj/machinery/ore_silo/ui_static_data(mob/user)
	return materials.ui_static_data()

/obj/machinery/ore_silo/ui_data(mob/user)
	var/list/data = list()

	data["materials"] =  materials.ui_data()

	data["machines"] = list()
	for(var/datum/component/remote_materials/remote as anything in ore_connected_machines)
		var/atom/parent = remote.parent
		data["machines"] += list(
			list(
				"icon" = icon2base64(icon(initial(parent.icon), initial(parent.icon_state), frame = 1)),
				"name" = parent.name,
				"onHold" = !!holds[remote],
				"location" = get_area_name(parent, TRUE),
			)
		)

	data["logs"] = list()
	for(var/datum/ore_silo_log/entry as anything in GLOB.silo_access_logs[REF(src)])
		data["logs"] += list(
			list(
				"rawMaterials" = entry.get_raw_materials(""),
				"machineName" = entry.machine_name,
				"areaName" = entry.area_name,
				"action" = entry.action,
				"amount" = entry.amount,
				"time" = entry.timestamp,
				"noun" = entry.noun,
			)
		)

	return data

/obj/machinery/ore_silo/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("remove")
			var/index = params["id"]
			if(isnull(index))
				return

			index = text2num(index)
			if(isnull(index))
				return

			var/datum/component/remote_materials/remote = ore_connected_machines[index]
			if(isnull(remote))
				return

			remote.disconnect_from(src)
			return TRUE

		if("hold")
			var/index = params["id"]
			if(isnull(index))
				return

			index = text2num(index)
			if(isnull(index))
				return

			var/datum/component/remote_materials/remote = ore_connected_machines[index]
			if(isnull(remote))
				return

			remote.toggle_holding()
			return TRUE

		if("eject")
			var/datum/material/ejecting = locate(params["ref"])
			if(!istype(ejecting))
				return

			var/amount = params["amount"]
			if(isnull(amount))
				return

			amount = text2num(amount)
			if(isnull(amount))
				return

			materials.retrieve_sheets(amount, ejecting, drop_location())
			return TRUE

/**
 * The logic for disconnecting a remote receptacle (RCD, fabricator, etc.) is collected here for sanity's sake
 * rather than being on specific types. Serves to agnosticize the remote_materials component somewhat rather than
 * snowflaking code for silos into the component.
 * * receptacle - The datum/component/remote_materials component that is getting connected.
 * * physical_receptacle - the actual object in the game world that was connected to our material supply. Typed as atom/movable for
 *   future-proofing against anything that may conceivably one day have remote silo access, such as a cyborg, an implant, structures, vehicles,
 *   and so-on.
 */
/obj/machinery/ore_silo/proc/connect_receptacle(datum/component/remote_materials/receptacle, atom/movable/physical_receptacle)
	ore_connected_machines += receptacle
	receptacle.mat_container = src.materials
	receptacle.silo = src
	RegisterSignal(physical_receptacle, COMSIG_ORE_SILO_PERMISSION_CHECKED, PROC_REF(check_permitted))

/**
 * The logic for disconnecting a remote receptacle (RCD, fabricator, etc.) is collected here for sanity's sake
 * rather than being on specific types. Cleans up references to us and to the receptacle.
 * * receptacle - The datum/component/remote_materials component that is getting destroyed.
 * * physical_receptacle - the actual object in the game world that was connected to our material supply. Typed as atom/movable for
 *   future-proofing against anything that may conceivably one day have remote silo access, such as a cyborg, an implant, structures, vehicles,
 *   and so-on.
 */
/obj/machinery/ore_silo/proc/disconnect_receptacle(datum/component/remote_materials/receptacle, atom/movable/physical_receptacle)
	ore_connected_machines -= receptacle
	receptacle.mat_container = null
	receptacle.silo = null
	holds -= receptacle
	UnregisterSignal(physical_receptacle, COMSIG_ORE_SILO_PERMISSION_CHECKED)

/obj/machinery/ore_silo/proc/check_permitted(datum/source, alist/user_data, atom/movable/physical_receptacle)
	SIGNAL_HANDLER

	if(!ID_required)
		return COMPONENT_ORE_SILO_ALLOW
	if(!islist(user_data))
		// Just allow to salvage the situation
		. = COMPONENT_ORE_SILO_ALLOW
		user_data = ID_DATA(null)
		CRASH("Invalid data passed to check_permitted")
	if(user_data[SILICON_OVERRIDE] || user_data[CHAMELEON_OVERRIDE] || astype(user_data["accesses"], /list)?.Find(ACCESS_QM))
		return COMPONENT_ORE_SILO_ALLOW
	if(user_data[ID_READ_FAILURE])
		physical_receptacle.say("SILO ERR: ID interface failure. Please contact the Head of Personnel.")
		return COMPONENT_ORE_SILO_DENY
	if(!user_data["account_id"] || !isnum(user_data["account_id"]))
		if(prob(5))
			physical_receptacle.say("SILO ERR: Bank account ID not found. Initiating anti-communist silo-access policy.")
		physical_receptacle.say("SILO ERR: No account ID found. Please contact Head of Personnel.")
		return COMPONENT_ORE_SILO_DENY
	if(banned_users.Find(user_data["account_id"]))
		physical_receptacle.say("SILO ERR: You are banned from using this ore silo.")
		return COMPONENT_ORE_SILO_DENY
	return COMPONENT_ORE_SILO_ALLOW

/obj/machinery/ore_silo/ui_interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "ore_silo", null, 600, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/ore_silo/proc/generate_ui()
	var/list/ui = list("<head><title>Ore Silo</title></head><body><div class='statusDisplay'><h2>Stored Material:</h2>")
	var/any = FALSE
	for(var/M in materials.materials)
		var/datum/material/mat = M
		var/amount = materials.materials[M]
		var/sheets = round(amount) / SHEET_MATERIAL_AMOUNT
		var/ref = REF(M)
		if (sheets)
			if (sheets >= 1)
				ui += "<a href='byond://?src=[REF(src)];ejectsheet=[ref];eject_amt=1'>Eject</a>"
			else
				ui += "<span class='linkOff'>Eject</span>"
			if (sheets >= 20)
				ui += "<a href='byond://?src=[REF(src)];ejectsheet=[ref];eject_amt=20'>20x</a>"
			else
				ui += "<span class='linkOff'>20x</span>"
			ui += "<b>[mat.name]</b>: [sheets] sheets<br>"
			any = TRUE
	if(!any)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Connected Machines:</h2>"
	for(var/datum/component/remote_materials/mats as anything in ore_connected_machines)
		var/atom/parent = mats.parent
		ui += "<a href='byond://?src=[REF(src)];remove=[REF(mats)]'>Remove</a>"
		ui += "<a href='byond://?src=[REF(src)];hold=[REF(mats)]'>[holds[mats] ? "Allow" : "Hold"]</a>"
		ui += " <b>[parent.name]</b> in [get_area_name(parent, TRUE)]<br>"
	if(!ore_connected_machines.len)
		ui += "Nothing!"

	ui += "</div><div class='statusDisplay'><h2>Access Logs:</h2>"
	var/list/logs = GLOB.silo_access_logs[REF(src)]
	var/len = LAZYLEN(logs)
	var/num_pages = 1 + round((len - 1) / 30)
	var/page = clamp(log_page, 1, num_pages)
	if(num_pages > 1)
		for(var/i in 1 to num_pages)
			if(i == page)
				ui += "<span class='linkOff'>[i]</span>"
			else
				ui += "<a href='byond://?src=[REF(src)];page=[i]'>[i]</a>"

	ui += "<ol>"
	any = FALSE
	for(var/i in (page - 1) * 30 + 1 to min(page * 30, len))
		var/datum/ore_silo_log/entry = logs[i]
		ui += "<li value=[len + 1 - i]>[entry.formatted]</li>"
		any = TRUE
	if (!any)
		ui += "<li>Nothing!</li>"

	ui += "</ol></div>"
	return ui.Join()

/obj/machinery/ore_silo/Topic(href, href_list)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["remove"])
		var/datum/component/remote_materials/mats = locate(href_list["remove"]) in ore_connected_machines
		if (mats)
			mats.disconnect_from(src)
			updateUsrDialog()
			return TRUE
	else if(href_list["hold"])
		var/datum/component/remote_materials/mats = locate(href_list["hold"]) in ore_connected_machines
		mats.toggle_holding()
		updateUsrDialog()
		return TRUE
	else if(href_list["ejectsheet"])
		var/datum/material/eject_sheet = locate(href_list["ejectsheet"])
		var/amount = text2num(href_list["eject_amt"])
		materials.retrieve_sheets(amount, eject_sheet, drop_location())
		return TRUE
	else if(href_list["page"])
		log_page = text2num(href_list["page"]) || 1
		updateUsrDialog()
		return TRUE

/obj/machinery/ore_silo/proc/silo_log(obj/machinery/M, action, amount, noun, list/mats)
	if (!length(mats))
		return
	var/datum/ore_silo_log/entry = new(M, action, amount, noun, mats)

	var/list/datum/ore_silo_log/logs = GLOB.silo_access_logs[REF(src)]
	if(!LAZYLEN(logs))
		GLOB.silo_access_logs[REF(src)] = logs = list(entry)
	else if(!logs[1].merge(entry))
		logs.Insert(1, entry)

	updateUsrDialog()
	flick("silo_active", src)

/obj/machinery/ore_silo/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be linked to techfabs, circuit printers and protolathes with a multitool.")

/datum/ore_silo_log
	var/name  // for VV
	var/formatted  // for display

	var/timestamp
	var/machine_name
	var/area_name
	var/action
	var/noun
	var/amount
	var/list/materials

/datum/ore_silo_log/New(obj/machinery/M, _action, _amount, _noun, list/mats=list())
	timestamp = station_time_timestamp()
	machine_name = M.name
	area_name = get_area_name(M, TRUE)
	action = _action
	amount = _amount
	noun = _noun
	materials = mats.Copy()
	for(var/each in materials)
		materials[each] *= abs(_amount)
	format()
	var/list/data = list(
		"machine_name" = machine_name,
		"area_name" = AREACOORD(M),
		"action" = action,
		"amount" = abs(amount),
		"noun" = noun,
		"raw_materials" = get_raw_materials(""),
		"direction" = amount < 0 ? "withdrawn" : "deposited",
	)
	logger.Log(
		LOG_CATEGORY_SILO,
		"[machine_name] in \[[AREACOORD(M)]\] [action] [abs(amount)]x [noun] | [get_raw_materials("")]",
		data,
	)

/datum/ore_silo_log/proc/merge(datum/ore_silo_log/other)
	if (other == src || action != other.action || noun != other.noun)
		return FALSE
	if (machine_name != other.machine_name || area_name != other.area_name)
		return FALSE

	timestamp = other.timestamp
	amount += other.amount
	for(var/each in other.materials)
		materials[each] += other.materials[each]
	format()
	return TRUE

/datum/ore_silo_log/proc/format()
	name = "[machine_name]: [action] [amount]x [noun]"
	formatted = "([timestamp]) <b>[machine_name]</b> in [area_name]<br>[action] [abs(amount)]x [noun]<br> [get_raw_materials("")]"

/datum/ore_silo_log/proc/get_raw_materials(separator)
	var/list/msg = list()
	for(var/key in materials)
		var/datum/material/M = key
		var/val = round(materials[key])
		msg += separator
		separator = ", "
		msg += "[amount < 0 ? "-" : "+"][val] [M.name]"
	return msg.Join()
