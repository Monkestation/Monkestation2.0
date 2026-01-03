#define MAX_ADVANCES 3
#define MIN_PAY_MOD 0.5
#define MAX_PAY_MOD 1.5

/obj/machinery/computer/accounting
	name = "account lookup console"
	desc = "Used to view crew member accounts and purchases."
	icon_screen = "accounts"
	icon_keyboard = "id_key"
	circuit = /obj/item/circuitboard/computer/accounting
	light_color = LIGHT_COLOR_GREEN

	///In Union mode, we show Cargo-related stuff.
	var/union_mode = FALSE

/obj/machinery/computer/accounting/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "AccountingConsole", name)
		ui.open()

/obj/machinery/computer/accounting/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["crashing"] = HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING)
	data["station_time"] = station_time_timestamp("hh:mm")
	return data

/obj/machinery/computer/accounting/ui_static_data(mob/user)
	var/list/data = list()
	var/static/ian_format = pick("png", "jpg", "jpeg", "webp", "bmp")
	data["pic_file_format"] = ian_format
	data["young_ian"] = check_holidays(IAN_HOLIDAY)
	data["union_mode"] = union_mode
	data["max_advances"] = MAX_ADVANCES
	data["max_pay_mod"] = MAX_PAY_MOD
	data["min_pay_mod"] = MIN_PAY_MOD
	return data

/obj/machinery/computer/accounting/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	playsound(src, SFX_TERMINAL_TYPE, 50, FALSE)

/obj/machinery/computer/accounting/hop/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/bank_account/bank_account = SSeconomy.bank_accounts_by_id[params["account_id"]]
	if(isnull(bank_account) || !(bank_account.account_job?.job_flags & JOB_CREW_MANIFEST))
		return

	switch(action)
		if("paycheck_advance")
			if(bank_account.paydays_to_skip[bank_account.account_job.paycheck_department] < MAX_ADVANCES)
				bank_account.payday(1, event = "Paycheck advance")
				bank_account.paydays_to_skip[bank_account.account_job.paycheck_department] += 1
			return TRUE
		if("change_pay_mod")
			var/old_modifier = bank_account.payday_modifier[bank_account.account_job.paycheck_department]
			bank_account.payday_modifier[bank_account.account_job.paycheck_department] = clamp(round(text2num(params["pay_mod"]), 0.05), MIN_PAY_MOD, MAX_PAY_MOD)
			var/new_check_total = bank_account.payday_modifier[bank_account.account_job.paycheck_department] * bank_account.account_job.paycheck
			var/raise_or_cut = new_check_total > old_modifier * bank_account.account_job.paycheck ? "raised" : "cut"
			bank_account.bank_card_talk("Paycheck [raise_or_cut] to [new_check_total]cr.")
			SSeconomy.add_audit_entry(bank_account, new_check_total, "Paycheck [raise_or_cut]")
			return TRUE

/obj/machinery/computer/accounting/hop/ui_data(mob/user)
	var/list/data = ..()
	var/list/player_accounts = list()

	for(var/id in SSeconomy.bank_accounts_by_id)
		var/datum/bank_account/current_bank_account = SSeconomy.bank_accounts_by_id[id]
		if(!(current_bank_account.account_job?.job_flags & JOB_CREW_MANIFEST))
			continue
		player_accounts += list(list(
			"name" = current_bank_account.account_holder,
			"job" = current_bank_account.account_job.title,
			"balance" = round(current_bank_account.account_balance),
			"modifier" = current_bank_account.payday_modifier[current_bank_account.account_job.paycheck_department],
			"num_advances" = current_bank_account.paydays_to_skip[current_bank_account.account_job.paycheck_department] || 0,
			"id" = id,
		))
	data["accounts"] = player_accounts
	data["audit_log"] = SSeconomy.audit_log
	return data

/obj/machinery/computer/accounting/union
	name = "union management console"
	desc = "Handles paychecks of all Union personnel."
	union_mode = TRUE

/obj/machinery/computer/accounting/union/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/bank_account/bank_account = SSeconomy.bank_accounts_by_id[params["account_id"]]
	if(isnull(bank_account) || !(bank_account.account_job?.job_flags & JOB_CREW_MANIFEST))
		return

	switch(action)
		if("paycheck_advance")
			if(bank_account.paydays_to_skip[ACCOUNT_CAR] < MAX_ADVANCES)
				bank_account.payday(1, event = "Union pay advance", budget_used = ACCOUNT_CAR)
				bank_account.paydays_to_skip[ACCOUNT_CAR] += 1
			return TRUE
		if("change_pay_mod")
			var/old_modifier = bank_account.payday_modifier[ACCOUNT_CAR]
			bank_account.payday_modifier[ACCOUNT_CAR] = clamp(round(text2num(params["pay_mod"]), 0.05), MIN_PAY_MOD, MAX_PAY_MOD)
			var/new_check_total = bank_account.payday_modifier[ACCOUNT_CAR] * bank_account.account_job.paycheck
			var/raise_or_cut = new_check_total > old_modifier * bank_account.account_job.paycheck ? "raised" : "cut"
			bank_account.bank_card_talk("Union pay [raise_or_cut] to [new_check_total]cr.")
			SSeconomy.add_audit_entry(bank_account, new_check_total, "Paycheck [raise_or_cut]")
			return TRUE

/obj/machinery/computer/accounting/union/ui_data(mob/user)
	var/list/data = ..()
	var/list/player_accounts = list()
	for(var/member in GLOB.cargo_union.union_employees)
		var/datum/bank_account/current_bank_account = member[CARGO_UNION_BANK]
		if(!(current_bank_account.account_job?.job_flags & JOB_CREW_MANIFEST))
			continue
		player_accounts += list(list(
			"name" = member[CARGO_UNION_NAME],
			"job" = current_bank_account.account_job.title,
			"balance" = round(current_bank_account.account_balance),
			"modifier" = current_bank_account.payday_modifier[ACCOUNT_CAR],
			"num_advances" = current_bank_account.paydays_to_skip[ACCOUNT_CAR] || 0,
			"id" = "[current_bank_account.account_id]",
		))
	data["accounts"] = player_accounts
	data["audit_log"] = list()
	return data

#undef MAX_ADVANCES
#undef MIN_PAY_MOD
#undef MAX_PAY_MOD
