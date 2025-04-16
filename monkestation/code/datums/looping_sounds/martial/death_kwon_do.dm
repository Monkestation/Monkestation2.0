/datum/martial_art/death_kwon_do
	name = "Death Kwon Do"
	id = MARTIAL_ART_DEATH_KWON_DO
	var/datum/action/death_punch/death_punch = new/datum/action/death_punch()
	var/datum/action/death_kick/death_kick = new/datum/action/death_kick()
	var/datum/action/death_block/death_block = new/datum/action/death_block()

/datum/martial_art/death_kwon_do/proc/check_streak(mob/living/attacker, mob/living/defender)
	switch(streak)
		if("punch")
			streak = ""
			death_punch(attacker, defender)
			return TRUE
		if("kick")
			streak = ""
			death_kick(attacker, defender)
			return TRUE
	return FALSE

/datum/action/death_punch
	name = "Death Punch"
	desc = "Lands a devestating punch on your foes."
	button_icon = 'monkestation/icons/hud/martial_arts_actions.dmi'
	button_icon_state = ""

/datum/action/death_punch/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You cant death punch while you're incapacitated! Your forms all wrong!"))
		return
	owner.visible_message(span_danger("[owner] has an impecable form!"))
	owner.mind.martial_art.streak = "punch"

/datum/action/death_punch
	name = "Death Kick"
	desc = "Lands a devestating flying kick on your foes."
	button_icon = 'monkestation/icons/hud/martial_arts_actions.dmi'
	button_icon_state = ""

/datum/action/death_punch/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You cant death kcik while you're incapacitated! Your forms all wrong!"))
		return
	owner.visible_message(span_danger("[owner] has an impecable form!"))
	owner.mind.martial_art.streak = "kick"

/datum/action/death_punch
	name = "Death Block"
	desc = ""
	button_icon = 'monkestation/icons/hud/martial_arts_actions.dmi'
	button_icon_state = ""

/datum/action/death_punch/Trigger(trigger_flags)
	if(owner.incapacitated())
		to_chat(owner, span_warning("You cant death block while you're incapacitated! Your forms all wrong!"))
		return
	owner.visible_message(span_danger("[owner] has an impecable form!"))
	owner.mind.martial_art.streak = "block"
