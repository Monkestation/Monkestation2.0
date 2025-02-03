/// Quite the weaker version of wraiths, able to be summoned by the trickster
/// They lack the absorb corpse, possess object and most importantly evolve abilities
/mob/living/basic/wraith/poltergeist
	abilities = list(
		/datum/action/cooldown/spell/wraith/haunt,
		/datum/action/cooldown/spell/pointed/wraith/whisper,
		/datum/action/cooldown/spell/pointed/wraith/blood_writing,
		/datum/action/cooldown/spell/wraith/spook,
		/datum/action/cooldown/spell/pointed/wraith/decay,
		/datum/action/cooldown/spell/pointed/wraith/command,
		/datum/action/cooldown/spell/pointed/wraith/animate_object,
	)
	weakened = TRUE // You've got one shot, lightbulb man
	/// The ability that made us
	var/datum/action/cooldown/spell/wraith/make_poltergeist/ability

/mob/living/basic/wraith/poltergeist/Initialize(mapload, mob/ghost, datum/action/cooldown/spell/wraith/make_poltergeist/buttong)
	if(ghost)
		ckey = ghost.ckey
		mind.add_antag_datum(/datum/antagonist/wraith/poltergeist)
	if(buttong)
		ability = buttong
		ability.current_ghosts++
	return ..()

/mob/living/basic/wraith/poltergeist/Destroy(force)
	if(ability)
		ability.current_ghosts--
		ability = null
	return ..()
