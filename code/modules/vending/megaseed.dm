/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!;Now with WAY more categories! YEEHAW!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	panel_type = "panel2"
	light_mask = "seeds-light-mask"
	product_categories = list(
		list(
			"name" = "Berries",
			"icon" = "holly-berry",
			"products" = list (
				/obj/item/seeds/banana = 3,
				/obj/item/seeds/berry = 3,
				/obj/item/seeds/cherry = 3,
				/obj/item/seeds/cucumber = 3,
				/obj/item/seeds/grape = 3,
				/obj/item/seeds/lanternfruit = 3,
				/obj/item/seeds/pineapple = 3,
				/obj/item/seeds/plum = 3,
				/obj/item/seeds/pumpkin = 5,
				/obj/item/seeds/toechtauese = 3,
				/obj/item/seeds/watermelon = 5,
			),
		),
		list(
			"name" = "Flowers",
			"icon" = "leaf",
			"products" = list(
				/obj/item/seeds/cabbage = 3,
				/obj/item/seeds/coffee = 3,
				/obj/item/seeds/cotton = 3,
				/obj/item/seeds/grass = 3,
				/obj/item/seeds/harebell = 3,
				/obj/item/seeds/herbs = 3,
				/obj/item/seeds/poppy/lily = 3,
				/obj/item/seeds/rose = 3,
				/obj/item/seeds/sunflower = 3,
				/obj/item/seeds/sugarcane = 3,
			),
		),
		list(
			"name" = "Grains",
			"icon" = "wheat-awn",
			"products" = list(
				/obj/item/seeds/corn = 3,
				/obj/item/seeds/korta_nut = 3,
				/obj/item/seeds/wheat/rice = 3,
				/obj/item/seeds/wheat = 3,
			),
		),

		list(
			"name" = "Medicinal",
			"icon" = "staff-snake",
			"products" = list(
				/obj/item/seeds/aloe = 3,
				/obj/item/seeds/ambrosia = 3,
				/obj/item/seeds/poppy/lily/trumpet = 3,
				/obj/item/seeds/tea = 3,
			),
		),
		list(
			"name" = "Mushrooms",
			"icon" = "bread-slice",
			"products" = list(
				/obj/item/seeds/chanter = 3,
				/obj/item/seeds/plump = 3,
				/obj/item/seeds/reishi = 3,
				/obj/item/seeds/glosscup = 3,
			)
		),
		list(
			"name" = "Nightshades",
			"icon" = "pepper-hot",
			"products" = list(
				/obj/item/seeds/chili/bell_pepper = 3,
				/obj/item/seeds/chili = 3,
				/obj/item/seeds/eggplant = 3,
				/obj/item/seeds/potato = 3,
				/obj/item/seeds/tobacco = 3,
				/obj/item/seeds/tomato = 3,
			),
		),
		list(
			"name" = "Peas",
			"icon" = "bowl-rice",
			"products" = list(
				/obj/item/seeds/greenbean = 3,
				/obj/item/seeds/peanut = 3,
				/obj/item/seeds/peas = 3,
				/obj/item/seeds/soya = 3,
			),
		),
		list(
			"name" = "Roots",
			"icon" = "carrot",
			"products" = list(
				/obj/item/seeds/carrot = 3,
				/obj/item/seeds/garlic = 3,
				/obj/item/seeds/ginger = 3,
				/obj/item/seeds/onion = 3,
				/obj/item/seeds/whitebeet = 3,
			),
		),
		list(
			"name" = "Trees",
			"icon" = "tree",
			"products" = list (
				/obj/item/seeds/apple = 3,
				/obj/item/seeds/agave = 3,
				/obj/item/seeds/cocoapod = 3,
				/obj/item/seeds/lemon = 3,
				/obj/item/seeds/lime = 3,
				/obj/item/seeds/olive = 3,
				/obj/item/seeds/orange = 3,
				/obj/item/seeds/tree = 3,
			),
		),
	)
	contraband = list(
		/obj/item/seeds/amanita = 3,
		/obj/item/seeds/cannabis = 3,
		/obj/item/seeds/glowshroom = 3,
		/obj/item/seeds/liberty = 3,
		/obj/item/seeds/nettle = 3,
		/obj/item/seeds/poppy = 3,
		/obj/item/seeds/starthistle = 3,
		/obj/item/seeds/cocaleaf = 3,
		/obj/item/seeds/coconut = 3,
		/obj/item/seeds/random = 3,
	)

	premium = list(
	)

	refill_canister = /obj/item/vending_refill/hydroseeds
	default_price = PAYCHECK_LOWER
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"
