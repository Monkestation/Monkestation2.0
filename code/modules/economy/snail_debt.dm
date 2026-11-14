GLOBAL_DATUM(snail_debt, /datum/snail_debt)

/// Provenance ledger for the single cursed payout. Normal income is never marked.
/datum/snail_debt
	var/list/claims = list()
	var/list/last_carriers = list()
	/// Banked cursed funds retain the identity of the person who deposited them.
	var/list/banked_debts = list()
	var/list/debtor_refs = list()
	var/turf/origin
	var/recovered = 0
	/// The pursuer owns this ledger; other snails must not delete or consume it.
	var/datum/weakref/collector_ref

/datum/snail_debt/New(turf/origin)
	src.origin = origin
	return ..()

/datum/snail_debt/Destroy()
	for(var/datum/holder as anything in claims)
		UnregisterSignal(holder, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_CREDITS_TRANSFERRED))
		if(istype(holder, /obj/effect/snail_credit_trace))
			qdel(holder)
	claims.Cut()
	last_carriers.Cut()
	banked_debts.Cut()
	debtor_refs.Cut()
	clear_curse_alerts()
	origin = null
	collector_ref = null
	if(GLOB.snail_debt == src)
		GLOB.snail_debt = null
	return ..()

/datum/snail_debt/proc/mark(datum/holder, amount)
	if(!holder || amount <= 0)
		return
	if(!claims[holder])
		RegisterSignal(holder, COMSIG_QDELETING, PROC_REF(on_deleted))
		RegisterSignal(holder, COMSIG_CREDITS_TRANSFERRED, PROC_REF(on_credits_transferred))
		if(isliving(holder))
			RegisterSignal(holder, COMSIG_LIVING_DEATH, PROC_REF(on_debtor_death))
		else if(ismovable(holder))
			RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_money_moved))
	claims[holder] += amount
	remember_carrier(holder)
	if(istype(holder, /obj/item/holochip))
		var/obj/item/holochip/chip = holder
		chip.update_appearance()
	update_curse_alerts()

/datum/snail_debt/proc/remember_carrier(datum/holder)
	var/mob/living/carrier = carrier_of(holder)
	if(carrier)
		last_carriers[holder] = WEAKREF(carrier)

/datum/snail_debt/proc/on_money_moved(datum/source)
	SIGNAL_HANDLER
	remember_carrier(source)
	update_curse_alerts()
	if(!get_turf(location_of(source)))
		transfer(source, null, claims[source])

/datum/snail_debt/proc/on_credits_transferred(datum/source, datum/recipient, amount)
	SIGNAL_HANDLER
	transfer(source, recipient, amount)

/datum/snail_debt/proc/refresh_carriers()
	for(var/datum/holder as anything in claims.Copy())
		remember_carrier(holder)
		// Moving an enclosing container can strand money without moving the money itself.
		if(!isliving(holder) && !get_turf(location_of(holder)))
			transfer(holder, null, claims[holder])

/// Cursed credits leave first, making splitting and laundering deterministic.
/datum/snail_debt/proc/transfer(datum/from, datum/recipient, amount)
	var/moving = min(claims[from], amount)
	if(moving <= 0 || from == recipient)
		return
	var/atom/source_location = location_of(from)
	var/mob/living/spender
	var/datum/weakref/last_carrier = last_carriers[from]
	var/atom/container = source_location
	while(container && !isturf(container))
		if(isliving(container))
			spender = container
			break
		container = container.loc
	if(!spender)
		spender = last_carrier?.resolve()
	// Station budgets, CC and economic sinks cannot return physical credits.
	// The spender inherits a death debt instead; dropping other cash cannot clear it.
	var/settled_by_death = FALSE
	if(!recipient || IS_DEPARTMENTAL_ACCOUNT(recipient) || istype(recipient, /datum/bank_account/remote))
		if(spender && spender.stat != DEAD)
			recipient = spender
		else if(spender?.stat == DEAD)
			settled_by_death = TRUE
		else if(last_carrier)
			var/mob/living/basic/immortal_snail/collector = collector_ref?.resolve()
			if(collector && (collector.original_dead || !collector.original_target()) && (last_carrier == collector.target_ref || last_carrier == collector.corpse_ref))
				settled_by_death = TRUE
	if(settled_by_death)
		recovered += moving
	else if(!recipient)
		recipient = new /obj/effect/snail_credit_trace(get_turf(source_location) || origin)
	if(!settled_by_death)
		mark(recipient, moving)
		if(spender && !last_carriers[recipient])
			last_carriers[recipient] = WEAKREF(spender)
		if(istype(recipient, /datum/bank_account))
			remember_banked_debt(recipient, spender, moving)
	if(istype(from, /datum/bank_account))
		consume_banked_debt(from, spender, moving)
	claims[from] -= moving
	if(!claims[from])
		claims -= from
		last_carriers -= from
		banked_debts -= from
		UnregisterSignal(from, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_CREDITS_TRANSFERRED))
		if(istype(from, /obj/item/holochip))
			var/obj/item/holochip/chip = from
			chip.update_appearance()
	update_curse_alerts()

/datum/snail_debt/proc/on_debtor_death(mob/living/source)
	SIGNAL_HANDLER
	recovered += claims[source]
	claims -= source
	last_carriers -= source
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_CREDITS_TRANSFERRED))
	update_curse_alerts()

