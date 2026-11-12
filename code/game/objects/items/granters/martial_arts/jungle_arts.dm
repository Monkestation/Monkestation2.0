/// Uplink scroll that teaches simians a combat mode only version of Jungle Arts.
/obj/item/book/granter/martial/jungle_arts
	martial = /datum/martial_art/jungle_arts/trained
	name = "banana-stained scroll"
	martial_name = "jungle arts"
	desc = "A scroll covered in crude drawings of monkeys biting people. It smells faintly of bananas."
	greet = span_sciradio("You have learned the primal ways of Jungle Arts! While in combat mode, your attacks, shoves and grabs \
		become vicious bites and tail strikes. Turn combat mode off to grab and shove like normal.")
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	worn_icon_state = "scroll"
	remarks = list(
		"Bite first, ask questions never...",
		"A good tail is worth two hands...",
		"Drag them down, then chew...",
		"Ook ook eek...",
		"These pictures are very educational...",
	)

/obj/item/book/granter/martial/jungle_arts/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/jungle_arts/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

/obj/item/book/granter/martial/jungle_arts/can_learn(mob/user)
	if(!issimianspecies(user))
		to_chat(user, span_warning("You try to read the scroll but it's just a bunch of monkey doodles."))
		return FALSE
	return ..()
