/datum/action/cooldown/vampire/exactitude
	name = "Exactitude"
	desc = "Focus your powers into your hands, enabling you to attack with preternatural precision."
	button_icon_state = "power_exactitude"
	power_explanation = "Imbues your hands with supernatural precision. Cannot be used with gloves on.\n\
						Use with combat mode. When punching, you will automatically hit the closest being. Best used without moving your mouse at all."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	cooldown_time = 30 SECONDS
	vitaecost = 50
	constant_vitaecost = 5


/datum/action/cooldown/vampire/exactitude/can_use()
	. = ..()
	if(!.)
		return FALSE
	if(owner.get_item_by_slot(ITEM_SLOT_GLOVES))
		owner.balloon_alert(owner, "you're wearing gloves!")
		return FALSE

/datum/action/cooldown/vampire/exactitude/activate_power()
	. = ..()
	RegisterSignals(owner, list(COMSIG_HUMAN_EARLY_UNARMED_ATTACK, COMSIG_LIVING_EARLY_UNARMED_ATTACK), PROC_REF(on_unarmed_attack))

/datum/action/cooldown/vampire/exactitude/deactivate_power()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_HUMAN_EARLY_UNARMED_ATTACK, COMSIG_LIVING_EARLY_UNARMED_ATTACK))

/datum/action/cooldown/vampire/exactitude/continue_active()
	. = ..()
	if(owner.get_item_by_slot(ITEM_SLOT_GLOVES))
		return FALSE

/datum/action/cooldown/vampire/exactitude/proc/on_unarmed_attack(mob/living/source, atom/target, proximity, modifiers)
	if(!(source.istate & ISTATE_HARM) || !currently_active)
		return NONE

	if(isliving(target) && target != source)
		var/mob/living/living_target = target
		if(living_target.stat != DEAD) // don't focus on dead targets
			return NONE

	for(var/mob/living/to_attack in oview(1, source))
		if(to_attack.stat == DEAD || to_attack.invisibility > source.see_invisible)
			continue
		source.face_atom(to_attack)
		to_attack.attack_hand(source, modifiers)
		source.changeNext_move(CLICK_CD_MELEE * 0.75)
		return COMPONENT_CANCEL_ATTACK_CHAIN


