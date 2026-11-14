/// Walks into range of whoever the ability in ability_key wants to be used on, see the ability's ai_range
/datum/bt_node/ai_behavior/move_to_target/chicken_ability
	/// Blackboard key holding the chicken ability to use once we get there
	var/ability_key

/datum/bt_node/ai_behavior/move_to_target/chicken_ability/setup(datum/ai_controller/controller)
	var/datum/action/cooldown/mob_cooldown/chicken/ability = controller.blackboard[ability_key]
	if(istype(ability))
		required_dist = ability.ai_range
	return ..()

/// Shoots at whoever we're after, as long as they're not one of our friends
/datum/bt_node/subtree/pet_command/attack/chicken_ranged
	behavior_tree_json = "monkestation/code/modules/ranching/chickens/ai/pet_command_attack_chicken_ranged.bt.json"
