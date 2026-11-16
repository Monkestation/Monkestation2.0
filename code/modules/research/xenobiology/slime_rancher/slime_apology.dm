/// A friend peeled us off someone, so we stop right away and feel bad about it
/mob/living/basic/slime/proc/apologize_to(mob/living/spared, mob/living/friend)
	friend.visible_message(
		span_notice("[friend] gently peels \the [name] off [spared]."),
		span_notice("You gently peel \the [name] off [spared]."),
	)
	stop_feeding(silent = TRUE)
	set_temporary_mood(SLIME_MOOD_SAD)
	manual_emote(pick(
		"blorbles apologetically at [spared].",
		"droops and stares at the floor.",
		"shrinks back from [spared], looking guilty.",
	))

	var/datum/ai_controller/basic_controller/slime/controller = ai_controller
	controller.ignore_target(spared, 2 MINUTES)
	controller.forget(BB_BASIC_MOB_RETALIATE_LIST, spared)
	for(var/target_key in list(BB_SLIME_EAT_TARGET, BB_BASIC_MOB_CURRENT_TARGET))
		if(controller.blackboard[target_key] == spared)
			controller.clear_blackboard_key(target_key)
