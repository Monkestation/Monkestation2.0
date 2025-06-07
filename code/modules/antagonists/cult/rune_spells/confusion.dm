GLOBAL_LIST_INIT(confusion_victims, list())

/datum/rune_spell/confusion
	name = "Confusion"
	desc = "Sow panic in the mind of your enemies, and obscure cameras."
	desc_talisman = "Sow panic in the mind of your enemies, and obscure cameras. The effect is shorter than when used from a rune."
	invocation = "Sti' kaliesin!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/other
	page = "This rune instills paranoia in the heart and mind of your enemies. \
	Every non-cultist human in range will see their surroundings appear covered with occult markings, and everyone will look like monsters to them. \
	HUDs won't help officer differentiate their owns for the duration of the illusion.\
	<br><br>Robots in view will be simply blinded for a short while, cameras however will remain dark until someone resets their wiring.\
	<br><br>Because it also causes a few seconds of blindness to those affected, this rune is useful as both a way to initiate a fight, escape, or kidnap someone amidst the chaos.\
	<br><br>The duration is a bit shorter when used from a talisman, but you can slap it directly on someone to only afflict them with the same duration as a rune's."
	var/rune_duration = 30 SECONDS
	var/talisman_duration = 20 SECONDS
	var/hallucination_radius = 25
	touch_cast = 1

/datum/rune_spell/confusion/cast_touch(mob/mob)
	var/turf/T = get_turf(mob)
	invoke(activator, invocation, 1)

	new /obj/effect/cult_ritual/confusion(T, rune_duration, hallucination_radius, mob, activator)

	qdel(src)

/datum/rune_spell/confusion/cast(duration = rune_duration)
	new /obj/effect/cult_ritual/confusion(spell_holder, duration, hallucination_radius, null, activator)
	qdel(spell_holder)

/datum/rune_spell/confusion/cast_talisman()//talismans have the same range, but the effect lasts shorter.
	cast(talisman_duration)

/obj/effect/cult_ritual/confusion
	anchored = 1
	icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi'
	icon_state = ""
	pixel_x = -32/2
	pixel_y = -32/2
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0
	var/duration = 5
	var/hallucination_radius = 25

/obj/effect/cult_ritual/confusion/New(turf/loc, duration = 30 SECONDS, radius = 25, mob/specific_victim = null, mob/culprit)
	..()
	//Alright, this is a pretty interesting rune, first of all we prepare the fake cult floors & walls that the victims will see.
	var/turf/T = get_turf(src)
	var/list/hallucinated_turfs = list()
	if (!specific_victim)
		playsound(T, 'monkestation/code/modules/bloody_cult/sound/confusion_start.ogg', 75, 0, 0)
	for(var/turf/U in range(radius, T))
		if (istype(U, /area/station/service/chapel))//the chapel is protected against such illusions, the mobs in it will still be affected however.
			continue
		var/dist = cheap_pythag(U.x - T.x, U.y - T.y)
		if (dist < 15 || prob((radius-dist)*4))
			var/image/I_turf
			if (!U.density)
				I_turf = image(icon = 'icons/turf/floors.dmi', loc = U, icon_state = "cult")
				//if it's a floor, give it a chance to have some runes written on top
				if (GLOB.rune_appearances_cache.len > 0 && prob(7))
					var/lookup = pick(GLOB.rune_appearances_cache)//finally a good use for that cache
					var/image/I = GLOB.rune_appearances_cache[lookup]
					I_turf.overlays += I
			hallucinated_turfs.Add(I_turf)

	//now let's round up our victims: any non-cultist with an unobstructed line of sight to the rune/talisman will be affected
	var/list/potential_victims = list()

	if (specific_victim)
		potential_victims.Add(specific_victim)
		specific_victim.playsound_local(T, 'monkestation/code/modules/bloody_cult/sound/confusion_start.ogg', 75, 0, 0)
	else
		for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
			potential_victims.Add(M)

	var/datum/antagonist/cult/our_cultist
	if (culprit && culprit.mind)
		our_cultist = culprit.mind.has_antag_datum(/datum/antagonist/cult)

	for(var/mob/living/M in potential_victims)

		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (IS_CULTIST(C))
				continue

			var/datum/confusion_manager/CM
			if (M in GLOB.confusion_victims)
				CM = GLOB.confusion_victims[M]
			else
				CM = new(M, duration)
				GLOB.confusion_victims[M] = CM

			if (M.stat != DEAD && our_cultist)
				if (specific_victim == M)
					our_cultist.gain_devotion(50, DEVOTION_TIER_2, "confusion_papered", M)
				else
					our_cultist.gain_devotion(50, DEVOTION_TIER_2, "confusion_carbon", M)

			spawn()
				CM.apply_confusion(T, hallucinated_turfs)

		if (issilicon(M) && !isAI(M))//Silicons get a fade to black, then just a flash, until I can think of something else
			shadow(M, T)
			if (M.stat != DEAD && our_cultist)
				our_cultist.gain_devotion(50, DEVOTION_TIER_2, "confusion_silicon", M)
			M.overlay_fullscreen("blindblack", /atom/movable/screen/fullscreen/black)
			M.update_fullscreen_alpha("blindblack", 255, 5)
			spawn(5)
				M.clear_fullscreen("blindblack", animated = FALSE)

	//now to blind cameras, the effects on cameras do not time out, but they can be fixed
	if (!specific_victim)
		for(var/obj/machinery/camera/C in dview(world.view, T, INVISIBILITY_MAXIMUM))
			shadow(C, T)
			var/col = C.color
			animate(C, color = col, time = 4)
			animate(color = "black", time = 5)
			animate(color = col, time = 5)
			if (our_cultist)
				our_cultist.gain_devotion(50, DEVOTION_TIER_2, "confusion_camera", C)
			C.setViewRange(-1)//The camera won't reveal the area for the AI anymore

	qdel(src)

