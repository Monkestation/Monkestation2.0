//Magical traumas, caused by spells and curses.
//Blurs the line between the victim's imagination and reality
//Unlike regular traumas this can affect the victim's body and surroundings

/datum/brain_trauma/magic
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/magic/lumiphobia
	name = "Lumiphobia"
	desc = "Patient has an inexplicable adverse reaction to light."
	scan_desc = "light hypersensitivity"
	gain_text = span_warning("You feel a craving for darkness.")
	lose_text = span_notice("Light no longer bothers you.")
	/// Cooldown to prevent warning spam
	COOLDOWN_DECLARE(damage_warning_cooldown)
	var/next_damage_warning = 0

/datum/brain_trauma/magic/lumiphobia/on_life(seconds_per_tick, times_fired)
	..()
	var/turf/turf = owner.loc
	if(!istype(turf))
		return

	if(turf.get_lumcount() <= SHADOW_SPECIES_DIM_LIGHT) //if there's enough light, start dying
		return

	if(COOLDOWN_FINISHED(src, damage_warning_cooldown))
		to_chat(owner, span_warning("<b>The light burns you!</b>"))
		COOLDOWN_START(src, damage_warning_cooldown, 10 SECONDS)
	owner.take_overall_damage(burn = 1.5 * seconds_per_tick)

/datum/brain_trauma/magic/poltergeist
	name = "Poltergeist"
	desc = "Patient appears to be targeted by a violent invisible entity."
	scan_desc = "paranormal activity"
	gain_text = span_warning("You feel a hateful presence close to you.")
	lose_text = span_notice("You feel the hateful presence fade away.")

/datum/brain_trauma/magic/poltergeist/on_life(seconds_per_tick, times_fired)
	..()
	if(!SPT_PROB(2, seconds_per_tick))
		return

	var/most_violent = -1 //So it can pick up items with 0 throwforce if there's nothing else
	var/obj/item/throwing
	for(var/obj/item/I in view(5, get_turf(owner)))
		if(I.anchored)
			continue
		if(I.throwforce > most_violent)
			most_violent = I.throwforce
			throwing = I
	if(throwing)
		throwing.throw_at(owner, 8, 2)

/datum/brain_trauma/magic/antimagic
	name = "Athaumasia"
	desc = "Patient is completely inert to magical forces."
	scan_desc = "thaumic blank"
	gain_text = span_notice("You realize that magic cannot be real.")
	lose_text = span_notice("You realize that magic might be real.")

/datum/brain_trauma/magic/antimagic/on_gain()
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/antimagic/on_lose()
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	..()

/datum/brain_trauma/magic/stalker
	name = "Stalking Phantom"
	desc = "Patient is stalked by a phantom only they can see."
	scan_desc = "extra-sensory paranoia"
	gain_text = span_warning("You feel like something wants to kill you...")
	lose_text = span_notice("You no longer feel eyes on your back.")
	/// Type of stalker that is chasing us
	var/stalker_type = /obj/effect/client_image_holder/stalker_phantom
	/// Reference to the stalker(s) that is chasing us
	var/list/obj/effect/client_image_holder/stalker_phantom/stalkers = list()
	/// Plays a sound when the stalker is near their victim
	var/close_stalker = FALSE
	var/max_stalkers = 1

/datum/brain_trauma/magic/stalker/Destroy()
	QDEL_LIST(stalkers)
	return ..()

/datum/brain_trauma/magic/stalker/on_gain()
	create_stalkers()
	return ..()

/datum/brain_trauma/magic/stalker/on_lose()
	QDEL_LIST(stalkers)
	return ..()

/datum/brain_trauma/magic/stalker/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.stat != CONSCIOUS || !isturf(owner.loc))
		QDEL_LIST(stalkers)
		return

	var/any_stalkers_close = FALSE
	for(var/obj/effect/client_image_holder/stalker_phantom/stalker as anything in stalkers)
		if(QDELETED(stalker))
			continue
		if(stalk_tick(stalker, seconds_per_tick))
			any_stalkers_close ||= (get_dist(owner, stalker) <= 8)
		CHECK_TICK
	if(any_stalkers_close)
		if(!close_stalker)
			var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
			owner.playsound_local(owner, slowbeat, vol = 40, vary = FALSE, channel = CHANNEL_HEARTBEAT, use_reverb = FALSE)
			close_stalker = TRUE
	else if(close_stalker)
		owner.stop_sound_channel(CHANNEL_HEARTBEAT)
		close_stalker = FALSE

	create_stalkers()

/datum/brain_trauma/magic/stalker/proc/create_single_stalker(turf/stalker_source)
	if(!stalker_source)
		stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z) //random corner
	var/obj/effect/client_image_holder/stalker_phantom/stalker = new stalker_type(stalker_source, owner)
	RegisterSignal(stalker, COMSIG_QDELETING, PROC_REF(on_phantom_destroyed))
	stalkers += stalker

/datum/brain_trauma/magic/stalker/proc/create_stalkers()
	if(!isturf(owner?.loc))
		return
	var/amount_to_create = max_stalkers - length(stalkers)
	if(amount_to_create <= 0)
		return
	var/turf/stalker_source = locate(owner.x + pick(-12, 12), owner.y + pick(-12, 12), owner.z)
	for(var/i = 1 to amount_to_create)
		create_single_stalker(stalker_source)

/datum/brain_trauma/magic/stalker/proc/on_phantom_destroyed(obj/effect/client_image_holder/stalker_phantom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_QDELETING)
	stalkers -= source

/datum/brain_trauma/magic/stalker/proc/stalk_tick(obj/effect/client_image_holder/stalker_phantom/stalker, seconds_per_tick)
	if(QDELETED(owner) || !isturf(owner.loc) || !isturf(stalker.loc) || owner.z != stalker.z)
		qdel(stalker)
		return FALSE
	if(get_dist(owner, stalker) <= 1)
		playsound(owner, 'sound/magic/demon_attack1.ogg', vol = 50)
		owner.visible_message(span_warning("[owner] is torn apart by invisible claws!"), span_userdanger("Ghostly claws tear your body apart!"))
		owner.take_bodypart_damage(rand(20, 45), wound_bonus = CANT_WOUND)
	else if(SPT_PROB(30, seconds_per_tick))
		var/turf/next_step = get_step_towards(stalker, owner)
		if(!isturf(next_step) || QDELING(next_step))
			qdel(stalker)
			return FALSE
		stalker.forceMove(next_step)
	return TRUE

/datum/brain_trauma/magic/stalker/multiple
	name = "Stalking Phantoms"
	desc = "Patient is stalked by multiple phantoms only they can see."
	scan_desc = "extra-EXTRA-sensory paranoia"
	gain_text = span_warning("You feel like the gods have released the hounds...")
	lose_text = span_notice("You no longer feel the wrath of the gods watching you.")
	max_stalkers = 10

/obj/effect/client_image_holder/stalker_phantom
	name = "???"
	desc = "It's coming closer..."
	image_icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	image_state = "curseblob"

// Heretic subtype that replaces the ghost guy with a stargazer
/datum/brain_trauma/magic/stalker/cosmic
	stalker_type = /obj/effect/client_image_holder/stalker_phantom/cosmic
	trauma_flags = parent_type::trauma_flags | TRAUMA_NOT_RANDOM

/obj/effect/client_image_holder/stalker_phantom/cosmic
	image_icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	image_state = "star_gazer"
