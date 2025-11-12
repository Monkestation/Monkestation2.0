/obj/item/necromantic_stone
	name = "necromantic stone"
	desc = "A shard capable of resurrecting humans as skeleton thralls."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "necrostone"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/spooky_scaries = list()
	///Allow for unlimited thralls to be produced.
	var/unlimited = FALSE
	///Which species the resurected humanoid will be.
	var/applied_species = /datum/species/skeleton
	///The outfit the resurected humanoid will wear.
	var/applied_outfit = /datum/outfit/roman
	///Maximum number of thralls that can be created.
	var/max_thralls = 3

/obj/item/necromantic_stone/unlimited
	unlimited = 1

/obj/item/necromantic_stone/attack(mob/living/carbon/human/target, mob/living/carbon/human/user)
	if(!istype(target))
		return ..()

	if(!istype(user) || !user.can_perform_action(target))
		return

	if(target.stat != DEAD)
		to_chat(user, span_warning("This artifact can only affect the dead!"))
		return

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list) //excludes new players
		if(ghost.mind && ghost.mind.current == target && ghost.client)  //the dead mobs list can contain clientless mobs
			ghost.reenter_corpse()
			break

	if(!target.mind || !target.client)
		to_chat(user, span_warning("There is no soul connected to this body..."))
		return

	check_spooky()//clean out/refresh the list
	if(spooky_scaries.len >= max_thralls && !unlimited)
		to_chat(user, span_warning("This artifact can only affect [convert_integer_to_words(max_thralls)] thralls at a time!"))
		return
	if(applied_species)
		target.set_species(applied_species, icon_update=0)
	target.revive(ADMIN_HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	spooky_scaries |= target
	to_chat(target, span_userdanger("You have been revived by <B>[user.real_name]</B>!"))
	to_chat(target, span_userdanger("[user.p_theyre(TRUE)] your master now, assist [user.p_them()] even if it costs you your new life!"))
	var/datum/antagonist/wizard/antag_datum = user.mind.has_antag_datum(/datum/antagonist/wizard)
	if(antag_datum)
		if(!antag_datum.wiz_team)
			antag_datum.create_wiz_team()
		target.mind.add_antag_datum(/datum/antagonist/wizard_minion, antag_datum.wiz_team)

	equip_revived_servant(target)

/obj/item/necromantic_stone/examine(mob/user)
	. = ..()
	if(!unlimited)
		. += span_notice("[spooky_scaries.len]/[max_thralls] active thralls.")

/obj/item/necromantic_stone/proc/check_spooky()
	if(unlimited) //no point, the list isn't used.
		return

	for(var/X in spooky_scaries)
		if(!ishuman(X))
			spooky_scaries.Remove(X)
			continue
		var/mob/living/carbon/human/H = X
		if(H.stat == DEAD)
			H.dust(TRUE)
			spooky_scaries.Remove(X)
			continue
	list_clear_nulls(spooky_scaries)

/obj/item/necromantic_stone/proc/equip_revived_servant(mob/living/carbon/human/human)
	if(!applied_outfit)
		return
	for(var/obj/item/worn_item in human)
		human.dropItemToGround(worn_item)

	human.equipOutfit(applied_outfit)

//Funny gimmick, skeletons always seem to wear roman/ancient armour
/datum/outfit/roman
	name = "Roman"
	head = /obj/item/clothing/head/helmet/roman
	uniform = /obj/item/clothing/under/costume/roman
	shoes = /obj/item/clothing/shoes/roman
	back = /obj/item/spear
	r_hand = /obj/item/claymore
	l_hand = /obj/item/shield/roman

/datum/outfit/roman/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	head = pick(/obj/item/clothing/head/helmet/roman, /obj/item/clothing/head/helmet/roman/legionnaire)
