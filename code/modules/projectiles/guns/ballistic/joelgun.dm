/obj/item/gun/ballistic/revolver/joel
	load_sound = 'sound/items/lisa/gunload.ogg'
	eject_sound = 'sound/items/lisa/empty.ogg'
	icon_state = "joelgun"
	name = "\improper Bolt Action pistol"
	desc = "The most powerful handgun in Olathe. It's best not to waste the only bullet. Examine again for more information."
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/c22
	custom_premium_price = PAYCHECK_CREW * 2.5
	///Cooldown between ability uses
	var/used_ability = FALSE

/obj/item/gun/ballistic/revolver/joel/examine_more(mob/user)
	. = ..()
	. += list(span_warning("<i>You examine [src]'s instructions;</i>"))
	. += list(
		span_warning("Activate [src] in hand to use Gun Toss (If wearing Holster: Gun Flip),\n\
		AltClick [src] to use Mind Games (If wearing Holster: Holster reveal),\n\
		Attempt to fire [src] anywhere to use Misdirection,\n\
		Right Click a target to use Steady Aim.\n\
		After each ability used, you will enter a cooldown before you can use the next ability.\n\
		Loading a bullet into the chamber will immediately allow you to use a new ability."),
	)

/obj/item/gun/ballistic/revolver/joel/proc/clear_cooldown()
	used_ability = FALSE

/obj/item/gun/ballistic/revolver/joel/proc/velvet_check(mob/living/target)
	if(target.mind && istype(target.mind.martial_art, /datum/martial_art/velvetfu))
		return TRUE
	return FALSE

/obj/item/gun/ballistic/revolver/joel/attackby(obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/ammo_casing/c22))
		return
	if(get_ammo(countchambered = TRUE) >= 1)
		to_chat(user, span_warning("[src] already has a bullet loaded!"))
		return
	// Load It In
	user.visible_message(
		span_danger("[user.name] puts the bullet in [src]!"),
		span_userdanger("You put the bullet in [src]!"),
		span_hear("You hear metal clanking..."),
		COMBAT_MESSAGE_RANGE,
	)
	. = ..()
	clear_cooldown()
	attacking_item.update_appearance()

/obj/item/gun/ballistic/revolver/joel/attack_self(mob/living/carbon/user)
	if(used_ability)
		to_chat(user, span_warning("You have to wait before using an ability!"))
		return
	. = ..()
	// If you have a holster, you'll spin it instead, you're experienced.
	if(HAS_TRAIT(user, TRAIT_GUNFLIP))
		user.visible_message(
			span_danger("[user.name] spins [src] around like mad!"),
			span_userdanger("You spin [src] around!"),
			span_hear("You hear metal clanking..."),
			COMBAT_MESSAGE_RANGE,
		)
		playsound(src, 'sound/items/lisa/gunreveal.ogg', 20, FALSE, -5)

	// Otherwise, we'll perform Gun Toss.
	else
		user.visible_message(
			span_danger("[user.name] throws [src] around!"),
			span_userdanger("You toss [src] around!"),
			span_hear("You hear metal clanking..."),
			COMBAT_MESSAGE_RANGE,
		)
		playsound(src, 'sound/items/lisa/guntoss.ogg', 50, FALSE, -5)
		user.drop_all_held_items()

	SpinAnimation(4,2)
	user.stamina.adjust(20)
	used_ability = TRUE
	for(var/mob/living/victims in viewers(7, user))
		victims.face_atom(user)
		victims.do_alert_animation()
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown)), 6 SECONDS)

/obj/item/gun/ballistic/revolver/joel/click_alt(mob/user)
	if(used_ability)
		to_chat(user, span_warning("You have to wait before using an ability!"))
		return
	// Gun reveal (If you have a holster)
	if(HAS_TRAIT(user, TRAIT_GUNFLIP))
		user.visible_message(
			span_danger("[user.name] opens their holster and pulls out [src]!"),
			span_userdanger("You reveal [src] from your holster!"),
			span_hear("You hear metal clanking..."),
			COMBAT_MESSAGE_RANGE,
		)
		for(var/mob/living/carbon/human/victims in viewers(7, user))
			if(prob(15) && !(victims == user) && !(victims.stat) && !velvet_check(victims))
				to_chat(victims, span_warning("Seeing [src] revealed in such a manner disgusts you!"))
				victims.vomit(
					lost_nutrition = 0,
					blood = FALSE,
					stun = TRUE,
					distance = 3,
					message = TRUE,
				)
		playsound(src, 'sound/items/lisa/gunreveal.ogg', 20, FALSE, -5)

	// No holster? Use mind games instead
	else
		user.visible_message(
			span_danger("[user.name] stares deeply around [user.p_them()]selves!"),
			span_userdanger("You stare directly into the souls of those around you."),
			span_hear("You hear metal clanking..."),
			COMBAT_MESSAGE_RANGE,
		)
		for(var/mob/living/victims in viewers(1, user))
			if(prob(75) && !(victims == user) && victims.stat <= CONSCIOUS && !velvet_check(victims))
				to_chat(victims, span_warning("You feel terrifyingly spooked by [user.name]!"))
				var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(victims, user)))
				victims.throw_at(throwtarget, 3, 2)

	used_ability = TRUE
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown)), 10 SECONDS)

