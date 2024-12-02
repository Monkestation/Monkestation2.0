/mob/living/basic/construct/wraith/perfect
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	icon_state = "wraith2"
	icon_living = "wraith2"
	icon_dead = "wraith2"
	new_glow = TRUE
	see_in_dark = 7
	construct_spells = list(
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shift,
		/datum/action/cooldown/spell/pointed/conjure/path_entrance,
		/datum/action/cooldown/spell/pointed/conjure/path_exit,
		)
