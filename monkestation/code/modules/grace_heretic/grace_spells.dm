/datum/action/cooldown/mob_cooldown/charge/basic_charge/dash
	name = "Rapid Dash"
	desc = "Empower your body and sprint towards your foes. Knock down anyone in your path."
	cooldown_time = 6 SECONDS
	charge_delay = 0.1 SECONDS
	charge_distance = 500
	melee_cooldown_time = 0
	charge_damage = 1000
	var/prev_move_force

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dash/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	if(!target_atom || target_atom == owner)
		return
	var/chargeturf = get_turf(target_atom)
	if(!chargeturf)
		return
	var/dir = get_dir(charger, target_atom)
	var/turf/target = get_ranged_target_turf(chargeturf, dir, past)
	if(!target)
		return

	if(charger in charging)
		// Stop any existing charging, this'll clean things up properly
		SSmove_manager.stop_looping(charger)

	charging += charger
	prev_move_force = charger.move_force
	charger.move_force = 9999999
	//charger.pass_flags |= PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE //modification
	actively_moving = FALSE
	SEND_SIGNAL(owner, COMSIG_STARTED_CHARGE)
	RegisterSignal(charger, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump), TRUE)
	RegisterSignal(charger, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move), TRUE)
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved), TRUE)
	charger.setDir(dir)
	do_charge_indicator(charger, target)

	SLEEP_CHECK_DEATH(delay, charger)

	var/time_to_hit = min(get_dist(charger, target), charge_distance) * charge_speed

	var/datum/move_loop/new_loop = SSmove_manager.home_onto(charger, target, delay = charge_speed, timeout = time_to_hit, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	RegisterSignal(new_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(charge_end))

	// Yes this is disgusting. But we need to queue this stuff, and this code just isn't setup to support that right now. So gotta do it with sleeps
	sleep(time_to_hit + charge_speed)
	charger.setDir(dir)

	return TRUE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dash/charge_end(datum/move_loop/source)
	//SIGNAL_HANDLER
	var/atom/movable/charger = source.moving
	charger.move_force = prev_move_force
	//charger.pass_flags &= ~(PASSCLOSEDTURF | PASSGLASS | PASSGRILLE | PASSMACHINE | PASSSTRUCTURE | PASSTABLE | PASSMOB | PASSDOORS | PASSVEHICLE)
	UnregisterSignal(charger, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
	SEND_SIGNAL(owner, COMSIG_FINISHED_CHARGE)
	actively_moving = FALSE
	charging -= charger

/datum/status_effect/eldritch/grace
	effect_icon = 'monkestation/code/modules/grace_heretic/mark.dmi'
	effect_icon_state = "emark_grace"
