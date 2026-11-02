/datum/action/cooldown/borer/stealth_mode
	name = "Stealth Mode"
	cooldown_time = 1 MINUTES
	button_icon_state = "hiding"
	chemical_cost = 100
	sugar_restricted = TRUE
	ability_explanation = "\
	Very effectivelly hides your presence\n\
	While in stealth, you will crawl onto people without any noticable signs nor warning\n\
	Additionally you will not have any negative effects onto your host, but wont generate internal chemicals\n\
	"

/datum/action/cooldown/borer/stealth_mode/Activate(mob/living/basic/cortical_borer/user)
	var/in_stealth = (user.upgrade_flags & BORER_STEALTH_MODE)
	owner.balloon_alert(owner, "stealth mode [in_stealth ? "disabled" : "enabled"]")
	if(in_stealth)
		user.upgrade_flags &= ~BORER_STEALTH_MODE
		chemical_cost = 0
	else
		user.upgrade_flags |= BORER_STEALTH_MODE
		chemical_cost = initial(chemical_cost)

	user.chemical_storage -= chemical_cost
	return ..()
