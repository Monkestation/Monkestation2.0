/obj/effect/spawner/livingplush
	name = "Ghost controlled plush spawner"
	desc = "Will immediately create an offer a plushie to the ghosts"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/spawner/livingplush/Initialize(mapload)
	..()
	. = INITIALIZE_HINT_NORMAL
	INVOKE_ASYNC(src, PROC_REF(spawn_plush))

/obj/effect/spawner/livingplush/proc/spawn_plush()
	var/plush = pick(subtypesof(/obj/item/toy/plush) - /obj/item/toy/plush/lobotomy)
	plush = new plush(get_turf(src))

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [plush]?",
		check_jobban = ROLE_SENTIENCE,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SENTIENCE_POTION,
		alert_pic = plush,
		role_name_text = "[plush]",
	)

	if(!length(candidates))
		qdel(src)
		return

	var/mob/dead/observer/chosen = pick(candidates)
	var/mob/living/basic/possession_holder/weak/created = new(get_turf(plush), plush)

	created.PossessByPlayer(chosen.ckey)
	qdel(src)
