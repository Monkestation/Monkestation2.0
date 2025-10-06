/datum/orderable_item/mining //for your generally useful things such as mining tools and equipment like scanners. Put the weaker less priority equipment lower on the list.
	category_index = CATEGORY_MINING

/datum/orderable_item/mining/mining_modsuit
	item_path = /obj/item/mod/control/pre_equipped/mining
	desc = "A mining-themed MODsuit that works best when in a mining environment."
	cost_per_order = 3000

/datum/orderable_item/mining/bhop
	item_path = /obj/item/clothing/shoes/bhop
	cost_per_order = 2500

/datum/orderable_item/mining/hiking_boots
	item_path = /obj/item/clothing/shoes/winterboots/ice_boots
	cost_per_order = 2500

/datum/orderable_item/mining/style_meter
	item_path = /obj/item/style_meter
	cost_per_order = 1500

/datum/orderable_item/mining/kheiralcuffs
	item_path = /obj/item/kheiral_cuffs
	cost_per_order = 750

/datum/orderable_item/mining/mining_belt
	item_path = /obj/item/storage/belt/mining
	cost_per_order = 500

/datum/orderable_item/mining/ashduelist
	item_path = /obj/item/storage/backpack/ashduelist
	cost_per_order = 1000

/datum/orderable_item/mining/rockspider
	item_path = /obj/item/storage/backpack/rockspider
	cost_per_order = 1000

/datum/orderable_item/mining/trenchjockey
	item_path = /obj/item/storage/backpack/trenchjockey
	cost_per_order = 1000

/datum/orderable_item/mining/mining_scanner
	item_path = /obj/item/t_scanner/adv_mining_scanner
	cost_per_order = 800

/datum/orderable_item/mining/resonator
	item_path = /obj/item/resonator
	cost_per_order = 800

/datum/orderable_item/mining/resonator_advanced
	item_path = /obj/item/resonator/upgraded
	cost_per_order = 2500

/datum/orderable_item/mining/marker_beacon
	item_path = /obj/item/stack/marker_beacon/ten
	cost_per_order = 100

/datum/orderable_item/mining/advanced_gps
	item_path = /obj/item/gps/advanced
	cost_per_order = 500

/datum/orderable_item/mining/tracking_implants
	item_path = /obj/item/storage/box/minertracker
	cost_per_order = 600

/datum/orderable_item/mining/fulton_core //i really have to wonder why the fulton core and the fulton were not next to each other from the beginning
	item_path = /obj/item/fulton_core
	cost_per_order = 400

/datum/orderable_item/mining/fulton
	item_path = /obj/item/extraction_pack
	cost_per_order = 1000

/datum/orderable_item/mining/jaunter
	item_path = /obj/item/wormhole_jaunter
	cost_per_order = 750

/datum/orderable_item/mining/skeleton_key
	item_path = /obj/item/skeleton_key
	cost_per_order = 777

/datum/orderable_item/mining/surplusnecro
	item_path = /obj/structure/closet/crate/necropolis/surplus
	desc = "A leftover necropolis crate from the Mining RND storage warehouse. Content quality not guranteed, but you dont need a key."
	cost_per_order = 5384 //your literally buying a necropolis crate, for no key, and no risk of combat or being dumped in a pit so it costs 3500 to shuttle buy

/datum/orderable_item/mining/conscription_kit
	item_path = /obj/item/storage/backpack/duffelbag/mining_conscript
	cost_per_order = 1500

/datum/orderable_item/mining/eva_kit
	item_path = /obj/item/storage/box/emergency_eva/explorer
	cost_per_order = 1000

/datum/orderable_item/mining/hardsuit_jetpack_upgrade
	item_path = /obj/item/jetpack_module
	cost_per_order = 250

/datum/orderable_item/mining/mining_drone //welcome to the big boy tab fellah
	item_path = /mob/living/basic/mining_drone
	cost_per_order = 800

/datum/orderable_item/mining/drone_health
	item_path = /obj/item/mine_bot_upgrade/health
	cost_per_order = 400

/datum/orderable_item/mining/drone_pka
	item_path = /obj/item/borg/upgrade/modkit/cooldown/minebot
	cost_per_order = 600

/datum/orderable_item/mining/drone_sentience
	item_path = /obj/item/slimepotion/slime/sentience/mining
	cost_per_order = 1000

/datum/orderable_item/mining/magnetic
	item_path = /obj/item/reagent_containers/hypospray/medipen/magnet
	cost_per_order = 250
