/**** Mechanical God ****/

/datum/religion_sect/mechanical
	name = "Mechanical"
	quote = "May you find peace in a metal shell."
	desc = "Bibles now recharge cyborgs and heal robotic limbs if targeted, but they \
	do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	tgui_icon = "robot"
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/power_store/cell = "with battery charge")
	rites_list = list(/datum/religion_rites/synthconversion, /datum/religion_rites/machine_blessing)
	altar_icon_state = "convertaltar-blue"
	max_favor = 2500

/datum/religion_sect/mechanical/sect_bless(mob/living/target, mob/living/chap)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/blessed = target

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/internal/stomach/ethereal/eth_stomach = blessed.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(60)
		did_we_charge = TRUE

	//if we're not targeting a robot part we stop early
	var/obj/item/bodypart/bodypart = blessed.get_bodypart(chap.zone_selected)
	if(!IS_ORGANIC_LIMB(bodypart))
		if(!did_we_charge)
			to_chat(chap, span_warning("[GLOB.deity] scoffs at the idea of healing such fleshy matter!"))
		else
			blessed.visible_message(span_notice("[chap] charges [blessed] with the power of [GLOB.deity]!"))
			to_chat(blessed, span_boldnotice("You feel charged by the power of [GLOB.deity]!"))
			blessed.add_mood_event("blessing", /datum/mood_event/blessing)
			playsound(chap, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(bodypart.heal_damage(5,5,BODYTYPE_ROBOTIC))
		blessed.update_damage_overlays()

	blessed.visible_message(span_notice("[chap] [did_we_charge ? "repairs" : "repairs and charges"] [blessed] with the power of [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!"))
	playsound(chap, 'sound/effects/bang.ogg', 25, TRUE, -1)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/mechanical/on_sacrifice(obj/item/I, mob/living/chap)
	var/obj/item/stock_parts/power_store/cell/the_cell = I
	if(!istype(the_cell)) //how...
		return
	if(the_cell.charge < 300)
		to_chat(chap,span_notice("[GLOB.deity] does not accept pity amounts of power."))
		return
	adjust_favor(round(the_cell.charge/300), chap)
	to_chat(chap, span_notice("You offer [the_cell]'s power to [GLOB.deity], pleasing them."))
	qdel(I)
	return TRUE

/**** Mechanical God ****/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android. Buckle a human to convert them, otherwise it will convert you."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
		"By the inner workings of our god ...",
		"... We call upon you, in the face of adversity ...",
		"... to complete us, removing that which is undesirable ...",
	)
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 1000

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to convert the one buckled on [movable_reltool]."))
		return ..()

	if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	if(isandroid(user))
		to_chat(user, span_warning("You've already converted yourself. To convert others, they must be buckled to [movable_reltool]."))
		return FALSE
	to_chat(user, span_warning("You're going to convert yourself with this ritual."))
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.set_species(/datum/species/android)
	rite_target.visible_message(span_notice("[rite_target] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations = list(
		"Let your will power our forges.",
		"...Help us in our great conquest!",
	)
	invoke_msg = "The end of flesh is near!"
	favor_cost = 2000

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
		/obj/item/organ/internal/cyberimp/arm/item_set/surgery,
		/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/chest/thrusters,
		/obj/item/organ/internal/eyes/robotic/glow,
	)
	new blessing(altar_turf)
	return TRUE
