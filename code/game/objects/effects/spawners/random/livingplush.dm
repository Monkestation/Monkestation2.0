/obj/effect/spawner/random/livingplush
	name = "Ghost controlled plush spawner"
	desc = "Will immediately create an offer a plushie to the ghosts"
	loot_subtype_path = /obj/item/toy/plush
	loot = list()


/obj/effect/spawner/random/livingplush/post_spawn(atom/movable/spawned_loot)
	var/obj/item/toy/plush/boi = spawned_loot
	boi.AddComponent(/datum/component/ghost_object_control,boi,TRUE)
	var/datum/component/ghost_object_control/spiritholder = boi.GetComponent(/datum/component/ghost_object_control)
	if(!(spiritholder.bound_spirit))
		spiritholder.request_control(0.6)
