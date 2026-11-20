/obj/effect/abstract/wonderland_tear
	name = "wonderland tear"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Whoever is cutting the rift open, they slice away at us.
	var/mob/living/cutter
	/// The lens that bends the world around us.
	var/atom/movable/warp_effect/warp
	var/pulses = 0
	var/pulse_timer
	/// Turfs nothing has sprouted on yet, nearest first.
	var/list/turf/unsprouted
	var/list/obj/structure/flora/sprouted = list()
	/// Onlookers who already got told their head is going funny.
	var/list/mob/living/dazed = list()

/obj/effect/abstract/wonderland_tear/Initialize(mapload, mob/living/cutter)
	. = ..()
	src.cutter = cutter
	warp = new(src)
	warp.transform = matrix().Scale(0.3)
	vis_contents += warp

	var/list/rings = list(list(), list())
	for(var/turf/candidate in dview(2, loc))
		var/ring = get_dist(loc, candidate)
		if(ring < 1 || isgroundlessturf(candidate) || candidate.is_blocked_turf(exclude_mobs = TRUE))
			continue
		rings[ring] += candidate
	shuffle_inplace(rings[1])
	shuffle_inplace(rings[2])
	unsprouted = rings[1] + rings[2]

	pulse()
	pulse_timer = addtimer(CALLBACK(src, PROC_REF(pulse)), 1 SECONDS, TIMER_LOOP | TIMER_STOPPABLE)

/obj/effect/abstract/wonderland_tear/Destroy()
	if(pulse_timer)
		deltimer(pulse_timer)
		pulse_timer = null
	vis_contents -= warp
	QDEL_NULL(warp)
	cutter = null
	unsprouted = null
	sprouted = null
	dazed = null
	return ..()

/obj/effect/abstract/wonderland_tear/proc/pulse()
	pulses++
	if(!QDELETED(cutter))
		cutter.do_attack_animation(loc)
		var/obj/item/weapon = cutter.get_active_held_item()
		if(weapon?.hitsound)
			playsound(loc, weapon.hitsound, vol = 50, vary = TRUE, pressure_affected = FALSE)

	do_cognitohazard_thing()

	var/lens_scale = min(0.3 + pulses * 0.05, 0.8)
	animate(warp, transform = matrix().Scale(lens_scale * 0.5), time = 0.3 SECONDS)
	animate(transform = matrix().Scale(lens_scale), time = 0.7 SECONDS)

	var/static/list/plant_types = list(
		/obj/structure/flora/bush/flowers_yw/style_random,
		/obj/structure/flora/bush/flowers_br/style_random,
		/obj/structure/flora/bush/flowers_pp/style_random,
		/obj/structure/flora/bush/lavendergrass/style_random,
		/obj/structure/flora/bush/sparsegrass/style_random,
		/obj/structure/flora/bush/fullgrass/style_random,
	)
	for(var/i in 1 to rand(1, 2))
		var/turf/spot = popleft(unsprouted)
		if(!spot)
			break
		var/plant_type = pick(plant_types)
		var/obj/structure/flora/plant = new plant_type(spot)
		plant.transform = matrix().Scale(0.1)
		plant.alpha = 0
		animate(plant, transform = matrix(), alpha = 255, time = 0.4 SECONDS, easing = BACK_EASING | EASE_OUT)
		sprouted += plant

/// Everyone watching who isn't a hunter gets their head scrambled a little more with each slice
/obj/effect/abstract/wonderland_tear/proc/do_cognitohazard_thing()
	for(var/mob/living/victim in viewers(4, loc))
		if(victim.stat == DEAD || IS_MONSTERHUNTER(victim))
			continue
		if(!(victim in dazed))
			dazed += victim
			to_chat(victim, span_hypnophrase("The world tilts sideways. Something is opening here."))
		var/multiplier = is_monster_hunter_prey(victim) ? 2.5 : 1
		victim.adjust_dizzy_up_to(2 SECONDS * multiplier, 10 SECONDS * multiplier)
		victim.adjust_confusion_up_to(1 SECONDS * multiplier, 4 SECONDS * multiplier)
		victim.adjust_disgust(3 * multiplier)
		victim.mob_mood?.adjust_sanity(-2 * multiplier)

/// Cutting finished, the lens bursts outward and the plants stay.
/obj/effect/abstract/wonderland_tear/proc/burst()
	deltimer(pulse_timer)
	pulse_timer = null
	animate(warp, transform = matrix().Scale(1.5), alpha = 0, time = 0.6 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	QDEL_IN(src, 0.6 SECONDS)

/// Cutting got interrupted, everything it grew withers away.
/obj/effect/abstract/wonderland_tear/proc/fizzle()
	deltimer(pulse_timer)
	pulse_timer = null
	animate(warp, transform = matrix().Scale(0.05), time = 0.3 SECONDS)
	for(var/obj/structure/flora/plant as anything in sprouted)
		if(QDELETED(plant))
			continue
		animate(plant, color = "#6b4a2b", transform = matrix().Scale(1, 0.4), alpha = 0, time = 0.6 SECONDS)
		QDEL_IN(plant, 0.6 SECONDS)
	QDEL_IN(src, 0.6 SECONDS)
