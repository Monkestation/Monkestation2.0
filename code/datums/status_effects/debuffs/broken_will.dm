//Broken Will: Applied by Devour Will, and functions similarly to Kindle. Induces sleep for 30 seconds, going down by 1 second for every point of damage the target takes. //yogs start: darkspawn
/datum/status_effect/broken_will
	id = "broken_will"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 0.5 SECONDS
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/broken_will
	///the amount of damage needed to wake up the person
	var/wake_threshold = 5

/datum/status_effect/broken_will/on_apply()
	if(IS_TEAM_DARKSPAWN(owner) || owner.stat == DEAD)
		return FALSE
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, TRAIT_STATUS_EFFECT(id))
	owner.Unconscious(15) // initial knockout before first tick
	return TRUE

/datum/status_effect/broken_will/on_remove()
	if(owner)
		UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
		REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, TRAIT_STATUS_EFFECT(id))
		owner.SetUnconscious(0) //wake them up
	return ..()

/datum/status_effect/broken_will/tick()
	if(IS_TEAM_DARKSPAWN(owner) || owner.stat == DEAD)
		qdel(src)
		return
	owner.Unconscious(15)
	if(owner.health > HEALTH_THRESHOLD_CRIT)
		return
	owner.heal_ordered_damage(3, list(BURN, BRUTE)) //so if they're left to bleed out, they'll survive, probably?
	if(prob(10))
		to_chat(owner, span_velvet("sleep... bliss...")) //give a notice that they're probably healing because of the sleep

/datum/status_effect/broken_will/proc/on_take_damage(datum/source, damage, damagetype)
	if(damage < wake_threshold)
		return
	owner.visible_message(span_warning("[owner] is jolted awake by the impact!") , span_boldannounce("Something hits you, pulling you towards wakefulness!"))
	ADD_TRAIT(owner, TRAIT_NOSOFTCRIT, TRAIT_STATUS_EFFECT(id))
	addtimer(TRAIT_CALLBACK_REMOVE(owner, TRAIT_NOSOFTCRIT, TRAIT_STATUS_EFFECT(id)), 20 SECONDS)
	qdel(src)

/atom/movable/screen/alert/status_effect/broken_will
	name = "Broken Will"
	desc = "..."
	icon_state = "broken_will"
	alerttooltipstyle = "alien"
