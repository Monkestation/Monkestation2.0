//////////////////////////////
//                          //
//        BLOOD NAIL        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist throws a blood dagger
//////////////////////////////

/obj/projectile/blooddagger
	name = "blood dagger"
	icon = 'monkestation/code/modules/bloody_cult/icons/projectiles_experimental.dmi'
	icon_state = "blood_dagger"
	damage = 5
	speed = 0.66
	var/absorbed = 0
	var/stacks = 0

/obj/projectile/blooddagger/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'monkestation/code/modules/bloody_cult/sound/forge_over.ogg', 100, 1)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.color = color
			S.update_icon()
	..()

/obj/projectile/blooddagger/Bump(atom/A)
	. = ..()
	if (isliving(A))
		forceMove(A.loc)
		var/mob/living/M = A
		if (!IS_CULTIST(M))
			density = FALSE
			invisibility = 101
			var/obj/effect/rooting_trap/bloodnail/nail = new (A.loc)
			nail.transform = transform
			if (color)
				nail.color = color
			else
				nail.color = COLOR_BLOOD
			if(isliving(A))
				nail.stick_to(A)
				var/mob/living/L = A
				L.take_overall_damage(damage,0)
				to_chat(L, "<span class='warning'>\The [src] stabs your body, sticking you in place.</span>")
				to_chat(L, "<span class='danger'>Resist or click the nail to dislodge it.</span>")
			else if(loc)
				var/turf/T = get_turf(src)
				nail.stick_to(T,get_dir(src,A))
			qdel(src)
			return
		else if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (!HAS_TRAIT(H, TRAIT_NOBLOOD))
				H.blood_volume += 5 + stacks * 5
				to_chat(H, "<span class='notice'>[firer ? "\The [firer]'s" : "The"] [src] enters your body painlessly, irrigating your vessels with some fresh blood.</span>")
			else
				to_chat(H, "<span class='notice'>[firer ? "\The [firer]'s" : "The"] [src] enters your body, but you have no vessels to irrigate.</span>")
			absorbed = 1
			playsound(H, 'monkestation/code/modules/bloody_cult/sound/bloodyslice.ogg', 30, 1)

	qdel(src)

/obj/projectile/blooddagger/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (isliving(target))
		var/mob/living/M = target
		if (IS_CULTIST(M))
			return BULLET_ACT_BLOCK
		if (M.stat == DEAD)
			return BULLET_ACT_BLOCK


/obj/projectile/blooddagger/narsie_act()
	return
