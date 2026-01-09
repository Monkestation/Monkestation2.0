/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	/// The maximum amount of stamina this container has.
	/// Don't touch this directly, it is set using set_maximum().
	var/maximum = 0
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = STAMINA_REGEN
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Should we be regenerating right now?
	var/is_regenerating = TRUE
	///Is stamina regeneration currently paused due to cooldown?
	var/regen_on_cooldown = FALSE
	///Is stamina regeneration currently force stopped?
	var/regen_force_stopped = FALSE
	///Is this stamina container currently processing stamina regeneration? Is set to FALSE when the stamina is at maximum.
	var/process_stamina = TRUE
	/// Used to determine when the stamina changes, to properly run on_stamina_update on the parent.
	VAR_PRIVATE/should_notify_parent = FALSE

	///cooldowns
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

/datum/stamina_container/proc/update(seconds_per_tick = 0)
	var/last_current = current

	if (current != maximum)
		process_stamina = TRUE

	if(process_stamina)
		if(!is_regenerating && regen_on_cooldown)
			if(COOLDOWN_FINISHED(src, paused_stamina))
				is_regenerating = TRUE
				regen_on_cooldown = FALSE

		if(seconds_per_tick)
			if(is_regenerating)
				current = min(current + (regen_rate*seconds_per_tick), maximum)
		if(current != last_current)
			should_notify_parent = TRUE
		loss = maximum - current
		loss_as_percent = loss ? (loss == maximum ? 0 : loss / maximum * 100) : 0

	if(current == maximum)
		process_stamina = FALSE

	if(should_notify_parent)
		parent.on_stamina_update()
		should_notify_parent = FALSE

///Pause stamina regeneration for some period of time. Will override previous cooldown if one was set. Will NOT override stop(), if stop() was used to halt stamina regen.
/datum/stamina_container/proc/pause(time)
	if (regen_force_stopped)
		return

	is_regenerating = FALSE
	regen_on_cooldown = TRUE
	COOLDOWN_START(src, paused_stamina, time)

///Stops stamina regeneration entirely until manually resumed.
/datum/stamina_container/proc/stop()
	is_regenerating = FALSE
	regen_on_cooldown = FALSE
	regen_force_stopped = TRUE

///Resume stamina regeneration
/datum/stamina_container/proc/resume()
	is_regenerating = TRUE
	regen_on_cooldown = FALSE
	regen_force_stopped = FALSE

///Adjust stamina by an amount.
/datum/stamina_container/proc/adjust(amt as num, forced = FALSE)
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)

	var/old_current = current
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	if(current != old_current)
		should_notify_parent = TRUE
	if(modify < 0)
		pause(STAMINA_REGEN_TIME)
	update()
	return modify

/// Revitalize the stamina to the maximum this container can have.
/datum/stamina_container/proc/revitalize(forced = FALSE)
	return adjust(maximum, forced)

/datum/stamina_container/proc/adjust_to(amt as num, lowest_stamina_value, forced = FALSE)
	var/modify = parent.pre_stamina_change(amt, forced)

	var/old_current = current

	var/stamina_after_loss = current + modify
	if(stamina_after_loss < lowest_stamina_value)
		current = round(clamp(lowest_stamina_value, 0, maximum), DAMAGE_PRECISION)
	else
		current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	if(current != old_current)
		should_notify_parent = TRUE
	if(modify < 0)
		pause(STAMINA_REGEN_TIME)
	update()
	return modify

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
