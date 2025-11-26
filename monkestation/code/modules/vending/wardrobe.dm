/obj/machinery/vending/wardrobe/xeno_wardrobe
	name = "XenoDrobe"
	desc = "A machine for dispending xenobio related clothing."
	icon_state = "xenodrobe"
	product_ads = "Pesky aliens eating away at your flesh? Dress for the job!"
	vend_reply = "Thank you for using the XenoDrobe"
	icon = 'monkestation/icons/obj/vending.dmi'
	products = list(
	/obj/item/storage/backpack/xenobiologist = 2,
	/obj/item/storage/backpack/satchel/xenobiologist = 2,
	/obj/item/storage/backpack/duffelbag/xenobiologist = 2,
	/obj/item/clothing/under/rank/rnd/xenobiologist = 2,
	/obj/item/clothing/under/rank/rnd/xenobiologist/skirt = 2,
	/obj/item/clothing/suit/toggle/labcoat/xenobiologist = 2,
	/obj/item/clothing/shoes/winterboots = 2,
	/obj/item/clothing/mask/gas = 2,
	/obj/item/clothing/gloves/color/grey/protects_cold = 2,
	)
	refill_canister = /obj/item/vending_refill/wardrobe/xeno_wardrobe
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/wardrobe/xeno_wardrobe
	machine_name = "xenoDrobe"
