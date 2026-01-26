/datum/symptom/cult_hallucination
	name = "Visions of the End-Times"
	desc = "UNKNOWN"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	severity = 2
	max_multiplier = 2.5

/datum/symptom/cult_hallucination/activate(mob/living/mob)
	var/turf/mob_turf = get_turf(mob)
	if(!mob_turf || IS_CULTIST(mob) || istype(get_area(mob), /area/station/service/chapel) || !mob?.client)
		return
	mob.whisper("...[pick("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")]...", forced = "[type]")

	var/list/turf_list = list()
	turf_loop:
		for(var/turf/open/turf in RANGE_TURFS(10, mob_turf))
			if(!prob(2 * multiplier))
				continue
			if(istype(get_area(turf), /area/station/service/chapel))
				continue
			for(var/atom/movable/atom_content as anything in turf.contents)
				if(isobj(atom_content) && atom_content.density)
					continue turf_loop
			turf_list += turf
	for(var/turf/open/turf as anything in turf_list)
		addtimer(CALLBACK(src, PROC_REF(start_rune_fade_in), mob, turf), rand(0, 5 SECONDS))

/datum/symptom/cult_hallucination/proc/start_rune_fade_in(mob/living/victim, turf/turf)
	if(QDELETED(victim) || !victim.client || QDELETED(src))
		return
	var/client/victim_client = victim.client
	var/runenum = rand(1, 2)
	var/image/rune_holder = image('monkestation/code/modules/virology/icons/deityrunes.dmi', turf, "")
	var/image/rune_render = image('monkestation/code/modules/virology/icons/deityrunes.dmi', turf, "fullrune-[runenum]")
	rune_render.color = LIGHT_COLOR_BLOOD_MAGIC

	victim_client.images += rune_holder

	addtimer(CALLBACK(src, PROC_REF(finish_rune_fade_in), victim, rune_holder, rune_render), 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(rune_fade_out), victim, rune_holder, rune_render), rand(20 SECONDS, 40 SECONDS))

/datum/symptom/cult_hallucination/proc/finish_rune_fade_in(mob/living/victim, image/rune_holder, image/rune_render)
	rune_holder.overlays += rune_render
	AnimateFakeRune(rune_holder)

/datum/symptom/cult_hallucination/proc/rune_fade_out(mob/living/victim, image/rune_holder, image/rune_render)
	var/client/victim_client = victim?.client
	if(!victim_client)
		return
	rune_holder.overlays -= rune_render
	addtimer(CALLBACK(src, PROC_REF(finish_rune_fade_out), victim, rune_holder), 1.2 SECONDS)

/datum/symptom/cult_hallucination/proc/finish_rune_fade_out(mob/living/victim, image/rune_holder)
	var/client/victim_client = victim?.client
	if(victim_client)
		victim_client.images -= rune_holder

/datum/symptom/cult_hallucination/proc/AnimateFakeRune(image/rune)
	animate(rune, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2
