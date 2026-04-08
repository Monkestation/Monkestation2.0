//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	panel_type = "panel14"
	light_mask = "robotics-light-mask"
	req_access = list(ACCESS_ROBOTICS)
	product_categories =  list(
		list(
			"name" = "Equipment & Parts",
			"products" = list(
				/obj/item/stack/cable_coil = 4,
				/obj/item/assembly/flash/handheld = 4,
				/obj/item/stock_parts/power_store/cell/high = 4,
				/obj/item/assembly/signaler = 3,
				/obj/item/tank/internals/anesthetic = 2,
				/obj/item/clothing/mask/breath/medical = 2,
				/obj/item/screwdriver = 3,
				/obj/item/crowbar = 3,
				/obj/item/storage/bag/construction = 1,
				/obj/item/storage/bag/bio = 1,
				/obj/item/storage/box/bodybags = 1,



			),
		),

		list(
			"name" = "Bot Assembly Parts",
			"products" = list(
				/obj/item/clothing/head/utility/hardhat = 3,
				/obj/item/extinguisher/empty = 3,
				/obj/item/reagent_containers/cup/bucket = 3,
				/obj/item/assembly/prox_sensor = 6,
				/obj/item/healthanalyzer = 3,
				/obj/item/storage/medkit = 3,
				/obj/item/bot_assembly/hygienebot = 3,
				/obj/item/stack/ducts = 3,
				/obj/item/bot_assembly/secbot = 1,
				/obj/item/storage/crayons = 1,



			),
		),
	)
	contraband = list(
		/obj/item/stock_parts/power_store/cell/potato = 3, //adds clown stuff to make honk mechs
		/obj/item/storage/box/clown = 5,
		/obj/item/bikehorn = 1,
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/clothing/shoes/clown_shoes = 1,
		/obj/item/melee/baton/security = 1, //so beepsky can be completed


	)
	premium = list(
		/obj/item/shears = 1,
		/obj/item/storage/box/flashes = 2,
		/obj/item/reagent_containers/medipen/deforest/robot_liquid_solder = 2,
		/obj/item/reagent_containers/medipen/deforest/robot_system_cleaner = 2,
		/obj/item/clothing/gloves/latex/surgical = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,


	)
	refill_canister = /obj/item/vending_refill/robotics
	default_price = PAYCHECK_COMMAND
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/robotics
	machine_name = "Robotech Deluxe"
	icon_state = "refill_engi"
