
///this is hell and should be replaced.
/image/reveal
	var/client/owner_client

/image/reveal/proc/set_client(mob/user)
	owner_client = user.client
	RegisterSignal(owner_client.mob, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(offset_image))

/image/reveal/Destroy(force)
	. = ..()
	UnregisterSignal(owner_client.mob, COMSIG_MOVABLE_PRE_MOVE)
	owner_client.images -= src

/image/reveal/proc/offset_image(atom/mover, turf/new_loc)
	if(new_loc.density)
		return // this is sanity checking incase running into wall
	var/direction = get_dir(mover, new_loc)

	switch(direction)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32

/datum/rune_spell/reveal
	name = "Reveal"
	desc = "Reveal what you have previously hidden, terrifying enemies in the process."
	desc_talisman = "Reveal what you have previously hidden, terrifying enemies in the process. The effect is shorter than when used from a rune."
	invocation = "Nikt'o barada kla'atu!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/hide
	page = "This rune (whose words are the same as the Conceal rune in reverse) lets you reveal every rune and structures in a circular 7 tile range around it.\
		<br><br>Each revealed rune will stun non-cultists in a 3 tile range around them, stunning and muting them for 2 seconds, up to a total of 10 seconds. Affects through walls. The stun ends if the victims are moved away from where they stand, unless they get knockdown first, so you might want to follow up with a Stun talisman."

	walk_effect = TRUE

	var/effect_range = 7
	var/shock_range = 3
	var/shock_per_obj = 2
	var/max_shock = 10
	var/last_threshold = -1
	var/total_uses = 5

/datum/rune_spell/reveal/cast()
	var/turf/T = get_turf(spell_holder)
	var/list/shocked = list()
	to_chat(activator, span_notice("All concealed runes and cult structures in range phase back into reality, stunning nearby foes.") )
	playsound(T, 'monkestation/code/modules/bloody_cult/sound/reveal.ogg', 50, 0, -3)
	var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)

	for(var/obj/structure/cult/concealed/S in range(effect_range, T))//only concealed structures trigger the effect
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		if (dist <= effect_range+0.5)
			cult_datum.gain_devotion(10, DEVOTION_TIER_0, "reveal_structure", S)
			anim(target = S, a_icon = 'monkestation/code/modules/bloody_cult/icons/224x224.dmi', flick_anim = "rune_reveal", offX = -32*shock_range, offY = -32*shock_range, plane = ABOVE_LIGHTING_PLANE)
			for(var/mob/living/L in viewers(S))
				if (IS_CULTIST(L))
					continue
				var/dist2 = cheap_pythag(L.x - S.x, L.y - S.y)
				if (dist2 > shock_range+0.5)
					continue
				shadow(L, S.loc, "rune_reveal")
				if (L in shocked)
					shocked[L] = min(shocked[L]+shock_per_obj, max_shock)
				else
					shocked[L] = 2
			S.reveal()

	for(var/obj/effect/new_rune/R in range(effect_range, T))
		var/dist = cheap_pythag(R.x - T.x, R.y - T.y)
		if (dist <= effect_range+0.5)
			if (R.reveal())//only hidden runes trigger the effect
				cult_datum.gain_devotion(10, DEVOTION_TIER_0, "reveal_rune", R)
				anim(target = R, a_icon = 'monkestation/code/modules/bloody_cult/icons/224x224.dmi', flick_anim = "rune_reveal", offX = -32*shock_range, offY = -32*shock_range, plane = ABOVE_LIGHTING_PLANE)
				for(var/mob/living/L in viewers(R))
					if (IS_CULTIST(L))
						continue
					var/dist2 = cheap_pythag(L.x - R.x, L.y - R.y)
					if (dist2 > shock_range+0.5)
						continue
					shadow(L, R.loc, "rune_reveal")
					if (L in shocked)
						shocked[L] = min(shocked[L]+shock_per_obj, max_shock)
					else
						shocked[L] = 2

	for(var/mob/living/L in shocked)
		if (L.stat != DEAD)
			cult_datum.gain_devotion(50, DEVOTION_TIER_2, "reveal_stun", L)
		new /obj/effect/cult_ritual/reveal(L.loc, L, shocked[L])
		to_chat(L, span_danger("You feel a terrifying shock resonate within your body as the hidden runes are revealed!") )
		L.update_fullscreen_alpha("shockborder", 100, 5)
		spawn(8)
			L.update_fullscreen_alpha("shockborder", 0, 5)
			sleep(8)
			L.clear_fullscreen("shockborder", animated = FALSE)

	qdel(spell_holder)

