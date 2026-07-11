/obj/item/organ/internal/stomach/clockwork
	name = "nutriment refinery"
	desc = "A biomechanical furnace, which turns calories into mechanical energy."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "stomach-clock"
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/internal/stomach/clockwork/emp_act(severity)
	owner.adjust_nutrition(-100)  //got rid of severity part

/obj/item/organ/internal/stomach/battery/clockwork
	name = "biometallic flywheel"
	desc = "A biomechanical battery which stores mechanical energy."
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "stomach-clock"
	organ_flags = ORGAN_ROBOTIC
	//max_charge = 7500
	//charge = 7500 //old bee code

/obj/item/organ/internal/stomach/slime
	name = "golgi apparatus"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/stomach/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

///IPCS NO LONGER ARE PURE ELECTRICAL BEINGS, any attempts to change this outside of Borbop will be denied. Thanks.
/obj/item/organ/internal/stomach/synth
	name = "synthetic bio-reactor"
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "stomach-ipc"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	zone = "chest"
	slot = "stomach"
	desc = "A specialised mini reactor, for synthetic use only. Has a low-power mode to ensure baseline functions. Without this, synthetics are unable to stay powered."
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES
	var/blending = FALSE
	/// The single pending start or finish timer for the grinder sequence.
	var/will_it_blend_timer
	COOLDOWN_DECLARE(blend_cd)

/obj/item/organ/internal/stomach/synth/Destroy()
	cancel_blend_sequence()
	return ..()

/obj/item/organ/internal/stomach/synth/emp_act(severity)
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			owner.nutrition = max(0, owner.nutrition - SYNTH_STOMACH_HEAVY_EMP_CHARGE_LOSS)
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organ_flag = ORGAN_ROBOTIC)
			to_chat(owner, span_warning("Alert: Severe battery discharge!"))

		if(EMP_LIGHT)
			owner.nutrition = max(0, owner.nutrition - SYNTH_STOMACH_LIGHT_EMP_CHARGE_LOSS)
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organ_flag = ORGAN_ROBOTIC)
			to_chat(owner, span_warning("Alert: Minor battery discharge!"))

/obj/item/organ/internal/stomach/synth/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!.)
		return
	RegisterSignal(receiver, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/organ/internal/stomach/synth/Remove(mob/living/carbon/stomach_owner, special)
	cancel_blend_sequence()
	. = ..()
	UnregisterSignal(stomach_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)

/// Cancels either phase of the grinder sequence and resets its state.
/obj/item/organ/internal/stomach/synth/proc/cancel_blend_sequence()
	if(will_it_blend_timer)
		deltimer(will_it_blend_timer)
		will_it_blend_timer = null
	blending = FALSE

/// Returns whether this stomach is still installed in the expected owner.
/obj/item/organ/internal/stomach/synth/proc/valid_blend_owner(mob/living/carbon/carbon)
	return !QDELETED(src) && !QDELETED(carbon) && owner == carbon && carbon.get_organ_slot(ORGAN_SLOT_STOMACH) == src

///Handles charging the synth from borg chargers
/obj/item/organ/internal/stomach/synth/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	if(owner.nutrition >= NUTRITION_LEVEL_ALMOST_FULL)
		return

	amount /= 50 // Lowers the charging amount so it isn't instant
	owner.nutrition = min((owner.nutrition + amount), NUTRITION_LEVEL_ALMOST_FULL) // Makes sure we don't make the synth too full, which would apply the overweight slowdown

/obj/item/organ/internal/stomach/synth/on_life(seconds_per_tick, times_fired)
	. = ..()
	var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in reagents.reagent_list
	if(!nutri)
		return
	if(will_it_blend_timer || blending || !COOLDOWN_FINISHED(src, blend_cd))
		return
	will_it_blend_timer = addtimer(CALLBACK(src, PROC_REF(start_blending), owner), 4 SECONDS, TIMER_STOPPABLE)

/obj/item/organ/internal/stomach/synth/proc/start_blending(mob/living/carbon/carbon)
	will_it_blend_timer = null
	if(!valid_blend_owner(carbon) || !carbon.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment))
		return
	blending = TRUE
	carbon.Shake(2, 2, 10 SECONDS)
	playsound(carbon, 'monkestation/code/modules/smithing/sounds/blend.ogg', 50, TRUE, mixer_channel = CHANNEL_MOB_SOUNDS)
	will_it_blend_timer = addtimer(CALLBACK(src, PROC_REF(finish_blending), carbon), 10 SECONDS, TIMER_STOPPABLE)

/obj/item/organ/internal/stomach/synth/proc/finish_blending(mob/living/carbon/human/carbon)
	will_it_blend_timer = null
	if(!valid_blend_owner(carbon))
		blending = FALSE
		return
	var/nutri_amount = carbon.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	carbon.reagents.del_reagent(/datum/reagent/consumable/nutriment)
	carbon.nutrition = min(NUTRITION_LEVEL_FULL, carbon.nutrition + (nutri_amount * 5))
	blending = FALSE
	COOLDOWN_START(src, blend_cd, 60 SECONDS)
