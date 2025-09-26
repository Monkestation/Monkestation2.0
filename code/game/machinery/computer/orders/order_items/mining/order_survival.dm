/datum/orderable_item/survival //should be used for anything that makes sure the miner is not dead in ways that do not involve killing stuff
	category_index = CATEGORY_SURVIVAL

/datum/orderable_item/survival/survival_pen
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival
	cost_per_order = 500

/datum/orderable_item/survival/luxury_pen
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/luxury
	cost_per_order = 1000

/datum/orderable_item/survival/luxury_pen/oozeling //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/luxury/oozeling
	cost_per_order = 1000

/datum/orderable_item/survival/survival_pen/synthcare //monkestation edit CHEAPER THAN SURVIVAL PEN BECAUSE IT DOES NOT HEAL NEARLY AS MUCH AS A SURVIVAL PEN
	item_path = /obj/item/reagent_containers/hypospray/medipen/synthcare
	cost_per_order = 250

/datum/orderable_item/survival/luxury_pen/synthcare //monkestation edit WAY CHEAPER THAN A LUX PEN BECAUSE DOES NOT INCLUDE ALL THE FANCY CHEMS AND HAS DEVESTATING OVERDOSE EFFECTS
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/synthcare
	cost_per_order = 750

/datum/orderable_item/survival/synthcaresurgeon //monke edit, basically a medkit implant for synthetics
	item_path = /obj/item/autosurgeon/toolset/synthcare
	cost_per_order = 750

/datum/orderable_item/survival/robopiates //monkestation edit Slows you down so only really good for out of fight usage
	item_path = /obj/item/reagent_containers/hypospray/medipen/synthpainkill
	cost_per_order = 500

/datum/orderable_item/survival/temperature //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/temperature
	cost_per_order = 200

/datum/orderable_item/survival/magnetic //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/magnet
	cost_per_order = 250

/datum/orderable_item/survival/speed //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/speed
	cost_per_order = 550

/datum/orderable_item/survival/penthrite //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/penthrite
	cost_per_order = 750

/datum/orderable_item/survival/mining_stabilizer
	item_path = /obj/item/mining_stabilizer
	cost_per_order = 400

/datum/orderable_item/survival/capsule
	item_path = /obj/item/survivalcapsule
	cost_per_order = 400

/datum/orderable_item/survival/medkit_basic
	item_path = /obj/item/storage/medkit/regular
	cost_per_order = 400

/datum/orderable_item/survival/medkit_brute
	item_path = /obj/item/storage/medkit/brute
	cost_per_order = 600

/datum/orderable_item/survival/medkit_fire
	item_path = /obj/item/storage/medkit/fire
	desc = "For emergency magmatic burn relief."
	cost_per_order = 600

/datum/orderable_item/survival/rescue_hook
	item_path = /obj/item/fishing_hook/rescue
	desc = "A large hook for fishing people out of chasms. You will need to provide your own rod and string..."
	cost_per_order = 500
