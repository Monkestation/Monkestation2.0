/obj/machinery/gang_machine/credit_converter/siphon
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator-Blue"
	credits_per_rep = 50
	desired_rep_per_process = 3
	gives_message = FALSE

/obj/machinery/gang_machine/credit_converter/siphon/Initialize(mapload, gang)
	. = ..()
	begin_processing()
	addtimer(CALLBACK(src, PROC_REF(announce)), 1 MINUTE)

/obj/machinery/gang_machine/credit_converter/siphon/process(seconds_per_tick)
	var/datum/bank_account/account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(account)
		var/siphoned = min(account.account_balance, credits_per_rep * desired_rep_per_process)
		account.adjust_money(-siphoned)
		stored_credits += siphoned
	..() //dont return as we dont want to process kill

/obj/machinery/gang_machine/credit_converter/siphon/proc/announce()
	priority_announce("Data theft signal detected, source registered on local gps units.")
	AddComponent(/datum/component/gps, "Data Theft Signal")

//used by objectives
/obj/machinery/gang_machine/credit_converter/siphon/proc/send_activation_signal()
	if(QDELETED(src))
		return

	SEND_SIGNAL(src, COMSIG_GANG_MACHINE_ACTIVATED, src)
