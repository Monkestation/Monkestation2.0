/obj/machinery/vending/wallmed
	name = "\improper NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	icon_deny = "wallmed-deny"
	panel_type = "wallmed-panel"
	density = FALSE
	product_categories = list(
		list(
			"name" = "Medical",
			"icon" = "head-side-virus",
			"products" = list(
				/obj/item/stack/medical/gauze = 8,
				/obj/item/reagent_containers/syringe = 12,
				/obj/item/reagent_containers/dropper = 3,
				/obj/item/healthanalyzer = 4,
				/obj/item/wrench/medical = 1,
				/obj/item/stack/sticky_tape/surgical = 3,
				/obj/item/healthanalyzer/simple = 4,
				/obj/item/stack/medical/ointment = 2,
				/obj/item/stack/medical/suture = 2,
				/obj/item/stack/medical/bone_gel = 4,
				/obj/item/cane/white = 2,
				/obj/item/clothing/glasses/eyepatch/medical = 2,
				/obj/item/reagent_containers/medipen/deforest/robot_system_cleaner = 4,
			),
		),
		list(
			"name" = "Hyposprays",
			"icon" = "syringe",
			"products" = list(
				/obj/item/hypospray = 5,
				/obj/item/storage/medkit/hypospray = 3,
				/obj/item/storage/medkit/hypospray/advanced = 1,
				/obj/item/storage/lockbox/vialbox = 5,
			),
		))
	contraband = list(
		/obj/item/reagent_containers/pill/tox = 2,
		/obj/item/reagent_containers/pill/morphine = 2,
		/obj/item/storage/box/gum/happiness = 1,
	)
	refill_canister = /obj/item/vending_refill/wallmed
	default_price = PAYCHECK_COMMAND //Double the medical price due to being meant for public consumption, not player specfic
	extra_price = PAYCHECK_COMMAND * 1.5
	payment_department = ACCOUNT_MED
	tiltable = FALSE
	light_mask = "wallmed-light-mask"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/vending/wallmed, 32)

/obj/item/vending_refill/wallmed
	machine_name = "NanoMed"
	icon_state = "refill_medical"
