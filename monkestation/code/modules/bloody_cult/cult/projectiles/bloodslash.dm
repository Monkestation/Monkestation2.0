//////////////////////////////
//                          //
//        BLOOD SLASH       ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Used when a cultist swings a soul blade that has at least 5 blood in it.
//////////////////////////////

/obj/projectile/bloodslash
	name = "blood slash"
	icon = 'monkestation/code/modules/bloody_cult/icons/projectiles_experimental.dmi'
	icon_state = "bloodslash"
	damage = 15
	speed = 0.4
	extra_rotation = 45
	damage_type = BURN

/obj/projectile/bloodslash/Destroy()
	var/turf/T = get_turf(src)
	playsound(T, 'monkestation/code/modules/bloody_cult/sound/forge_over.ogg', 100, 1)
	if (!locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		S.count = 1
	..()

/obj/projectile/bloodslash/Bump(atom/A)
	if (isliving(A))
		forceMove(A.loc)
		var/mob/living/M = A
		if (!IS_CULTIST(M))
			..()
	qdel(src)

/obj/projectile/bloodslash/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if (isliving(target))
		var/mob/living/M = target
		if (IS_CULTIST(M))
			return BULLET_ACT_BLOCK
		if (M.stat == DEAD)
			return BULLET_ACT_BLOCK
		to_chat(M, span_warning("You feel a searing heat inside of you!") )

/obj/projectile/bloodslash/narsie_act()
	return
