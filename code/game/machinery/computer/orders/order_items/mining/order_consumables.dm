/datum/orderable_item/consumables
	category_index = CATEGORY_CONSUMABLES

/datum/orderable_item/consumables/survival_pen
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival
	cost_per_order = 500

/datum/orderable_item/consumables/luxury_pen
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/luxury
	cost_per_order = 1000

/datum/orderable_item/consumables/luxury_pen/oozling //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/luxury/oozling
	cost_per_order = 1000

/datum/orderable_item/consumables/survival_pen/synthcare //monkestation edit CHEAPER THAN SURVIVAL PEN BECAUSE IT DOES NOT HEAL NEARLY AS MUCH AS A SURVIVAL PEN
	item_path = /obj/item/reagent_containers/hypospray/medipen/synthcare
	cost_per_order = 250

/datum/orderable_item/consumables/luxury_pen/synthcare //monkestation edit WAY CHEAPER THAN A LUX PEN BECAUSE DOES NOT INCLUDE ALL THE FANCY CHEMS AND HAS DEVESTATING OVERDOSE EFFECTS
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/synthcare
	cost_per_order = 750

/datum/orderable_item/consumables/temperature //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/temperature
	cost_per_order = 200

/datum/orderable_item/consumables/magnetic //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/magnet
	cost_per_order = 250

/datum/orderable_item/consumables/speed //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/speed
	cost_per_order = 550

/datum/orderable_item/consumables/penthrite //monkestation edit
	item_path = /obj/item/reagent_containers/hypospray/medipen/survival/penthrite
	cost_per_order = 750

/datum/orderable_item/consumables/medkit_brute
	item_path = /obj/item/storage/medkit/brute
	cost_per_order = 600

/datum/orderable_item/consumables/medkit_fire
	item_path = /obj/item/storage/medkit/fire
	desc = "For emergency magmatic burn relief."
	cost_per_order = 600

/datum/orderable_item/consumables/medkit_basic
	item_path = /obj/item/storage/medkit/regular
	cost_per_order = 400

/datum/orderable_item/consumables/synthcaresurgeon //monke edit, basically a medkit implant for synthetics
	item_path = /obj/item/autosurgeon/toolset/synthcare
	cost_per_order = 750

/datum/orderable_item/consumables/whiskey
	item_path = /obj/item/reagent_containers/cup/glass/bottle/whiskey
	cost_per_order = 100

/datum/orderable_item/consumables/absinthe
	item_path = /obj/item/reagent_containers/cup/glass/bottle/absinthe/premium
	cost_per_order = 100

/datum/orderable_item/consumables/bubblegum
	item_path = /obj/item/storage/box/gum/bubblegum
	cost_per_order = 100

/datum/orderable_item/consumables/havana_cigars
	item_path = /obj/item/clothing/mask/cigarette/cigar/havana
	cost_per_order = 150

/datum/orderable_item/consumables/havana_cigars
	item_path = /obj/item/clothing/mask/cigarette/cigar/havana
	cost_per_order = 150

/datum/orderable_item/consumables/tracking_implants
	item_path = /obj/item/storage/box/minertracker
	cost_per_order = 600

/datum/orderable_item/consumables/space_cash
	item_path = /obj/item/stack/spacecash/c1000
	desc = "A stack of space cash worth 1000 credits."
	cost_per_order = 2000

/datum/orderable_item/consumables/surplusnecro //monke edit
	item_path = /obj/structure/closet/crate/necropolis/surplus
	desc = "A leftover necropolis crate from the Mining RND storage warehouse. Content quality not guranteed, but you dont need a key."
	cost_per_order = 6750 //your literally buying a necropolis crate, for no key, and no risk of combat or being dumped in a pit
