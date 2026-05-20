/obj/projectile/paintball
	name = "paintball"
	icon_state = "grey_glob_projectile"
	hitsound = 'sound/effects/attackblobfast.ogg'
	hitsound_wall = 'sound/effects/attackblobfast.ogg'
	damage = 1
	damage_type = BRUTE
	stamina = 10
	armor_flag = BIO //bio makes the most sense here
	///How many paint status effect stacks do we apply
	var/applied_paint_stacks = 1

	//eyeblur = 20 SECONDS
	//knockdown = 10

/obj/projectile/paintball/on_hit(atom/target, blocked = 0, pierce_hit)
	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', (isturf(target) ? "splash_floor" : "splash"))
	splash_animation.color = color
	target.flick_overlay_view(splash_animation, 1 SECONDS)
	if(color)
		paint_target(target)
	return ..()

/obj/projectile/paintball/proc/paint_target(atom/target, blocked = 0, pierce_hit)
	if(isturf(target))
		target.add_atom_colour(color_transition_filter(color, SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)
	else if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/painted, applied_paint_stacks, src)
