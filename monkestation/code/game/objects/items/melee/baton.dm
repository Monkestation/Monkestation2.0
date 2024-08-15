/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(isganymede(user))
		user.visible_message("<span class='danger'>[user] accidentally crushes [src] in their hand!</span>")
		qdel(src)
		return
	return ..()
