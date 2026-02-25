/datum/orderable_item/explorer // Explorer items from the voucher sets, and other spacce exploration items. Should stay pretty expensive. Golems and free miners dont need these either.
	category_index = CATEGORY_EXPLORER

/datum/orderable_item/explorer/laser
	item_path = /obj/item/gun/energy/laser/explorer
	cost_per_order = 2500

/datum/orderable_item/explorer/explosivecharge // if someone uses an emag and boulder machines to generate 100 c4 this could probably be increased
	item_path = /obj/item/grenade/c4/explosivecharge
	cost_per_order = 1500

/datum/orderable_item/explorer/bowie
	item_path = /obj/item/storage/belt/bowie_sheath 
	cost_per_order = 2500

/datum/orderable_item/explorer/combat // same as bowie but can be bayonetted on the lasgun
	item_path = /obj/item/knife/combat
	cost_per_order = 2500

/datum/orderable_item/explorer/hunting
	item_path = /obj/item/knife/hunting
	cost_per_order = 500

/datum/orderable_item/explorer/sledge 
	item_path = /obj/item/melee/sledgehammer
	cost_per_order = 10000

/datum/orderable_item/explorer/conscription_kit 
	item_path = /obj/item/storage/backpack/duffelbag/explorer_conscript
	cost_per_order = 2000

/datum/orderable_item/explorer/eva_kit
	item_path = /obj/item/storage/box/emergency_eva/explorer
	cost_per_order = 1000

/datum/orderable_item/explorer/hardsuit_jetpack_upgrade
	item_path = /obj/item/jetpack_module
	cost_per_order = 250
