/datum/ai_controller/monkey/dukeman
	movement_delay = 0.4 SECONDS

/datum/ai_controller/monkey/dukeman/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	override_blackboard_key(BB_MONKEY_IDLE_COMMON_EMOTES, list(
		"screech",
		"roar",
		"twitch",
		"vibrate",
		"whistle",
		"flip",
		"spin",
	))
	override_blackboard_key(BB_MONKEY_IDLE_RARE_EMOTES, list(
		"scratch",
		"tail",
		"ooga",
		"honk",
		"swear",
		"thinking",
	))
