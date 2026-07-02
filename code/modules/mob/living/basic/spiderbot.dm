// No AI controller for these guys - they should be inert if they're not player controlled.
/mob/living/basic/spiderbot
	name = "Spider-bot"
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
	var/mob/emagged_master = null

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
			return ITEM_INTERACT_SUCCESS
		if(!B.brainmob)
			to_chat(user, span_warning("Sticking an empty MMI into the frame would sort of defeat the purpose."))
			return ITEM_INTERACT_SUCCESS
		if(!B.brainmob.key)
			to_chat(user, span_warning("This MMI is inactive."))
			return ITEM_INTERACT_SUCCESS

		if(B.brainmob.stat == DEAD)
			to_chat(user, span_warning("[B] is dead. Sticking it into the frame would sort of defeat the purpose."))
			return ITEM_INTERACT_SUCCESS

		if(is_banned_from(B.brainmob.key, list(ROLE_PAI, JOB_CYBORG)))
			to_chat(user, span_warning("[B] does not seem to fit."))
			return ITEM_INTERACT_SUCCESS

		to_chat(user, span_notice("You install [B] in [src]!"))

		user.dropItemToGround()
		B.forceMove(src)
		mmi = B
		transfer_personality(B)

		update_icon()
		return ITEM_INTERACT_SUCCESS

	else if(istype(O, /obj/item/card/id) || istype(O, /obj/item/modular_computer/pda))
		if(!mmi)
			to_chat(user, span_warning("There's no reason to swipe your ID - the spiderbot has no brain to remove."))
			return ITEM_INTERACT_SUCCESS

		if(emagged)
			to_chat(user, span_warning("[src] doesn't seem to respond."))
			return ITEM_INTERACT_SUCCESS

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/modular_computer/pda/pda = O
			id_card = pda.computer_id_slot

		if(ACCESS_ROBOTICS in id_card.access)
			to_chat(user, span_notice("You swipe your access card and pop the brain out of [src]."))
			eject_brain()
			return ITEM_INTERACT_SUCCESS
		else
			to_chat(user, span_warning("You swipe your card, with no effect."))
			return ITEM_INTERACT_SUCCESS

/mob/living/basic/spiderbot/welder_act(mob/user, obj/item/tool)
	if((user.istate & ISTATE_HARM) && usr != src)
		return FALSE
	if(user == src) // No self-repair dummy
		to_chat(user, span_warning("You can not repair yourself!"))
		return
	if(health >= maxHealth)
		to_chat(user, span_warning("[src] does not need repairing!"))
		return
	. = TRUE
	if (!tool.tool_start_check(user, amount=1)) //The welder has 1u of fuel consumed by it's afterattack, so we don't need to worry about taking any away.
		return
	adjustBruteLoss(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!",span_notice("You repair [src]."))

/mob/living/basic/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, span_warning("[src] doesn't seem to respond."))
		return FALSE
	else
		emagged = TRUE
		to_chat(user, span_notice("You short out the security protocols and rewrite [src]'s internal memory."))
		to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!"))
		emagged_master = user
		log_silicon("EMAG: [key_name(user)] emagged cyborg [key_name(src)].")
		maxHealth = 60
		health = 60
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/machines/defib_zap.ogg'
		return TRUE

/mob/living/basic/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	mind = M.brainmob.mind
	mind.key = M.brainmob.key
	ckey = M.brainmob.ckey
	name = "Spider-bot ([M.brainmob.name])"
	if(emagged)
		to_chat(src, span_userdanger("You have been emagged; you are now completely loyal to [emagged_master] and [emagged_master.p_their()] every order!"))

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
	if(mmi)
		var/turf/T = get_turf(src)
		mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		mmi = null
		name = "Spider-bot"
		update_icon()
