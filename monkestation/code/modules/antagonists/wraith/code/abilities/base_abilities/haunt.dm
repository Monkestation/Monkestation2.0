/datum/action/cooldown/spell/wraith/haunt
	name = "Haunt"
	desc = "Materialize into the living plane, granting you additional essence regeneration depending on how many people are watching you."
	button_icon_state = "haunt"

	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/wraith/haunt/cast(mob/living/cast_on)
	. = ..()
	var/mob/living/basic/wraith/true_owner = owner
	if(!istype(true_owner)) // this is basically the only ability that cannot be used by non-wraiths, admemes take note.
		return

	if(!true_owner.density)
		true_owner.materialize()
	else
		true_owner.unmaterialize()
		reset_spell_cooldown()
