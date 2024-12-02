////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune
//      CULT FORGE       //Also a source of heat
//                       // Add /obj/item/melee/cultblade/halberd
///////////////////////////


/obj/structure/cult/forge
	name = "forge"
	desc = "Molten rocks flow down its cracks producing a searing heat, better not stand too close for long."
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	icon_state = ""
	max_integrity = 100
	pixel_x = -16 * 1
	pixel_y = -16 * 1
	plane = GAME_PLANE
	light_color = LIGHT_COLOR_ORANGE
	custom_process = 1
	map_id = HOLOMAP_MARKER_CULT_ALTAR
	marker_icon_state = "forge"

	var/heating_power = 40000
	var/set_temperature = 50
	var/mob/forger = null
	var/template = null
	var/forge_icon = ""
	var/obj/effect/cult_ritual/forge/forging = null


/obj/structure/cult/forge/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	set_light(2)
	flick("forge-spawn", src)
	spawn(10)
		setup_overlays()

/obj/structure/cult/forge/Destroy()
	if (forging)
		qdel(forging)
	forging = null
	forger = null
	STOP_PROCESSING(SSobj, src)
	..()

/obj/structure/cult/forge/proc/setup_overlays()
	animate(src, alpha = 255, time = 10, loop = -1)
	animate(alpha = 240, time = 2)
	animate(alpha = 224, time = 2)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 176, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 144, time = 1)
	animate(alpha = 128, time = 3)
	animate(alpha = 144, time = 1)
	animate(alpha = 160, time = 1)
	animate(alpha = 176, time = 1)
	animate(alpha = 192, time = 1.5)
	animate(alpha = 208, time = 1.5)
	animate(alpha = 224, time = 2)
	animate(alpha = 240, time = 2)
	overlays.len = 0
	var/image/I_base = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "forge")
	SET_PLANE_EXPLICIT(I_base, GAME_PLANE, src)
	I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
	var/image/I_lave = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "forge-lightmask")
	I_lave.plane = ABOVE_LIGHTING_PLANE
	I_lave.blend_mode = BLEND_ADD
	overlays += I_base
	overlays += I_lave

/obj/structure/cult/forge/process()
	..()
	if (isturf(loc))
		var/turf/L = loc
		if(!isspaceturf(loc))
			for (var/mob/living/carbon/M in view(src, 3))
				M.bodytemperature += (6-round(M.get_cult_power()/30))/((get_dist(src, M)+1))//cult gear reduces the heat buildup
		if (forging)
			if (forger)
				if (!Adjacent(forger) || forger.incapacitated())
					if (forger.client)
						forger.client.images -= progbar
					forger = null
					return
				else
					timeleft--
					update_progbar()
					var/datum/antagonist/cult/cult_datum = IS_CULTIST(forger)
					if (cult_datum)
						cult_datum.gain_devotion(10, DEVOTION_TIER_2, "[forge_icon]", timeleft)
					if (timeleft <= 0)
						playsound(L, 'monkestation/code/modules/bloody_cult/sound/forge_over.ogg', 50, 0, -3)
						if (forger.client)
							forger.client.images -= progbar
						QDEL_NULL(forging)
						var/obj/item/I = new template(L)
						if (istype(I))
							SET_PLANE_EXPLICIT(I, GAME_PLANE, src)
							I.pixel_y = 12
						else
							I.forceMove(get_turf(forger))
						forger = null
						template = null
					else
						anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', flick_anim = "forge-work", offX = pixel_x, offY = pixel_y, plane = ABOVE_LIGHTING_PLANE)
						playsound(L, 'monkestation/code/modules/bloody_cult/sound/forge.ogg', 50, 0, -4)
						forging.overlays.len = 0
						var/image/I = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "[forging.icon_state]-mask")
						I.plane = ABOVE_LIGHTING_PLANE
						I.blend_mode = BLEND_ADD
						I.alpha = (timeleft/timetotal)*255
						forging.overlays += I



