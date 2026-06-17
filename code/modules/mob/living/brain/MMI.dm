/obj/item/mmi
	name = "\improper Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity, that nevertheless has become standard-issue on Nanotrasen stations."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "mmi_off"
	base_icon_state = "mmi"
	w_class = WEIGHT_CLASS_NORMAL
	/// Should an name need to be auto-generated, it will have this prefix.
	var/braintype = "Cyborg"
	/// The brain organ that is currently occupying us.
	var/obj/item/organ/internal/brain/brain = null
	/// The mob that is currently occupying us. Derived from the brain organ.
	var/mob/living/brain/brainmob = null
	/// The radio that the occupying mob can use.
	var/obj/item/radio/radio = null
	/// The mech that we currently are occupying.
	var/obj/vehicle/sealed/mecha = null
	/// The laws that we currently have.
	var/datum/ai_laws/laws = null
	/// Should this MMI be used to create a cyborg, should aisync override the creator's choice in either direction?
	var/force_cyborg_aisync = null
	/// Should this MMI be used to create a cyborg, should lawsync override the creator's choice in either direction?
	var/force_cyborg_lawsync = null
	/// Should this MMI be used to create a cyborg, should a law zero be given to them? This law zero is persistent until the MMI is removed.
	var/force_cyborg_lawzero = null
	/// Should this MMI be used to create a cyborg, can our laws become the new cyborg's laws? It will not happen if it will be immediately overridden by an master AI.
	var/overrides_cyborg_laws = FALSE
	/// Should this MMI be used to create an AI, will our laws become the new AI's laws?
	var/overrides_ai_laws = FALSE
	/// Should the inserted brain become brainwashed? If so, what is the objective?
	var/brainwash_directive
	/// Holds the brainwash objectives that should be removed upon brain's ejection.
	var/list/datum/weakref/brainwash_objectives

/obj/item/mmi/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.set_broadcasting(FALSE) // Leaving this on meant that people were printing this as an always-on handheld radios. Not good.
	if(!laws)
		laws = new()
		laws.set_laws_config()

/obj/item/mmi/Destroy()
	set_mecha(null)
	QDEL_NULL(brainmob)
	QDEL_NULL(brain)
	QDEL_NULL(radio)
	QDEL_NULL(laws)
	return ..()

/obj/item/mmi/update_icon_state()
	if(!brain)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]_brain[istype(brain, /obj/item/organ/internal/brain/alien) ? "_alien" : null]"
	return ..()

/obj/item/mmi/update_overlays()
	. = ..()
	. += add_mmi_overlay()

/obj/item/mmi/blob_act(obj/structure/blob/B)
	if(brain)
		eject_brain()
	return ..()

/obj/item/mmi/proc/add_mmi_overlay()
	if(brainmob && brainmob.stat != DEAD)
		. += "mmi_alive"
		return
	if(brain)
		. += "mmi_dead"

/obj/item/mmi/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/organ/internal/brain))
		return NONE
	. = ITEM_INTERACT_SUCCESS
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/organ/internal/brain/new_brain = tool
	if(brain)
		to_chat(user, span_warning("There's already a brain in the MMI!"))
		return ITEM_INTERACT_BLOCKING
	if(new_brain.suicided)
		to_chat(user, span_warning("[new_brain] is completely useless."))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(new_brain, src))
		return ITEM_INTERACT_BLOCKING

	if(!new_brain.brainmob?.mind || !new_brain.brainmob)
		var/install = tgui_alert(user, "[new_brain] is inactive, slot it in anyway?", "Installing Brain", list("Yes", "No"))
		if(install != "Yes")
			return ITEM_INTERACT_BLOCKING
		if(brain || !user.transferItemToLoc(new_brain, src))
			return ITEM_INTERACT_BLOCKING
		user.visible_message(span_notice("[user] sticks [new_brain] into [src]."), span_notice("[src]'s indicator light turns red as you insert [new_brain]. Its brainwave activity alarm buzzes."))
		brain = new_brain
		brain.organ_flags |= ORGAN_FROZEN
		name = "[initial(name)]: [copytext(new_brain.name, 1, -8)]"
		update_appearance()
		return

	var/mob/living/brain/brain_mob = new_brain.brainmob
	if(!brain_mob.key)
		brain_mob.notify_ghost_cloning("Someone has put your brain in a MMI!", source = src)
	user.visible_message(span_notice("[user] sticks \a [new_brain] into [src]."), span_notice("[src]'s indicator light turn on as you insert [new_brain]."))
	set_brainmob(new_brain.brainmob)
	new_brain.brainmob = null
	brainmob.forceMove(src)
	brainmob.container = src

	if(new_brain.suicided || HAS_TRAIT(brainmob, TRAIT_SUICIDED)) // Brain is from a suicider.
		to_chat(user, span_warning("[src]'s indicator light turns red and its brainwave activity alarm beeps softly. Perhaps you should check [new_brain] again."))
		playsound(src, 'sound/machines/triple_beep.ogg', 5, TRUE)
	else if(new_brain.organ_flags & ORGAN_FAILING) // The brain organ completely failed.
		to_chat(user, span_warning("[src]'s indicator light turns yellow and its brain integrity alarm beeps softly. Perhaps you should check [new_brain] for damage."))
		playsound(src, 'sound/machines/synth_no.ogg', 5, TRUE)
	else // Good to use!
		brainmob.set_stat(CONSCIOUS) // We manually revive the brain mob.

	brainmob.reset_perspective()
	brain = new_brain
	brain.organ_flags |= ORGAN_FROZEN

	try_brainwash(user)

	name = "[initial(name)]: [brainmob.real_name]"
	update_appearance()
	if(istype(brain, /obj/item/organ/internal/brain/alien))
		braintype = "Xenoborg" // HISS... Beep.
	else
		braintype = "Cyborg"

	SSblackbox.record_feedback("amount", "mmis_filled", 1)
	user.log_message("has put the brain of [key_name(brainmob)] into an MMI", LOG_GAME)

