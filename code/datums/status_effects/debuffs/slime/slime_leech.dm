/atom/movable/screen/alert/status_effect/slime_leech
	name = "Covered in Slime"
	desc = "A slime is draining your very lifeforce! Remove it by hand, by hitting it, or by water."
	icon = 'icons/hud/screen_slimecore.dmi'
	icon_state = "template"
	overlay_icon = 'icons/obj/xenobiology/slime_rancher/slimes.dmi'
	overlay_state = "grey-baby"

/datum/status_effect/slime_leech
	id = "slime_leech"
	alert_type = /atom/movable/screen/alert/status_effect/slime_leech
	/// The slime draining the owner.
	var/mob/living/basic/slime/our_slime

/datum/status_effect/slime_leech/on_creation(mob/living/new_owner, mob/living/basic/slime/our_slime)
	src.our_slime = our_slime
	return ..()

/datum/status_effect/slime_leech/on_apply()
	if(!isslime(our_slime))
		return FALSE

	RegisterSignals(our_slime, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_SET_BUCKLED, COMSIG_QDELETING), PROC_REF(on_buckle_end))
	return ..()

///If the buckling ends
/datum/status_effect/slime_leech/proc/on_buckle_end(datum/source, new_buckled)
	SIGNAL_HANDLER

	// set_buckled fires on the latch itself too
	if(new_buckled == owner || QDELETED(owner))
		return

	var/bio_protection = 100 - owner.getarmor(null, BIO)
	if(prob(bio_protection))
		owner.apply_status_effect(/datum/status_effect/slimed, our_slime.slime_type.rgb_code, our_slime.slime_type.color == SLIME_TYPE_RAINBOW)

	UnregisterSignal(our_slime, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_SET_BUCKLED, COMSIG_QDELETING))
	if(!QDELETED(our_slime))
		our_slime.stop_feeding()

	qdel(src)

/datum/status_effect/slime_leech/on_remove()
	our_slime = null

/datum/status_effect/slime_leech/tick(seconds_between_ticks)
	var/mob/living/basic/slime/our_slime = src.our_slime // our food can get deleted mid-tick
	if(QDELETED(our_slime))
		qdel(src)
		return
	if(our_slime.stat != CONSCIOUS || !owner)
		our_slime.stop_feeding(silent = TRUE)
		return

	if(owner.stat == DEAD)
		if(our_slime.client)
			to_chat(our_slime, span_info("This subject does not have a strong enough life energy anymore..."))

		SEND_SIGNAL(owner, COMSIG_SLIME_DRAINED, our_slime)

		if(prob(60) && ishuman(owner) && owner.client && !our_slime.ai_controller?.blackboard[BB_SLIME_RABID])
			our_slime.ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE) //we might go rabid after finishing to feed on a human with a client.

		our_slime.stop_feeding()
		return

	// measured off health, since monke's damage procs don't agree on what sign they return (carbons give it back positive)
	// someone fix this plz because i'm too lazy ~Lucy
	var/health_before = owner.health
	owner.adjustToxLoss(rand(1, 2) * 0.5 * seconds_between_ticks, updating_health = FALSE) // apply_damage on the next line runs updatehealth
	owner.apply_damage(rand(2, 4) * 0.5 * seconds_between_ticks, BRUTE, spread_damage = TRUE, wound_bonus = CANT_WOUND) // use apply_damage instead of adjust_brute_loss so we don't crack someone's ribs lol
	var/drained = health_before - owner.health

	if(drained <= 0)
		our_slime.balloon_alert(our_slime, "not food!")
		our_slime.stop_feeding()
		return

	if(SPT_PROB(5, seconds_between_ticks) && owner.client)
		var/static/list/pain_lines
		if(isnull(pain_lines))
			pain_lines = list(
				"You can feel your body becoming weak!",
				"You feel like you're about to die!",
				"You feel every part of your body screaming in agony!",
				"A low, rolling pain passes through your body!",
				"Your body feels as if it's falling apart!",
				"You feel extremely weak!",
				"A sharp, deep pain bathes every inch of your body!",
			)

		to_chat(owner, span_userdanger(pick(pain_lines)))

	SEND_SIGNAL(our_slime, COMSIG_SLIME_LATCH_DRAINED, owner, drained)
	our_slime.adjust_nutrition(1.8 * drained) //damage is already modified by seconds_between_ticks
	our_slime.adjustBruteLoss(-1.5 * seconds_between_ticks)
