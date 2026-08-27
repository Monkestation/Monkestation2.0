/datum/computer_file/program/budgetorders
	filename = "orderapp"
	filedesc = "NT Shopping Network"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Nanotrasen Shopping Network interface for purchasing supplies from the cargo catalogue using a department budget account."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 10
	tgui_id = "NtosCargo"
	program_icon = FA_ICON_CART_FLATBED
	///Access needed to approve things within the app.
	var/approve_access = ACCESS_CARGO
	///The Cargo console we steal for its UI and such.
	var/obj/machinery/computer/cargo/cargo_console

/datum/computer_file/program/budgetorders/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	cargo_console = new(computer_installing)

/datum/computer_file/program/budgetorders/Destroy()
	QDEL_NULL(cargo_console)
	return ..()

/datum/computer_file/program/budgetorders/ui_data(mob/user)
	var/list/data = cargo_console.ui_data(user)

	var/datum/bank_account/buyer = SSeconomy.get_dep_account(cargo_console.cargo_account)
	var/obj/item/card/id/id_card = computer.computer_id_slot?.GetID()

	//Command can put orders in using their department's account
	if(ACCESS_COMMAND in id_card?.access)
		if(id_card?.registered_account?.account_job)
			buyer = SSeconomy.get_dep_account(id_card?.registered_account.account_job.paycheck_department)
	//Cargo techs can use it as a regular cargo console
	else if(approve_access in id_card?.access)
		cargo_console.requestonly = FALSE
		cargo_console.can_approve_requests = TRUE
	//Everyone else is just a request console
	else
		cargo_console.requestonly = TRUE
		cargo_console.can_approve_requests = FALSE

	data["department"] = "[buyer.account_holder] Requisitions"
	return data

/datum/computer_file/program/budgetorders/ui_static_data(mob/user)
	return cargo_console.ui_static_data(user)

/datum/computer_file/program/budgetorders/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	return cargo_console.ui_act(action, params, ui, state)
