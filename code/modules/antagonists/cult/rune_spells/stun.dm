
/datum/rune_spell/stun
	name = "Stun"
	desc = "Overwhelm everyone's senses with a blast of pure chaotic energy. Cultists will recover their senses a bit faster."
	desc_talisman = "Use to produce a smaller radius blast, or touch someone with it to focus the entire power of the spell on their person."
	invocation = "Fuu ma'jin!"
	touch_cast = TRUE
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/hide
	word3 = /datum/rune_word/technology
	page = "Concentrated chaotic energies violently released that will temporarily enfeeble anyone in a large radius, even cultists, although those recover a second faster than non-cultists.\
		<br><br>When cast from a talisman, the energy affects creatures in a smaller radius and for a smaller duration, which might still be useful in an enclosed space.\
		<br><br>However the real purpose of this rune when imbued into a talisman is revealed when you directly touch someone with it, as all of the energies will be concentrated onto their single body, \
		paralyzing and muting them for a longer duration. This application was created to allow cultists to easily kidnap crew members to convert or torture."


/datum/rune_spell/stun/pre_cast()
	var/mob/living/user = activator

	if (istype (spell_holder, /obj/effect/new_rune))
		invoke(user, invocation)
		cast()
	else if (istype (spell_holder, /obj/item/talisman))
		invoke(user, invocation, 1)
		cast_talisman()

/datum/rune_spell/stun/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	new/obj/effect/cult_ritual/stun(R.loc, 1, activator)

	qdel(R)

/datum/rune_spell/stun/cast_talisman()
	var/turf/T = get_turf(spell_holder)
	new/obj/effect/cult_ritual/stun(T, 2, activator)
	qdel(src)

/datum/rune_spell/stun/cast_touch(mob/living/M)
	anim(target = M, a_icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi', flick_anim = "touch_stun", offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)

	playsound(spell_holder, 'monkestation/code/modules/bloody_cult/sound/stun_talisman.ogg', 25, 0, -5)
	if (prob(15))//for old times' sake
		invoke(activator, "Dream sign ''Evil sealing talisman''!", 1)
	else
		invoke(activator, invocation, 1)

	if (M.stat != DEAD)
		var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum.gain_devotion(100, DEVOTION_TIER_2, "stun_papered", M)

	if(issilicon(M))
		to_chat(M, span_danger("WARNING: Short-circuits detected, Rebooting...") )
		M.Knockdown(9 SECONDS)

	else if(iscarbon(M))
		to_chat(M, span_danger("A surge of dark energies takes hold of your limbs. You stiffen and fall down.") )
		var/mob/living/carbon/C = M
		C.Knockdown(5 SECONDS)//used to be 25
		C.Stun(5 SECONDS)//used to be 25
		if (isalien(C))
			C.Paralyze(5 SECONDS)

	if (!(locate(/obj/effect/stun_indicator) in M))
		new /obj/effect/stun_indicator(M)

	qdel(src)

/obj/effect/cult_ritual/stun
	//icon_state = "stun_warning"
	icon_state = null
	color = "black"
	anchored = 1
	alpha = 0
	//plane = HIDING_MOB_PLANE
	mouse_opacity = 0
	var/stun_duration = 10 SECONDS

/obj/effect/cult_ritual/stun/New(turf/loc, type = 1, mob/living/carbon/caster)
	..()

	switch (type)
		if (1)
			stun_duration = 10 SECONDS
			anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi', flick_anim = "rune_stun", sleeptime = 20, offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'monkestation/code/modules/bloody_cult/icons/480x480.dmi'
			pixel_x = -224
			pixel_y = -224
			animate(src, alpha = 255, time = 10)
		if (2)
			stun_duration = 5 SECONDS
			anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi', flick_anim = "talisman_stun", sleeptime = 20, offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'monkestation/code/modules/bloody_cult/icons/224x224.dmi'
			pixel_x = -96
			pixel_y = -96
			animate(src, alpha = 255, time = 10)

	playsound(src, 'monkestation/code/modules/bloody_cult/sound/stun_rune_charge.ogg', 75, 0, 0)
	spawn(20)
		playsound(src, 'monkestation/code/modules/bloody_cult/sound/stun_rune.ogg', 75, 0, 0)
		visible_message(span_warning("The rune explodes in a bright flash of chaotic energies.") )

		for(var/mob/living/L in dview(7, get_turf(src)))
			var/duration = stun_duration
			var/dist = cheap_pythag(L.x - src.x, L.y - src.y)
			if (type == 1 && dist >= 8)
				continue
			if (type == 2 && dist >= 4)//talismans have a reduced range
				continue
			shadow(L, loc, "rune_stun")
			if (IS_CULTIST(L))
				duration = 1 SECONDS
			else if (caster)
				if (L.stat != DEAD)
					var/datum/antagonist/cult/cult_datum = caster.mind.has_antag_datum(/datum/antagonist/cult)
					cult_datum.gain_devotion(50, DEVOTION_TIER_2, "stun_rune", L)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.Knockdown(duration)
				C.Stun(duration)
				if (isalien(C))
					C.Paralyze(duration)

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Knockdown(duration)//TODO: TEST THAT
		qdel(src)
