
/obj/machinery/vending/vendcation
	name = "VendCation"
	desc = "A vending machine for when you really wish you weren't at work right now."
	icon = 'monkestation/code/modules/biodome/icons/vending.dmi'
	icon_state = "vacation"
	icon_deny = "vacation-deny"
	panel_type = "panel15"
	product_slogans = "It's always island time!;Kick up your feet!;Feel the sun!;Don't forget sunscreen!"
	vend_reply = "Take it easy!"
	products = list(
		/obj/item/clothing/under/shorts/red = 2,
		/obj/item/clothing/under/shorts/green = 2,
		/obj/item/clothing/under/shorts/blue = 2,
		/obj/item/clothing/under/shorts/black = 2,
		/obj/item/clothing/under/shorts/purple = 2,
		/obj/item/clothing/under/dress/sundress = 2,
		/obj/item/clothing/under/dress/tango = 2,
		/obj/item/clothing/suit/costume/hawaiian = 4,
		/obj/item/clothing/glasses/sunglasses/cheap = 4,
		/obj/item/clothing/shoes/sandal = 4,
		/obj/item/clothing/head/costume/scarecrow_hat = 2,
		/obj/item/toy/beach_ball/branded = 4,
	)
	refill_canister = /obj/item/vending_refill/vacation
	default_price = PAYCHECK_CREW * 0.7
	extra_price = PAYCHECK_COMMAND
	payment_department = NO_FREEBIES
//	light_mask = "wardrobe-light-mask"
	light_color = LIGHT_COLOR_ELECTRIC_CYAN

/obj/item/vending_refill/vacation
	machine_name = "VendCation"
	icon_state = "refill_clothes"
