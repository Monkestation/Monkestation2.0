#define DMG_MOD 0.5

/datum/movespeed_modifier/vampire_fortitude // Decent bit of slowdown.
	multiplicative_slowdown = 1

/obj/effect/abstract/fortitude
	icon_state = "blank"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE | VIS_INHERIT_LAYER | VIS_INHERIT_ID
	blend_mode = BLEND_INSET_OVERLAY
	color = "#888888"
	alpha = 0

/datum/action/cooldown/vampire/fortitude
	name = "Fortitude"
	desc = "Enhance your body even further at the cost of speed. Drains lifeforce while active."
	button_icon_state = "power_fortitude"
	cooldown_time = 1 MINUTE
	toggleable = TRUE
	constant_life_cost = LIFEFORCE_PER_HUMAN / 300 // 5 minutes of fortitude per human.

	/// How much damage Fortitude can still resist before breaking and causing backlash.
	var/durability = 80

	var/obj/effect/abstract/fortitude/grey_flash_overlay

/datum/action/cooldown/vampire/fortitude/Destroy()
	QDEL_NULL(grey_flash_overlay)
	return ..()

/datum/action/cooldown/vampire/fortitude/on_toggle_on()
	durability = initial(durability) * (vampire.get_stat_modified(VAMPIRE_STAT_TENACITY) / VAMPIRE_SP_MAXIMUM * 2) // Fortitude is granted at half points to max, meaning the scaling starts at 1, then reaches 2 at max.

	user.physiology?.brute_mod *= DMG_MOD
	user.physiology?.burn_mod *= DMG_MOD

	user.add_movespeed_modifier(/datum/movespeed_modifier/vampire_fortitude)

	grey_flash_overlay = new
	user.vis_contents += grey_flash_overlay

	RegisterSignal(user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))

	to_chat(user, span_notice("You enhance your body past it's limits. No mortal may harm you now."))

/datum/action/cooldown/vampire/fortitude/on_toggle_off()
	user.physiology?.brute_mod /= DMG_MOD
	user.physiology?.burn_mod /= DMG_MOD

	user.remove_movespeed_modifier(/datum/movespeed_modifier/vampire_fortitude)

	user.vis_contents -= grey_flash_overlay
	QDEL_NULL(grey_flash_overlay)

	UnregisterSignal(user, COMSIG_MOB_APPLY_DAMAGE)

	if(durability > 0) // Don't give two messages to the user.
		to_chat(user, span_notice("You stop enhancing your body, freed of the burden once more."))

/datum/action/cooldown/vampire/fortitude/proc/on_apply_damage(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
	SIGNAL_HANDLER

	if(damagetype != BRUTE && damagetype != BURN) // Don't bother with non-lethal damage types or suff/tox and whatever else.
		return

	durability -= damage / DMG_MOD // This is triggered after damage modifiers are applied, so we negate our own.

	user.visible_message(
		message = span_danger("[user]'s body flashes an iron grey!"),
		blind_message = span_hear("You hear a clang!")
	)

	playsound(user, 'sound/effects/bang.ogg', vol = 10, vary = TRUE)

	animate(grey_flash_overlay, 0.2 SECONDS, easing = EASE_OUT, flags = ANIMATION_PARALLEL, alpha = 150)
	animate(0.2 SECONDS, easing = EASE_IN, flags = ANIMATION_PARALLEL, alpha = 0)

	if(durability <= 0)
		shatter(attack_direction)

/datum/action/cooldown/vampire/fortitude/proc/shatter(attack_direction)
	user.visible_message(
		message = span_danger("[user] reels back in anguish!"),
		self_message = span_userdanger("Your Fortitude shatters!"),
		blind_message = span_hear("You hear something shatter!")
	)

	if(attack_direction)
		user.Move(get_step(user, attack_direction))

	user.stamina.adjust(-STAMINA_MAX * 0.25) // Puts you above the stun threshold, but below the exhaustion threshold, thus inflicting the latter.

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, emote), /datum/emote/living/groan::key) // This is called by a signal.

	playsound(user, 'sound/effects/glassbr2.ogg', vol = 50, vary = TRUE)

	toggle_off()

#undef DMG_MOD
