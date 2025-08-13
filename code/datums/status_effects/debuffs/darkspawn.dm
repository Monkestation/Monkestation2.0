//Broken Will: Applied by Devour Will, and functions similarly to Kindle. Induces sleep for 30 seconds, going down by 1 second for every point of damage the target takes. //yogs start: darkspawn
/datum/status_effect/broken_will
	id = "broken_will"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 300
	examine_text = "<span class='deadsay'>SUBJECTPRONOUN is in a deep, deathlike sleep, with no signs of awareness to anything around them.</span>"
	alert_type = /obj/screen/alert/status_effect/broken_will
	var/old_health

/datum/status_effect/creep/get_examine_text()
	return span_notice("[owner.p_are(TRUE)] is in a deep, deathlike sleep, with no signs of awareness to anything around them.")

/datum/status_effect/broken_will/tick()
	owner.Unconscious(15)
	if(!old_health)
		old_health = owner.health
	var/health_difference = old_health - owner.health
	if(!health_difference)
		return
	owner.visible_message("<span class='warning'>[owner] jerks in their sleep as they're harmed!</span>")
	to_chat(owner, "<span class='boldannounce'>Something hits you, pulling you towards wakefulness!</span>")
	health_difference *= 10 //1 point of damage = 1 second = 10 deciseconds
	duration -= health_difference
	old_health = owner.health

/obj/screen/alert/status_effect/broken_will
	name = "Broken Will"
	desc = "..."
	icon_state = "broken_will"
	alerttooltipstyle = "alien" //yogs end
