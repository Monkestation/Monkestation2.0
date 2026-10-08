#define RABBIT_CD_TIME (30 SECONDS)

/obj/item/clothing/head/hats/tophat
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	inhand_icon_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1
	/// Cooldown for how often we can pull rabbits out of here
	COOLDOWN_DECLARE(rabbit_cooldown)
	var/bee_chance = 10 //monkestation addition

/obj/item/clothing/head/hats/tophat/attackby(obj/item/hitby_item, mob/user, params)
	. = ..()
	if(istype(hitby_item, /obj/item/gun/magic/wand))
		abracadabra(hitby_item, user)

/obj/item/clothing/head/hats/tophat/proc/abracadabra(obj/item/hitby_wand, mob/magician)
	if(!COOLDOWN_FINISHED(src, rabbit_cooldown))
		to_chat(magician, span_warning("You can't find another rabbit in [src]! Seems another hasn't gotten lost in there yet..."))
		return

	COOLDOWN_START(src, rabbit_cooldown, RABBIT_CD_TIME)
	playsound(get_turf(src), 'sound/weapons/emitter.ogg', 70)
	do_smoke(amount = DIAMOND_AREA(1), holder = src, location = src, smoke_type=/obj/effect/particle_effect/fluid/smoke/quick)

	if(prob(bee_chance)) //monkestation edit
		magician.visible_message(span_danger("[magician] taps [src] with [hitby_wand], then reaches in and pulls out a bu- wait, those are bees!"), span_danger("You tap [src] with your [hitby_wand.name] and pull out... <b>BEES!</b>"))
		var/wait_how_many_bees_did_that_guy_pull_out_of_his_hat = rand(4, 8)
		for(var/b in 1 to wait_how_many_bees_did_that_guy_pull_out_of_his_hat)
			var/mob/living/basic/bee/barry = new(get_turf(magician))
			if(prob(20))
				barry.say(pick("BUZZ BUZZ", "PULLING A RABBIT OUT OF A HAT IS A TIRED TROPE", "I DIDN'T ASK TO BEE HERE"), forced = "bee hat")
	else
		magician.visible_message(span_notice("[magician] taps [src] with [hitby_wand], then reaches in and pulls out a bunny! Cute!"), span_notice("You tap [src] with your [hitby_wand.name] and pull out a cute bunny!"))
		var/mob/living/basic/rabbit/bunbun = new(get_turf(magician))
		bunbun.mob_try_pickup(magician, instant=TRUE)

/obj/item/clothing/head/hats/tophat/balloon
	name = "balloon top-hat"
	desc = "It's a colourful looking top-hat to match your colourful personality."
	icon_state = "balloon_tophat"
	inhand_icon_state = "balloon_that"
	throwforce = 0
	resistance_flags = FIRE_PROOF
	dog_fashion = null

/obj/item/clothing/head/hats/tophat/syndicate
	name = "top-hat of EVIL"
	desc = "It's an EVIL looking hat."
	icon_state = "evil_tophat"
	icon = 'icons/mob/clothing/costumes/syndicate/evil_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/costumes/syndicate/evil_clothing_worn.dmi'
	inhand_icon_state = "that"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | PLASMAMAN_PREVENT_IGNITION
	dog_fashion = null
	worn_y_offset = 5
	throw_range = 0
	armor_type = /datum/armor/helmet_swat
	strip_delay = 120
	bee_chance = 100
	var/id = "syndicate_tophat"
	var/primed = FALSE

/obj/item/clothing/head/hats/tophat/syndicate/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	to_chat(user, span_warning("An ominous voice rings out from within your mind..."))
	user.SetSleeping(8 SECONDS)
	speak(user)
	user.remove_filter(id)
	user.add_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_FEARLESS), id)
	user.add_filter(id, 2, drop_shadow_filter(x = 0, y = 0, size = 0.5, offset = 1, color = "#ff0000"))
	primed = TRUE
	to_chat(user, span_boldwarning("You hear a faint click inside the hat... you get the feeling you shouldn't take it off."))
	message_admins("A top-hat of EVIL has been worn by [ADMIN_LOOKUPFLW(user)].")
	log_admin("A top-hat of EVIL has been worn by [key_name(user)]")
	notify_ghosts(
		"[user.real_name] has donned a hat of EVIL!",
		source = user,
		action = NOTIFY_ORBIT,
		notify_flags = NOTIFY_CATEGORY_NOFLASH,
		header = "TIME FOR CRIME!",
	)

/obj/item/clothing/head/hats/tophat/syndicate/proc/speak(mob/living/carbon/human/user)
	sleep(2 SECONDS)
	to_chat(user,  span_boldwarning("Time!"))
	user.playsound_local(get_turf(user), 'sound/voice/robotic/time.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECONDS)
	to_chat(user,  span_boldwarning("For!"))
	user.playsound_local(get_turf(user), 'sound/voice/robotic/for.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECONDS)
	to_chat(user,  span_boldwarning("CRIME!!"))
	user.playsound_local(get_turf(user), 'sound/voice/robotic/crime.ogg',100,0, use_reverb = TRUE)
	sleep(2 SECONDS)

/obj/item/clothing/head/hats/tophat/syndicate/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	if(primed)
		to_chat(user, span_userdanger("You hesitate remembering the faint click you heard..."))
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
		user.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_RESISTLOWPRESSURE, TRAIT_FEARLESS), id)
		addtimer(CALLBACK(src, PROC_REF(explode), user), 0.5 SECONDS)

/obj/item/clothing/head/hats/tophat/syndicate/proc/explode(mob/living/carbon/human/user)
	user.remove_filter(id)
	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	user.visible_message(span_userdanger("A bright flash eminates from under [user]'s hat!"))
	log_game("[key_name(user)] has been gibbed by the removal of their [src]")
	user.gib()
	explosion(src, devastation_range = 0, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2, flash_range = 7)
	qdel(src)

#undef RABBIT_CD_TIME
