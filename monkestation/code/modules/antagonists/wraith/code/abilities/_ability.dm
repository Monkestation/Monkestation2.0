/datum/action/cooldown/spell/wraith
	panel = "Wraith Abilities"

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_HOLY

	button_icon = 'monkestation/code/modules/antagonists/wraith/icons/abilities.dmi'
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"

	/// How much essence this spell costs to fire
	var/essence_cost = 0

/datum/action/cooldown/spell/wraith/New()
	. = ..()
	name = "[name] ([essence_cost]e) ([cooldown_time]s)"

/datum/action/cooldown/spell/wraith/can_cast_spell(feedback = TRUE)
	var/mob/living/basic/wraith/true_owner = owner
	if(!istype(true_owner))
		return TRUE // If an admin wants to give this to humans, we let them

	if(true_owner.stunned)
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] whilst stunned!"))
		return FALSE

	if(true_owner.essence < essence_cost)
		if(feedback)
			to_chat(owner, span_warning("You are missing [essence_cost - true_owner.essence] essence to cast this spell!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/wraith/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!can_cast_spell())
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/wraith/cast(atom/cast_on)
	. = ..()
	var/mob/living/basic/wraith/true_owner = owner
	if(istype(true_owner))
		true_owner.essence -= essence_cost

/datum/action/cooldown/spell/pointed/wraith
	panel = "Wraith Abilities"

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_HOLY

	button_icon = 'monkestation/code/modules/antagonists/wraith/icons/abilities.dmi'
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"

	/// How much essence this spell costs to fire
	var/essence_cost = 0

/datum/action/cooldown/spell/pointed/wraith/New()
	. = ..()
	name = "[name] ([essence_cost]e) [cooldown_time ? "([cooldown_time / 10]s)" : ""]"

/datum/action/cooldown/spell/pointed/wraith/can_cast_spell(feedback = TRUE)
	var/mob/living/basic/wraith/true_owner = owner
	if(!istype(true_owner))
		return TRUE // If an admin wants to give this to humans, we let them

	if(true_owner.stunned)
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] whilst stunned!"))
		return FALSE

	if(true_owner.essence < essence_cost)
		if(feedback)
			to_chat(owner, span_warning("You are missing [essence_cost - true_owner.essence] essence to cast this spell!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/wraith/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!can_cast_spell())
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/cast(atom/cast_on)
	. = ..()
	var/mob/living/basic/wraith/true_owner = owner
	if(istype(true_owner))
		true_owner.essence -= essence_cost
