/datum/species/golem/bone
	name = "Bone Golem"
	id = SPECIES_GOLEM_BONE
	prefix = "Bone"
	special_names = list("Head", "Broth", "Fracture", "Rattler", "Appetit")
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/internal/tongue/bone
	mutantstomach = /obj/item/organ/internal/stomach/bone
	sexes = FALSE
	fixed_mut_color = null
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_NOBREATH,
		TRAIT_NOFIRE,
		TRAIT_NODISMEMBER,
		TRAIT_NOFLASH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBLOOD,
	)
	species_language_holder = /datum/language_holder/golem/bone
	info_text = "As a <span class='danger'>Bone Golem</span>, You have a powerful spell that lets you chill your enemies with fear, and milk heals you! Just make sure to watch our for bone-hurting juice."
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/golem/bone,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/golem/bone,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/golem/bone,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/golem/bone,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/golem/bone,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/golem/bone,
	)
	var/datum/action/innate/bonechill/bonechill

/datum/species/golem/bone/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		bonechill = new
		bonechill.Grant(C)

/datum/species/golem/bone/on_species_loss(mob/living/carbon/C)
	if(bonechill)
		bonechill.Remove(C)
	..()

/datum/species/golem/bone/handle_chemical(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	if(chem.type == /datum/reagent/toxin/bonehurtingjuice)
		H.stamina.adjust(-7.5 * REM * seconds_per_tick, 0)
		H.adjustBruteLoss(0.5 * REM * seconds_per_tick, 0)
		if(SPT_PROB(10, seconds_per_tick))
			switch(rand(1, 3))
				if(1)
					H.say(pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = /datum/reagent/toxin/bonehurtingjuice)
				if(2)
					H.manual_emote(pick("oofs silently.", "looks like [H.p_their()] bones hurt.", "grimaces, as though [H.p_their()] bones hurt."))
				if(3)
					to_chat(H, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(SPT_PROB(2, seconds_per_tick) && iscarbon(H)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly.
				var/obj/item/bodypart/bp = H.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bp)
					playsound(H, get_sfx(SFX_DESECRATION), 50, TRUE, -1) //You just want to socialize
					H.visible_message(span_warning("[H] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					H.say("OOF!!", forced=/datum/reagent/toxin/bonehurtingjuice)
					bp.receive_damage(200, 0, 0) //But I don't think we should
				else
					to_chat(H, span_warning("Your missing arm aches from wherever you left it."))
					H.emote("sigh")
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * seconds_per_tick)
		return TRUE

/datum/action/innate/bonechill
	name = "Bone Chill"
	desc = "Rattle your bones and strike fear into your enemies!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "bonechill"
	var/cooldown = 600
	var/last_use
	var/snas_chance = 3

/datum/action/innate/bonechill/Activate()
	if(world.time < last_use + cooldown)
		to_chat(owner, span_warning("You aren't ready yet to rattle your bones again!"))
		return
	owner.visible_message(span_warning("[owner] rattles [owner.p_their()] bones harrowingly."), span_notice("You rattle your bones"))
	last_use = world.time
	if(prob(snas_chance))
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES2.ogg', 100)
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/mutable_appearance/badtime = mutable_appearance('icons/mob/species/human/bodyparts.dmi', "b_golem_eyes", -HIGHEST_LAYER-0.5)
			badtime.appearance_flags = RESET_COLOR
			H.overlays_standing[HIGHEST_LAYER+0.5] = badtime
			H.apply_overlay(HIGHEST_LAYER+0.5)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/, remove_overlay), HIGHEST_LAYER+0.5), 25)
	else
		playsound(get_turf(owner),'sound/magic/RATTLEMEBONES.ogg', 100)
	for(var/mob/living/L in orange(7, get_turf(owner)))
		if((L.mob_biotypes & MOB_UNDEAD) || isgolem(L) || HAS_TRAIT(L, TRAIT_RESISTCOLD))
			continue //Do not affect our brothers

		to_chat(L, span_cultlarge("A spine-chilling sound chills you to the bone!"))
		L.apply_status_effect(/datum/status_effect/bonechill)
		L.add_mood_event("spooked", /datum/mood_event/spooked)
