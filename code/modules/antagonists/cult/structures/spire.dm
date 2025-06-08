////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                       //Spawned from the Raise Structure rune.
//      CULT SPIRE       //Enables rune-less cult comms for cultists on their current Z-Level
//                       //
///////////////////////////
GLOBAL_LIST_INIT(cult_spires, list())

/obj/structure/cult/spire
	name = "spire"
	desc = "A blood-red needle surrounded by dangerous looking...teeth?."
	icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi'
	icon_state = ""
	max_integrity = 100
	pixel_x = -16 * 1
	pixel_y = -4 * 1
	plane = GAME_PLANE
	map_id = HOLOMAP_MARKER_CULT_SPIRE
	marker_icon_state = "spire"
	light_color = "#FF0000"
	var/stage = 1

/obj/structure/cult/spire/New()
	..()
	GLOB.cult_spires += src
	set_light(1)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult)
		switch(cult.stage)
			if (BLOODCULT_STAGE_MISSED, BLOODCULT_STAGE_DEFEATED)
				stage = 1
			if (BLOODCULT_STAGE_NORMAL)
				stage = 2
			if (BLOODCULT_STAGE_READY, BLOODCULT_STAGE_ECLIPSE, BLOODCULT_STAGE_NARSIE)
				stage = 3
	flick("spire[stage]-spawn", src)
	spawn(10)
		update_stage()

/obj/structure/cult/spire/Destroy()
	GLOB.cult_spires -= src
	..()

/obj/structure/cult/spire/proc/upgrade(new_stage)
	new_stage = clamp(new_stage, 1, 3)
	if (new_stage>stage)
		alpha = 255
		overlays.len = 0
		color = null
		flick("spire[new_stage]-morph", src)
		spawn(3)
			update_stage()
	else if (new_stage<stage)
		alpha = 255
		overlays.len = 0
		color = null
		flick("spire[new_stage]-demorph", src)
		spawn(3)
			update_stage()
	stage = new_stage

