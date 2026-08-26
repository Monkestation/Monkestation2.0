// No AI controller for these guys - they should be inert if they're not player controlled.
/mob/living/basic/spiderbot
	name = "spider bot"
	desc = "A skittering robotic friend!" // More like ultimate shitter
	icon = 'icons/mob/silicon/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	health = 40
	maxHealth = 40
	pass_flags = PASSTABLE

	melee_damage_lower = 2
	melee_damage_upper = 2
	melee_damage_type = BURN
	attack_verb_continuous = "shocks"
	attack_verb_simple = "shocks"
	attack_sound = "sparks"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomps on"
	speed = 0
	mob_biotypes = MOB_ROBOTIC
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("beeps", "clicks", "chirps")

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	// Leave a smashed chassis behind so icon_dead is visible after destruction.
	basic_mob_flags = NONE
	req_access = list(ACCESS_ROBOTICS)

	/// Whether the spiderbot has been emagged and will explode when destroyed.
	var/emagged = FALSE
	/// The MMI currently installed in the spiderbot.
	var/obj/item/mmi/mmi
	/// A weak reference to the mob that emagged the spiderbot.
	var/datum/weakref/emagged_master

/mob/living/basic/spiderbot/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/death_loot = list(/obj/effect/gibspawner/robot)
	AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/spiderbot/Destroy()
	eject_brain()
	return ..()

/mob/living/basic/spiderbot/death(gibbed)
	if(stat == DEAD)
		return FALSE

	. = ..()

	if(!emagged)
		return

	// Detonate once on death. The devastation zone gibs the spiderbot itself.
	emagged = FALSE
	QDEL_NULL(mmi)
	explosion(
		get_turf(src),
		devastation_range = 1,
		heavy_impact_range = 2,
		light_impact_range = 3,
		flash_range = 5,
		explosion_cause = "Emagged spiderbot death",
	)

/mob/living/basic/spiderbot/item_interaction(mob/living/user, obj/item/attacking_item, list/modifiers)
	if(istype(attacking_item, /obj/item/mmi))
		var/obj/item/mmi/inserted_mmi = attacking_item
		if(mmi) // There's already a brain in it.
			balloon_alert(user, "already has a brain!")
			return ITEM_INTERACT_BLOCKING
		if(!inserted_mmi.brainmob)
			balloon_alert(user, "mmi is empty!")
			return ITEM_INTERACT_BLOCKING
		if(!inserted_mmi.brainmob.key)
			balloon_alert(user, "mmi is inactive!")
			return ITEM_INTERACT_BLOCKING
		if(!inserted_mmi.brainmob.mind)
			balloon_alert(user, "mmi has no personality!")
			return ITEM_INTERACT_BLOCKING

		if(inserted_mmi.brainmob.stat == DEAD)
			balloon_alert(user, "mmi is dead!")
			return ITEM_INTERACT_BLOCKING

		if(is_banned_from(inserted_mmi.brainmob.key, list(ROLE_PAI, JOB_CYBORG)))
			balloon_alert(user, "mmi rejected!")
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(inserted_mmi, src))
			return ITEM_INTERACT_BLOCKING
		mmi = inserted_mmi
		transfer_personality(inserted_mmi)

		balloon_alert(user, "brain installed")
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(attacking_item.GetID())
		if(!mmi)
			balloon_alert(user, "no brain installed!")
			return ITEM_INTERACT_BLOCKING

		if(emagged)
			balloon_alert(user, "access system unresponsive!")
			return ITEM_INTERACT_BLOCKING

		if(allowed(user))
			balloon_alert(user, "brain ejected")
			eject_brain()
			return ITEM_INTERACT_SUCCESS

		balloon_alert(user, "access denied!")
		return ITEM_INTERACT_BLOCKING

/mob/living/basic/spiderbot/welder_act(mob/living/user, obj/item/tool)
	if((user.istate & ISTATE_HARM) && user != src)
		return ITEM_INTERACT_SKIP_TO_ATTACK
	if(user == src) // No self-repair dummy
		balloon_alert(user, "cannot self-repair!")
		return ITEM_INTERACT_BLOCKING
	if(health >= maxHealth)
		balloon_alert(user, "no repairs needed!")
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0 SECONDS, volume = 40, amount = 1))
		return ITEM_INTERACT_BLOCKING
	adjustBruteLoss(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!", span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS

/mob/living/basic/spiderbot/emag_act(mob/living/user, obj/item/card/emag/emag_card)
	if(emagged)
		balloon_alert(user, "already emagged!")
		return FALSE
	emagged = TRUE
	balloon_alert(user, "security protocols rewritten")
	to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!"))
	emagged_master = WEAKREF(user)
	log_silicon("EMAG: [key_name(user)] emagged cyborg [key_name(src)].")
	maxHealth = 60
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/machines/defib_zap.ogg'
	return TRUE

/// Transfers the inserted MMI's personality into the spiderbot.
/mob/living/basic/spiderbot/proc/transfer_personality(obj/item/mmi/inserted_mmi)
	inserted_mmi.brainmob.mind.transfer_to(src)
	if(!emagged)
		return

	var/mob/living/master = emagged_master?.resolve()
	if(master)
		to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [master] and [master.p_their()] every order!"))
		return

	emagged_master = null
	to_chat(src, span_userdanger("You have been emagged; your original master signal is no longer traceable."))

/mob/living/basic/spiderbot/update_name(updates)
	. = ..()
	name = mmi ? "Spider-bot ([mmi.brainmob.name])" : initial(name)

/mob/living/basic/spiderbot/update_icon_state()
	if(mmi)
		if(istype(mmi, /obj/item/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
		else
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"
	return ..()

/// Ejects the installed MMI and returns its personality to the contained brain.
/mob/living/basic/spiderbot/proc/eject_brain()
	if(!mmi)
		return
	var/obj/item/mmi/ejected_mmi = mmi
	mmi = null
	ejected_mmi.forceMove(drop_location())
	if(mind)
		if(ejected_mmi.brainmob)
			mind.transfer_to(ejected_mmi.brainmob)
		else
			to_chat(src, span_boldannounce("Your MMI was unable to receive your personality. You have been ghosted; please report this bug."))
			ghostize()
			stack_trace("Spiderbot MMI lacked a brainmob during ejection")
	ejected_mmi.update_appearance()
	update_appearance()
	return ejected_mmi
