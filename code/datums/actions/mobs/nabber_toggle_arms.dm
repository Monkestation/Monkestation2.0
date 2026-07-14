/datum/action/cooldown/toggle_arms
	name = "Toggle mantis arms"
	desc = "Pump your Haemolyph from the rest of your body into your hunting arms, allowing you to stab at foes. This will take time to do, and can be interrupted."
	cooldown_time = 3 SECONDS

	button_icon = 'icons/mob/actions/actions_nabber.dmi'
	var/blade_type = NABBER_ARM_TYPE_REGULAR //Need to hold this here.
	var/held_desc // Manages any custom blade messages on examine

/datum/action/cooldown/toggle_arms/Destroy()
	blade_type = null
	held_desc = null
	return ..()

/datum/action/cooldown/toggle_arms/New(Target, original)
	. = ..()
	button_icon_state = "arms_off"

/datum/action/cooldown/toggle_arms/Activate(atom/target)
	var/mob/living/carbon/human/nabber = owner
	if(!nabber)
		return FALSE

	if(isdead(nabber) || nabber.incapacitated())
		nabber.balloon_alert(nabber, "Incapacitated!")
		return FALSE

	if(nabber.num_hands < 2)
		nabber.balloon_alert(nabber, "Need both hands!")
		return	FALSE

	var/obj/item/held = nabber.get_active_held_item()
	var/obj/item/inactive = nabber.get_inactive_held_item()

	if(((held || inactive) && !nabber.drop_all_held_items()) && !(istype((inactive || held), /obj/item/melee/nabber_blade)))
		nabber.balloon_alert(nabber, "Hands occupied!")
		return	FALSE

	else if(istype((inactive || held), /obj/item/melee/nabber_blade))
		StartCooldown()
		down_arms()
		return TRUE

	rise_arms()
	StartCooldown()
	return TRUE

/datum/action/cooldown/toggle_arms/proc/rise_arms()
	var/mob/living/carbon/human/nabber = owner
	nabber.balloon_alert(nabber, "Begin pumping blood in!")
	nabber.visible_message(span_danger("[nabber] starts to pump blood into their hunting arms!"), span_warning("You let out a aggressive screech, raising your blade-arms!"), span_hear("You hear a sharp screech of an agitated creature!"))
	playsound(nabber, 'sound/voice/nabber/nabberscream.ogg', 70)

	if(!do_after(nabber, 1.5 SECONDS, nabber))
		StartCooldown()
		nabber.balloon_alert(nabber, "Stand still!")
		return FALSE
	RegisterSignal(nabber, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile), override = TRUE)
	nabber.balloon_alert(nabber, "Arms raised!")
	nabber.visible_message(span_warning("[nabber] raised their mantid-like hunting arms in a frenzy, ready for a fight!"), span_warning("You raise your mantis arms, ready for combat."), span_hear("You hear a terrible hunting screech!"))
	playsound(nabber, 'sound/voice/nabber/nabberscream.ogg', 70)

	var/c = nabber.dna.features["mcolor"]
	var/active_path = text2path("/obj/item/melee/nabber_blade[blade_type]")
	var/inactive_path = text2path("/obj/item/melee/nabber_blade[blade_type]/alt")
	var/obj/item/melee/nabber_blade/active_hand =  new active_path
	var/obj/item/melee/nabber_blade/inactive_hand = new inactive_path

	active_hand.color = c
	inactive_hand.color = c

	nabber.put_in_active_hand(active_hand)
	nabber.put_in_inactive_hand(inactive_hand)
	if(blade_type) //Rather than just having these be items that can cause huge problems, ensure we delete them and just recreate with the force neccessary.
		RegisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
		if(active_hand.icon_type_on)
			nabber.modify_accessory_overlay(active_hand.icon_type_on)
	RegisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB, PROC_REF(on_lose_hand))
	button_icon_state = "arms_on"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/down_arms(force = FALSE)
	var/mob/living/carbon/human/nabber = owner
	nabber.visible_message(span_notice("[nabber] starts to relax, pumping blood away from their hunting-arms!"), span_notice("You start pumping blood out your mantis arms. Stay still!"), span_hear("You hear [src] let out a quiet hissing sigh."))

	if(force)
		nabber.Stun(5 SECONDS)
		for(var/obj/item/held in nabber.held_items)
			var/obj/item/melee/nabber_blade/held_temp = held
			if(held_temp.icon_type_off)
				nabber.modify_accessory_overlay(held_temp.icon_type_off)
			qdel(held)
		button_icon_state = "arms_on"
		nabber.update_action_buttons()
		UnregisterSignal(nabber, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT))
		return	FALSE

	nabber.balloon_alert(nabber, "Removing blood from hunting-arms!")

	if(!do_after(nabber, 0.5 SECONDS, nabber))
		nabber.balloon_alert(nabber, "Stand still!")
		return	FALSE

	UnregisterSignal(nabber, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT))
	playsound(nabber, 'sound/voice/nabber/nabberscream.ogg', 70)
	if(blade_type)
		UnregisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
	for(var/obj/item/held in nabber.held_items)
		var/obj/item/melee/nabber_blade/held_temp = held
		if(held_temp.icon_type_off)
			nabber.modify_accessory_overlay(held_temp.icon_type_off)
		qdel(held)

	UnregisterSignal(owner, COMSIG_CARBON_REMOVE_LIMB)
	nabber.balloon_alert(nabber, "Arms down!")
	button_icon_state = "arms_off"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/on_lose_hand()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/nabber = owner
	UnregisterSignal(nabber, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT))
	if(!(nabber.num_hands < 2))
		return	FALSE

	nabber.visible_message(span_notice("[nabber] has their arm violently removed, spurting high-pressure haemolyph, the other going limp!"), span_notice("HOLY SHIT MY ARM!"), span_hear("You hear [nabber] let out a sharp hiss as they lose a limb!"))
	playsound(nabber, 'sound/voice/nabber/nabberscream.ogg', 70)
	nabber.balloon_alert(nabber, "Lost hands!")
	nabber.Stun(5 SECONDS)
	if(blade_type)
		UnregisterSignal(nabber, COMSIG_ATOM_EXAMINE, PROC_REF(examined))
	for(var/obj/item/held in nabber.held_items)
		var/obj/item/melee/nabber_blade/held_temp = held
		if(held_temp.icon_type_off)
			nabber.modify_accessory_overlay(held_temp.icon_type_off)
		qdel(held)

	button_icon_state = "arms_off"
	nabber.update_action_buttons()

/datum/action/cooldown/toggle_arms/proc/examined(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(held_desc)
		var/examine_text = span_bolditalic("[examined] [held_desc]")
		examine_list += examine_text

/datum/action/cooldown/toggle_arms/proc/hit_by_projectile(mob/living/nabber, obj/projectile/hitting_projectile, def_zone) //stolen from sleeping carp my beloved
	SIGNAL_HANDLER
	if(blade_type == (NABBER_ARM_TYPE_SYNDICATE || NABBER_ARM_TYPE_NUCLEAR))
		if(hitting_projectile.reflectable == TRUE) //Should only work on very few projectiles.
			nabber.visible_message(
				span_bolddanger("[nabber] deflects [hitting_projectile] aside with a shower of sparks! [nabber.p_They()] can deflect energy projectiles with [nabber.p_their()] glowing armblades!"),
				span_userdanger("You deflect [hitting_projectile]!"),
			)
			playsound(nabber, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), vol = 75, vary = TRUE)
			hitting_projectile.firer = nabber
			hitting_projectile.set_angle(rand(0, 360))//SHING
			return COMPONENT_BULLET_PIERCED
	return NONE

