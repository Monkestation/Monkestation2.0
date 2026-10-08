/obj/effect/spawner/set_selector
	name = "Set Selector Spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "loot"
	layer = OBJ_LAYER
	///How many selector items do we spawn
	var/spawned_selector_amount = 0
	///The list we pass as our spawned selectors stock_list
	var/list/spawned_stock_list
	///The type of selector we create
	var/selector_type = /obj/item/set_selector

/obj/effect/spawner/set_selector/Initialize(mapload)
	. = ..()
	if(!loc || !spawned_selector_amount || !length(spawned_stock_list)) //dont spawn a bunch of thing in nullspace
		return

	spawned_stock_list = fill_with_ones(spawned_stock_list)
	var/to_spawn = spawned_selector_amount
	while(to_spawn) //we are getting qdeled anyway so we can just
		to_spawn--
		new selector_type(loc, spawned_stock_list) //spawn in loc so we work inside storage containers
	spawned_stock_list = null //we really want our list to be specific to a given set

/obj/effect/spawner/set_selector/wand_belt
	spawned_selector_amount = 5
	spawned_stock_list = list(/obj/item/gun/magic/wand/death = 1,
			/obj/item/gun/magic/wand/resurrection = 1,
			/obj/item/gun/magic/wand/polymorph = 1,
			/obj/item/gun/magic/wand/teleport = 1,
			/obj/item/gun/magic/wand/door = 1,
			/obj/item/gun/magic/wand/fireball = 1,
			/obj/item/gun/magic/wand/shrink = 1)
	selector_type = /obj/item/set_selector/wand_belt
