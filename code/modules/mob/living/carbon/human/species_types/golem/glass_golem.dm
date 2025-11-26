//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	id = SPECIES_GOLEM_GLASS
	fixed_mut_color = "#5a96b4aa" //transparent body
	meat = /obj/item/shard
	armor = 0
	brutemod = 3 //very fragile
	burnmod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/glass/spec_death(gibbed, mob/living/carbon/human/H)
	playsound(H, SFX_SHATTER, 70, TRUE)
	H.visible_message(span_danger("[H] shatters!"))
	for(var/obj/item/W in H)
		H.dropItemToGround(W)
	for(var/i in 1 to rand(3,5))
		new /obj/item/shard(get_turf(H))
	qdel(H)

/*
/datum/species/golem/glass/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.armor_flag == LASER || P.armor_flag == ENERGY)
			H.visible_message(span_danger("The [P.name] gets reflected by [H]'s glass skin!"), \
			span_userdanger("The [P.name] gets reflected by [H]'s glass skin!"))
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				// redirect the projectile
				P.firer = H
				P.preparePixelProjectile(locate(clamp(new_x, 1, world.maxx), clamp(new_y, 1, world.maxy), H.z), H)
			return BULLET_ACT_FORCE_PIERCE
	return ..()
*/
