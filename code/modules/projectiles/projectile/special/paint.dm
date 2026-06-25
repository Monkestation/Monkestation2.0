/obj/projectile/paintball
	name = "paintball"
	icon_state = "grey_glob_projectile"
	hitsound = 'sound/effects/attackblobfast.ogg'
	hitsound_wall = 'sound/effects/attackblobfast.ogg'
	damage = 3
	damage_type = BRUTE
	stamina = 10
	armor_flag = BIO //bio makes the most sense here
	///How many paint status effect stacks do we apply
	var/applied_paint_stacks = 1

	//eyeblur = 20 SECONDS
	//knockdown = 10

/obj/projectile/paintball/on_hit(mob/living/target, blocked = 0, pierce_hit)
	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', (isturf(target) ? "splash_floor" : "splash"))
	splash_animation.color = color
	target.flick_overlay_view(splash_animation, 1 SECONDS)
	var/did_paint = paint_target(target)
	if(istype(target))
		if(!did_paint) //dont hit members of the same gang, did_paint will only be true if our target was from another gang
			return

		var/datum/status_effect/painted/status = target.has_status_effect(/datum/status_effect/painted)
		if(status.stacks >= status.max_stacks)
			damage *= 3
			stamina *= 2
	return ..()

/obj/projectile/paintball/proc/paint_target(atom/target, blocked = 0, pierce_hit)
	SSgangs.paint_atom(target, color, applied_paint_stacks)
