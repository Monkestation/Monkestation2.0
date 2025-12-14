//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone
	name = "Generic Stone"
	icon = 'monkestation/icons/obj/infinity.dmi'
	icon_state = "stone"
	w_class = WEIGHT_CLASS_SMALL
	var/mob/living/current_holder
	var/mob/living/aura_holder
	var/mob/living/last_holder
	var/stone_type = ""
	var/list/ability_text = list()
	var/list/spells = list()
	var/list/gauntlet_spells = list()
	var/list/stone_spells = list()
	var/list/spell_types = list()
	var/list/gauntlet_spell_types = list()
	var/list/stone_spell_types = list()
	var/mutable_appearance/aura_overlay

/obj/item/badmin_stone/Initialize(mapload)
	. = ..()
	for(var/spell_type in spell_types)
		spells += new spell_type(src)
	for(var/gauntlet_spell_type in gauntlet_spell_types)
		gauntlet_spells += new gauntlet_spell_type(src)
	for(var/stone_spell_type in stone_spell_types)
		stone_spells += new stone_spell_type(src)
	AddComponent(/datum/component/stationloving, TRUE)
	START_PROCESSING(SSobj, src)
	SSpoints_of_interest.make_point_of_interest(src)
	aura_overlay = mutable_appearance('monkestation/icons/obj/infinity.dmi', "aura", -MUTATIONS_LAYER)
	aura_overlay.color = color

/obj/item/badmin_stone/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/badmin_stone/examine(mob/user)
	. = ..()
	. += span_bold("[name]")
	for(var/ability in ability_text)
		. += span_notice("[ability]")

/obj/item/badmin_stone/proc/force_drop_stone(mob/user)
	user.dropItemToGround(src, TRUE)
	forceMove(get_turf(user))

/obj/item/badmin_stone/proc/give_abilities(mob/living/living_mob, gauntlet = FALSE)
	for(var/datum/action/cooldown/spell/spell in spells)
		spell.Grant(living_mob)
	if(gauntlet)
		for(var/datum/action/cooldown/spell/spell in gauntlet_spells)
			spell.Grant(living_mob)
	else
		for(var/datum/action/cooldown/spell/spell in stone_spells)
			spell.Grant(living_mob)

/obj/item/badmin_stone/proc/remove_abilities(mob/living/living_mob)
	for(var/datum/action/cooldown/spell/spell in spells + gauntlet_spells)
		spell.Remove(living_mob)

/obj/item/badmin_stone/proc/give_visual_effects(mob/living/living_mob)
	living_mob.add_overlay(aura_overlay)

/obj/item/badmin_stone/proc/give_status_effect(mob/living/target)
	if(istype(loc, /obj/item/badmin_gauntlet))
		return
	target.apply_status_effect(/datum/status_effect/badmin_stone, src)

/obj/item/badmin_stone/proc/take_visual_effects(mob/living/living_mob)
	living_mob.cut_overlay(aura_overlay)

/obj/item/badmin_stone/proc/take_status_effect(mob/living/target)
	var/list/effects = target.has_status_effect_list(/datum/status_effect/badmin_stone)
	var/datum/status_effect/badmin_stone/badmin_status_effect
	for(var/datum/status_effect/badmin_stone/status_effect in effects)
		if(status_effect.stone == src)
			badmin_status_effect = status_effect
			break
	if(badmin_status_effect)
		qdel(badmin_status_effect)

/obj/item/badmin_stone/proc/get_holder()
	return isliving(loc) ? loc : null

/obj/item/badmin_stone/proc/get_aura_holder()
	return recursive_loc_check(src, /mob/living)

/obj/item/badmin_stone/process(delta_time)
	update_holder()

/obj/item/badmin_stone/proc/update_holder()
	if(istype(loc, /obj/item/badmin_gauntlet))
		return
	var/mob/living/new_holder = get_holder()
	var/mob/living/new_aura_holder = get_aura_holder()
	if(new_holder != current_holder)
		if(isliving(current_holder))
			remove_abilities(current_holder)
		if(isliving(new_holder))
			if(loc == new_holder)
				give_abilities(new_holder)
			current_holder = new_holder
		else
			current_holder = null
	if(new_aura_holder != last_holder && isliving(new_aura_holder))
		log_game("[src] has a new holder: [ADMIN_LOOKUPFLW(new_aura_holder)]!")
		message_admins("[src] has a new holder: [key_name(new_aura_holder)]!")
	if(new_aura_holder != aura_holder)
		if(isliving(aura_holder))
			take_visual_effects(aura_holder)
			take_status_effect(aura_holder)
		if(isliving(new_aura_holder))
			give_visual_effects(new_aura_holder)
			give_status_effect(new_aura_holder)
			aura_holder = new_aura_holder
			last_holder = new_aura_holder
		else
			aura_holder = null

/obj/item/badmin_stone/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!isliving(user) || istype(target, /obj/item/badmin_gauntlet))
		return
	switch(user.istate)
		if(ISTATE_SECONDARY)
			disarm_act(target, user, proximity_flag)
		if(ISTATE_HARM)
			harm_act(target, user, proximity_flag)
		else
			help_act(target, user, proximity_flag)

/obj/item/badmin_stone/proc/disarm_act(atom/target, mob/living/user, proximity_flag)

/obj/item/badmin_stone/proc/harm_act(atom/target, mob/living/user, proximity_flag)

/obj/item/badmin_stone/proc/help_act(atom/target, mob/living/user, proximity_flag)

/datum/action/cooldown/spell/infinity
	button_icon = 'monkestation/icons/obj/infinity.dmi'
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/pointed/infinity
	button_icon = 'monkestation/icons/obj/infinity.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
