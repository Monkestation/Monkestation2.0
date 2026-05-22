/datum/religion_sect/necro_sect
	name = "Necromancy"
	desc = "A sect dedicated to the revival and summoning of the dead. Sacrificing dead mobs and organs grants you favor."
	quote = "An undead army is a must have!"
	tgui_icon = "skull"
	alignment = ALIGNMENT_EVIL
	max_favor = 10000
	desired_items = list(/obj/item/organ/)
	rites_list = list(
		/datum/religion_rites/sacrifice,
		/datum/religion_rites/raise_dead,
		/datum/religion_rites/raise_undead,
		/datum/religion_rites/lesser_lichdom,
	)
	altar_icon_state = "convertaltar-green"

//Necro bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/necro_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/necro_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/organ))
		return
	adjust_favor(10, L)
	to_chat(L, span_notice("You offer [N] to [GLOB.deity], pleasing them and gaining 10 favor in the process."))
	qdel(N)
	return TRUE
/// Necro Rites

/datum/religion_rites/lesser_lichdom
	name = "Lesser Lichdom"
	desc = "Binds the soul of the caster to their altar creating a lesser phylactery, causing them to become a undying skeleton. \
	Be warned, if the phylactery is destroyed you will turn to dust. The altar will no longer be moveable once this ritual is performed, and can only be performed in the chapel."
	ritual_length = 60 SECONDS //This one's pretty powerful so it'll still be long
	ritual_invocations = list(
		"From the depths of the soul pool...",
		"... come forth into this being...",
		"... grant this servant power...",
		"... grant them temporary immortality...",
	)
	invoke_msg = "... Grant them the power to become one with necromancy!!"
	favor_cost = 2250

/datum/religion_rites/lesser_lichdom/perform_rite(mob/living/user, atom/religious_tool)
	var/turf/T = get_area(religious_tool)
	if(!istype(T, /area/station/service/chapel))
		to_chat(user, span_warning("The altar must be in the chapel to perform this ritual!")) // So its harder to hide the altar where it'll never be found
		return FALSE
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_NO_SOUL))
		to_chat(user, span_warning("You lack a soul."))
		return FALSE
	return ..()

/datum/religion_rites/lesser_lichdom/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/mob/living/carbon/human/rite_target
	var/datum/religion_sect/necro_sect/sect = GLOB.religious_sect
	rite_target = user
	if(!rite_target)
		return FALSE
	sect.altar_anchorable = FALSE
	rite_target.set_species(/datum/species/skeleton)
	rite_target.AddComponent(/datum/component/regenerator, outline_colour = COLOR_VERY_DARK_LIME_GREEN) // slow regeneration but you will eventually get back up
	religious_tool.AddComponent(/datum/component/lesser_phylactery, user.mind) // Nodeath and Nosoul trait while it exist, dust if destroyed
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/raise_undead
	name = "Raise Undead"
	desc = "Creates an weak but subservant undead creature if a soul is willing to take it."
	ritual_length = 50 SECONDS
	ritual_invocations = list(
		"Come forth from the pool of souls ...",
		"... enter our realm ...",
		"... become one with our world ...",
		"... rise ...",
		"... RISE! ...",
	)
	invoke_msg = "... RISE!!!"
	favor_cost = 1500

