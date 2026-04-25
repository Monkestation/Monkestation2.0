/obj/machinery/vending/egodrobe
	name = "\improper EGOdrobe"
	desc = "A vending machine designed to dispense abnormal outfits."
	icon_state = "egosuit"
	panel_type = "panel14"
	product_categories = list(
		list(
			"name" = "ZAYIN",
			"icon" = "z",
			"products" = list(
				/obj/item/clothing/suit/toggle/labcoat = 4
			),
		),
		list(
			"name" = "TETH",
			"icon" = "t",
			"products" = list(
				/obj/item/clothing/under/rank/rnd/roboticist = 4
			),
		),
		list(
			"name" = "HE",
			"icon" = "h",
			"products" = list(
				/obj/item/stack/cable_coil = 4,
			),
		),
		list(
			"name" = "WAW",
			"icon" = "w",
			"products" = list(
				/obj/item/assembly/flash/handheld = 4
			),
		),
		list(
			"name" = "ALEPH",
			"icon" = "a",
			"products" = list(
				/obj/item/stock_parts/power_store/cell/high = 12
			),
		)
	)

	refill_canister = /obj/item/vending_refill/egosuit
	default_price = PAYCHECK_CREW * 0.8 //Default of 40.
	extra_price = PAYCHECK_CREW
	payment_department = NO_FREEBIES
	light_mask = "egosuit-light-mask"

/obj/item/vending_refill/egosuit
	machine_name = "EGOdrobe"
	icon_state = "refill_egosuit"
