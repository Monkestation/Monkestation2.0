GLOBAL_DATUM(snail_debt, /datum/snail_debt)

/// Provenance ledger for the single cursed payout. Normal income is never marked.
/datum/snail_debt
	var/list/claims = list()
	var/list/last_carriers = list()
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

/datum/snail_debt/proc/remember_carrier(datum/holder)
	var/mob/living/carrier = carrier_of(holder)
	if(carrier)
		last_carriers[holder] = WEAKREF(carrier)

/datum/snail_debt/proc/on_money_moved(datum/source)
	SIGNAL_HANDLER
	remember_carrier(source)
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
	var/atom/container = source_location
	while(container && !isturf(container))
		if(isliving(container))
			spender = container
			break
		container = container.loc
	if(!spender)
		var/datum/weakref/last_carrier = last_carriers[from]
		spender = last_carrier?.resolve()
	// Station budgets, CC and economic sinks cannot return physical credits.
	// The spender inherits a death debt instead; dropping other cash cannot clear it.
	if(!recipient || IS_DEPARTMENTAL_ACCOUNT(recipient) || istype(recipient, /datum/bank_account/remote))
		if(spender && spender.stat != DEAD)
			recipient = spender
	if(!recipient)
		recipient = new /obj/effect/snail_credit_trace(get_turf(source_location) || origin)
	mark(recipient, moving)
	if(spender && !last_carriers[recipient])
		last_carriers[recipient] = WEAKREF(spender)
	claims[from] -= moving
	if(!claims[from])
		claims -= from
		last_carriers -= from
		UnregisterSignal(from, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_MOVABLE_MOVED, COMSIG_CREDITS_TRANSFERRED))

/datum/snail_debt/proc/on_debtor_death(mob/living/source)
	SIGNAL_HANDLER
	recovered += claims[source]
	claims -= source
	last_carriers -= source
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_LIVING_DEATH, COMSIG_CREDITS_TRANSFERRED))

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

/// Non-spendable trace left where currency was consumed by an economic sink.
/obj/effect/snail_credit_trace
	name = "cursed credit residue"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
