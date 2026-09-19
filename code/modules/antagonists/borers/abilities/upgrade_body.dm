/datum/action/cooldown/borer/upgrade_stat
	name = "Become Stronger"
	button_icon_state = "level"
	stat_evo_points = 1
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Lets you become stronger in exchange for an evolution point\n\
	Your maximum health, regeneration, chemical storage and chemical regeneration will all be faster\n\
	"

/datum/action/cooldown/borer/upgrade_stat/Activate(mob/living/basic/cortical_borer/user)
	user.stat_evolution -= stat_evo_points
	user.maxHealth += user.health_per_level
	user.health_regen += user.health_regen_per_level
	user.max_chemical_storage += user.chem_storage_per_level
	user.chemical_regen += user.chem_regen_per_level
	user.level += 1

	user.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)

	user.human_host.adjust_eye_blur(6 SECONDS * user.host_harm_multiplier) //about 12 seconds' worth by default
	to_chat(user, span_notice("You have grown!"))
	to_chat(user.human_host, span_warning("You feel a sharp pressure in your head!"))
	return ..()
