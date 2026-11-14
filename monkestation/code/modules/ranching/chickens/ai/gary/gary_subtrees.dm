/// Gary gets bored at home every now and then and goes to visit someone
/datum/bt_node/decorator/gary_wants_to_wander

/datum/bt_node/decorator/gary_wants_to_wander/check_condition(datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(BB_GARY_HIDEOUT))
		return FALSE
	if(world.time < controller.blackboard[BB_GARY_WANDER_COOLDOWN])
		return FALSE
	return prob(20)
