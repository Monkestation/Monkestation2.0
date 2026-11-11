/datum/discipline/obtenebration
	name = "Obtenebration"
	discipline_explanation = "Obtenebration is the Lasombra's stolen art. They reach into nullspace and drag its darkness out into the world, shaping it into clouds, arms, armor, and finally a body of pure shadow.\n\
		Every power but Shadow Play costs double while you stand in bright light."
	icon_state = "visceratika"
	vassal_power = /datum/action/cooldown/vampire/shadow_play

	level_1 = list(/datum/action/cooldown/vampire/shadow_play)
	level_2 = list(/datum/action/cooldown/vampire/shadow_play/two, /datum/action/cooldown/vampire/targeted/shroud_of_night)
	level_3 = list(/datum/action/cooldown/vampire/shadow_play/three, /datum/action/cooldown/vampire/targeted/shroud_of_night, /datum/action/cooldown/vampire/targeted/arms_of_the_abyss)
	level_4 = list(/datum/action/cooldown/vampire/shadow_play/four, /datum/action/cooldown/vampire/targeted/shroud_of_night, /datum/action/cooldown/vampire/targeted/arms_of_the_abyss, /datum/action/cooldown/vampire/black_metamorphosis)
	level_5 = list(/datum/action/cooldown/vampire/shadow_play/five, /datum/action/cooldown/vampire/targeted/shroud_of_night, /datum/action/cooldown/vampire/targeted/arms_of_the_abyss, /datum/action/cooldown/vampire/black_metamorphosis, /datum/action/cooldown/vampire/tenebrous_form)

/// Whether a tile is dark enough for Obtenebration. Uses get_lumcount, since that one counts negative lights.
/proc/is_obtenebration_dark(turf/target)
	return target.is_softly_lit() || target.get_lumcount() < LIGHTING_TILE_IS_DARK

/// Black wisps curling up off a Lasombra, with the odd fleck of blood in them.
/particles/lasombra_shadow
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 1)
	width = 96
	height = 96
	count = 40
	spawning = 1.2
	lifespan = 1.4 SECONDS
	fade = 0.8 SECONDS
	fadein = 0.3 SECONDS
	position = generator(GEN_BOX, list(-12, -14, 0), list(12, -8, 0), UNIFORM_RAND)
	velocity = generator(GEN_VECTOR, list(-0.1, 0.25, 0), list(0.1, 0.45, 0), NORMAL_RAND)
	drift = generator(GEN_SPHERE, 0, 0.15, NORMAL_RAND)
	friction = 0.15
	scale = generator(GEN_VECTOR, list(0.35, 0.35), list(0.6, 0.6), UNIFORM_RAND)
	grow = -0.01
	spin = generator(GEN_NUM, -4, 4, UNIFORM_RAND)
	gradient = list(0, "#000000", 0.8, "#0d0006", 1, "#6b0014")
	color = generator(GEN_NUM, 0, 1, UNIFORM_RAND)

/// Thicker version for Black Metamorphosis, covering the whole body.
/particles/lasombra_shadow/dense
	count = 120
	spawning = 4
	lifespan = 1.2 SECONDS
	position = generator(GEN_BOX, list(-12, -14, 0), list(12, 10, 0), UNIFORM_RAND)
	scale = generator(GEN_VECTOR, list(0.5, 0.5), list(0.9, 0.9), UNIFORM_RAND)

/// Billowing cloud for Shroud of Night, spread over a 3x3 area.
/particles/lasombra_shadow/cloud
	width = 160
	height = 160
	count = 200
	spawning = 8
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	fadein = 0.5 SECONDS
	position = generator(GEN_BOX, list(-40, -40, 0), list(40, 40, 0), UNIFORM_RAND)
	velocity = generator(GEN_VECTOR, list(-0.2, -0.1, 0), list(0.2, 0.3, 0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(1, 1), list(1.6, 1.6), UNIFORM_RAND)
	grow = 0.02
	gradient = list(0, "#000000", 0.9, "#05000a", 1, "#4a000e")
