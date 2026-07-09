#define MINIMUM_YUCK_REQUIRED 5

/datum/religion_sect/maintenance
	name = "Maintenance"
	quote = "Your kingdom in the darkness."
	desc = "Sacrifice the organic slurry created from rats dipped in welding fuel to gain favor. Exchange favor to adapt to the maintenance shafts."
	tgui_icon = "eye"
	altar_icon_state = "convertaltar-maint"
	alignment = ALIGNMENT_EVIL //while maint is more neutral in my eyes, the flavor of it kinda pertains to rotting and becoming corrupted by the maints
	rites_list = list(/datum/religion_rites/maint_adaptation, /datum/religion_rites/adapted_eyes, /datum/religion_rites/adapted_food, /datum/religion_rites/ritual_totem)
	desired_items = list(/obj/item/reagent_containers = "holding organic slurry")

/datum/religion_sect/maintenance/sect_bless(mob/living/blessed_living, mob/living/chap)
	if(!ishuman(blessed_living))
		return TRUE
	var/mob/living/carbon/human/blessed = blessed_living
	if(blessed.reagents.has_reagent(/datum/reagent/drug/maint/sludge))
		to_chat(blessed, span_warning("[GLOB.deity] has already empowered them."))
		return TRUE
	blessed.reagents.add_reagent(/datum/reagent/drug/maint/sludge, 5)
	blessed.visible_message(span_notice("[chap] empowers [blessed] with the power of [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("The power of [GLOB.deity] has made you harder to wound for a while!"))
	playsound(chap, SFX_PUNCH, 25, TRUE, -1)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return TRUE //trust me, you'll be feeling the pain from the maint drugs all well enough

/datum/religion_sect/maintenance/on_sacrifice(obj/item/reagent_containers/offering, mob/living/user)
	if(!istype(offering))
		return
	var/datum/reagent/yuck/wanted_yuck = offering.reagents.has_reagent(/datum/reagent/yuck, MINIMUM_YUCK_REQUIRED)
	var/favor_earned = offering.reagents.get_reagent_amount(/datum/reagent/yuck)
	if(!wanted_yuck)
		to_chat(user, span_warning("[offering] does not have enough organic slurry for [GLOB.deity] to enjoy."))
		return
	to_chat(user, span_notice("[GLOB.deity] loves organic slurry."))
	adjust_favor(favor_earned, user)
	playsound(get_turf(offering), 'sound/items/drink.ogg', 50, TRUE)
	offering.reagents.clear_reagents()
	return TRUE

/*********Maintenance God**********/

/datum/religion_rites/maint_adaptation
	name = "Maintenance Adaptation"
	desc = "Begin your metamorphasis into a being more fit for Maintenance."
	ritual_length = 10 SECONDS
	ritual_invocations = list(
		"I abandon the world ...",
		"... to become one with the deep.",
		"My form will become twisted ...",
	)
	invoke_msg = "... but my smile I will keep!"
	favor_cost = 150 //150u of organic slurry

/datum/religion_rites/maint_adaptation/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	//uses HAS_TRAIT_FROM because junkies are also hopelessly addicted
	if(HAS_TRAIT_FROM(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation"))
		to_chat(user, span_warning("You've already adapted.</b>"))
		return FALSE
	return ..()

/datum/religion_rites/maint_adaptation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	to_chat(user, span_warning("You feel your genes rattled and reshaped. <b>You're becoming something new.</b>"))
	user.emote("laugh")
	ADD_TRAIT(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation")
	//addiction sends some nasty mood effects but we want the maint adaption to be enjoyed like a fine wine
	user.add_mood_event("maint_adaptation", /datum/mood_event/maintenance_adaptation)
	if(iscarbon(user))
		var/mob/living/carbon/vomitorium = user
		vomitorium.vomit()
		var/datum/dna/dna = vomitorium.has_dna()
		dna?.add_mutation(/datum/mutation/stimmed, MUTATION_SOURCE_MAINT_ADAPT) //some fluff mutations
		dna?.add_mutation(/datum/mutation/strong, MUTATION_SOURCE_MAINT_ADAPT)
	user.mind.add_addiction_points(/datum/addiction/maintenance_drugs, 1000)//ensure addiction

/datum/religion_rites/adapted_eyes
	name = "Adapted Eyes"
	desc = "Only available after maintenance adaptation. Your eyes will adapt as well, becoming useless in the light."
	ritual_length = 10 SECONDS
	invoke_msg = "I no longer want to see the light."
	favor_cost = 300 //300u of organic slurry, i'd consider this a reward of the sect

/datum/religion_rites/adapted_eyes/perform_rite(mob/living/carbon/human/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	if(!HAS_TRAIT_FROM(user, TRAIT_HOPELESSLY_ADDICTED, "maint_adaptation"))
		to_chat(user, span_warning("You need to adapt to maintenance first."))
		return FALSE
	var/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/adapted = user.get_organ_slot(ORGAN_SLOT_EYES)
	if(adapted && istype(adapted))
		to_chat(user, span_warning("Your eyes are already adapted!"))
		return FALSE
	return ..()

/datum/religion_rites/adapted_eyes/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	. = ..()
	var/obj/item/organ/internal/eyes/oldeyes = user.get_organ_slot(ORGAN_SLOT_EYES)
	to_chat(user, span_warning("You feel your eyes adapt to the darkness!"))
	if(oldeyes)
		oldeyes.Remove(user, special = TRUE)
		qdel(oldeyes)//eh
	var/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/neweyes = new
	neweyes.Insert(user, special = TRUE)

/datum/religion_rites/adapted_food
	name = "Moldify"
	desc = "Once adapted to the Maintenance, you will not be able to eat regular food. This should help."
	ritual_length = 5 SECONDS
	invoke_msg = "Moldify!"
	favor_cost = 5 //5u of organic slurry
	///the food that will be molded, only one per rite
	var/obj/item/food/mold_target

/datum/religion_rites/adapted_food/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/food/could_mold in get_turf(religious_tool))
		if(istype(could_mold, /obj/item/food/badrecipe/moldy))
			continue
		mold_target = could_mold //moldify this o great one
		return ..()
	to_chat(user, span_warning("You need to place food on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/adapted_food/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/obj/item/food/moldify = mold_target
	mold_target = null
	if(QDELETED(moldify) || !(get_turf(religious_tool) == moldify.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[moldify] becomes rancid!"))
	user.emote("laugh")
	new /obj/item/food/badrecipe/moldy(get_turf(religious_tool))
	qdel(moldify)
	return TRUE

/datum/religion_rites/ritual_totem
	name = "Create Ritual Totem"
	desc = "Creates a Ritual Totem, a portable tool for performing rites on the go. Requires wood. Can only be picked up by the holy."
	favor_cost = 100
	invoke_msg = "Padala!!"
	///the food that will be molded, only one per rite
	var/obj/item/stack/sheet/mineral/wood/converted

/datum/religion_rites/ritual_totem/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/stack/sheet/mineral/wood/could_totem in get_turf(religious_tool))
		converted = could_totem //totemify this o great one
		return ..()
	to_chat(user, span_warning("You need at least 1 wood to do this!"))
	return FALSE

/datum/religion_rites/ritual_totem/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	var/obj/item/stack/sheet/mineral/wood/padala = converted
	converted = null
	if(QDELETED(padala) || !(get_turf(religious_tool) == padala.loc)) //check if the same food is still there
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[padala] reshapes into a totem!"))
	if(!padala.use(1))//use one wood
		return
	user.emote("laugh")
	new /obj/item/ritual_totem(altar_turf)
	return TRUE

#undef MINIMUM_YUCK_REQUIRED
