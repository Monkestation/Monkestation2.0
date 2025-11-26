/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	/// The maximum amount of stamina this container has.
	/// Don't touch this directly, it is set using set_maximum().
	var/maximum = 0
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = 10
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Every tick, remove this much stamina
	var/decrement = 0
	///Are we regenerating right now?
	var/is_regenerating = TRUE
	//unga bunga
	var/process_stamina = TRUE
	/// Used to determine when the stamina changes, to properly run on_stamina_update on the parent.
	VAR_PRIVATE/should_notify_parent = FALSE

	///cooldowns
	///how long until we can lose stamina again
	COOLDOWN_DECLARE(stamina_grace_period)
	///how long stamina is paused for
	COOLDOWN_DECLARE(paused_stamina)

	/// Signals which we react in order to re-check if we should be processing or not.
	var/static/list/update_on_signals = list(
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_NO_TRANSFORM),
		SIGNAL_REMOVETRAIT(TRAIT_NO_TRANSFORM),
	)

/datum/stamina_container/New(parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	if(maximum <= 0)
		stack_trace("Attempted to initialize stamina container with an invalid maximum limit of [maximum], defaulting to [STAMINA_MAX]")
		maximum = STAMINA_MAX
	src.parent = parent
	src.maximum = maximum
	src.regen_rate = regen_rate
	src.current = maximum
	RegisterSignals(parent, update_on_signals, PROC_REF(update_process))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(nullspace_move_check))
	update_process()

/datum/stamina_container/Destroy()
	if(!isnull(parent))
		parent.stamina = null
		UnregisterSignal(parent, update_on_signals)
		UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	parent = null
	STOP_PROCESSING(SSstamina, src)
	return ..()

/datum/stamina_container/proc/update(seconds_per_tick = 1)
	var/last_current = current
	if(process_stamina == TRUE)
		if(!is_regenerating)
			if(!COOLDOWN_FINISHED(src, paused_stamina))
				return
			is_regenerating = TRUE

		if(seconds_per_tick)
			current = min(current + (regen_rate*seconds_per_tick), maximum)
			if(decrement)
				current = max(current + (-decrement*seconds_per_tick), 0)
		if(current != last_current)
			should_notify_parent = TRUE
		loss = maximum - current
		loss_as_percent = loss ? (loss == maximum ? 0 : loss / maximum * 100) : 0

	if(seconds_per_tick && current == maximum)
		process_stamina = FALSE
	else if(!(current == maximum))
		process_stamina = TRUE

	if(should_notify_parent)
		parent.on_stamina_update()
		should_notify_parent = FALSE

///Pause stamina regeneration for some period of time. Does not support doing this from multiple sources at once because I do not do that and I will add it later if I want to.
/datum/stamina_container/proc/pause(time)
	is_regenerating = FALSE
	COOLDOWN_START(src, paused_stamina, time)

///Stops stamina regeneration entirely until manually resumed.
/datum/stamina_container/proc/stop()
	is_regenerating = FALSE

///Resume stamina processing
/datum/stamina_container/proc/resume()
	is_regenerating = TRUE

///adjust the grace period a mob has usually used after stam crit to prevent infinite stamina locking
/datum/stamina_container/proc/adjust_grace_period(time)
	COOLDOWN_START(src, stamina_grace_period, time)

///Adjust stamina by an amount.
/datum/stamina_container/proc/adjust(amt as num, forced, base_modify = FALSE)
	if((!amt || !COOLDOWN_FINISHED(src, stamina_grace_period)) && !forced)
		return
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)
	if(base_modify)
		modify = amt
	var/old_current = current
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	if(current != old_current)
		should_notify_parent = TRUE
	update()
	if((amt < 0) && is_regenerating)
		pause(STAMINA_REGEN_TIME)
	return amt

/// Revitalize the stamina to the maximum this container can have.
/datum/stamina_container/proc/revitalize(forced = FALSE)
	return adjust(maximum, forced)

/datum/stamina_container/proc/adjust_to(amount, lowest_stamina_value, forced = FALSE)
	if((!amount || !COOLDOWN_FINISHED(src, stamina_grace_period)) && !forced)
		return

	var/stamina_after_loss = current + amount
	if(stamina_after_loss < lowest_stamina_value)
		amount = current - lowest_stamina_value

	var/old_current = current
	current = round(clamp(current + amount, 0, maximum), DAMAGE_PRECISION)
	if(current != old_current)
		should_notify_parent = TRUE
	update()
	if((amount < 0) && is_regenerating)
		pause(STAMINA_REGEN_TIME)
	return amount

/// Signal handler for COMSIG_MOVABLE_MOVED to ensure that update_process() gets called whenever moving to/from nullspace.
/datum/stamina_container/proc/nullspace_move_check(atom/movable/mover, atom/old_loc, dir, force)
	SIGNAL_HANDLER
	if(isnull(old_loc) || isnull(mover.loc))
		update_process()

/// Returns if the container should currently be processing or not.
/datum/stamina_container/proc/should_process()
	SHOULD_BE_PURE(TRUE)
	if(QDELETED(parent) || isnull(parent.loc))
		return FALSE
	if(!parent.uses_stamina)
		return FALSE
	if(parent.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(parent, TRAIT_NO_TRANSFORM))
		return FALSE
	return TRUE

/// Checks to see if the container should be processing, and starts/stops it.
/datum/stamina_container/proc/update_process()
	SIGNAL_HANDLER
	if(should_process())
		START_PROCESSING(SSstamina, src)
	else
		STOP_PROCESSING(SSstamina, src)

/// Sets the maximum amount of stamina.
/// Always use this instead of directly setting the stamina var, as this has sanity checks, and immediately updates afterwards.
/datum/stamina_container/proc/set_maximum(value = STAMINA_MAX)
	if(!IS_SAFE_NUM(value) || value <= 0)
		maximum = STAMINA_MAX
		update()
		CRASH("Attempted to set maximum stamina to invalid value ([value]), resetting to the default maximum of [STAMINA_MAX]")
	if(value == maximum)
		return
	maximum = value
	update()
	return TRUE

/mob/living/carbon
	uses_stamina = TRUE

/mob/living/carbon/alien
	uses_stamina = FALSE

/mob/living/basic
	uses_stamina = TRUE

/mob/living/simple_animal
	uses_stamina = TRUE
