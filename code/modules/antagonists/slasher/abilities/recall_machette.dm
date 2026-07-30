#define VARIANT_SLASHER "slasher"
#define VARIANT_CLUWNE "cluwne"
#define VARIANT_BRUTE "brute"

/datum/action/cooldown/slasher/summon_machette
	name = "Summon Machette"
	desc = "Summon your machete to your active hand, or create one if it doesn't exist. This machete deals 15 BRUTE on hit increasing by 2.5 for every soul you own, and stuns on throw."

	button_icon_state = "summon_machete"

	cooldown_time = 15 SECONDS

	var/obj/item/slasher_machette/stored_machette


/datum/action/cooldown/slasher/summon_machette/Destroy()
	. = ..()
	QDEL_NULL(stored_machette)

/datum/action/cooldown/slasher/summon_machette/Activate(atom/target)
	. = ..()
	if(owner.stat == DEAD)
		return
	if(!stored_machette || QDELETED(stored_machette))
		var/datum/antagonist/slasher/slasherdatum = IS_SLASHER(owner)
		if(!slasherdatum)
			return
		switch(slasherdatum.slasher_variant)
			if(VARIANT_SLASHER)
				stored_machette = new /obj/item/slasher_machette
			if(VARIANT_CLUWNE)
				stored_machette = new /obj/item/slasher_machette/cluwne
			if(VARIANT_BRUTE)
				stored_machette = new /obj/item/slasher_machette/brute
		slasherdatum.linked_machette = stored_machette

	if(!owner.put_in_hands(stored_machette))
		stored_machette.forceMove(get_turf(owner))
	else
		SEND_SIGNAL(owner, COMSIG_LIVING_PICKED_UP_ITEM, stored_machette)

/obj/item/slasher_machette
	name = "slasher's machete"
	desc = "An old machete, clearly showing signs of wear and tear due to its age."

	icon = 'goon/icons/obj/items/weapons.dmi'
	icon_state = "welder_machete"
	hitsound = 'goon/sounds/impact_sounds/Flesh_Cut_1.ogg'

	inhand_icon_state = "PKMachete0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'

	force = 20 //damage increases by 2.5 for every soul they take
	throwforce = 20 //damage goes up by 2.5 for every soul they take
	demolition_mod = 1.25
	armour_penetration = 10
	//tool_behaviour = TOOL_CROWBAR // lets you pry open doors forcibly

	sharpness = SHARP_EDGED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Used to keep track of the force we had before throws. After the throw, `throwforce` is
	/// restored to this.
	var/pre_throw_force

/obj/item/slasher_machette/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PRE_THROW, PROC_REF(pre_throw))
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))

/obj/item/slasher_machette/Destroy(force)
	UnregisterSignal(src, list(COMSIG_MOVABLE_PRE_THROW, COMSIG_MOVABLE_POST_THROW))
	return ..()

/obj/item/slasher_machette/proc/pre_throw(obj/item/source, list/arguments)
	SIGNAL_HANDLER
	var/mob/living/thrower = arguments[4]
	if(!istype(thrower) || !IS_SLASHER(thrower))
		// Just in case our thrower isn't actually a slasher (somehow). This shouldn't ever come up,
		// but if it does, then we just prevent the throw.
		return COMPONENT_CANCEL_THROW

/obj/item/slasher_machette/throw_impact(mob/living/hit_living, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_living))
		hit_living.Knockdown(1.5 SECONDS)
		if(iscarbon(hit_living))
			playsound(src, 'goon/sounds/impact_sounds/Flesh_Stab_3.ogg', 25, 1)


/obj/item/slasher_machette/proc/post_throw(obj/item/source, datum/thrownthing, spin)
	SIGNAL_HANDLER
	// Restore the force we had before the throw.
	throwforce = pre_throw_force

/obj/item/slasher_machette/attack_hand(mob/user, list/modifiers)
	if(force_drop_machete(user))
		return FALSE
	var/datum/antagonist/slasher/slasherdatum = IS_SLASHER(user)
	if(istype(slasherdatum?.active_action, /datum/action/cooldown/slasher/soul_steal))
		return FALSE // Blocks the attack
	return ..() // Proceeds with normal attack if no soul steal is active

/obj/item/slasher_machette/attack(mob/living/target_mob, mob/living/user, params)
	if(force_drop_machete(user))
		return TRUE
	var/datum/antagonist/slasher/slasherdatum = IS_SLASHER(user)
	if(slasherdatum?.active_action)
		return TRUE // Blocks the attack
	return ..()

/obj/item/slasher_machette/proc/force_drop_machete(mob/living/victim)
	if(!isliving(victim) || IS_SLASHER(victim))
		return FALSE
	var/hand_zone = ((victim.get_held_index_of_item(src) || victim.active_hand_index) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
	victim.dropItemToGround(src, force = TRUE, silent = TRUE)
	victim.emote("scream")
	to_chat(victim, span_warning("You scream out in pain as you hold the [src]!"))
	victim.apply_damage(force, def_zone = hand_zone, sharpness = SHARP_EDGED)
	return TRUE

/obj/machinery/door/airlock/proc/attack_slasher_machete(atom/target, mob/living/user)
	if(!IS_SLASHER(user))
		return
	if(isElectrified() && shock(user, 100)) //Mmm, fried slasher!
		add_fingerprint(user)
		return
	if(!density) //Already open
		return
	if(locked || welded || seal) //Extremely generic, as slasher is stupid.
		if((user.istate & ISTATE_HARM))
			return
		to_chat(user, span_warning("[src] refuses to budge!"))
		return
	add_fingerprint(user)
	user.visible_message(span_warning("[user] begins prying open [src]."),\
						span_noticealien("You begin digging your machete into [src] with all your might!"),\
						span_warning("You hear groaning metal..."))
	var/time_to_open = 5 //half a second
	if(hasPower())
		time_to_open = 5 SECONDS //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 60, TRUE, mixer_channel = CHANNEL_SOUND_EFFECTS)


	if(do_after(user, time_to_open, src))
		if(density && !open(BYPASS_DOOR_CHECKS)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, span_warning("Despite your efforts, [src] managed to resist your attempts to open it!"))
		return

/obj/item/slasher_machette/cluwne
	name = "Cluwne's Carving Blade"
	desc = "A Killer Cluwne's favorite tool, its edge is no laughing matter."
	icon_state = "cluwne_machete"
	inhand_icon_state = "cluwne_machete"

/obj/item/slasher_machette/brute
	name = "Brute's Bonecrusher"
	desc = "A spiked mace, with each victim, its thirst for violence only seems to grow."
	hitsound = SFX_SWING_HIT
	icon_state = "brute_mace"
	inhand_icon_state = "brute_mace"

#undef VARIANT_SLASHER
#undef VARIANT_CLUWNE
#undef VARIANT_BRUTE
