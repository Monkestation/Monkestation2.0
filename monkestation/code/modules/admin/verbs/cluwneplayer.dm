/mob/living/carbon/human/proc/cluwne()
	for(var/obj/item/item in src)
		if(!dropItemToGround(item))
			qdel(item)
			regenerate_icons()

	var/datum/mind/cluwned_mind = mind

	var/mob/living/simple_animal/cluwne/new_cluwne =  new(get_turf(src))

	cluwned_mind.transfer_to(new_cluwne)
	if(key)
		new_cluwne.key = key

	var/msg = "\n\n\n\n\nYour mind is ripped apart like threads in fabric, everything you've ever known is gone.\n"
	msg += "There is only the <b><i>Honkmother</i></b> now.\n"
	msg += "Honk!\n"
	to_chat(cluwned_mind, msg)

	qdel(src)
