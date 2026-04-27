/mob/living/basic/guardian/standard/timestop
	// Like Vampires do, you will take more damage to Burn and less to Brute
	damage_coeff = list(BRUTE = 0.5, BURN = 2.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	creator_name = "Timestop"
	creator_desc = "Devastating close combat attacks and high damage resistance. Can smash through weak walls and stop time."
	creator_icon = "timestop"

/mob/living/basic/guardian/standard/timestop/Initialize(mapload, theme)
	//Wizard Holoparasite theme, just to be more visibly stronger than regular ones
	theme = GLOB.guardian_themes[GUARDIAN_THEME_TECH]
	. = ..()
	var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = new()
	timestop_ability.Grant(src)

/mob/living/basic/guardian/standard/timestop/set_summoner(mob/living/to_who, different_person = FALSE)
	..()
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.grant_summoner_immunity()

/mob/living/basic/guardian/standard/timestop/cut_summoner(different_person = FALSE)
	for(var/action in actions)
		var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = action
		if(istype(timestop_ability))
			timestop_ability.remove_summoner_immunity()
	..()

///Guardian Timestop ability
/datum/action/cooldown/spell/timestop/guardian
	name = "Guardian Timestop"
	desc = "This spell stops time for everyone except for you and your master, \
		allowing you to move freely while your enemies and even projectiles are frozen."
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/timestop/guardian/proc/grant_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/vampire_guardian = owner
	if(vampire_guardian && istype(vampire_guardian) && vampire_guardian.summoner)
		ADD_TRAIT(vampire_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/guardian/proc/remove_summoner_immunity()
	var/mob/living/basic/guardian/standard/timestop/vampire_guardian = owner
	if(vampire_guardian && istype(vampire_guardian) && vampire_guardian.summoner)
		REMOVE_TRAIT(vampire_guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))