//each affected mob gets their own
/datum/confusion_manager
	var/time_of_last_confusion = 0
	var/list/my_hallucinated_stuff = list()
	var/mob/victim = null
	var/duration = 30 SECONDS

/datum/confusion_manager/New(mob/M, D)
	..()
	victim = M
	duration = D

/datum/confusion_manager/Destroy()
	my_hallucinated_stuff = list()
	victim = null
	..()

/datum/confusion_manager/proc/apply_confusion(turf/T, list/hallucinated_turfs)
	shadow(victim, T)//shadow trail moving from the spell_holder to the victim
	anim(target = victim, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_blind", plane = ABOVE_LIGHTING_PLANE)

	if (!time_of_last_confusion)
		start_confusion(T, hallucinated_turfs)
		return
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] had the effects of Confusion refreshed back to [duration/10] seconds.")
		log_admin("BLOODCULT: [key_name(victim)] had the effects of Confusion refreshed by back to [duration/10] seconds.")
	var/time_key = world.time
	time_of_last_confusion = time_key
	victim.update_fullscreen_alpha("blindblack", 255, 5)
	ADD_TRAIT(victim, TRAIT_POOR_AIM, "rune")
	addtimer(CALLBACK(src, PROC_REF(refresh_confusion), T, hallucinated_turfs, time_key), 1 SECONDS)

/datum/confusion_manager/proc/start_confusion(turf/T, list/hallucinated_turfs)
	var/time_key = world.time
	time_of_last_confusion = time_key
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] is now under the effects of Confusion for [duration/10] seconds.")
		log_admin("BLOODCULT: [key_name(victim)] is now under the effects of Confusion for [duration/10] seconds.")
	to_chat(victim, span_danger("Your vision goes dark, panic and paranoia take their toll on your mind.") )
	victim.overlay_fullscreen("blindborder", /atom/movable/screen/fullscreen/confusion_border)//victims DO still get blinded for a second
	victim.overlay_fullscreen("blindblack", /atom/movable/screen/fullscreen/black)//which will allow us to subtly reveal the surprise
	victim.update_fullscreen_alpha("blindblack", 255, 5)
	victim.playsound_local(victim, 'monkestation/code/modules/bloody_cult/sound/confusion.ogg', 50, 0, 0, 0, 0)
	victim.overlay_fullscreen("blindblind", /atom/movable/screen/fullscreen/blind)
	addtimer(CALLBACK(src, PROC_REF(refresh_confusion), T, hallucinated_turfs, time_key), 1 SECONDS)

/datum/confusion_manager/proc/refresh_confusion(turf/T,  list/hallucinated_turfs, time_key)
	victim.update_fullscreen_alpha("blindblind", 255, 0)
	victim.update_fullscreen_alpha("blindblack", 0, 10)
	victim.update_fullscreen_alpha("blindblind", 0, 80)
	victim.update_fullscreen_alpha("blindborder", 150, 5)

	if (victim.client)
		var/static/list/hallucination_mobs = list("faithless", "forgotten", "otherthing")
		for(var/image/image as anything in my_hallucinated_stuff)
			if(!istype(image))
				continue
			victim.client.images -= image //removing images caused by every blind rune used consecutively on that mob
		my_hallucinated_stuff = hallucinated_turfs.Copy()
		for(var/mob/living/L in range(T, 25))//All mobs in a large radius will look like monsters to the victims.
			if (L == victim)
				continue//the victims still see themselves as humans (or whatever they are)
			var/image/override_overlay = image(icon = 'monkestation/code/modules/bloody_cult/icons/animal.dmi', loc = L, icon_state = pick(hallucination_mobs))
			override_overlay.override = TRUE
			my_hallucinated_stuff.Add(override_overlay)
		for(var/image/image as anything in my_hallucinated_stuff)
			if(!istype(image))
				continue
			victim.client.images |= image

	addtimer(CALLBACK(src, PROC_REF(clear_confusion), time_key), duration - 5)

/datum/confusion_manager/proc/clear_confusion(time_key)
	if (time_of_last_confusion != time_key)//only the last applied confusion gets to end it
		return

	victim.update_fullscreen_alpha("blindborder", 0, 5)
	victim.overlay_fullscreen("blindwhite", /atom/movable/screen/fullscreen/white)
	victim.update_fullscreen_alpha("blindwhite", 255, 3)
	sleep(5)
	REMOVE_TRAIT(victim, TRAIT_POOR_AIM, "rune")
	GLOB.confusion_victims.Remove(victim)
	victim.update_fullscreen_alpha("blindwhite", 0, 12)
	victim.clear_fullscreen("blindblack", animated = FALSE)
	victim.clear_fullscreen("blindborder", animated = FALSE)
	victim.clear_fullscreen("blindblind", animated = FALSE)
	anim(target = victim, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_blind_remove", plane = ABOVE_LIGHTING_PLANE)
	if (victim.client)
		for(var/image/image as anything in my_hallucinated_stuff)
			if(!istype(image))
				continue
			victim.client.images -= image //removing images caused by every blind rune used consecutively on that mob
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] is no longer under the effects of Confusion.")
		log_admin("BLOODCULT: [key_name(victim)] is no longer under the effects of Confusion.")
	sleep(15)
	victim.clear_fullscreen("blindwhite", animated = FALSE)
	qdel(src)
