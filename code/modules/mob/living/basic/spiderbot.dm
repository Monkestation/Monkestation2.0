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

	basic_mob_flags = DEL_ON_DEATH

	/// Is it getting ready to explode?
	var/emagged = FALSE
	/// MMI it contains
	var/obj/item/mmi/mmi = null
	/// Who emagged the spiderbot
	var/datum/weakref/emagged_master = null

/mob/living/basic/spiderbot/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/death_loot = list(/obj/effect/gibspawner/robot)
	AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5, explosion_cause = "Emagged spiderbot destruction")
	else
		eject_brain()
	return ..()

/mob/living/basic/spiderbot/item_interaction(mob/living/user, obj/item/O, list/modifiers)
	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/B = O
		if(mmi) // There's already a brain in it.
			to_chat(user, span_warning("There's already a brain in [src]!"))
			return ITEM_INTERACT_BLOCKING
		if(!B.brainmob)
			to_chat(user, span_warning("Sticking an empty MMI into the frame would sort of defeat the purpose."))
			return ITEM_INTERACT_BLOCKING
		if(!B.brainmob.key)
			to_chat(user, span_warning("This MMI is inactive."))
			return ITEM_INTERACT_BLOCKING
		if(!B.brainmob.mind)
			to_chat(user, span_warning("This MMI has no personality to transfer."))
			return ITEM_INTERACT_BLOCKING

		if(B.brainmob.stat == DEAD)
			to_chat(user, span_warning("[B] is dead. Sticking it into the frame would sort of defeat the purpose."))
			return ITEM_INTERACT_BLOCKING

		if(is_banned_from(B.brainmob.key, list(ROLE_PAI, JOB_CYBORG)))
			to_chat(user, span_warning("[B] does not seem to fit."))
			return ITEM_INTERACT_BLOCKING

		if(!user.transferItemToLoc(B, src))
			return ITEM_INTERACT_BLOCKING
		mmi = B
		transfer_personality(B)

		to_chat(user, span_notice("You install [B] in [src]!"))
		update_icon()
		return ITEM_INTERACT_SUCCESS

	else if(istype(O, /obj/item/card/id) || istype(O, /obj/item/modular_computer/pda))
		if(!mmi)
			to_chat(user, span_warning("There's no reason to swipe your ID - the spiderbot has no brain to remove."))
			return ITEM_INTERACT_BLOCKING

		if(emagged)
			to_chat(user, span_warning("[src] doesn't seem to respond."))
			return ITEM_INTERACT_BLOCKING

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/modular_computer/pda/pda = O
			id_card = pda.computer_id_slot

		if(!id_card)
			to_chat(user, span_warning("[O] has no ID card to swipe."))
			return ITEM_INTERACT_BLOCKING

		if(ACCESS_ROBOTICS in id_card.access)
			to_chat(user, span_notice("You swipe your access card and pop the brain out of [src]."))
			eject_brain()
			return ITEM_INTERACT_SUCCESS

		to_chat(user, span_warning("You swipe your card, with no effect."))
		return ITEM_INTERACT_BLOCKING

/mob/living/basic/spiderbot/welder_act(mob/user, obj/item/tool)
	if((user.istate & ISTATE_HARM) && user != src)
		return FALSE
	if(user == src) // No self-repair dummy
		to_chat(user, span_warning("You can not repair yourself!"))
		return
	if(health >= maxHealth)
		to_chat(user, span_warning("[src] does not need repairing!"))
		return
	. = TRUE
	if(!tool.tool_start_check(user, amount = 1)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
		return
	adjustBruteLoss(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!",span_notice("You repair [src]."))

/mob/living/basic/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, span_warning("[src] doesn't seem to respond."))
		return FALSE
	emagged = TRUE
	to_chat(user, span_notice("You short out the security protocols and rewrite [src]'s internal memory."))
	to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!"))
	emagged_master = WEAKREF(user)
	log_silicon("EMAG: [key_name(user)] emagged cyborg [key_name(src)].")
	maxHealth = 60
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/machines/defib_zap.ogg'
	return TRUE

/mob/living/basic/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	name = "Spider-bot ([M.brainmob.name])"
	M.brainmob.mind.transfer_to(src)
	if(emagged)
		var/mob/living/master = emagged_master?.resolve()
		if(master)
			to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [master] and [master.p_their()] every order!"))
		else
			emagged_master = null
			to_chat(src, span_userdanger("You have been emagged; your original master signal is no longer traceable."))

/mob/living/basic/spiderbot/update_icon_state()
	if(mmi)
		if(istype(mmi, /obj/item/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"
	return ..()

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
	name = initial(name)
	update_appearance(UPDATE_ICON_STATE)
	return ejected_mmi
