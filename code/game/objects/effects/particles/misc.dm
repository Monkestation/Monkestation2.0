//general or un-matched particles, make a new file if a few can be sorted together.
/particles/pollen
	icon = 'icons/effects/particles/pollen.dmi'
	icon_state = "pollen"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)

/particles/echo
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 1, "echo2" = 1, "echo3" = 2)
	width = 480
	height = 480
	count = 1000
	spawning = 0.5
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	gravity = list(0, -0.1)
	position = generator(GEN_BOX, list(-240, -240), list(240, 240), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.1, 0), list(0.1, 0))
	rotation = generator(GEN_NUM, 0, 360, NORMAL_RAND)


//STEAM
/particles/steam
	width = 64
	height = 64
	count = 20
	spawning = 0

	lifespan = 1 SECONDS
	fade = 1 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "steam"
	color = "#FFFFFF99"
	position = 0
	velocity = 1
	scale = list(0.6, 0.6)
	grow = list(0.05, 0.05)
	rotation = generator("num", 0, 360)

//TEAR REALITY DARKNESS
/particles/tear_reality
	width = 64
	height = 64
	count = 30
	spawning = 0.1

	lifespan = 1 SECONDS
	fade = 1 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "darkness"
	color = "#FFFFFF99"
	position = 0
	velocity = 0
	scale = list(1, 1)
	grow = list(0.05, 0.05)
	rotation = generator("num", 0, 360)

	//plane = NOIR_BLOOD_PLANE

//CANDLE
/particles/candle
	width = 32
	height = 64
	count = 5
	spawning = 0.02

	lifespan = 1.5 SECONDS
	fade = 0.7 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "candle"
	position = generator("box", list(-1, 12), list(1, 12))
	velocity = list(0, 3)
	friction = 0.3
	drift = generator("box", list(-0.2, -0.2), list(0.2, 0.2))

	appearance_flags = RESET_COLOR
	blend_mode = BLEND_ADD
	plane = ABOVE_LIGHTING_PLANE

/particles/candle_alt
	width = 32
	height = 64
	count = 5
	spawning = 0.05

	lifespan = 1 SECONDS
	fade = 0.3 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "candle"
	position = generator("box", list(-1, 12), list(1, 12))
	velocity = list(0, 3)
	friction = 0.3
	drift = generator("sphere", 0, 1)

	appearance_flags = RESET_COLOR
	blend_mode = BLEND_ADD
	plane = ABOVE_LIGHTING_PLANE

//CULT GAUGE
/particles/cult_gauge
	width = 600
	height = 64
	count = 20
	spawning = 1

	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "blood_gauge"
	position = generator("box", list(-16, -1), list(-16, -14))
	velocity = list(0, 0)

	plane = HUD_PLANE
	layer = MIND_UI_BUTTON+0.5

//CULT SMOKE
/particles/cult_smoke
	width = 32
	height = 64
	count = 20
	spawning = 0
	//spawning = 0.6
	color = "#FFFFFF99"

	lifespan = 8.5
	fadein = 3
	fade = 5
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "darkness"
	position = list(0, -12)
	scale = generator("num", 0.40, 0.45)
	velocity = generator("box", list(-1, 4), list(-2, 4))
	drift = generator("box", list(0.1, 0), list(0.2, 0))
	rotation = generator("num", 0, 360)

	plane = FLOAT_PLANE

/particles/cult_smoke/alt
	velocity = generator("box", list(1, 4), list(2, 4))
	drift = generator("box", list(-0.1, 0), list(-0.2, 0))

/particles/cult_smoke/box
	spawning = 0.8
	position = generator("box", list(-12, -12), list(12, 12))
	velocity = list(0, 4)
	drift = generator("box", list(-0.2, 0), list(0.2, 0))

	plane = FLOAT_PLANE

//CULT HALO
/particles/cult_halo
	width = 32
	height = 64
	count = 20
	spawning = 0.1

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "cult_halo4"
	position = list(0, 8)
	drift = generator("box", list(-0.02, -0.02), list(0.02, 0.02))

	plane = ABOVE_LIGHTING_PLANE

