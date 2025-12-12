//Snowflake spot for putting sling organ related stuff
/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	w_class = 1
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN_TUMOR
	///How many process ticks the organ can be in light before it evaporates
	var/organ_health = 3
	///Cached darkspawn team that gets the willpower
	var/datum/team/darkspawn/antag_team
	///How much willpower is granted by this tumor
	var/willpower_amount = 1

/obj/item/organ/internal/shadowtumor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/shadowtumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	antag_team = null
	return ..()

/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = GET_SIMPLE_LUMCOUNT(T)
		if(light_count > SHADOW_SPECIES_DIM_LIGHT) //Die in the light
			if(organ_health > 0)
				organ_health--
		else //Heal in the dark
			if(organ_health < 3)
				organ_health = min(organ_health + 1, 3)
		if(organ_health <= 0)
			visible_message(span_warning("[src] collapses in on itself!"))
			qdel(src)
	else
		organ_health = min(organ_health+0.5, 3)
	if(owner && owner.stat != DEAD && antag_team)
		antag_team.willpower_progress(willpower_amount)

/obj/item/organ/internal/shadowtumor/on_find(mob/living/finder)
	. = ..()
	finder.visible_message(span_danger("[finder] opens up [owner]'s skull, revealing a pulsating black mass, with red tendrils attaching it to [owner.p_their()] brain."))

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Thrall version------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/internal/shadowtumor/thrall
	//provides extra willpower because willpower was spent to thrall someone
	willpower_amount = 2
	///adds a cooldown to the resist so a thrall ipc or preternis can't weaponize it
	COOLDOWN_DECLARE(resist_cooldown)
	///How long the resist cooldown is
	var/cooldown_length = 15 SECONDS

/obj/item/organ/internal/shadowtumor/thrall/process()
	if(!IS_THRALL(owner))
		qdel(src)
		return
	return ..()

/obj/item/organ/internal/shadowtumor/thrall/proc/resist(mob/living/carbon/angery)
	if(QDELETED(src))
		return FALSE
	if(angery.stat != CONSCIOUS)//Thralls cannot be deconverted while awake
		return FALSE
	if(angery.handcuffed && angery.buckled)//Thralls cannot be deconverted while uncontained.
		angery.visible_message(span_userdanger("[angery] suddenly slams upward, thrashing against their restraints."))
		return FALSE
	if(!IS_THRALL(angery))//non thralls don't resist
		return FALSE
	if(!COOLDOWN_FINISHED(src, resist_cooldown))//adds a cooldown to the resist so a thrall ipc or preternis can't weaponize it
		return FALSE
	COOLDOWN_START(src, resist_cooldown, cooldown_length)

	playsound(angery, 'sound/effects/tendril_destroyed.ogg', vol = 80, vary = TRUE)
	angery.visible_message(
		span_userdanger("[angery] suddenly slams upward, violently knocking everyone back!"),
		span_progenitor(span_bolditalic("NOT LIKE THIS!")),
		span_hear("You hear a massive, violent thump!"),
	)
	angery.uncuff()
	angery.buckled?.unbuckle_mob(angery)
	angery.stamina?.revitalize(forced = TRUE)
	angery.SetAllImmobility(0)
	angery.set_resting(FALSE, instant = TRUE)
	for(var/mob/living/victim in range(2, get_turf(src)) - angery)
		if(IS_TEAM_DARKSPAWN(victim))
			continue
		var/turf/target = get_ranged_target_turf(victim, get_dir(angery, victim))
		victim.throw_at(target, 2, 2, angery)
		victim.take_overall_damage(brute = 20)
		victim.Knockdown(4 SECONDS)
		victim.set_confusion_if_lower(15 SECONDS)
		if(issilicon(victim))
			playsound(victim, 'sound/effects/bang.ogg', vol = 50, vary = TRUE)
		log_combat(angery, victim, "knocked back", null, "while resisting having their darkspawn thrall tumor removed")
	return TRUE
