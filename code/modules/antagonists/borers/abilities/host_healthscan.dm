/datum/action/cooldown/borer/check_blood
	name = "Check Blood"
	cooldown_time = 5 SECONDS
	button_icon_state = "blood"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Allows you to check your host's health\n\
	Additionally you will be able to taste the host's chemicals and measure them acuratelly\n\
	"

/datum/action/cooldown/borer/check_blood/Activate(mob/living/basic/cortical_borer/user)
	healthscan(user, user.human_host, advanced = TRUE) // :thinking:
	chemscan(user, user.human_host)
	return ..()
