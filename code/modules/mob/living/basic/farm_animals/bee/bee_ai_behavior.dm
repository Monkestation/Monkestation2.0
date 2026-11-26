/datum/targeting_strategy/basic/bee

/datum/targeting_strategy/basic/bee/is_valid_target(mob/living/owner, atom/target, vision_range, datum/ai_controller/controller = null)
	if(!isliving(target))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/mob_target = target

	if(mob_target.mob_biotypes & MOB_PLANT)
		return FALSE

	var/datum/ai_controller/basic_controller/bee_ai = owner.ai_controller
	if(isnull(bee_ai))
		return FALSE

	var/atom/bee_hive = bee_ai.blackboard[BB_CURRENT_HOME]
	if(bee_hive && get_dist(target, bee_hive) > 5)
		return FALSE

	return !(mob_target.bee_friendly())
