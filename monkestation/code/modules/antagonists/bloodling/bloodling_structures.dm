/obj/structure/bloodling
	name = "Abstract bloodling structure"
	max_integrity = 100
	icon = 'monkestation/code/modules/antagonists/bloodling/sprites/bloodling_sprites.dmi'

/obj/structure/bloodling/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.5
			if(BURN)
				damage_amount *= 3
	return ..()

/obj/structure/bloodling/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/bloodling/rat_warren
	name = "Rat warren"
	desc = "A pool of biomass and primordial soup, you hear a faint chittering from it."
	max_integrity = 100
	icon_state = "ratwarren"
	anchored = TRUE
	///the minimum time it takes for a rat to spawn
	var/minimum_rattime = 1 MINUTES
	///the maximum time it takes for a rat to spawn
	var/maximum_rattime = 2 MINUTES
	//the cooldown between each rat
	COOLDOWN_DECLARE(rattime)

/obj/structure/bloodling/rat_warren/Initialize(mapload)
	. = ..()

	//start the cooldown
	COOLDOWN_START(src, rattime, rand(minimum_rattime, maximum_rattime))

	//start processing
	START_PROCESSING(SSobj, src)

/obj/structure/bloodling/rat_warren/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bloodling/rat_warren/process()
	//we need to have a cooldown, so check and then add
	if(!COOLDOWN_FINISHED(src, rattime))
		return
	COOLDOWN_START(src, rattime, rand(minimum_rattime, maximum_rattime))

	var/turf/our_turf = src.loc
	new /mob/living/basic/mouse(our_turf)
	our_turf.add_liquid_list(list(/datum/reagent/toxin/mutagen = 15), TRUE)
