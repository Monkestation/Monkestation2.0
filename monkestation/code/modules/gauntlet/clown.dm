//Originally coded for HippieStation by Steamp0rt, shared under the AGPL licenterse.

/obj/item/badmin_stone/clown
	name = "Clown Stone"
	desc = "HONK HONK HONK HONK HONK"
	color = "#FFC0CB"
	stone_type = CLOWN_STONE
	ability_text = list(
		"HELP INTENT: fire banana cream pies.",
		"DISARM INTENT: Throw an angry monkey that is aligned with the clown.",
		"HARM INTENT: Spawn the Traps."
	)
	spell_types = list(
		/datum/action/cooldown/spell/infinity/pranksters_delusion,
		/datum/action/cooldown/spell/infinity/cake
	)
	stone_spell_types = list(
		/datum/action/cooldown/spell/infinity/honksong,
		/datum/action/cooldown/spell/infinity/party_popper
	)
	gauntlet_spell_types = list(
		/datum/action/cooldown/spell/infinity/thanoscar_thanoscar
	)
	var/next_traps = 0
	var/monkey_stockpile = 3
	var/next_monkey = 0

/obj/item/badmin_stone/clown/process()
	..()
	if(world.time >= next_monkey)
		monkey_stockpile = min(3, monkey_stockpile + 1)
		next_monkey = world.time + 25 SECONDS

/obj/item/badmin_stone/clown/help_act(atom/target, mob/user, proximity_flag)
	var/obj/item/food/pie/cream/pie = new(get_turf(user))
	pie.throw_at(target, 30, 3, user, TRUE)
	playsound(src, 'sound/magic/staff_animation.ogg', 50, 1)
	new /obj/effect/temp_visual/dir_setting/firing_effect/magic(get_turf(src))
	user.changeNext_move(CLICK_CD_RANGE)

/obj/item/badmin_stone/clown/harm_act(atom/target, mob/user, proximity_flag)
	if(next_traps > world.time)
		to_chat(user, span_danger("You need to wait [DisplayTimeText(next_traps - world.time)] to summon more traps!"))
		return
	var/list/trap_area = view(4, user)
	for(var/i = 0, i < 5, i++)
		var/turf/T = get_turf(pick_n_take(trap_area))
		var/trap_type = pick(list(
			/obj/structure/trap/stun,
			/obj/structure/trap/fire,
			/obj/structure/trap/chill,
			/obj/structure/trap/damage
		))
		var/obj/structure/trap/TR = new trap_type(T)
		TR.immune_minds += user.mind
		TR.charges = 1
		QDEL_IN(TR, 900) // they last 90 seconds
	next_traps = world.time + 15 SECONDS

/obj/item/badmin_stone/clown/disarm_act(atom/target, mob/user, proximity_flag)
	if(monkey_stockpile < 1)
		to_chat(user, span_warning("\The [src] is out of monkeys!"))
		return
	var/turf/monkey_loc = get_step(get_turf(user), get_dir(user, target))
	var/mob/living/carbon/human/species/monkey/angry/monkey = new(monkey_loc)
	monkey.faction = list(FACTION_NEUTRAL, FACTION_MONKEY, FACTION_CLOWN)
	monkey.throw_at(target, 7, 3, src, TRUE)
	monkey_stockpile--

/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/infinity/party_popper
	name = "Clown Stone: Party Popper"
	desc = "Gib yourself and heal everyone around you, even the dead."
	button_icon_state = "partypop"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "clown"
	cooldown_time = 0

