/datum/action/cooldown/vampire/blush_of_life
	name = "Blush of Life"
	desc = "Feign the vital signs of a mortal, and escape both casual and medical notice as the monster you truly are."
	button_icon_state = "power_human"
	power_explanation = "Blush of Life will forge your identity to be practically identical to that of a human.\n\
		You lose nearly all Vampire benefits, including your passive healing.\n\
		You gain a Genetic sequence, and appear to have 100% blood when scanned by a Health Analyzer.\n\
		You won't appear as pale when examined. Anything further than pale, however, will not be hidden.\n\
		After deactivating Blush of Life, you will re-gain your Vampiric abilities, as well as lose any Diseases or mutations you might have gained."
	vampire_power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN | BP_AM_COSTLESS_UNCONSCIOUS
	vampire_check_flags = BP_CANT_USE_IN_FRENZY | BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_ALLOW_WHILE_SILVER_CUFFED
	vitaecost = 10
	cooldown_time = 5 SECONDS
	constant_vitaecost = 0.1

/datum/action/cooldown/vampire/blush_of_life/activate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "blush of life turned on.")
	carbon_owner.apply_status_effect(/datum/status_effect/blush_of_life)

/datum/action/cooldown/vampire/blush_of_life/deactivate_power()
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.balloon_alert(carbon_owner, "blush of life turned off.")
	carbon_owner.remove_status_effect(/datum/status_effect/blush_of_life)

/datum/status_effect/blush_of_life
	id = "blush_of_life"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/blush_of_life

/atom/movable/screen/alert/status_effect/blush_of_life
	name = "Blush of Life"
	desc = "You are currently hiding your identity using the Blush of Life power. This halts Vampiric healing."
	icon = 'icons/mob/actions/actions_vampire.dmi'
	icon_state = "masquerade_alert"
	alerttooltipstyle = "cult"

/datum/status_effect/blush_of_life/on_apply()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return FALSE

	// Handle Traits
	carbon_owner.remove_traits(vampiredatum.vampire_traits - vampiredatum.always_traits, TRAIT_VAMPIRE)
	carbon_owner.add_traits(list(TRAIT_BLUSH_OF_LIFE, TRAIT_FAKEGENES), TRAIT_STATUS_EFFECT(id))

	// Handle organs
	var/obj/item/organ/internal/heart/vampheart = carbon_owner.get_organ_by_type(/obj/item/organ/internal/heart)
	vampheart?.Restart()

	to_chat(carbon_owner, span_notice("Your heart beats falsely within your lifeless chest. You may yet pass for a mortal."))
	to_chat(carbon_owner, span_warning("Your vampiric healing is halted while imitating life."))

	return TRUE

/datum/status_effect/blush_of_life/on_remove()
	var/mob/living/carbon/carbon_owner = owner
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(carbon_owner)
	if(!vampiredatum)
		return

	// Clear mutations and diseases
	carbon_owner.dna.remove_all_mutations()
	for(var/datum/disease/diseases in carbon_owner.diseases)
		diseases.cure(target = carbon_owner, safe = TRUE)

	// Handle Traits
	carbon_owner.add_traits(vampiredatum.vampire_traits, TRAIT_VAMPIRE)
	carbon_owner.remove_traits(list(TRAIT_BLUSH_OF_LIFE, TRAIT_FAKEGENES), TRAIT_STATUS_EFFECT(id))

	// Handle organs
	var/obj/item/organ/internal/heart/vampheart = carbon_owner.get_organ_slot(ORGAN_SLOT_HEART)
	vampheart?.Stop()

	to_chat(carbon_owner, span_notice("Your heart beats one final time, while your skin dries out and your icy pallor returns."))
