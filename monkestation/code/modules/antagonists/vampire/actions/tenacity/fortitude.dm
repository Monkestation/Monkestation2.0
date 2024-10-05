/datum/armor/vampire_fortitude // Way stronger than nanite armor.
	melee = 40
	bullet = 40
	laser = 30
	energy = 30

/datum/movespeed_modifier/vampire_fortitude // Decent bit of slowdown.
	multiplicative_slowdown = 0.5

/datum/action/cooldown/vampire/fortitude
	name = "Fortitude"
	desc = "Enhance your body even further at the cost of speed. Drains lifeforce while active."
	button_icon_state = "power_fortitude"
	cooldown_time = 1 MINUTE
	toggleable = TRUE
	constant_life_cost = LIFEFORCE_PER_HUMAN / 300 // 5 minutes of fortitude per human.

	/// How much damage Fortitude can still resist before breaking and causing backlash.
	var/durability = 100

/datum/action/cooldown/vampire/fortitude/on_toggle_on()
	durability = initial(durability) * (vampire.get_stat_modified(VAMPIRE_STAT_TENACITY) / VAMPIRE_SP_MAXIMUM * 2) // Fortitude is granted at half points to max, meaning the scaling starts at 1, then reaches 2 at max.

	user.set_armor(user.get_armor().add_other_armor(/datum/armor/vampire_fortitude))
	user.add_movespeed_modifier(/datum/movespeed_modifier/vampire_fortitude)

	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))

	to_chat(user, span_notice("You enhance your body past it's limits. No one may hurt you any longer."))

/datum/action/cooldown/vampire/fortitude/on_toggle_off()
	user.set_armor(user.get_armor().subtract_other_armor(/datum/armor/vampire_fortitude))
	user.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_fortitude)

	UnregisterSignal(user, COMSIG_MOB_APPLY_DAMAGE)

	to_chat(user, span_notice("You stop enhancing your body, freed of the burden once more."))

/datum/action/cooldown/vampire/fortitude/proc/on_apply_damage(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
	SIGNAL_HANDLER

	if(damagetype != BRUTE && damagetype != BURN) // Don't bother with non-lethal damage types or suff/tox and whatever else.
		return

	durability -= damage

	user.visible_message(
		message = span_danger("[user]'s body flashes an iron grey!"),
		blind_message = span_hear("You hear a clang!")
	)

	if(durability <= 0)
		shatter(attack_direction)
		return

/datum/action/cooldown/vampire/fortitude/proc/shatter(attack_direction)
	user.visible_message(
		message = span_danger("[user] reels back in anguish!"),
		self_message = span_userdanger("Your Fortitude shatters!"),
		blind_message = span_hear("You hear something shatter!")
	)

	if(attack_direction)
		user.Move(get_step(user, attack_direction))

	user.stamina.adjust(-STAMINA_MAX * 0.25) // Puts you above the stun threshold, but below the exhaustion threshold, thus inflicting the latter.

	toggle_off()