/obj/structure/cult/forge/conceal()
	overlays.len = 0
	set_light(0)
	anim(location = loc, target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', flick_anim = "forge-conceal", offX = pixel_x, offY = pixel_y, plane = GAME_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "forge"

/obj/structure/cult/forge/reveal()
	..()
	animate(src)
	alpha = 255
	set_light(2)
	flick("forge-spawn", src)
	spawn(10)
		animate(src, alpha = 255, time = 10, loop = -1)
		animate(alpha = 240, time = 2)
		animate(alpha = 224, time = 2)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 176, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 144, time = 1)
		animate(alpha = 128, time = 3)
		animate(alpha = 144, time = 1)
		animate(alpha = 160, time = 1)
		animate(alpha = 176, time = 1)
		animate(alpha = 192, time = 1.5)
		animate(alpha = 208, time = 1.5)
		animate(alpha = 224, time = 2)
		animate(alpha = 240, time = 2)
		var/image/I_base = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "forge")
		SET_PLANE_EXPLICIT(I_base, GAME_PLANE, src)
		I_base.appearance_flags |= RESET_ALPHA //we don't want the stone to pulse
		var/image/I_lave = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "forge-lightmask")
		I_lave.plane = ABOVE_LIGHTING_PLANE
		I_lave.blend_mode = BLEND_ADD
		overlays += I_base
		overlays += I_lave

/obj/structure/cult/forge/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/fag = I
		fag.light(span_notice("\The [user] lights \the [fag] by bringing its tip close to \the [src]'s molten flow.") )
		return 1
	if(istype(I, /obj/item/candle))
		var/obj/item/candle/stick = I
		stick.light(span_notice("\The [user] lights \the [stick] by bringing its wick close to \the [src]'s molten flow.") )
		return 1
	..()

/obj/structure/cult/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'monkestation/code/modules/bloody_cult/icons/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = 32
		progbar.plane = HUD_PLANE
		progbar.pixel_x = 16 * 1
		progbar.pixel_y = 16 * 1
		progbar.appearance_flags = RESET_ALPHA|RESET_COLOR
	progbar.icon_state = "prog_bar_[round((100 - min(1, timeleft / timetotal) * 100), 10)]"

/obj/structure/cult/altar/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'monkestation/code/modules/bloody_cult/icons/doafter_icon.dmi', "loc" = src, "icon_state" = "prog_bar_0")
		progbar.pixel_z = 32
		progbar.plane = HUD_PLANE
	progbar.icon_state = "prog_bar_[round((100 - min(1, timeleft / timetotal) * 100), 10)]"

/obj/structure/cult/forge/cultist_act(var/mob/user, var/menu = "default")
	. = ..()
	if (!.)
		return

	if (template)
		if (forger)
			if (forger == user)
				to_chat(user, "You are already working at this forge.")
			else
				to_chat(user, "\The [forger] is currently working at this forge already.")
		else
			to_chat(user, "You resume working at the forge.")
			forger = user
			if (forger.client)
				forger.client.images |= progbar
		return


	var/list/choices = list(
		list("Forge Blade", "radial_blade", "A powerful ritual blade, the signature weapon of the bloodthirsty cultists. Features a notch in which a Soul Gem can fit."),
		list("Forge Construct Shell", "radial_constructshell", "A polymorphic sculpture that can be shaped into a powerful ally by inserting a full Soul Gem or Shard."),
		list("Forge Armor", "radial_armor", "This protective armor offers the same enhancing powers that Cult Robes provide, on top of being space proof."),
	)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	var/task = show_radial_menu(user, loc, made_choices, tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial.dmi')//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	if (template || !Adjacent(user) || !task )
		return
	forge_icon = ""
	switch (task)
		if ("Forge Blade")
			template = /obj/item/weapon/melee/cultblade
			timeleft = 10
			forge_icon = "forge_blade"
		if ("Forge Armor")
			template = /obj/item/clothing/suit/hooded/cultrobes/hardened
			timeleft = 23
			forge_icon = "forge_armor"
		if ("Forge Construct Shell")
			template = /obj/structure/constructshell
			timeleft = 25
			forge_icon = "forge_shell"
	timetotal = timeleft
	forger = user
	update_progbar()
	if (forger.client)
		forger.client.images |= progbar
	forging = new (loc, forge_icon)

/obj/effect/cult_ritual/forge
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	icon_state = ""
	pixel_x = -16 * 1
	pixel_y = -16 * 1
	plane = GAME_PLANE

/obj/effect/cult_ritual/forge/New(var/turf/loc, var/i_forge = "")
	..()
	icon_state = i_forge
	var/image/I = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "[i_forge]-mask")
	I.plane = ABOVE_LIGHTING_PLANE
	I.blend_mode = BLEND_ADD
	overlays += I
