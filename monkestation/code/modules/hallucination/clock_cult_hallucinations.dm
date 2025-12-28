/datum/hallucination/fake_item/clockwork_slab
	random_hallucination_weight = 0
	template_item_type  = /obj/item/clockwork/clockwork_slab
	valid_slots = ITEM_SLOT_HANDS

/datum/hallucination/nearby_fake_item/clockwork_slab
	left_hand_file = 'monkestation/icons/mob/clock_cult/clockwork_lefthand.dmi'
	right_hand_file = 'monkestation/icons/mob/clock_cult/clockwork_righthand.dmi'
	image_icon_state = "clockwork_slab"

/datum/hallucination/hazard/clockwork_skewer
	random_hallucination_weight = 0
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/clockwork_skewer

/obj/effect/client_image_holder/hallucination/danger/clockwork_skewer
	name = "brass skewer"
	image_icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	image_state = "brass_skewer"

/obj/effect/client_image_holder/hallucination/danger/clockwork_skewer/on_hallucinator_entered(mob/living/afflicted)
	to_chat(afflicted, span_userdanger("You are impaled by [src]!"))
	afflicted.visible_message(span_warning("[afflicted] falls to the ground suddenly!"), ignored_mobs = afflicted)
	afflicted.Paralyze(4 SECONDS)
	afflicted.emote("scream")
	afflicted.stamina.adjust(-40)
	image_state = "brass_skewer_pokeybit"
	image_layer = ABOVE_MOB_LAYER
	update_appearance()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), afflicted, span_notice("...You feel the pain of being stabbed fading strangely quickly.")), 1.5 SECONDS)
	QDEL_IN(src, 3 SECONDS)

/datum/hallucination/delusion/preset/clock_cultists
	dynamic_delusion = TRUE
	random_hallucination_weight = 0
	delusion_name = "Servant of Ratvar"
	affects_others = TRUE
	skip_nearby = TRUE

/datum/hallucination/delusion/preset/clock_cultists/make_delusion_image(mob/over_who)
	var/static/mutable_appearance/servant_appearance
	if(isnull(servant_appearance))
		servant_appearance = get_dynamic_human_appearance(/datum/outfit/clock/preview, r_hand = NO_REPLACE)
	delusion_appearance = servant_appearance
	return ..()

/datum/hallucination/fake_sound/weird/clockcult_kindle
	sound_type = 'sound/magic/staff_animation.ogg'

/datum/hallucination/fake_sound/weird/clockcult_kindle/play_fake_sound(turf/source, sound_to_play)
	. = ..()
	if(prob(50))
		queue_fake_sound(source, 'sound/weapons/handcuffs.ogg', delay = 4 SECONDS)

/datum/hallucination/fake_sound/weird/clockcult_warp
	sound_type = 'sound/magic/magic_missile.ogg'