//SPACE RUNES
/particles/space_runes
	width = 64
	height = 64
	count = 2
	spawning = 0.01

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = list("rune-1", "rune-2", "rune-4", "rune-8", "rune-16", "rune-32", "rune-64", "rune-128", "rune-256", "rune-512", )
	drift = generator("box", list(-0.02, -0.02), list(0.02, 0.02))


//NAR-SIE HAS RISEN
/particles/narsie_has_risen
	width = 300
	height = 64
	count = 20
	spawning = 0.2

	lifespan = 20
	fadein = 5
	fade = 10
	icon = 'monkestation/code/modules/bloody_cult/icons/bloodcult/223x37.dmi'
	icon_state = "narsie"
	drift = generator("box", list(-0.05, -0.05), list(0.05, 0.05))

	plane = ABOVE_HUD_PLANE

/particles/narsie_has_risen/next
	icon_state = "has"

	plane = ABOVE_HUD_PLANE

/particles/narsie_has_risen/last
	icon_state = "risen"

	plane = ABOVE_HUD_PLANE

//ZAS DUST
/particles/zas_dust
	width = 96
	height = 96
	count = 20
	spawning = 2

	color = "#FFFFFF99"
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "zas_dust"
	position = generator("box", list(-15, -15), list(15, 15))
	velocity = list(0, 0)


//DANDELIONS
/particles/dandelions
	width = 96
	height = 96
	count = 10
	spawning = 1

	lifespan = 3 SECONDS
	fadein = 0.3 SECONDS
	fade = 0.5 SECONDS
	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "dandelions"
	position = generator("box", list(-12, -12), list(12, 12))
	velocity = list(0, 0)
	friction = 0.1
	drift = generator("box", list(-0.1, -0.1), list(0.1, 0.1))

	plane = ABOVE_GAME_PLANE

//CROSS DUST & ORBB
/particles/cross_dust
	width = 64
	height = 64
	count = 10

	lifespan = 10
	fade = 2
	spawning = 1.5

	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = list("cross_dust_1", "cross_dust_2", "cross_dust_3")
	position = generator("box", list(-12, -12), list(12, 12))
	velocity = list(0, -2)
	drift = generator("box", list(-0.2, -0.2), list(0.2, 0.2))

	appearance_flags = RESET_COLOR|RESET_ALPHA
	blend_mode = BLEND_ADD
	plane = ABOVE_LIGHTING_PLANE


/particles/cross_orb
	count = 2

	lifespan = 10
	spawning = 0.5

	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = list("cross_orb")
	position = generator("box", list(-12, -12), list(12, 12))
	velocity = list(0, -2)
	friction = 0.1
	drift = generator("box", list(-0.2, -0.2), list(0.2, 0.2))
	grow = list(-0.2, -0.2)

	appearance_flags = RESET_COLOR|RESET_ALPHA
	plane = ABOVE_LIGHTING_PLANE

//SACRED FLAME
/particles/sacred_flame
	width = 96
	height = 96
	count = 30

	lifespan = 10
	fade = 5
	spawning = 1.5

	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "sacred_flame"
	position = generator("box", list(-15, -15), list(15, 15))
	friction = 0.1
	drift = generator("box", list(-0.2, -0.2), list(0.2, 0.2))
	scale = list(0.6, 0.6)
	grow = list(0.1, 0.1)

/particles/sacred_flame/alt
	plane = LIGHTING_PLANE

//BIBLE PAGE
/particles/bible_page
	width = 96
	height = 96
	count = 1

	lifespan = 10
	fade = 5
	spawning = 0//we set the spawning after velocity has been adjusted

	icon = 'monkestation/code/modules/bloody_cult/icons/effects_particles.dmi'
	icon_state = "bible_page"
	rotation = generator("num", 0, 360)
	spin = 10
	grow = generator("box", list(-0.3, -0.3), list(0, 0))

	appearance_flags = RESET_COLOR|RESET_ALPHA
	plane = ABOVE_LIGHTING_PLANE
