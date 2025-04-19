
/obj/effect/cult_ritual/backup_spawn
	name = "gateway"
	desc = "Something is coming through!"
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "runetrigger-build"
	anchored = 1
	mouse_opacity = 1
	var/static/bloodstone_backup = 0

/obj/effect/cult_ritual/backup_spawn/New()
	..()
	spawn (30)
		bloodstone_backup++
		var/mobtype
		switch (bloodstone_backup)
			if (0, 1, 2)
				mobtype = pick(
					1;/mob/living/basic/bat,
					2;/mob/living/basic/bat,
					)
			if (3, 4)
				mobtype = pick(
					1;/mob/living/basic/bat,
					3;/mob/living/basic/bat,
					2;/mob/living/basic/bat,
					)
			if (5, 6)
				mobtype = pick(
					2;/mob/living/basic/bat,
					2;/mob/living/basic/bat,
					1;/mob/living/basic/bat,
					)
			if (7 to INFINITY)
				mobtype = pick(
					2;/mob/living/basic/bat,
					1;/mob/living/basic/bat,
					)
		new mobtype(get_turf(src))
		qdel(src)