/datum/rune_spell/reveal/Added(var/mob/mover)
	if (total_uses <= 0)
		return
	if (!isliving(mover))
		return
	var/mob/living/L = mover
	if (last_threshold + 20 SECONDS > world.time)
		return
	if (!IS_CULTIST(L))
		total_uses--
		last_threshold = world.time
		var/list/seers = list()
		for (var/mob/living/seer in range(7, get_turf(spell_holder)))
			if (IS_CULTIST(seer) && seer.client)
				seers += seer

		cast_image(mover, seers, 10)

/datum/rune_spell/reveal/proc/cast_image(mob/mover, list/seers, count)
	if(count == 0)
		return
	var/mob/living/L = mover
	for (var/mob/living/seer in seers)
		if (QDELETED(seer))
			seers -= seer
			continue
		var/image/reveal/image_intruder = new
		image_intruder.appearance = L
		image_intruder.loc = seer
		image_intruder.dir = L.dir
		var/delta_x = (L.x - seer.x)
		var/delta_y = (L.y - seer.y)

		image_intruder.set_client(seer)

		image_intruder.pixel_x = delta_x*32
		image_intruder.plane = ABOVE_LIGHTING_PLANE
		image_intruder.pixel_y = delta_y*32
		image_intruder.alpha = 200
		image_intruder.color = COLOR_BLOOD

		animate(image_intruder, alpha = 0, time = 3)
		seer.client.images += image_intruder // see the mover for a set period of time
		QDEL_IN(image_intruder, 4)

	count--
	addtimer(CALLBACK(src, PROC_REF(cast_image), mover, seers, count), 1 SECONDS)

/datum/rune_spell/reveal/cast_talisman()
	shock_per_obj = 1.5
	max_shock = 8
	cast()


/obj/effect/cult_ritual/reveal
	anchored = 1
	icon_state = "rune_reveal"
	plane = ABOVE_LIGHTING_PLANE
	var/mob/living/victim = null
	var/duration = 2

/obj/effect/cult_ritual/reveal/Destroy()
	victim = null
	anim(target = loc, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_reveal-stop", plane = ABOVE_LIGHTING_PLANE)
	..()

/obj/effect/cult_ritual/reveal/New(var/turf/loc, var/mob/living/vic = null, var/dur = 2)
	..()
	if (!vic)
		vic = locate() in loc
		if (!vic)
			qdel(src)
			return
	playsound(loc, 'monkestation/code/modules/bloody_cult/sound/shock.ogg', 20, 0, 0)
	victim = vic
	duration = dur
	victim.Stun(duration)
	if (isalien(victim))
		victim.Paralyze(duration)
	spawn (duration*10)
		if (src && loc && victim && victim.loc == loc && !victim.IsKnockdown())
			to_chat(victim, span_warning("You come back to your senses.") )
			victim.AdjustStun(-duration)
			if (isalien(victim))
				victim.AdjustParalyzed(-duration)
			victim = null
		qdel(src)

/obj/effect/cult_ritual/reveal/HasProximity(var/atom/movable/AM)//Pulling victims will immediately dispel the effects
	if (!victim)
		qdel(src)
		return

	if (victim.loc != loc)
		if (!victim.IsKnockdown())//if knockdown (by any cause), moving away doesn't purge you from the remaining stun.
			if (victim.pulledby)
				to_chat(victim, span_warning("You come back to your senses as \the [victim.pulledby] drags you away.") )
			victim.AdjustStun(-duration)
			if (isalien(victim))
				victim.AdjustParalyzed(-duration)
			victim = null
		qdel(src)