/datum/action/cooldown/spell/infinity/party_popper/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/living_caster = cast_on
	var/prompt = alert("Are you sure you'd like to pop? There's no way to be revived!", "Confirm", "Yes", "No")
	if(prompt != "Yes")
		return
	cast_on.visible_message(span_boldnotice("[cast_on] pops!"))
	playsound(get_turf(cast_on), 'sound/items/party_horn.ogg', 50, 1)
	for(var/mob/living/living in view(7, cast_on))
		if(living == cast_on)
			continue
		for(var/i = 1 to 5)
			new /obj/effect/temp_visual/heal(get_turf(living))
		living.grab_ghost()
		living.revive(TRUE, TRUE)
		to_chat(living, span_notice("You feel amazing!"))
	living_caster.gib(TRUE, TRUE, TRUE)

/datum/action/cooldown/spell/infinity/pranksters_delusion
	name = "Clown Stone: Prankster's Delusion"
	desc = "Causes those around you to see others as a clumsy clown (or maybe a gondola)! Now how will they know who is who?"
	button_icon_state = "prankstersdelusion"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "clown"
	cooldown_time = 75 SECONDS

/datum/action/cooldown/spell/infinity/pranksters_delusion/cast(atom/cast_on)
	. = ..()
	for(var/mob/living/carbon/carbon in view(7, cast_on))
		if(carbon == cast_on)
			continue
		to_chat(carbon, span_clown("HONK."))
		if(prob(50))
			new /datum/hallucination/delusion(carbon, TRUE, "custom", 600, 0, "clown", 'icons/mob/simple/clown_mobs.dmi')
		else
			new /datum/hallucination/delusion(carbon, TRUE, "custom", 600, 0, "gondola", 'icons/mob/simple/gondolas.dmi')

/datum/action/cooldown/spell/infinity/honksong
	name = "Clown Stone: Honksong"
	desc = "Summon a 6x6 dance floor, and dance to heal everyone around you (but yourself)!"
	button_icon_state = "honksong"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "clown"
	cooldown_time = 100 SECONDS
	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE
	var/turf/initial_loc
	var/lights_spinning = FALSE
	var/list/spotlights = list()
	var/list/sparkles = list()
	var/sparkles_setup = FALSE

/datum/action/cooldown/spell/infinity/honksong/cast(atom/cast_on)
	. = ..()
	var/obj/item/badmin_stone/clown/clown_stone = locate() in cast_on
	if(!isliving(cast_on))
		return
	var/mob/living/living_caster = cast_on
	if(!clown_stone)
		to_chat(cast_on, span_notice("How are you casting this without the clown stone wtf?"))
		return
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)
	if(dancefloor_exists)
		dancefloor_exists = FALSE
		sparkles_setup = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/turf = dancefloor_turfs[i]
			if(turf)
				turf.ChangeTurf(dancefloor_turfs_types[i])
		QDEL_LIST(spotlights)
	else
		var/list/funky_turfs = RANGE_TURFS(3, cast_on)
		dancefloor_exists = TRUE
		sparkles_setup = FALSE
		var/i = 1
		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len
		for(var/turf/open/open_turf in funky_turfs)
			dancefloor_turfs[i] = open_turf
			dancefloor_turfs_types[i] = open_turf.type
			open_turf.ChangeTurf((i % 2 == 0) ? /turf/open/floor/light/colour_cycle/dancefloor_a : /turf/open/floor/light/colour_cycle/dancefloor_b)
			i++
		cast_on.visible_message(span_notice("A dance floor forms around [cast_on]!"))
		dance_setup(cast_on)
		initial_loc = cast_on.loc
		i = 1
		living_caster.spin(175, 1)
		INVOKE_ASYNC(src, PROC_REF(setup_sparkles), cast_on)
		while(do_after(cast_on, 10, target = clown_stone))
			living_caster.spin(20, 1)
			cast_on.SpinAnimation(7,1)
			if(prob(75))
				playsound(cast_on, 'sound/items/bikehorn.ogg', 50, 1)
			else
				playsound(cast_on, 'sound/items/airhorn2.ogg', 50, 1)
			lights_spin(cast_on)
			for(var/dancefloor in 1 to dancefloor_turfs.len)
				var/turf/dancefloor_turf = dancefloor_turfs[dancefloor]
				for(var/mob/living/living_on_dancefloor in dancefloor_turf)
					if(living_on_dancefloor == cast_on)
						continue
					living_on_dancefloor.heal_overall_damage(5, 5, 5)
					new /obj/effect/temp_visual/heal(get_turf(living_on_dancefloor))
			i++
		QDEL_LIST(sparkles)
		QDEL_LIST(spotlights)
		cast_on.visible_message(span_notice("The dance floor reverts back to normal..."))
		for(var/dancefloor in 1 to dancefloor_turfs.len)
			var/turf/dancefloor_turf = dancefloor_turfs[dancefloor]
			if(dancefloor_turf)
				dancefloor_turf.ChangeTurf(dancefloor_turfs_types[dancefloor])


