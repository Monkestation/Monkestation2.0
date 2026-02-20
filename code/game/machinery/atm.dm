/// List of bank accounts playing the lottery with amount of tickets sold.
GLOBAL_LIST_EMPTY_TYPED(lottery_ticket_owners, /datum/bank_account)

/obj/machinery/atm
	name = "ATM"
	desc = "You can withdraw or deposit Monkecoins in here, also acts as a terminal for flash sale items."

	density = FALSE
	active_power_usage = 0

	max_integrity = 10000

	icon = 'monkestation/icons/obj/machines/atm.dmi'
	icon_state = "atm"

	///the flash sale item if avaliable
	var/static/datum/store_item/flash_sale_datum
	///the current size of the lottery prize pool
	var/static/lottery_pool = 500
	///static variable to check if a lottery is running
	var/static/lottery_running = FALSE
	///static var, keeping track of how much time there is until the next lottery pull.
	var/static/lottery_timer_id

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/atm, 30)

/obj/machinery/atm/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, INFINITY)
	if(!lottery_running)
		lottery_running = TRUE
		lottery_timer_id = addtimer(CALLBACK(src, PROC_REF(poll_lottery_winner)), 20 MINUTES, TIMER_STOPPABLE)

/obj/machinery/atm/ui_interact(mob/user, datum/tgui/ui)
	if(!is_operational || !user.client)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ATM")
		ui.open()

/obj/machinery/atm/ui_data(mob/user)
	var/list/data = list()
	if(!user.client)
		return

	var/datum/bank_account/registed_account = astype(user, /mob/living)?.get_bank_account()
	if(isnull(registed_account) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		registed_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]

	var/cash_balance = 0
	if(registed_account)
		cash_balance = registed_account.account_balance

	data["meta_balance"] = user.client.prefs.metacoins
	data["cash_balance"] = cash_balance
	data["lottery_pool"] = lottery_pool
	data["time_until_draw"] = DisplayTimeText(timeleft(lottery_timer_id))
	return data

/obj/machinery/atm/ui_static_data(mob/user)
	var/list/data = list()

	var/flash_value = FALSE
	if(flash_sale_datum)
		flash_value = TRUE
		data["flash_sale_name"] = flash_sale_datum.name
		data["flash_sale_cost"] = flash_sale_datum.item_cost
		data["flash_sale_desc"] = flash_sale_datum.store_desc

	data["flash_sale_present"] = flash_value
	return data

/obj/machinery/atm/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("withdraw")
			attempt_withdraw(user)
			return TRUE
		if("withdraw_cash")
			withdraw_cash(user)
			return TRUE
		if("lottery_buy")
			buy_lottery(user)
			return TRUE
		if("buy_flash")
			buy_flash_sale(user)
			return TRUE
		if("buy_lootbox")
			buy_lootbox(user)
			return TRUE
	return TRUE

/obj/machinery/atm/proc/poll_lottery_winner()
	if(length(GLOB.lottery_ticket_owners))
		var/datum/bank_account/winning_account = pick_weight(GLOB.lottery_ticket_owners)
		winning_account.adjust_money(lottery_pool, "Lottery Winner")
		priority_announce("[winning_account.account_holder] has just won the station lottery winning a total of [lottery_pool] credits! The next lottery will begin in 20 minutes!", "Nanotrasen Gambling Society")
		lottery_pool = 0
	else
		priority_announce("No one has won the lottery with a prize pool of [lottery_pool] credits, the next lottery will happen in 20 minutes.", "Nanotrasen Gambling Society")
	lottery_pool += 500
	GLOB.lottery_ticket_owners.Cut()
	deltimer(lottery_timer_id)
	lottery_timer_id = addtimer(CALLBACK(src, PROC_REF(poll_lottery_winner)), 20 MINUTES, TIMER_STOPPABLE)