/datum/religion_rites/raise_undead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	new /obj/effect/temp_visual/cult/blood/long(altar_turf)
	new /obj/effect/temp_visual/dir_setting/curse/long(altar_turf)
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you wish to be resurrected as a Holy Summoned Undead?",
		check_jobban = ROLE_HOLY_SUMMONED,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_HOLYUNDEAD,
		jump_target = religious_tool,
		role_name_text = "holy summoned undead",
		alert_pic = /mob/living/carbon/human/species/skeleton,
		amount_to_pick = 1,
	)
	var/mob/dead/observer/candidate = pick(candidates)
	if(!candidate)
		to_chat(user, span_warning("The soul pool is empty..."))
		new /obj/effect/gibspawner/human/bodypartless(altar_turf)
		user.visible_message(span_warning("The soul pool was not strong enough to bring forth the undead."))
		GLOB.religious_sect?.adjust_favor(favor_cost, user) //refund if nobody takes the role
		return NOT_ENOUGH_PLAYERS
	var/datum/mind/mind = new(candidate.key)
	var/undead_species = pick(/mob/living/carbon/human/species/zombie/fragile, /mob/living/carbon/human/species/skeleton/fragile)
	var/mob/living/carbon/human/species/undead = new undead_species(altar_turf)
	undead.real_name = "Holy Undead ([rand(1,999)])"
	mind.active = TRUE
	mind.transfer_to(undead)
	undead.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(undead), ITEM_SLOT_BACK)
	undead.equip_to_slot_or_del(new /obj/item/clothing/under/costume/skeleton(undead), ITEM_SLOT_ICLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/chaplain_hoodie(undead), ITEM_SLOT_OCLOTHING)
	undead.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(undead), ITEM_SLOT_FEET)
	if(GLOB.religion)
		var/obj/item/book/bible/B = new
		undead.mind?.holy_role = HOLY_ROLE_PRIEST
		B.deity_name = GLOB.deity
		B.name = GLOB.bible_name
		B.icon_state = GLOB.bible_icon_state
		B.inhand_icon_state = GLOB.bible_inhand_icon_state
		to_chat(undead, "There is already an established religion onboard the station. You are an acolyte of [GLOB.deity]. Defer to the Chaplain.")
		undead.equip_to_slot_or_del(B, ITEM_SLOT_BACKPACK)
		GLOB.religious_sect?.on_conversion(undead)
	if(is_special_character(user))
		to_chat(undead, span_userdanger("You are grateful to have been summoned into this word by [user]. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost."))
	else
		to_chat(undead, span_boldnotice("You are grateful to have been summoned into this world. You are now a member of this station's crew, Try not to cause any trouble."))
	playsound(altar_turf, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg',), 50, TRUE)
	return ..()

/datum/religion_rites/raise_dead
	name = "Raise Dead"
	desc = "Revives a buckled dead creature or person."
	ritual_length = 40 SECONDS
	ritual_invocations = list(
		"Rejoin our world...",
		"... come forth from the beyond...",
		"... fresh life awaits you...",
		"... return to us...",
		"... by the power granted by the gods...",
		"... you shall rise again...",
	)
	invoke_msg = "Welcome back to the mortal plain."
	favor_cost = 1250

///the target
	var/mob/living/carbon/human/raise_target

/datum/religion_rites/raise_dead/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/mob/living/carbon/r_target in movable_reltool.buckled_mobs)
		if(!iscarbon(r_target))
			to_chat(user, span_warning("Only carbon lifeforms can be properly resurrected!"))
			return FALSE
		if(r_target.stat != DEAD)
			to_chat(user, span_warning("You can only resurrect dead bodies, this one is still alive!"))
			return FALSE
		if(!r_target.mind)
			to_chat(user, span_warning("This creature has no connected soul..."))
			return FALSE
		if(tgui_alert(r_target, "Accept revival? You will become a high functioning zombie", "You feel a holy power drawing you back to your body", list("Yes", "No")) != "Yes")
			return FALSE
		raise_target = r_target
		raise_target.notify_ghost_cloning("Your soul is being summoned back to your body by mystical power!", source = src)
		return ..()

/datum/religion_rites/raise_dead/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(raise_target in religious_tool.buckled_mobs))
		to_chat(user, span_warning("The body is no longer on the altar!"))
		raise_target = null
		return FALSE
	if(!raise_target.mind)
		to_chat(user, span_warning("This creature's soul has left the pool..."))
		raise_target = null
		return FALSE
	if(raise_target.stat != DEAD)
		to_chat(user, span_warning("The target has to stay dead for the rite to work! If they came back without your spiritual guidence... Who knows what could happen!?"))
		raise_target = null
		return FALSE
	raise_target.grab_ghost() // Shove them back in their body.
	raise_target.revive(HEAL_ALL)
	raise_target.set_species(/datum/species/zombie)
	playsound(altar_turf, 'sound/magic/staff_healing.ogg', 50, TRUE)
	raise_target = null
	return ..()

/datum/religion_rites/sacrifice
	name = "Living Sacrifice"
	desc = "Sacrifice a non-sentient buckled creature for favor, dead or alive based on how much vitality it had."
	ritual_length = 25 SECONDS
	ritual_invocations = list(
		"To offer this being unto the gods ...",
		"... to feed them with its soul ...",
		"... so that they may consume all within their path ...",
		"... release their binding on this mortal plane ...",
		"... I offer you this living being ...",
	)
	invoke_msg = "... may it join the horde of undead, and become one with the souls of the damned. "
//the living creature chosen for the sacrifice of the rite
	var/mob/living/chosen_sacrifice

/datum/religion_rites/sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!religious_tool || !ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!length(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/mob/living/creature in movable_reltool.buckled_mobs)
		chosen_sacrifice = creature
		if(chosen_sacrifice.mind)
			to_chat(user, span_warning("This sacrifice is sentient! [GLOB.deity] will not accept this offering."))
			chosen_sacrifice = null
			return FALSE
		if(chosen_sacrifice.flags_1 & HOLOGRAM_1)
			to_chat(user, span_warning("You cannot sacrifice this. It is not made of flesh!"))
			chosen_sacrifice = null
			return FALSE
		if(iscarbon(creature))
			cuff(creature)
		return ..()

/datum/religion_rites/sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/turf/altar_turf = get_turf(religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right creature is still buckled
		to_chat(user, span_warning("The right sacrifice is no longer on the altar!"))
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = chosen_sacrifice.maxHealth / 2 + 100 // get at least 100 favor
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	new /obj/effect/temp_visual/cult/blood/out(altar_turf)
	to_chat(user, span_notice("[GLOB.deity] absorbs [chosen_sacrifice], leaving blood and gore in its place. [GLOB.deity] rewards you with [favor_gained] favor."))
	chosen_sacrifice.gib(TRUE, FALSE, TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/bamf.ogg', 50, TRUE)
	chosen_sacrifice = null
	return ..()

/datum/religion_rites/sacrifice/proc/cuff(mob/living/carbon/C)
	if(C.handcuffed)
		return
	C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult(C)
	C.update_handcuffed()
	playsound(C, 'sound/magic/smoke.ogg', 50, 1)
	C.visible_message(span_warning("Darkness forms around [C]'s wrists as shadowy bindings appear on them!"))
