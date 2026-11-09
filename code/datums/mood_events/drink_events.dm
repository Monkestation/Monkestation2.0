/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_overlay

/datum/mood_event/drunk/add_effects(param)
	// monkestation edit: our drunk moodlet doesn't scale with drunkness, so personalities just change the flat value
	if(HAS_PERSONALITY(owner, /datum/personality/teetotal))
		mood_change *= -1.5
		description = "I don't like drinking... It makes me feel horrible."
	if(HAS_PERSONALITY(owner, /datum/personality/bibulous))
		mood_change *= 1.5
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	blush_overlay = human_owner.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush)

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

/datum/mood_event/drunk_after
	mood_change = 2
	description = "The buzz might be gone, but I still feel good."
	timeout = 5 MINUTES

/datum/mood_event/wrong_brandy
	description = "I hate that type of drink."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/quality_nice
	description = "That drink wasn't bad at all."
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "That drink was pretty good."
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "That drink was great!"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "That drink was amazing!"
	mood_change = 8
	timeout = 7 MINUTES

/datum/mood_event/amazingtaste
	description = "Amazing taste!"
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/wellcheers
	description = "What a tasty can of Wellcheers! The salty grape flavor is a great pick-me-up."
	mood_change = 3
	timeout = 7 MINUTES
