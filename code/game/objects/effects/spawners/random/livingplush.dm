/obj/effect/spawner/random/livingplush
	name = "Ghost controlled plush spawner"
	desc = "Will immediately create an offer a plushie to the ghosts"
	loot_subtype_path = /obj/item/toy/plush
	loot = list()

/obj/effect/spawner/random/livingplush/post_spawn(obj/item/toy/plush/boi)
	set waitfor = FALSE

	if(boi.icon_state == "debug" || isnull(boi.icon_state))
		var/obj/item/toy/plush/plush = pick(subtypesof(boi.type))
		qdel(boi)
		boi = new plush

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as [boi]?",
		check_jobban = ROLE_SENTIENCE,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_SENTIENCE_POTION,
		alert_pic = boi,
		role_name_text = "[boi]",
	)

	if(!length(candidates))
		return

	var/mob/dead/observer/chosen = pick(candidates)
	var/mob/living/basic/possession_holder/created = new(get_turf(boi), boi)

	created.health_regeneration = 0 // disabling regen
	created.maxHealth = 50
	created.health = 50

	created.PossessByPlayer(chosen.ckey)

	//var/datum/language_holder/lang = created.get_language_holder()
	//lang.omnitongue = TRUE
