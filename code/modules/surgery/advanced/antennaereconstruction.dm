/datum/surgery/advanced/antennae_reconstruction
	name = "Antennae Reconstruction"
	desc = "An experimental surgical procedure that reconstructs the damaged antennae of moth people. Requires Synthflesh."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/antennae_reconstruction,
	)

/datum/surgery/advanced/antennae_reconstruction/can_start(mob/user, mob/living/carbon/target)
	if(!istype(target))
		return FALSE
	var/obj/item/organ/external/antennae/antennae = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
	if(!istype(antennae))
		return FALSE
	return ..() && antennae.burnt

/datum/surgery_step/antennae_reconstruction
	name = "start antennae reconstruction (hemostat)"
	implements = list(
		TOOL_HEMOSTAT = 85,
		TOOL_SCREWDRIVER = 35,
		/obj/item/pen = 15)
	time = 200
	chems_needed = list(/datum/reagent/medicine/c2/synthflesh)
	require_all_chems = FALSE

/datum/surgery_step/antennae_reconstruction/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to reconstruct [target]'s charred antennae..."),
		span_notice("[user] begins to reconstruct [target]'s charred antennae."),
		span_notice("[user] begins to perform surgery on [target]'s charred antennae."),
	)
	display_pain(target, "You twitch in pain from the operation on your sensitive antennae!")

/datum/surgery_step/antennae_reconstruction/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		display_results(
			user,
			target,
			span_notice("You succeed in reconstructing [target]'s antennae."),
			span_notice("[user] successfully reconstructs [target]'s antennae!"),
			span_notice("[user] completes the surgery on [target]'s antennae."),
		)
		display_pain(target, "You can feel your antennae again!")
		var/obj/item/organ/external/antennae/antennae = target.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANTENNAE)
		if(istype(antennae))
			antennae.heal_antennae(user, ALL)

		human_target.update_body_parts()
	return ..()