/obj/machinery/atm/proc/buy_lottery(mob/user)
	var/datum/bank_account/registed_account = astype(user, /mob/living)?.get_bank_account()
	if(isnull(registed_account) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		registed_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
	if(isnull(registed_account))
		return
	var/cash_balance = registed_account.account_balance || 0
	if(cash_balance < 100)
		balloon_alert(user, "not enough money!")
		return
	var/tickets_bought = tgui_input_number(user, "How many tickets would you like to buy?", "ATM", 0, round(cash_balance * 0.01), 0)
	if(!tickets_bought)
		return

	registed_account.adjust_money(-(tickets_bought * 100), "Lottery Ticket")
	GLOB.lottery_ticket_owners[registed_account] += tickets_bought
	lottery_pool += tickets_bought * 100

/obj/machinery/atm/proc/buy_flash_sale(mob/user)
	if(!flash_sale_datum)
		return
	if(flash_sale_datum.item_path in user.client.prefs.inventory)
		return
	if(flash_sale_datum.attempt_purchase(user.client))
		say("Item successfully purchased.")

/obj/machinery/atm/proc/attempt_withdraw(mob/user)
	var/current_balance = user.client.prefs.metacoins
	var/withdraw_amount = tgui_input_number(user, "How many Monkecoins would you like to withdraw?", "ATM", 0 , current_balance, 0)
	if(!withdraw_amount)
		return

	withdraw_amount = clamp(withdraw_amount, 0, current_balance)
	if(!user.client.prefs.adjust_metacoins(user.client.ckey, -withdraw_amount, "Withdrew from an ATM", donator_multiplier = FALSE))
		return

	var/obj/item/stack/monkecoin/coin_stack = new(user.loc)
	coin_stack.amount = withdraw_amount
	coin_stack.update_desc()
	user.put_in_hands(coin_stack)

/obj/machinery/atm/proc/buy_lootbox(mob/user)
	var/current_balance = user.client.prefs.metacoins
	if(tgui_alert(user, "Are you sure you would like to purchase a lootbox for [LOOTBOX_COST] monkecoins?", "Balance: [current_balance]", list("Yes", "No")) != "Yes")
		return
	if(!user.client.prefs.has_coins(LOOTBOX_COST))
		balloon_alert(user, "not enough monkecoins!")
		return
	if(!user.client.prefs.adjust_metacoins(user.client.ckey, -LOOTBOX_COST, "Bought a lootbox"))
		return

	var/obj/item/lootbox/box = new(get_turf(user))
	user.put_in_hands(box)


/obj/machinery/atm/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/monkecoin))
		var/obj/item/stack/monkecoin/attacked_coins = tool
		var/coin_amount = attacked_coins.amount
		if(QDELETED(attacked_coins) || !user.temporarilyRemoveItemFromInventory(attacked_coins, force = TRUE))
			return
		if(attacked_coins.amount != coin_amount)
			stack_trace("Monkecoin stack amount somehow changed while removing from inventory (from [coin_amount] to [attacked_coins.amount])")
		qdel(attacked_coins)
		var/ckey = user.client?.ckey
		if(!user.client?.prefs?.adjust_metacoins(ckey, coin_amount, "Deposited coins to an ATM", donator_multiplier = FALSE))
			say("Error accepting coins, please try again later.")
			user.put_in_hands(new /obj/item/stack/monkecoin(drop_location(), coin_amount, FALSE), merge_stacks = FALSE)
			return
		say("Coins deposited to your account, have a nice day.")
		return ITEM_INTERACT_SUCCESS

	else if(istype(tool, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/attacked_cash = tool
		var/datum/bank_account/registed_account = astype(user, /mob/living)?.get_bank_account()
		if(isnull(registed_account) && ishuman(user))
			var/mob/living/carbon/human/human_user = user
			registed_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
		if(isnull(registed_account))
			balloon_alert(user, "no bank account!")
			return ITEM_INTERACT_BLOCKING
		registed_account.adjust_money(attacked_cash.get_item_credit_value(), "ATM: Deposit")
		qdel(attacked_cash)
		return ITEM_INTERACT_SUCCESS

	else if(istype(tool, /obj/item/holochip))
		var/obj/item/holochip/attacked_chip = tool
		var/datum/bank_account/registed_account = astype(user, /mob/living)?.get_bank_account()
		if(isnull(registed_account) && ishuman(user))
			var/mob/living/carbon/human/human_user = user
			registed_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
		if(isnull(registed_account))
			balloon_alert(user, "no bank account!")
			return ITEM_INTERACT_BLOCKING
		registed_account.adjust_money(attacked_chip.credits, "ATM: Deposit")
		qdel(attacked_chip)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/machinery/atm/proc/withdraw_cash(mob/user)
	var/datum/bank_account/registed_account = astype(user, /mob/living)?.get_bank_account()
	if(isnull(registed_account) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		registed_account = SSeconomy.bank_accounts_by_id["[human_user.account_id]"]
	if(isnull(registed_account))
		return
	var/withdrawn_amount = tgui_input_number(user, "How much cash would you like to withdraw?", "ATM", 0, registed_account.account_balance, 0)
	if(!withdrawn_amount)
		return

	withdrawn_amount = clamp(withdrawn_amount, 0, registed_account.account_balance)
	registed_account.adjust_money(-withdrawn_amount, "ATM: Withdrawal")
	var/obj/item/stack/spacecash/c1/stack_of_cash = new(user.drop_location())
	stack_of_cash.amount = withdrawn_amount
	user.put_in_hands(stack_of_cash)
