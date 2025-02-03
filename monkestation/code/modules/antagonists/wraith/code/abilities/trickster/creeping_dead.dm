/datum/action/cooldown/spell/pointed/wraith/creeping_dead
	name = "Creeping Dead"
	desc = "Curse someone to be fatally scared of the dark."
	button_icon_state = "creeping_dead"

	essence_cost = 80
	cooldown_time = 1 MINUTE

	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND // If your mind is resistant, this aint gonna work

	/// List of all the mobs cursed by us, format:
	/// [MOB REFERENCE] = [NUMBER (points of paranoia)]
	var/list/cursed_list = list()

/datum/action/cooldown/spell/pointed/wraith/creeping_dead/Destroy(force)
	for(var/mob/living/hooman as anything in cursed_list)
		UnregisterSignal(hooman, COMSIG_MOVABLE_MOVED)

	cursed_list = null
	return ..()

/datum/action/cooldown/spell/pointed/wraith/creeping_dead/before_cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(!istype(cast_on))
		return . | SPELL_CANCEL_CAST

	if(HAS_TRAIT(cast_on, TRAIT_FEARLESS))
		to_chat(owner, span_revenwarning("Their soul is too fearless for us to strike the initial match..."))
		return . | SPELL_CANCEL_CAST

	if(cast_on.dna?.species.id in list(SPECIES_SHADOW, SPECIES_NIGHTMARE))
		to_chat(owner, span_revenwarning("That'd be too silly.")) // It would
		return . | SPELL_CANCEL_CAST

	if(cursed_list[cast_on])
		to_chat(owner, span_revenwarning("They are already haunted by darkness."))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/creeping_dead/cast(mob/living/carbon/human/cast_on)
	. = ..()
	RegisterSignal(cast_on, COMSIG_MOVABLE_MOVED, PROC_REF(check_darkness))
	cursed_list[cast_on] = 0

/datum/action/cooldown/spell/pointed/wraith/creeping_dead/proc/check_darkness(mob/living/carbon/human/victim, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(victim.stat != CONSCIOUS || victim.IsSleeping() || victim.IsUnconscious())
		return

	if((victim.sight & SEE_TURFS) == SEE_TURFS) // You can't really be scared of dark if you can see past darkness, can you?
		if(cursed_list[victim] > 0)
			cursed_list[victim]--
		return

	var/turf/victim_turf = get_turf(victim)
	if(victim_turf.get_lumcount() > LIGHTING_TILE_IS_DARK)
		if(cursed_list[victim] > 0)
			cursed_list[victim]--
		return

	INVOKE_ASYNC(src, PROC_REF(use_darkness), victim) // We do this to use emotes whilst still being a "signal handler"

/datum/action/cooldown/spell/pointed/wraith/creeping_dead/proc/use_darkness(mob/living/carbon/human/victim)
	cursed_list[victim]++
	switch(cursed_list[victim])
		if(5)
			to_chat(victim, span_warning("You feel as if someone is watching you..."))
			victim.emote("look")

		if(10)
			to_chat(victim, span_danger("You catch a glimpse of something moving in the dark at the edge of your sight."))
			victim.emote("shiver")

		if(15)
			to_chat(victim, span_danger("You start hearing strange whispers..."))
			for(var/i in 1 to 3)
				victim.emote("look")
				sleep(0.2 SECONDS)

		if(20)
			to_chat(victim, span_userdanger("You can see someone-- something in the dark watching you... you can't take this much longer... you NEED to find light NOW."))
			victim.emote("scream") // vewy scawy

		if(25)
			to_chat(victim, span_userdanger("THIS IS TOO MUCH, THE DARKNESS IS EVERYWHERE, YOU CAN'T BREATHE."))
			var/obj/item/organ/internal/heart/heart = victim.get_organ_by_type(/obj/item/organ/internal/heart)
			if(heart.beating)
				victim.visible_message(span_danger("[victim] clutches at [victim.p_their()] chest as if [victim.p_their()] heart is stopping!"), \
					span_userdanger("You feel a terrible pain in your chest, as if your heart has stopped!"))
				heart.beating = FALSE // There's a special proc for setting a heart attack, but we're too cool to get stopped by 50 checks
			victim.playsound_local(victim, 'sound/effects/singlebeat.ogg', 100, 0)
