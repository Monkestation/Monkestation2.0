/mob/living/basic/construct
	var/list/healers = list()
	var/construct_color = COLOR_BLOOD
	var/new_glow = FALSE

/mob/living/basic/construct/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if (healers.len > 0)
		for (var/mob/living/basic/construct/artificer/perfect/P in healers)
			P.move_ray()

/mob/living/basic/construct/update_overlays()
	. = ..()
	if(!new_glow)
		return
	var/icon/glowicon = icon(icon, "glow-[icon_state]", src)
	glowicon.Blend(construct_color, ICON_ADD)
	. += emissive_appearance(glowicon, offset_spokesman = src)
	. += mutable_appearance(glowicon, offset_spokesman = src)

	var/damage = maxHealth - health
	var/icon/damageicon
	if (damage > (2*maxHealth/3))
		damageicon = icon(icon, "[icon_state]_damage_high", src)
	else if (damage > (maxHealth/3))
		damageicon = icon(icon, "[icon_state]_damage_low", src)
	if (damageicon)
		damageicon.Blend(construct_color, ICON_ADD)
		. += emissive_appearance(damageicon, offset_spokesman = src)
		. += mutable_appearance(damageicon, offset_spokesman = src)

/mob/living/basic/construct/adjust_health(amount, updating_health, forced)
	. = ..()
	update_appearance()