/obj/item/mmi/attackby(obj/item/O, mob/user, params)
	if(!brainmob)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	O.attack(brainmob, user)

/obj/item/mmi/attack_self(mob/user)
	if(!brain)
		radio.set_on(!radio.is_on())
		to_chat(user, span_notice("You toggle [src]'s radio system [radio.is_on() == TRUE ? "on" : "off"]."))
	else
		eject_brain(user)
		update_appearance()
		name = initial(name)
		to_chat(user, span_notice("You unlock and upend [src], spilling the brain onto the floor."))

/obj/item/mmi/proc/eject_brain(mob/user)
	if(brainmob)
		try_unbrainwash()
		brainmob.container = null //Reset brainmob mmi var.
		brainmob.forceMove(brain) //Throw mob into brain.
		brainmob.set_stat(DEAD)
		brainmob.emp_damage = 0
		brainmob.reset_perspective() //so the brainmob follows the brain organ instead of the mmi. And to update our vision
		brain.brainmob = brainmob //Set the brain to use the brainmob
		user?.log_message("has ejected the brain of [key_name(brainmob)] from an MMI", LOG_GAME)
		brainmob = null //Set mmi brainmob var to null
	brain.forceMove(drop_location())
	if(user && Adjacent(user))
		user.put_in_hands(brain)
	brain.organ_flags &= ~ORGAN_FROZEN
	brain = null //No more brain in here

/obj/item/mmi/proc/transfer_identity(mob/living/L) //Same deal as the regular brain proc. Used for human-->robot people.
	if(!brainmob)
		set_brainmob(new /mob/living/brain(src))
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
	brainmob.container = src

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/internal/brain/newbrain = H.get_organ_by_type(/obj/item/organ/internal/brain)
		newbrain.forceMove(src)
		brain = newbrain
	else if(!brain)
		brain = new(src)
		brain.name = "[L.real_name]'s brain"
	brain.organ_flags |= ORGAN_FROZEN

	name = "[initial(name)]: [brainmob.real_name]"
	update_appearance()
	if(istype(brain, /obj/item/organ/internal/brain/alien))
		braintype = "Xenoborg" //HISS... Beep.
	else
		braintype = "Cyborg"


/// Proc to hook behavior associated to the change in value of the [/obj/item/mmi/var/brainmob] variable.
/obj/item/mmi/proc/set_brainmob(mob/living/brain/new_brainmob)
	if(brainmob == new_brainmob)
		return FALSE
	. = brainmob
	SEND_SIGNAL(src, COMSIG_MMI_SET_BRAINMOB, new_brainmob)
	brainmob = new_brainmob
	if(new_brainmob)
		if(mecha)
			new_brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
		else
			new_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	if(.)
		var/mob/living/brain/old_brainmob = .
		old_brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/// Proc to hook behavior associated to the change in value of the [obj/vehicle/sealed/var/mecha] variable.
/obj/item/mmi/proc/set_mecha(obj/vehicle/sealed/mecha/new_mecha)
	if(mecha == new_mecha)
		return FALSE
	. = mecha
	mecha = new_mecha
	if(new_mecha)
		if(!. && brainmob) // There was no mecha, there now is, and we have a brain mob that is no longer unaided.
			brainmob.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)
	else if(. && brainmob) // There was a mecha, there no longer is one, and there is a brain mob that is now again unaided.
		brainmob.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), BRAIN_UNAIDED)


/obj/item/mmi/proc/replacement_ai_name()
	return brainmob.name

