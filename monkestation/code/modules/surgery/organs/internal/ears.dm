/obj/item/organ/internal/ears/get_status_appendix(advanced, add_tooltips)
	if (owner.stat == DEAD)
		return
	if (advanced)
		if (HAS_TRAIT_FROM(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE))
			return "Subject is temporarily hard of hearing from ear damage."
	return ..()

/obj/item/organ/internal/ears/proc/update_hearing_loss()
	var/was_deaf = HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE)
	var/was_hoh = HAS_TRAIT_FROM(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)

	if (!deaf)
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		return

	if (damage < 25 && !(organ_flags & ORGAN_FAILING))
		ADD_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		if (!was_hoh)
			if (was_deaf)
				to_chat(owner, span_warning("You're able to hear again, but everything sounds quiet."))
			else
				to_chat(owner, span_warning("Everything sounds quiet."))
	else
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_HARD_OF_HEARING, EAR_DAMAGE)
		if (!was_deaf)
			to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises."))

/obj/item/organ/internal/ears/robot/clockwork
	name = "biometallic recorder"
	desc = "An odd sort of microphone that looks grown, rather than built."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "ears-clock"

/obj/item/organ/internal/ears/jelly
	name = "core audiosomes"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE

/obj/item/organ/internal/ears/synth
	name = "auditory sensors"
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "ears-ipc"
	desc = "A pair of microphones intended to be installed in an IPC or Synthetics head, that grant the ability to hear."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/ears/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			owner.set_jitter_if_lower(SYNTH_BAD_EFFECT_DURATION * SYNTH_HEAVY_EMP_MULTIPLIER)
			owner.set_dizzy_if_lower(SYNTH_BAD_EFFECT_DURATION * SYNTH_HEAVY_EMP_MULTIPLIER)
			adjustEarDamage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, SYNTH_DEAF_STACKS)
			to_chat(owner, span_warning("Alert: Null feedback from auditory sensors detected, seek maintenance immediately. Error Code: AS-105"))

		if(EMP_LIGHT)
			owner.set_jitter_if_lower(SYNTH_BAD_EFFECT_DURATION)
			owner.set_dizzy_if_lower(SYNTH_BAD_EFFECT_DURATION)
			adjustEarDamage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, SYNTH_DEAF_STACKS)
			to_chat(owner, span_warning("Alert: Anomalous feedback from auditory sensors detected. Error Code: AS-50"))

/datum/design/synth_ears
	name = "Auditory Sensors"
	desc = "A pair of microphones intended to be installed in an IPC or Synthetics head, that grant the ability to hear."
	id = "synth_ears"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/ears/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS_1
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
