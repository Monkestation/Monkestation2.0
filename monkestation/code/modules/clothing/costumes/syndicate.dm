/obj/item/clothing/head/hats/tophat/syndicate
	name = "top-hat of EVIL"
	desc = "It's an EVIL looking hat."
	icon_state = "evil_tophat"
	icon = 'monkestation/icons/mob/clothing/costumes/syndicate/evil_clothing_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/syndicate/evil_clothing_worn.dmi'
	inhand_icon_state = "that"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | PLASMAMAN_PREVENT_IGNITION
	dog_fashion = null
	worn_y_offset = 5
	throw_range = 0
	var/id = "syndicate_tophat"
	var/primed = FALSE
	armor_type = /datum/armor/helmet_swat
	strip_delay = 120
	bee_chance = 100

/obj/item/clothing/head/hats/tophat/syndicate/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	to_chat(user, span_warning("An ominous voice rings out from within your mind..."))
	user.SetSleeping(8 SECONDS)
	speak(user)
	user.remove_filter(id)
	user.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_NO_PAIN_EFFECTS, TRAIT_FEARLESS), id)
	user.add_filter(id, 2, drop_shadow_filter(x = 0, y = 0, size = 0.5, offset = 1, color = "#ff0000"))
	primed = TRUE
	to_chat(user,  span_boldwarning("You hear a faint click inside the hat... you get the feeling you shouldn't take it off."))
	message_admins("A top-hat of EVIL has been worn by [user.mind].")
	log_admin("A top-hat of EVIL has been worn by [key_name(user)]")
	notify_ghosts(
		"[user.name] has donned a hat of EVIL!",
		source = user,
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "TIME FOR CRIME!",
	)

/obj/item/clothing/head/hats/tophat/syndicate/proc/speak(mob/living/carbon/human/user)
	sleep(2 SECOND)
	to_chat(user,  span_boldwarning("Time!"))
	user.playsound_local(get_turf(user), 'monkestation/sound/voice/robotic/time.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECOND)
	to_chat(user,  span_boldwarning("For!"))
	user.playsound_local(get_turf(user), 'monkestation/sound/voice/robotic/for.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECOND)
	to_chat(user,  span_boldwarning("CRIME!!"))
	user.playsound_local(get_turf(user), 'monkestation/sound/voice/robotic/crime.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECOND)

/obj/item/clothing/head/hats/tophat/syndicate/MouseDrop(atom/over_object)
	if(primed)
		to_chat(usr, span_userdanger("You hesitate remembering the faint click you heard..."))
		return
	return ..()


/obj/item/clothing/head/hats/tophat/syndicate/attack_hand(mob/user, list/modifiers)
	if(primed)
		to_chat(user, span_userdanger("You hesitate remembering the faint click you heard..."))
		return
	return ..()

/obj/item/clothing/head/hats/tophat/syndicate/dropped(mob/living/carbon/human/user)
	. = ..()
	if(primed)
		user.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_NO_PAIN_EFFECTS, TRAIT_FEARLESS), id)
		addtimer(CALLBACK(src, PROC_REF(explode), user), 0.5 SECOND)

/obj/item/clothing/head/hats/tophat/syndicate/proc/explode(mob/living/carbon/human/user)
	user.remove_filter(id)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	user.visible_message("A bright flash eminates from under [user]'s hat!")
	user.gib()
	log_game("[user] has been gibbed by the removal of their [src]")
	explosion(src, devastation_range = 0, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2, flash_range = 7)
	qdel(src)

/obj/item/clothing/neck/cloak/syndicate
	name = "cloak of EVIL"
	desc = "It's an EVIL looking cloak."
	icon_state = "syndiecloak"
	icon = 'monkestation/icons/mob/clothing/costumes/syndicate/evil_clothing_obj.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/costumes/syndicate/evil_clothing_worn.dmi'
	armor_type = /datum/armor/armor_swat
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/has_been_worn = FALSE

/obj/item/clothing/neck/cloak/syndicate/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_NECK))
		return
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	to_chat(user, span_notice("You feel it's time for a good bloodbath."))
	message_admins("A cloak of EVIL has been worn by [user.mind].")
	log_admin("A cloak of EVIL has been worn by [key_name(user)]")
	notify_ghosts(
		"[user.name] has donned a cloak of EVIL!",
		source = user,
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "TIME FOR MURDER!",
	)
	has_been_worn = TRUE

/obj/item/clothing/neck/cloak/syndicate/Initialize(mapload)
	. = ..()
	message_admins("A cloak of EVIL has been created. Someone might murderbone!")
	SSpoints_of_interest.make_point_of_interest(src)

/obj/item/clothing/neck/cloak/syndicate/dropped(mob/living/carbon/human/user)
	if(has_been_worn)
		do_sparks()
		user.visible_message("The cloak vanishes into thin air!")
		qdel(src)
		return
	return ..()

/obj/item/storage/briefcase/evilbundle
	desc = "It has a small golden engraving reading \"Syndicate\", but suspiciously has no other tags or branding. Smells like rusted metal."
	force = 10

/obj/item/storage/briefcase/evilbundle/PopulateContents()
	..()
	new /obj/item/clothing/head/hats/tophat/syndicate(src)
	new /obj/item/clothing/neck/cloak/syndicate(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/mask/fakemoustache(src)
