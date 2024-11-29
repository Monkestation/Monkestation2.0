/datum/action/cooldown/spell/pointed/wraith/command
	name = "Command"
	desc = "Hurl any nearby objects at your target."
	button_icon_state = "command"

	essence_cost = 50
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/pointed/wraith/command/before_cast(atom/cast_on)
	. = ..()
	if(!isturf(cast_on) && !ismob(cast_on))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/command/cast(turf/cast_on)
	. = ..()
	if(!istype(cast_on))
		cast_on = get_turf(cast_on)
	goonchem_vortex(cast_on, range = 7)