/obj/structure/cult/spire/proc/update_stage()
	animate(src, alpha = 128, color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 10, loop = -1)
	animate(alpha = 144, color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)
	animate(alpha = 160, color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 2)
	animate(alpha = 176, color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)
	animate(alpha = 192, color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1.5)
	animate(alpha = 208, color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 224, color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 240, color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 255, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5)
	animate(alpha = 240, color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 224, color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 208, color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 192, color = list(1.5, 0.27, 0, 0, 0, 1.5, 0.27, 0, 0.27, 0, 1.5, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 176, color = list(1.375, 0.19, 0, 0, 0, 1.375, 0.19, 0, 0.19, 0, 1.375, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 160, color = list(1.25, 0.12, 0, 0, 0, 1.25, 0.12, 0, 0.12, 0, 1.25, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(alpha = 144, color = list(1.125, 0.06, 0, 0, 0, 1.125, 0.06, 0, 0.06, 0, 1.125, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	overlays.len = 0
	var/image/I_base = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "spire[stage]")
	SET_PLANE_EXPLICIT(I_base, GAME_PLANE_UPPER, src)
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	var/image/I_spire = image('monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', "spire[stage]-light")
	I_spire.plane = ABOVE_LIGHTING_PLANE
	overlays += I_base
	overlays += I_spire


/obj/structure/cult/spire/conceal()
	overlays.len = 0
	set_light(0)
	anim(location = loc, target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult_64x64.dmi', flick_anim = "spire[stage]-conceal", offX = pixel_x, offY = pixel_y, plane = GAME_PLANE)
	..()
	var/obj/structure/cult/concealed/C = loc
	if (istype(C))
		C.icon_state = "spire[stage]"

/obj/structure/cult/spire/reveal()
	..()
	set_light(1)
	flick("spire[stage]-spawn", src)
	animate(src)
	alpha = 255
	color = list(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0)
	spawn(10)
		update_stage()


/obj/structure/cult/spire/cultist_act(/mob/user, menu = "default")
	. = ..()
	if (!.)
		return

	// For now spires work as cult telecomms relay. Eventually they'll serve as a link between the station and the blood realm.

	/*
	if (!ishuman(user))
		to_chat(user, span_warning("Only humans can bear the arcane markings granted by this [name].") )
		return

	var/mob/living/carbon/human/H = user
	var/datum/antagonist/cult/cult_datum = IS_CULTIST(H)

	var/list/available_tattoos = list("tier1", "tier2", "tier3")
	for (var/tattoo in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tattoo]
		available_tattoos -= "tier[CT.tier]"

	var/tattoo_tier = 0
	if (available_tattoos.len <= 0)
		to_chat(user, span_warning("You cannot bear any additional mark.") )
		return
	if ("tier1" in available_tattoos)
		tattoo_tier = 1
	else if ("tier2" in available_tattoos)
		tattoo_tier = 2
	else if ("tier3" in available_tattoos)
		tattoo_tier = 3

	if (!tattoo_tier)
		return

	var/list/choices = list()
	if (stage >= tattoo_tier)
		for (var/subtype in subtypesof(/datum/cult_tattoo))
			var/datum/cult_tattoo/T = new subtype
			if (T.tier == tattoo_tier)
				choices += list(list(T.name, "radial_[T.icon_state]", T.desc)) //According to BYOND docs, when adding to a list, "If an argument is itself a list, each item in the list will be added." My solution to that, because I am a genius, is to add a list within a list.
				to_chat(H, "<span class = 'danger'>[T.name]</span>: [T.desc]")
	else
		to_chat(user, span_warning("Come back to acquire another mark once your cult is a step closer to its goal.") )
		return

	var/tattoo = show_radial_menu(user, loc, choices, 'monkestation/code/modules/bloody_cult/icons/cult_radial2.dmi', "radial-cult2")//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()

	for (var/tat in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tat]
		if (CT.tier == tattoo_tier)//the spire won't let cultists get multiple tattoos of the same tier.
			return

	if (!Adjacent(user))//stay here you bloke!
		return

	for (var/subtype in subtypesof(/datum/cult_tattoo))
		var/datum/cult_tattoo/T = new subtype
		if (T.name == tattoo)
			var/datum/cult_tattoo/new_tattoo = T
			C.tattoos[new_tattoo.name] = new_tattoo

			anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/32x96.dmi', flick_anim = "tattoo_send", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
			spawn (3)
				C.update_cult_hud()
				new_tattoo.getTattoo(H)
				anim(target = H, a_icon = 'monkestation/code/modules/bloody_cult/icons/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
				sleep(1)
				H.update_mutations()
				var/atom/movable/overlay/tattoo_markings = anim(target = H, a_icon = 'icons/mob/cult_tattoos.dmi', flick_anim = "[new_tattoo.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
				animate(tattoo_markings, alpha = 0, time = 30)

			available_tattoos -= "tier[new_tattoo.tier]"
			if (available_tattoos.len > 0)
				cultist_act(user)
			break
	*/


/datum/saymode/cult
	key = "x"
	mode = MODE_CULT

/datum/saymode/cult/handle_message(mob/living/user, message, datum/language/language)
	//we can send the message
	if(!length(GLOB.cult_spires))
		return FALSE
	var/located_z = FALSE
	for(var/obj/structure/cult/spire/spire as anything in GLOB.cult_spires)
		if(spire.z == user.z)
			located_z = TRUE
			break

	if(!located_z)
		return FALSE
	if(!user.mind)
		return FALSE
	if(user.occult_muted())
		return
	if(!user.mind.has_antag_datum(/datum/antagonist/cult) && !istype(user, /mob/living/basic/shade) && !istype(user, /mob/living/basic/astral_projection))
		return

	if(istype(user, /mob/living/basic/construct))
		var/mob/living/basic/construct/construct = user
		if(construct.theme != THEME_CULT)
			return


	user.log_talk(message, LOG_SAY, tag = "cult member [user.name]")
	var/msg = span_cult("<b>[user.name]:</b> [message]")

	//the recipients can recieve the message
	var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
	for(var/datum/mind/mind in cult_team.members)
		if(QDELETED(mind))
			continue
		var/mob/living/cult_member = mind.current
		// can't recieve messages on the hivemind right now
		if(cult_member.occult_muted())
			continue

		var/found_z = FALSE
		for(var/obj/structure/cult/spire/spire as anything in GLOB.cult_spires)
			if(spire.z == user.z)
				found_z = TRUE
				break
		if(!found_z)
			continue

		to_chat(cult_member, msg)

	for(var/mob/dead/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "[FOLLOW_LINK(ghost, user)] [msg]")
	return FALSE
