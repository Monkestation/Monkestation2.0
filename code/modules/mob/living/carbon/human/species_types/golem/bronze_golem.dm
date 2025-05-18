/datum/species/golem/bronze
	name = "Bronze Golem"
	id = SPECIES_GOLEM_BRONZE
	prefix = "Bronze"
	special_names = list("Bell")
	fixed_mut_color = "#cd7f32"
	info_text = "As a <span class='danger'>Bronze Golem</span>, you are very resistant to loud noises, and make loud noises if something hard hits you, however this ability does hurt your hearing."
	mutantears = /obj/item/organ/internal/ears/bronze
	examine_limb_id = SPECIES_GOLEM
	var/last_gong_time = 0
	var/gong_cooldown = 150

/*
/datum/species/golem/bronze/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(world.time > last_gong_time + gong_cooldown))
		return ..()
	if(P.armor_flag == BULLET || P.armor_flag == BOMB)
		gong(H)
		return ..()
*/

/datum/species/golem/bronze/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)

/datum/species/golem/bronze/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_gong_time + gong_cooldown && (M.istate & ISTATE_HARM))
		gong(H)

/datum/species/golem/bronze/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/H)
	..()
	if(world.time > last_gong_time + gong_cooldown)
		gong(H)


/datum/species/golem/bronze/proc/gong(mob/living/carbon/human/H)
	last_gong_time = world.time
	for(var/mob/living/M in get_hearers_in_view(7,H))
		if(M.stat == DEAD) //F
			continue
		if(M == H)
			H.show_message(span_narsiesmall("You cringe with pain as your body rings around you!"), MSG_AUDIBLE)
			H.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
			H.soundbang_act(2, 0, 100, 1)
			H.adjust_jitter(14 SECONDS)
		var/distance = max(0,get_dist(get_turf(H),get_turf(M)))
		switch(distance)
			if(0 to 1)
				M.show_message(span_narsiesmall("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 100, TRUE)
				M.soundbang_act(1, 0, 30, 3)
				M.adjust_confusion(10 SECONDS)
				M.adjust_jitter(8 SECONDS)
				M.add_mood_event("gonged", /datum/mood_event/loud_gong)
			if(2 to 3)
				M.show_message(span_cult("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 75, TRUE)
				M.soundbang_act(1, 0, 15, 2)
				M.adjust_jitter(6 SECONDS)
				M.add_mood_event("gonged", /datum/mood_event/loud_gong)
			else
				M.show_message(span_warning("GONG!"), MSG_AUDIBLE)
				M.playsound_local(H, 'sound/effects/gong.ogg', 50, TRUE)