/obj/item/gun/ballistic/revolver/joel/interact_with_atom_secondary(mob/living/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(used_ability)
		to_chat(user, span_warning("You have to wait before using an ability!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(user == interacting_with)
		to_chat(user,span_warning("You can't steady aim yourself!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	// Steady Aim
	user.visible_message(
		span_danger("[user.name] holds [interacting_with.name] at gunpoint!"),
		span_userdanger("You hold [interacting_with.name] up at gunpoint!"),
		span_hear("You hear metal clanking..."),
		COMBAT_MESSAGE_RANGE,
	)
	playsound(loc, 'sound/items/lisa/steadyaim.ogg', 50, FALSE, -5)
	if(prob(50) && !velvet_check(interacting_with))
		interacting_with.Stun(rand(10, 20))
	used_ability = TRUE
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown)), 8 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/ballistic/revolver/joel/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/gun/ballistic/revolver/joel/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// Can pull the trigger if it's empty since we don't care
	if(!chambered)
		user.visible_message(span_danger("*click*"))
		playsound(loc, 'sound/items/lisa/gunclick.ogg', 50, FALSE, -5)
		return ITEM_INTERACT_BLOCKING
	// Prevents the gun from being fired.
	if(used_ability)
		to_chat(user, span_warning("You don't want to waste [src]'s only bullet!"))
		return ITEM_INTERACT_BLOCKING
	if(!interacting_with)
		return ITEM_INTERACT_BLOCKING
	// Misdirection
	user.visible_message(
		span_danger("[user.name] looks around themselves."),
		span_userdanger("You look for something to point [src] at."),
	)
	playsound(loc, 'sound/items/lisa/misdirect.ogg', 50, FALSE, -5)
	used_ability = TRUE
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown)), 7 SECONDS)

	if(!do_after(user, 0.4 SECONDS, target = src, progress = FALSE))
		return ITEM_INTERACT_BLOCKING

	user.setDir(turn(user.dir, 90))
	if(!do_after(user, 0.3 SECONDS, target = src, progress = FALSE))
		return ITEM_INTERACT_BLOCKING

	user.setDir(turn(user.dir, -90))
	if(!do_after(user, 0.3 SECONDS, target = src, progress = FALSE))
		return ITEM_INTERACT_BLOCKING

	user.setDir(turn(user.dir, 90))
	if(!do_after(user, 0.3 SECONDS, target = src, progress = FALSE))
		return ITEM_INTERACT_BLOCKING

	user.setDir(turn(user.dir, -90))
	if(!do_after(user, 0.3 SECONDS, target = src, progress = FALSE))
		return ITEM_INTERACT_BLOCKING

	user.emote("gasp")
	user.visible_message(
		span_danger("[user.name] quickly points their gun towards [interacting_with]!"),
		span_userdanger("You misdirect [src] towards [interacting_with]!"),
		span_hear("You hear a gasp..."),
	)
	// Everyone directly next to it will move
	for(var/mob/living/main_victims in view(1, interacting_with))
		if(!(main_victims == user) && main_victims.stat <= CONSCIOUS && !velvet_check(main_victims))
			main_victims.visible_message(
				span_danger("[main_victims] quickly jumps towards [interacting_with]!"),
				span_userdanger("You quickly jump towards [interacting_with]!"),
				span_hear("You hear aggressive shuffling!"),
				COMBAT_MESSAGE_RANGE,
			)
			step_towards(main_victims, interacting_with)
			main_victims.Knockdown(1 SECONDS)
	// Everyone else will just notice it
	for(var/mob/living/extra_victims in viewers(5, interacting_with))
		extra_victims.face_atom(interacting_with)
		extra_victims.do_alert_animation()
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/ballistic/revolver/joel/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	add_fingerprint(user)
	to_chat(user, span_warning("You don't want to waste [src]'s only bullet!"))
	return


/**
 *	# Cylinder, bullet & casing.
 *
 *	We're using unique ones so people cant get more bullets for anything.
 *	Unique gun, unique single bullet. You lose it, it's gone.
 *	Outside of well, buying an entirely new gun with a SecTech refill vendor, but they can't do much with 2 bullets anyways.
 */

/// Cylinder
/obj/item/ammo_box/magazine/internal/cylinder/c22
	name = "\improper Bolt Action revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c22
	caliber = CALIBER_C22
	max_ammo = 1
	multiload = FALSE

/// Bullet casing & Bullet
/obj/item/ammo_casing/c22
	name = "5.6mm bullet casing"
	desc = "An incredibly rare type of bullet."
	caliber = CALIBER_C22
	projectile_type = /obj/projectile/bullet/c22
	can_be_printed = FALSE

/obj/projectile/bullet/c22
	name = "5.6mm bullet"
	// This isnt meant to be fired, so do 0 damage.
	damage = 0