/datum/snail_debt/proc/on_deleted(datum/source)
	SIGNAL_HANDLER
	if(isliving(source))
		on_debtor_death(source)
		return
	// Destruction cannot erase the debt; spent/destroyed currency leaves a trace.
	transfer(source, null, claims[source])

/datum/snail_debt/proc/location_of(datum/holder)
	if(istype(holder, /datum/bank_account))
		var/datum/bank_account/account = holder
		var/obj/item/card/id/fallback
		for(var/obj/item/card/id/card as anything in account.bank_cards)
			if(QDELETED(card) || card.registered_account != account || !get_turf(card))
				continue
			fallback = card
			var/atom/container = card.loc
			while(container && !isturf(container))
				if(isliving(container))
					return card
				container = container.loc
		return fallback ? fallback : origin
	if(isatom(holder))
		return holder
	return origin

/datum/snail_debt/proc/carrier_of(datum/holder)
	var/atom/container = location_of(holder)
	while(container && !isturf(container))
		if(isliving(container))
			return container
		container = container.loc

/datum/snail_debt/proc/next_claim()
	var/datum/unreachable
	for(var/datum/holder as anything in claims)
		if(get_turf(location_of(holder)))
			return holder
		unreachable = holder
	// No reachable claim is different from no outstanding debt.
	return unreachable

/datum/snail_debt/proc/collect(datum/holder)
	var/amount = claims[holder]
	if(!amount)
		return
	if(istype(holder, /datum/bank_account))
		var/datum/bank_account/account = holder
		var/shortfall = amount - max(0, account.account_balance)
		if(shortfall > 0)
			// Uninstrumented balance changes cannot erase currency that went missing.
			transfer(holder, null, shortfall)
			amount = claims[holder]
			if(!amount)
				return
	claims -= holder
	last_carriers -= holder
	banked_debts -= holder
	UnregisterSignal(holder, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_CREDITS_TRANSFERRED))
	recovered += amount
	if(isliving(holder))
		var/mob/living/debtor = holder
		debtor.death()
	else if(istype(holder, /obj/item/holochip))
		var/obj/item/holochip/chip = holder
		chip.credits = max(0, chip.credits - amount)
		if(chip.credits)
			chip.update_appearance()
		else
			qdel(chip)
	else if(istype(holder, /datum/bank_account))
		var/datum/bank_account/account = holder
		account.adjust_money(-min(amount, account.account_balance), "Other: Immortal snail reclaimed cursed credits")
		account.bank_card_talk(span_warning("An impossible transfer reclaims [amount] cursed credits. The debt is settled."), TRUE)
	else if(istype(holder, /obj/effect/snail_credit_trace))
		qdel(holder)
	update_curse_alerts()

/// Records whose personal status owns cursed credits after they are deposited.
/datum/snail_debt/proc/remember_banked_debt(datum/bank_account/account, mob/living/debtor, amount)
	if(!account || !debtor || amount <= 0)
		return
	var/debtor_key = REF(debtor)
	debtor_refs[debtor_key] = WEAKREF(debtor)
	LAZYINITLIST(banked_debts[account])
	banked_debts[account][debtor_key] += amount

/// A withdrawal takes the depositor's own cursed balance first, then any remaining pooled balance.
/datum/snail_debt/proc/consume_banked_debt(datum/bank_account/account, mob/living/preferred_debtor, amount)
	var/list/account_debts = banked_debts[account]
	if(!account_debts || amount <= 0)
		return
	var/remaining = amount
	if(preferred_debtor)
		remaining -= consume_banked_debt_for(account_debts, REF(preferred_debtor), remaining)
	for(var/debtor_key in account_debts.Copy())
		if(remaining <= 0)
			break
		remaining -= consume_banked_debt_for(account_debts, debtor_key, remaining)
	if(!length(account_debts))
		banked_debts -= account

/datum/snail_debt/proc/consume_banked_debt_for(list/account_debts, debtor_key, amount)
	var/available = account_debts[debtor_key]
	var/consumed = min(available, amount)
	account_debts[debtor_key] -= consumed
	if(!account_debts[debtor_key])
		account_debts -= debtor_key
	return consumed

/// Shows every player both carried and personally banked cursed balances.
/datum/snail_debt/proc/update_curse_alerts()
	var/list/debts_by_carrier = list()
	for(var/datum/holder as anything in claims)
		if(istype(holder, /datum/bank_account))
			continue
		var/mob/living/carrier = carrier_of(holder)
		if(carrier)
			debts_by_carrier[carrier] += claims[holder]
	for(var/datum/bank_account/account as anything in banked_debts)
		for(var/debtor_key in banked_debts[account])
			var/mob/living/debtor = debtor_refs[debtor_key]?.resolve()
			if(debtor)
				debts_by_carrier[debtor] += banked_debts[account][debtor_key]
	for(var/mob/living/person as anything in GLOB.player_list)
		var/amount = debts_by_carrier[person]
		if(amount)
			var/atom/movable/screen/alert/immortal_snail_debt/alert = person.throw_alert("immortal_snail_debt", /atom/movable/screen/alert/immortal_snail_debt)
			alert?.set_debt(amount)
		else
			person.clear_alert("immortal_snail_debt")

/datum/snail_debt/proc/clear_curse_alerts()
	for(var/mob/living/person as anything in GLOB.player_list)
		person.clear_alert("immortal_snail_debt")

/// Non-spendable trace left where currency was consumed by an economic sink.
/obj/effect/snail_credit_trace
	name = "cursed credit residue"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