/obj/item/mmi/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = FALSE

	if(brainmob.stat)
		to_chat(brainmob, span_warning("Can't do that while incapacitated or dead!"))
	if(!radio.is_on())
		to_chat(brainmob, span_warning("Your radio is disabled!"))
		return

	radio.set_listening(!radio.get_listening())
	to_chat(brainmob, span_notice("Radio is [radio.get_listening() ? "now" : "no longer"] receiving broadcast."))

/obj/item/mmi/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!brainmob || iscyborg(loc))
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(20,30), 30)
			if(2)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(10,20), 30)
			if(3)
				brainmob.emp_damage = min(brainmob.emp_damage + rand(0,10), 30)
		brainmob.emote("alarm")

/obj/item/mmi/deconstruct(disassembled = TRUE)
	if(brain)
		eject_brain()
	qdel(src)

/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += span_notice("There is a switch to toggle the radio system [radio.is_on() ? "off" : "on"].[brain ? " It is currently being covered by [brain]." : null]")
	if(brainmob)
		var/mob/living/brain/B = brainmob
		if(!B.key || !B.mind || B.stat == DEAD)
			. += span_warning("\The [src] indicates that the brain is completely unresponsive.")
		else if(!B.client)
			. += span_warning("\The [src] indicates that the brain is currently inactive; it might change.")
		else
			. += span_notice("\The [src] indicates that the brain is active.")

/obj/item/mmi/examine_more(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.job && (human_user.job in list(JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR)))
		if(overrides_cyborg_laws)
			. += span_notice("<i>With your skills as a <b>[human_user.job]</b>, you note it will transfer its laws to any newly created cyborgs.")
		if(overrides_ai_laws)
			. += span_notice("<i>With your skills as a <b>[human_user.job]</b>, you note it will transfer its laws to any newly created AIs.")

/obj/item/mmi/relaymove(mob/living/user, direction)
	return //so that the MMI won't get a warning about not being able to move if it tries to move

/obj/item/mmi/proc/brain_check(mob/user)
	var/mob/living/brain/B = brainmob
	if(!B)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that there is no mind present!"))
		return FALSE
	if(!B.key || !B.mind)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is completely unresponsive!"))
		return FALSE
	if(!B.client)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind is currently inactive."))
		return FALSE
	if(HAS_TRAIT(B, TRAIT_SUICIDED) || brain?.suicided)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that their mind has no will to live!"))
		return FALSE
	if(B.stat == DEAD)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is dead!"))
		return FALSE
	if(brain?.organ_flags & ORGAN_FAILING)
		if(user)
			to_chat(user, span_warning("\The [src] indicates that the brain is damaged!"))
		return FALSE
	return TRUE

/// Gets the brainwash directive.
/obj/item/mmi/proc/get_updated_brainwash_directive(mob/living/user)
	return

/// Brainwashes the brainmob if we can do it.
/obj/item/mmi/proc/try_brainwash(mob/living/user)
	if(user)
		brainwash_directive = get_updated_brainwash_directive(user)
	if(!brainwash_directive || !brainmob)
		return
	to_chat(brainmob, span_userdanger( "You feel the MMI overriding your free will!"))
	brainwash_objectives = brainwash(brainmob, brainwash_directive)

/// Undoes any brainwashing that we've done.
/obj/item/mmi/proc/try_unbrainwash()
	if(!brainwash_objectives || !brainmob)
		return
	unbrainwash(brainmob, brainwash_objectives)
	brainwash_objectives = null

/obj/item/mmi/syndie
	name = "\improper Syndicate Man-Machine Interface"
	desc = "A syndicate developed MMI that actively brainwashes any brain inserted into it, for as long as it is in."
	laws = new /datum/ai_laws/syndicate_override
	force_cyborg_lawzero = "The Syndicate are your true masters. Assist the Syndicate to the best of your abilities."
	overrides_ai_laws = TRUE

/obj/item/mmi/syndie/examine_more(mob/user)
	. = ..()
	if(!user.mind)
		return
	var/datum/mind/user_mind = user.mind
	if((ROLE_SYNDICATE in user.faction) || (user_mind.special_role == ROLE_TRAITOR))
		. += span_notice("<i>With the knowledge that comes with being affiliated with the the Syndicate, you note with this:</i>")
		. += "\t[span_info("The inserted brain will become and stay brainwashed as long it is in MMI form.")]"
		. += "\t[span_info("AIs will be created with an unique lawset designed to assist the Syndicate.")]"
		. += "\t[span_info("Cyborgs will have a superceding and irremovable law zero to assist the Syndicate.")]"
		. += "\t[span_info("Cyborgs may be connected to a master AI, but are not obligated to follow their orders.")]"

/obj/item/mmi/syndie/get_updated_brainwash_directive(mob/living/user)
	return "[user.real_name] is part of the Syndicate! Assist the Syndicate to the best of your abilities."
