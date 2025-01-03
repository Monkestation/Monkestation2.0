/datum/action/cooldown/spell/wraith/haunt
	name = "Haunt"
	desc = "Materialize into the living plane, granting you additional essence regeneration depending on how many people are watching you."
	button_icon_state = "haunt"

	cooldown_time = 30 SECONDS

	wraith_only = TRUE

/datum/action/cooldown/spell/wraith/haunt/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/basic/wraith/true_owner = owner
	if(!true_owner.density)
		true_owner.materialize()
	else
		true_owner.unmaterialize()
		reset_spell_cooldown()
