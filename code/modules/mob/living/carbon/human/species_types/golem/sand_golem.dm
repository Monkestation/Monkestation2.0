//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	id = SPECIES_GOLEM_SAND
	fixed_mut_color = "#ffdc8f"
	meat = /obj/item/stack/ore/glass //this is sand
	armor = 0
	burnmod = 3 //melts easily
	brutemod = 0.25
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/sand/spec_death(gibbed, mob/living/carbon/human/H)
	H.visible_message(span_danger("[H] turns into a pile of sand!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/*
/datum/species/golem/sand/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.armor_flag == BULLET || P.armor_flag == BOMB)
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, TRUE)
			H.visible_message(span_danger("The [P.name] sinks harmlessly in [H]'s sandy body!"), \
			span_userdanger("The [P.name] sinks harmlessly in [H]'s sandy body!"))
			return BULLET_ACT_BLOCK
	return ..()
*/
