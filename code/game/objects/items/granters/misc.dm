/obj/item/book/granter/perfect_surgeon
	name = "The Methods of Liston Applied with Modern Medicine"
	desc = "A comprehensive guide to learning how to be quick with your surgeries."
	icon_state = "book1"
	remarks = list(
		"Speed is everything, you must be quick...",
		"First secure the patient...",
		"Midline, periumbilical, pararectus...",
		"Cut the skin and lift it from the fat...",
		"The bleeders should be clamped as tight as possible...",
		"300% mortality rate?",
		"Time me!",
	)

/obj/item/book/granter/perfect_surgeon/can_learn(mob/living/user)
	if (!iscarbon(user))
		return
	if(HAS_TRAIT(user, TRAIT_PERFECT_SURGEON))
		to_chat(user, span_warning("You get too bored and stop reading."))
		return
	return TRUE

/obj/item/book/granter/perfect_surgeon/recoil(mob/living/user)
	to_chat(user, span_warning("You can't read it, the pages are too faded and smudged!"))

/// Called when the reading is completely finished. This is where the actual granting should happen.
/obj/item/book/granter/perfect_surgeon/on_reading_finished(mob/living/user)
	..()
	ADD_TRAIT(user, TRAIT_PERFECT_SURGEON, TRAIT_GENERIC)

/obj/item/book/granter/gun_mastery
	name = "How to be a Badass with Guns"
	desc = "A comprehensive guide to dual wielding guns."
	icon_state = "stealthmanual"
	remarks = list(
		"Proper grip for not breaking your wrists...",
		"A good stance is key...",
		"Sunglasses optional?",
		"Go ahead, make my day.",
	)

/obj/item/book/granter/gun_mastery/can_learn(mob/living/user)
	if (!iscarbon(user))
		return
	if(HAS_TRAIT(user, TRAIT_AKIMBO))
		to_chat(user, span_warning("You already know this skill!"))
		return
	return TRUE

/obj/item/book/granter/gun_mastery/recoil(mob/living/user)
	to_chat(user, span_warning("You can't read it, the pages are too faded and smudged!"))

/// Called when the reading is completely finished. This is where the actual granting should happen.
/obj/item/book/granter/gun_mastery/on_reading_finished(mob/living/user)
	..()
	ADD_TRAIT(user,  TRAIT_AKIMBO, TRAIT_GENERIC)