/datum/action/cooldown/spell/infinity/honksong/proc/dance_setup(mob/living/user)
	var/turf/center = get_turf(user)
	FOR_DVIEW(var/turf/turf, 3, get_turf(user),INVISIBILITY_LIGHTING)
		if(turf.x == center.x && turf.y > center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_BLOOD_MAGIC
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1 + get_dist(user, light)
			spotlights += light
			continue
		if(turf.x == center.x && turf.y < center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_PURPLE
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1 + get_dist(user, light)
			spotlights += light
			continue
		if(turf.x > center.x && turf.y == center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_BRIGHT_YELLOW
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1 + get_dist(user, light)
			spotlights += light
			continue
		if(turf.x < center.x && turf.y == center.y)
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_GREEN
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1 + get_dist(user, light)
			spotlights += light
			continue
		if((turf.x+1 == center.x && turf.y+1 == center.y) || (turf.x+2==center.x && turf.y+2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_ORANGE
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1.4 + get_dist(user, light)
			spotlights += light
			continue
		if((turf.x-1 == center.x && turf.y-1 == center.y) || (turf.x-2==center.x && turf.y-2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_CYAN
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1.4 + get_dist(user, light)
			spotlights += light
			continue
		if((turf.x-1 == center.x && turf.y+1 == center.y) || (turf.x-2==center.x && turf.y+2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_BLUEGREEN
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1.4 + get_dist(user, light)
			spotlights += light
			continue
		if((turf.x+1 == center.x && turf.y-1 == center.y) || (turf.x+2==center.x && turf.y-2 == center.y))
			var/obj/item/flashlight/spotlight/light = new /obj/item/flashlight/spotlight(turf)
			light.light_color = LIGHT_COLOR_BLUE
			light.light_power = 30 - (get_dist(user, light) * 8)
			light.light_outer_range = 1.4 + get_dist(user, light)
			spotlights += light
			continue
		continue
	FOR_DVIEW_END

/datum/action/cooldown/spell/infinity/honksong/proc/setup_sparkles(mob/living/user)
	for(var/i in 1 to 25)
		if(QDELETED(src) || QDELETED(user) || !dancefloor_exists || user.loc != initial_loc)
			return
		var/obj/effect/overlay/sparkles/sparkle = new /obj/effect/overlay/sparkles(user)
		sparkle.alpha = 0
		sparkles += sparkle
		switch(i)
			if(1 to 8)
				sparkle.orbit(user, 30, TRUE, 60, 36, TRUE)
			if(9 to 16)
				sparkle.orbit(user, 62, TRUE, 60, 36, TRUE)
			if(17 to 24)
				sparkle.orbit(user, 95, TRUE, 60, 36, TRUE)
			if(25)
				sparkle.pixel_y = 7
				sparkle.forceMove(get_turf(user))
		sleep(7)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255

/datum/action/cooldown/spell/infinity/honksong/proc/lights_spin(mob/living/user)
	for(var/obj/item/flashlight/spotlight/glow in spotlights) //The multiples reflects custom adjustments to each colors after dozens of tests
		if(QDELETED(src) || QDELETED(user) || !dancefloor_exists || QDELETED(glow) || user.loc != initial_loc)
			return
		if(glow.light_color == LIGHT_COLOR_BLOOD_MAGIC)
			glow.light_color = LIGHT_COLOR_BLUE
			glow.light_power = glow.light_power * 1.48
			glow.light_outer_range = 0
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_BLUE)
			glow.light_color = LIGHT_COLOR_GREEN
			glow.light_outer_range = glow.light_outer_range * (rand(85, 115) * 0.01)
			glow.light_power = glow.light_power * 2 //Any changes to power must come in pairs to neutralize it for other colors
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_GREEN)
			glow.light_color = LIGHT_COLOR_ORANGE
			glow.light_power = glow.light_power * 0.5
			glow.light_outer_range = 0
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_ORANGE)
			glow.light_color = LIGHT_COLOR_PURPLE
			glow.light_power = glow.light_power * 2.27
			glow.light_outer_range = glow.light_outer_range * (rand(85, 115) * 0.01)
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_PURPLE)
			glow.light_color = LIGHT_COLOR_BLUEGREEN
			glow.light_power = glow.light_power * 0.44
			glow.light_outer_range = 0
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_BLUEGREEN)
			glow.light_color = LIGHT_COLOR_BRIGHT_YELLOW
			glow.light_outer_range = glow.light_outer_range * (rand(85, 115) * 0.01)
			glow.update_light()
		if(glow.light_color == LIGHT_COLOR_BRIGHT_YELLOW)
			glow.light_color = LIGHT_COLOR_CYAN
			glow.light_outer_range = 0
			glow.update_light()
			continue
		if(glow.light_color == LIGHT_COLOR_CYAN)
			glow.light_color = LIGHT_COLOR_BLOOD_MAGIC
			glow.light_power = glow.light_power * 0.68
			glow.light_outer_range = glow.light_outer_range * (rand(85, 115) * 0.01)
			glow.update_light()

/datum/action/cooldown/spell/infinity/cake
	name = "Clown Stone: Let There Be Cake!"
	desc = "Summon a powerful cake at your feet, capable of healing those who eat it, and injuring those who are hit by it. Only 2 cakes can exist at the same time."
	button_icon_state = "cake"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "clown"
	cooldown_time = 35 SECONDS
	var/list/cakes = list()

/datum/action/cooldown/spell/infinity/cake/proc/count_cakes()
	var/amount = 0
	for(var/obj/item/food/cake/birthday/infinity/cake in cakes)
		if(!QDELETED(cake) && cake && istype(cake))
			amount++
	return amount

/datum/action/cooldown/spell/infinity/cake/cast(atom/cast_on)
	. = ..()
	if(count_cakes() >= 2)
		to_chat(cast_on, span_danger("Only 2 cakes can exist at the same time!"))
		return
	cast_on.visible_message(span_notice("A cake appears at [cast_on]'s feet!"))
	cakes += new /obj/item/food/cake/birthday/infinity(get_turf(cast_on))

/obj/item/food/cake/birthday/infinity
	name = "infinity cake"
	throwforce = 35
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/sprinkles = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/medicine/omnizine = 40
	)
	tastes = list("cake" = 3, "power" = 2, "sweetness" = 1)

/obj/item/food/cake/birthday/infinity/make_processable()
	return

/obj/item/reagent_containers/food/snacks/store/cake/birthday/infinity/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		hit_living.fire_stacks += 3
		hit_living.ignite_mob()
		qdel(src)

/datum/action/cooldown/spell/infinity/thanoscar_thanoscar
	name = "Clown Stone: THANOS CAR"
	desc = "Summon the legendary THANOS CAR!"
	button_icon_state = "_thanoscar"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "clown"
	invocation_type = "shout"
	invocation = "THANOS CAR THANOS CAR"
	cooldown_time = 130 SECONDS

/datum/action/cooldown/spell/infinity/thanoscar_thanoscar/cast(atom/cast_on)
	. = ..()
	cast_on.visible_message(span_bolddanger("[cast_on] summons the THANOS CAR!"))
	var/obj/vehicle/sealed/car/thanos/thanos_car = new(get_turf(cast_on))
	thanos_car.mob_forced_enter(cast_on, TRUE)
	addtimer(CALLBACK(thanos_car, TYPE_PROC_REF(/obj/vehicle/sealed/car/thanos, ByeBye)), 15 SECONDS)


///////////////////////////////////////
//////// THANOS CAR THANOS CAR ////////
///////////////////////////////////////

/obj/vehicle/sealed/car/thanos
	name = "THANOS CAR"
	desc = "THANOS CAR THANOS CAR"
	icon = 'monkestation/icons/obj/infinity.dmi'
	icon_state = "thanoscar"
	color = "#6F3C89"
	max_integrity = 45
	max_occupants = 1
	key_type = null
	movedelay = 0.6
	var/bloodiness = 0

/obj/vehicle/sealed/car/thanos/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_BUMP, PROC_REF(vehicle_bump))
	RegisterSignal(src, COMSIG_MOVABLE_CROSS_OVER, PROC_REF(check_crossed))

/obj/vehicle/sealed/car/thanos/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_MOVABLE_BUMP)
	UnregisterSignal(src, COMSIG_MOVABLE_CROSS_OVER)

/obj/vehicle/sealed/car/thanos/proc/vehicle_bump(atom/movable/bumped)
	SIGNAL_HANDLER
	if(isliving(bumped))
		var/mob/living/bumped_living = bumped
		visible_message(span_danger("[src] rams into [bumped_living]!"))
		bumped_living.throw_at(get_edge_target_turf(src, get_dir(src, bumped_living)), 7, 5)
		bumped_living.take_bodypart_damage(10, check_armor = TRUE)

/obj/vehicle/sealed/car/thanos/proc/RunOver(mob/living/carbon/ran_over_human)
	log_combat(src, ran_over_human, "run over", null, "(DAMTYPE: [uppertext(BRUTE)])")
	ran_over_human.visible_message(
					span_danger("[src] drives over [ran_over_human]!"),
					span_userdanger("[src] drives over you!"))
	playsound(loc, 'sound/effects/splat.ogg', 50, 1)

	var/damage = rand(1,2)
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_HEAD, ran_over_human.run_armor_check(BODY_ZONE_HEAD, "melee"))
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_CHEST, ran_over_human.run_armor_check(BODY_ZONE_CHEST, "melee"))
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_LEG, ran_over_human.run_armor_check(BODY_ZONE_L_LEG, "melee"))
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_LEG, ran_over_human.run_armor_check(BODY_ZONE_R_LEG, "melee"))
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_L_ARM, ran_over_human.run_armor_check(BODY_ZONE_L_ARM, "melee"))
	ran_over_human.apply_damage(0.5 * damage, BRUTE, BODY_ZONE_R_ARM, ran_over_human.run_armor_check(BODY_ZONE_R_ARM, "melee"))

	var/turf/turf = get_turf(src)
	turf.add_mob_blood(ran_over_human)

	var/list/blood_dna = ran_over_human.get_blood_dna_list()
	add_blood_DNA(blood_dna)
	bloodiness += 4

/obj/vehicle/sealed/car/thanos/proc/ByeBye()
	for(var/mob/living/living_occupant in return_occupants())
		mob_exit(living_occupant, TRUE)
		living_occupant.throw_at(get_edge_target_turf(src, dir), 7, 5)
	visible_message(span_danger("[src] explodes!"))
	explosion(get_turf(src), 0, 0, 2, 3)
	qdel(src)

/obj/vehicle/sealed/car/thanos/proc/check_crossed(atom/movable/crossed)
	SIGNAL_HANDLER
	if(istype(crossed, /mob/living/carbon/human))
		RunOver(crossed)
