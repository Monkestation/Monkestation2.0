/datum/bt_node/ai_behavior/parrot_repeat_speech/get_cooldown(datum/ai_controller/cooldown_for)
	return rand(45 SECONDS, 3 MINUTES) // Prevents Poly from being too yappy
