/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge! Ctrl-click to toggle waddle dampeners."
	name = "clown shoes"
	icon_state = "clown"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	var/enabled_waddle = TRUE
	///List of possible sounds for the squeak component to use, allows for different clown shoe subtypes to have different sounds.
	var/list/squeak_sound = list('sound/effects/footstep/clownstep1.ogg'=1,'sound/effects/footstep/clownstep2.ogg'=1)
	lace_time = 20 SECONDS // how the hell do these laces even work??
	species_exception = list(/datum/species/golem/bananium)
	var/has_storage = TRUE

/obj/item/clothing/shoes/clown_shoes/Initialize(mapload)
	. = ..()

	if(has_storage)
		create_storage(storage_type = /datum/storage/pockets/shoes/clown)
	LoadComponent(/datum/component/squeak, squeak_sound, 50, falloff_exponent = 20) //die off quick please
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		if(enabled_waddle)
			user.AddElement(/datum/element/waddling)
		if(is_clown_job(user.mind?.assigned_role))
			user.add_mood_event("clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/living/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
	if(is_clown_job(user.mind?.assigned_role))
		user.clear_mood_event("clownshoes")

/obj/item/clothing/shoes/clown_shoes/item_ctrl_click(mob/user)
	if(!isliving(user))
		return CLICK_ACTION_BLOCKING
	if(user.get_active_held_item() != src)
		to_chat(user, span_warning("You must hold the [src] in your hand to do this!"))
		return CLICK_ACTION_BLOCKING
	if (!enabled_waddle)
		to_chat(user, span_notice("You switch off the waddle dampeners!"))
		enabled_waddle = TRUE
	else
		to_chat(user, span_notice("You switch on the waddle dampeners!"))
		enabled_waddle = FALSE
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jester's shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/clown_shoes/meown_shoes
	name = "meown shoes"
	desc = "The adorable sound they make when you walk will mean making friends is more likely."
	icon_state = "meown_shoes"
	squeak_sound = list('sound/effects/footstep/meowstep1.ogg'=1) //mew mew mew mew

/obj/item/clothing/shoes/clown_shoes/ducky_shoes
	name = "ducky shoes"
	desc = "I got boots, that go *quack quack quack quack quack."
	icon_state = "ducky_shoes"
	inhand_icon_state = "ducky_shoes"
	squeak_sound = list('sound/effects/quack.ogg'=1) //quack quack quack quack

/obj/item/clothing/shoes/clown_shoes/cluwne
	name = "cluwne shoes"
	desc = "A sense of bloodlust washes over you as you wear these shoes. Ctrl-click to toggle waddle dampeners. Alt-click to toggle sound dampeners."
	icon_state = "cluwne"
	inhand_icon_state = "cluwne_shoes"
	worn_icon_state = "cluwne"
	slowdown = SHOES_SLOWDOWN
	var/sound_dampener = TRUE

/obj/item/clothing/shoes/clown_shoes/cluwne/click_alt(mob/living/user)
	if(!isliving(user))
		return CLICK_ACTION_BLOCKING
	if(user.get_active_held_item() != src)
		to_chat(user, span_warning("You must hold the [src] in your hand to do this!"))
		return CLICK_ACTION_BLOCKING

	sound_dampener = !sound_dampener
	if(sound_dampener)
		to_chat(user, span_notice("You switch on the sound dampener. Your footsteps fall silent."))
	else
		to_chat(user, span_notice("You switch off the sound dampener. The shoes are ready to squeak again."))
	return CLICK_ACTION_SUCCESS
