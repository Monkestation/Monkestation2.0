/datum/slime_trait/visual/cat
	name = "Gooey Cat"
	desc = "A docile slime with cat ears!"

	trait_icon_state = "cat_ears"
	trait_icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	menu_buttons = list(FOOD_CHANGE, DOCILE_CHANGE, BEHAVIOUR_CHANGE)

/datum/slime_trait/visual/cat/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.ai_controller.set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic/no_trait/slime/cat)
	parent.emotion_states[EMOTION_HAPPY] = "aslime-:33"
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, parent.emotion_states)
	parent.recompile_ai_tree()

/datum/slime_trait/visual/cat/on_remove (mob/living/basic/slime/parent)
	parent.ai_controller.set_blackboard_key(BB_TARGETING_STRATEGY, /datum/targeting_strategy/basic/no_trait/slime)
	parent.emotion_states[EMOTION_HAPPY] = "aslime-happy"
	SEND_SIGNAL(parent, EMOTION_BUFFER_UPDATE_OVERLAY_STATES, parent.emotion_states)
	parent.recompile_ai_tree()
