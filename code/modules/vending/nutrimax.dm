/obj/machinery/vending/hydronutrients
	name = "\improper NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	panel_type = "panel2"
	light_mask = "nutri-light-mask"
	product_categories = list(
		list(
			"name" = "Chemicals",
			"icon" = "prescription-bottle",
			"products" = list(
				/obj/item/reagent_containers/cup/bottle/nutrient/ez = 30,
				/obj/item/reagent_containers/cup/bottle/nutrient/l4z = 20,
				/obj/item/reagent_containers/cup/bottle/nutrient/rh = 10,
				/obj/item/reagent_containers/spray/pestspray = 20,
				)
		),
		list(
			"name" = "Ranching",
			"icon" = "feather",
			"products" = list(
				/obj/item/chicken_carrier = 5,
				/obj/item/chicken_feed = 8,
				/obj/item/chicken_scanner = 3,
				/obj/item/storage/bag/egg = 5,
			)
		),
		list(
			"name" = "Tools",
			"icon" = "trowel",
			"products" = list(
				/obj/item/cultivator = 3,
				/obj/item/secateurs = 3,
				/obj/item/shovel/spade = 3,
				/obj/item/plant_analyzer = 4,
				/obj/item/storage/bag/plants = 5,
				/obj/item/reagent_containers/syringe = 5,
			)
		),
	)
	contraband = list(
		/obj/item/reagent_containers/cup/bottle/saltpetre = 8, //Adding saltpetre to make the 'optimal chem mix' more intuitive to newer botanists
		/obj/item/reagent_containers/cup/bottle/ammonia = 8,
		/obj/item/reagent_containers/cup/bottle/diethylamine = 2, //changed vendor quantity to make 'optimal chem mix' ratio more intuitive
	)
	premium = list(
		/obj/item/bottle_kit = 3,
		/obj/item/book/manual/botanical_lexicon = 8,
		/obj/item/book/manual/chicken_encyclopedia = 8,
		/obj/item/reagent_containers/spray/waterflower = 1,
	)
	refill_canister = /obj/item/vending_refill/hydronutrients
	default_price = PAYCHECK_CREW * 0.8
	extra_price = PAYCHECK_COMMAND * 0.8
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/hydronutrients
	machine_name = "NutriMax"
	icon_state = "refill_plant"
