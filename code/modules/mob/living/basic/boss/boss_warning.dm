/**
 * Bosses roar at the first person who gets close instead of attacking right away.
 * Succeeds when we should look for targets: we're already fighting, or someone we warned is still around.
 */
/datum/bt_node/ai_behavior/boss_warn_intruders
	/// How close someone has to get before we notice them
	var/warn_range = 4
	/// Time between roars
	var/warn_cooldown = 3 SECONDS
	/// How long a warning lasts before they get another one
	var/warning_memory = 20 SECONDS
	/// Blackboard key of our current target
	var/target_key = BB_CURRENT_TARGET

/datum/bt_node/ai_behavior/boss_warn_intruders/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/boss/boss = controller.pawn
	if(!istype(boss) || boss.client || controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	if(!COOLDOWN_FINISHED(boss, rawr_cooldown))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/list/intruders = list()
	for(var/mob/living/intruder in oview(warn_range, boss))
		if(intruder.stat != DEAD && !boss.faction_check_atom(intruder))
			intruders += intruder
	if(!length(intruders))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/picked = pick(intruders)
	var/warned_at = LAZYACCESS(boss.warned_players, REF(picked))
	if(warned_at && world.time - warned_at < warning_memory)
		LAZYNULL(boss.warned_players)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	boss.warn_players(intruders)
	for(var/mob/living/intruder as anything in intruders)
		LAZYSET(boss.warned_players, REF(intruder), world.time)
	COOLDOWN_START(boss, rawr_cooldown, warn_cooldown)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
