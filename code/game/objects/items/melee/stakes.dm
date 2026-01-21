/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/vampires/stakes.dmi'
	icon_state = "wood"
	inhand_icon_state = "wood"
	lefthand_file = 'icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'icons/vampires/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_POCKETS
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("staked", "stabbed", "tore into")
	attack_verb_simple = list("staked", "stabbed", "tore into")
	sharpness = SHARP_POINTY
	force = 6
	throwforce = 10
	max_integrity = 30
	embedding = list(
		"embed_chance" = 100,
		"fall_chance" = 0,
		"rip_time" = 2.5 SECONDS, // this is actually 5 seconds because it gets multiplied by the w_class
	)

	///Time it takes to embed the stake into someone's chest.
	var/staketime = 4 SECONDS

/obj/item/stake/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(.)
		return

	if(DOING_INTERACTION_WITH_TARGET(user, target))
		return
	// Cannot target yourself, must be in combat mode and targeting the chest
	if(target == user)
		return
	if(!(user.istate & ISTATE_HARM))
		return
	if(check_zone(user.zone_selected) != BODY_ZONE_CHEST)
		return

	if(HAS_TRAIT(target, TRAIT_BEINGSTAKED))
		to_chat(user, span_notice("[target] is already having a stake driven into [target.p_their()] chest!"))
		return

	// lol, cry about it
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_notice("[target]'s chest is too thick! [src] won't go in!"))
		return

	// Cannot have something in your chest
	var/obj/item/bodypart/chest = target.get_bodypart(BODY_ZONE_CHEST)
	if(!chest)
		return
	for(var/obj/item/embedded_object in chest.embedded_objects)
		to_chat(user, span_boldannounce("[target]'s chest already has [embedded_object] inside of it!"))
		return

	playsound(target, 'sound/magic/Demon_consume.ogg', vol = 50, vary = TRUE)
	to_chat(target, span_userdanger("[user] is driving a stake into your chest!"))
	to_chat(user, span_notice("You put all your weight into embedding [src] into [target]'s chest..."))

	ADD_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
	if(!do_after(user, staketime, target))
		REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)
		return

	REMOVE_TRAIT(target, TRAIT_BEINGSTAKED, TRAIT_VAMPIRE)

	// Actually embed the stake and apply damage
	if(!tryEmbed(target.get_bodypart(BODY_ZONE_CHEST), TRUE, TRUE))
		return

	target.apply_damage(force * 2, BRUTE, BODY_ZONE_CHEST)

	playsound(target, 'sound/effects/splat.ogg', vol = 40, vary = TRUE)
	user.visible_message(
		span_danger("[user] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)

	if(IS_VAMPIRE(target))
		to_chat(target, span_userdanger("You have been staked! Your powers are useless while it's in your chest!"))
		target.balloon_alert(target, "you have been staked!")

/obj/item/stake/examine(mob/user)
	. = ..()
	. += span_notice("To stake someone: Target the chest, activate combat mode, and hit them.")
	. += span_notice("* Hunter Tip: Remember that they can just pull it out if they are awake. Cuff them or kill them. A stake will stop them from reviving, not from regenerating. It will also stop all of their abilities.")

///Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/obj/item/stake/proc/can_be_staked(mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	if(!(target.mobility_flags & MOBILITY_MOVE))
		return TRUE
	return FALSE

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A wooden stake carved to a sharp point and hardened by fire."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	staketime = 3 SECONDS

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	inhand_icon_state = "silver"
	siemens_coefficient = 1
	force = 9
	armour_penetration = 25
	staketime = 2 SECONDS
