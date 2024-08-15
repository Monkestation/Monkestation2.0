/obj/structure/mirror/magic/attack_hand(mob/user)
	if(locate(/obj/item/badmin_gauntlet) in user)
		to_chat(user, span_notice("The badmin gauntlet interferes with the magic mirror. It won't work."))
		return
	return ..()
