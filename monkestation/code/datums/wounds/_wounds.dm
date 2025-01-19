/datum/wound
	/// Generic healing progress, not used by bleeding wounds.
	var/heal_progress = 0

/// Adds 'amount' to 'heal_progress' and handles removing/demoting the wound when it reaches 1.
/// Bleeding wounds have special handling based on blood flow instead.
/// Setting 'html_override' changes the 'to_chat' after it heals.
/datum/wound/proc/heal(amount, html_override)
	heal_progress = CLAMP01(heal_progress + amount / max(1, severity)) // without the max() trivial wounds would do a divide-by-zero here
	if(heal_progress < 1)
		return

	to_chat(victim, html_override || span_green("The [lowertext(name)] on your [limb.plaintext_zone] has healed up!"))
	qdel(src)

/datum/wound/burn/flesh/heal(amount, html_override) // technically this could use flesh_healing but that scales entirely differently compared to a 0-1 (and is inherently time locked)
	html_override ||= span_green("The burns on your [limb.plaintext_zone] have cleared up!")
	return ..()

/datum/wound/slash/flesh/heal(amount, html_override)
	adjust_blood_flow(-amount / 0.75) // max 'initial_flow' is 4

/datum/wound/pierce/bleed/heal(amount, html_override)
	adjust_blood_flow(-amount) // max 'initial_flow' is 3
