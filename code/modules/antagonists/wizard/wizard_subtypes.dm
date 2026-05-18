/datum/antagonist/wizard/apprentice
	name = "Wizard Apprentice"
	antag_hud_name = "apprentice"
	can_assign_self_objectives = FALSE
	move_to_lair = FALSE
	var/datum/mind/master
	var/school = APPRENTICE_DESTRUCTION
	outfit_type = /datum/outfit/wizard/apprentice
	wiz_age = APPRENTICE_AGE_MIN

/datum/antagonist/wizard/apprentice/greet()
	to_chat(owner, "<B>You are [master.current.real_name]'s apprentice! You are bound by magic contract to follow [master.p_their()] orders and help [master.p_them()] in accomplishing [master.p_their()] goals.")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/assign_ritual()
	return // Haven't learned how to do it yet

/datum/antagonist/wizard/apprentice/equip_wizard()
	. = ..()
	if(!ishuman(owner.current))
		return

	var/list/spells_to_grant = list()
	var/list/items_to_grant = list()

	switch(school)
		if(APPRENTICE_DESTRUCTION)
			spells_to_grant = list(
				/datum/action/cooldown/spell/aoe/magic_missile,
				/datum/action/cooldown/spell/pointed/projectile/fireball,
			)
			to_chat(owner, span_bold("Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned powerful, \
				destructive spells. You are able to cast magic missile and fireball."))

		if(APPRENTICE_BLUESPACE)
			spells_to_grant = list(
				/datum/action/cooldown/spell/teleport/area_teleport/wizard,
				/datum/action/cooldown/spell/jaunt/ethereal_jaunt,
			)
			to_chat(owner, span_bold("Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned reality-bending \
				mobility spells. You are able to cast teleport and ethereal jaunt."))

		if(APPRENTICE_HEALING)
			spells_to_grant = list(
				/datum/action/cooldown/spell/charge,
				/datum/action/cooldown/spell/forcewall,
			)
			items_to_grant = list(
				/obj/item/gun/magic/staff/healing,
			)
			to_chat(owner, span_bold("Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned life-saving \
				survival spells. You are able to cast charge and forcewall, and have a staff of healing."))
		if(APPRENTICE_ROBELESS)
			spells_to_grant = list(
				/datum/action/cooldown/spell/aoe/knock,
				/datum/action/cooldown/spell/pointed/mind_transfer,
			)
			to_chat(owner, span_bold("Your service has not gone unrewarded, however. \
				Studying under [master.current.real_name], you have learned stealthy, \
				robeless spells. You are able to cast knock and mindswap."))

	for(var/spell_type in spells_to_grant)
		var/datum/action/cooldown/spell/new_spell = new spell_type(owner)
		new_spell.Grant(owner.current)

	for(var/item_type in items_to_grant)
		var/obj/item/new_item = new item_type(owner.current)
		owner.current.put_in_hands(new_item)

/datum/antagonist/wizard/apprentice/create_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = owner
	new_objective.target = master
	new_objective.explanation_text = "Protect [master.current.real_name], the wizard."
	objectives += new_objective

//Random event wizard
/datum/antagonist/wizard/apprentice/imposter
	name = "Wizard Imposter"
	show_in_antagpanel = FALSE
	allow_rename = FALSE

/datum/antagonist/wizard/apprentice/imposter/greet()
	. = ..()
	to_chat(owner, "<B>Trick and confuse the crew to misdirect malice from your handsome original!</B>")
	owner.announce_objectives()

/datum/antagonist/wizard/apprentice/imposter/equip_wizard()
	var/mob/living/carbon/human/master_mob = master.current
	var/mob/living/carbon/human/current = owner.current
	if(!istype(master_mob) || !istype(current))
		return

	if(master_mob.ears)
		current.equip_to_slot_or_del(new master_mob.ears.type, ITEM_SLOT_EARS)
	if(master_mob.w_uniform)
		current.equip_to_slot_or_del(new master_mob.w_uniform.type, ITEM_SLOT_ICLOTHING)
	if(master_mob.shoes)
		current.equip_to_slot_or_del(new master_mob.shoes.type, ITEM_SLOT_FEET)
	if(master_mob.wear_suit)
		current.equip_to_slot_or_del(new master_mob.wear_suit.type, ITEM_SLOT_OCLOTHING)
	if(master_mob.head)
		current.equip_to_slot_or_del(new master_mob.head.type, ITEM_SLOT_HEAD)
	if(master_mob.back)
		current.equip_to_slot_or_del(new master_mob.back.type, ITEM_SLOT_BACK)

	//Operation: Fuck off and scare people
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = new(owner)
	jaunt.Grant(current)
	var/datum/action/cooldown/spell/teleport/area_teleport/wizard/teleport = new(owner)
	teleport.Grant(current)
	var/datum/action/cooldown/spell/teleport/radius_turf/blink/blink = new(owner)
	blink.Grant(current)

/datum/antagonist/wizard/swapper
	name = "Swapper"
	antag_hud_name = "apprentice"
	show_in_antagpanel = FALSE
	allow_rename = FALSE
	move_to_lair = FALSE
	can_assign_self_objectives = FALSE
	outfit_type = /datum/outfit/wizard/apprentice
	wiz_age = APPRENTICE_AGE_MIN

/datum/antagonist/wizard/swapper/create_objectives()
	var/datum/objective/protect/new_objective = new /datum/objective
	new_objective.owner = owner
	new_objective.explanation_text = "Scramble the minds of as people people as possible."
	objectives += new_objective

/datum/antagonist/wizard/swapper/assign_ritual()
	return //spawning extra ritual doers would be bad

/datum/antagonist/wizard/swapper/equip_wizard()
	. = ..()
	var/mob/living/carbon/human/current = owner.current
	if(!istype(current))
		return

	var/datum/action/cooldown/spell/aoe/mind_swap/swapper/swap = new(owner)
	swap.Grant(current)

/datum/antagonist/wizard/academy
	name = "Academy Teacher"
	show_in_antagpanel = FALSE
	outfit_type = /datum/outfit/wizard/academy
	move_to_lair = FALSE
	can_assign_self_objectives = FALSE

/datum/antagonist/wizard/academy/assign_ritual()
	return // Has other duties to be getting on with

/datum/antagonist/wizard/academy/equip_wizard()
	. = ..()
	if(!isliving(owner.current))
		return
	var/mob/living/living_current = owner.current

	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = new(owner)
	jaunt.Grant(living_current)
	var/datum/action/cooldown/spell/aoe/magic_missile/missile = new(owner)
	missile.Grant(living_current)
	var/datum/action/cooldown/spell/pointed/projectile/fireball/fireball = new(owner)
	fireball.Grant(living_current)

	var/obj/item/implant/exile/exiled = new /obj/item/implant/exile(living_current)
	exiled.implant(living_current)

/datum/antagonist/wizard/academy/create_objectives()
	var/datum/objective/new_objective = new("Protect Wizard Academy from the intruders")
	new_objective.owner = owner
	objectives += new_objective
