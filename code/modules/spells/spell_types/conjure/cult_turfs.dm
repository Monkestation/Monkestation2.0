/datum/action/cooldown/spell/conjure/cult_floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor."
	background_icon_state = "bg_cult"
	overlay_icon_state = "bg_cult_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "floorconstruct"

	school = SCHOOL_CONJURATION
	cooldown_time = 2 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/turf/open/floor/engine/cult)

/datum/action/cooldown/spell/conjure/cult_floor/post_summon(atom/summoned_object, atom/cast_on)
	. = ..()
	var/datum/antagonist/cult/cultist = owner.mind?.has_antag_datum(/datum/antagonist/cult)
	cultist?.gain_devotion(0, DEVOTION_TIER_0, "convert_floor")

/datum/action/cooldown/spell/conjure/cult_wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall."
	background_icon_state = "bg_cult"
	overlay_icon_state = "bg_cult_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "lesserconstruct"

	school = SCHOOL_CONJURATION
	cooldown_time = 10 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/turf/closed/wall/mineral/cult/artificer) // We don't want artificer-based runed metal farms.

/datum/action/cooldown/spell/conjure/cult_wall/post_summon(atom/summoned_object, atom/cast_on)
	. = ..()
	var/datum/antagonist/cult/cultist = owner.mind?.has_antag_datum(/datum/antagonist/cult)
	cultist?.gain_devotion(0, DEVOTION_TIER_0, "convert_wall")
