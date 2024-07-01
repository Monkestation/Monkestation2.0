/obj/machinery/vending/cola/advancedgg
	name = "\improper Advanced GG, Drink-up!"
	desc = "A drink-up vendor provided by ADVANCED.GG."
	icon = 'monkestation/icons/obj/machines/advanced_gg_vendor.dmi'
	icon_state = "advanced_drink"
	panel_type = "advanced_drink_pannel"
	product_slogans = "Advanced GG Drink-up!: A revolutionary set of supplements designed with flexibility and a wide range of benefits!"
	product_ads = "Healthy yet delicious!;Come drink!;Peak preformance!;Refreshing your mind!;Sweet taste with the right blend of flavors!;Perfect for taking on the battleground of the gods!"
	products = list(
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/original = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/cherry_limeade = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/electric_frost_berry = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/blueberry_acai = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/peppermint_candy = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/rocket_pop = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/guava_berry = 6,
		/obj/item/reagent_containers/cup/soda_cans/advancedgg/water_melon_swirl = 6,
	)
	premium = list(
		//add stuff like shakers and shirts here, if I ever get to that.
	)
	contraband = list(
		/obj/item/reagent_containers/cup/soda_cans/advancedgg = 6,
	)
	refill_canister = /obj/item/vending_refill/advancedgg
	default_price = PAYCHECK_CREW * 0.7
	extra_price = PAYCHECK_CREW
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/advancedgg
	machine_name = "Advanced GG, Drink-up!"
	icon = 'monkestation/icons/obj/vending_restock.dmi'
	icon_state = "refill_advancedgg"

/datum/supply_pack/vending/advancedgg
	name = "Advanced GG Supply Crate"
	desc = "A revolutionary set of supplements designed with flexibility and a wide range of benefits! Contains a \
		Advanced GG vending machine refill."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/vending_refill/advancedgg)
	crate_name = "advanced gg supply crate"
	crate_type = /obj/structure/closet/crate


/datum/reagent/consumable/advancedgg
	name = "Advanced GG, Soul of Power"
	color = "#dbc3c3"
	taste_description = "assistant soul extract"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	quality = DRINK_VERYGOOD
/datum/reagent/consumable/advancedgg/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	var/effect = rand(1,2)
	if(liver)
		if(effect == 1)
			drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 0.5 * REM * seconds_per_tick)
		if(effect == 2)
			drinker.stamina.adjust(5 * REM * seconds_per_tick)
			drinker.adjustOxyLoss(-1 * REM * seconds_per_tick)
	return ..()
/obj/item/reagent_containers/cup/soda_cans/advancedgg
	name = "\improper Advanced GG, Soul of Power"
	desc = "Assistant soul extract for ULTRA POWER (does not give you powers)."
	icon = 'monkestation/icons/obj/drinks/advancedgg.dmi'
	icon_state = ""
	list_reagents = list(/datum/reagent/consumable/advancedgg = 30)
	drink_type = SUGAR
/obj/item/reagent_containers/cup/soda_cans/advancedgg/attack(mob/M, mob/living/user)
	if(iscarbon(M) && !reagents.total_volume && (user.istate & ISTATE_HARM) && user.zone_selected == BODY_ZONE_HEAD)
		if(M == user)
			user.visible_message(span_warning("[user] attempts to crushe the can of [src] on [user.p_their()] forehead but fails!"), span_notice("You attempt to crush the can of [src] on your forehead but fail."))
		else
			user.visible_message(span_warning("[user] attempts to crush the can of [src] on [M]'s forehead but they fail!"), span_notice("You attempt to crush the can of [src] on [M]'s forehead but you fail."))
		return TRUE
	return ..()

/datum/reagent/consumable/advancedgg/original
	name = "Advanced GG, Original"
	color = "#ebce2a"
	taste_description = "classic limeade"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/original
	name = "\improper Advanced GG, Original"
	desc = "Your neighborhood lemonade stand just got a major refresh! Bubbling with energy, nutrients and our primo brain-boosting formula, the OG version of ADVANCED PREMIUM ENERGY captures the taste of summer — minus the seeds and the four-pound bag of sugar."
	icon_state = "original"
	list_reagents = list(/datum/reagent/consumable/advancedgg/original = 30)

/datum/reagent/consumable/advancedgg/cherry_limeade
	name = "Advanced GG, Cherry Limeade"
	color = "#be58b6"
	taste_description = "tangy, sweet limeade"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/cherry_limeade
	name = "\improper Advanced GG, Cherry Limeade"
	desc = "Experience the irresistibly tangy, sweet taste of Mr. Fruit’s Cherry Limeade FOCUS. This nootropic formulation offers a delicious twist on a soda-fountain classic, while keeping you focused during epic sessions online, at work, or at the gym. It’s one of our most popular flavors, and once you try it, you’ll see why!"
	icon_state = "cherry_limeade"
	list_reagents = list(/datum/reagent/consumable/advancedgg/cherry_limeade = 30)

/datum/reagent/consumable/advancedgg/electric_frost_berry
	name = "Advanced GG, Electric Frost Berry"
	color = "#6cb7d4"
	taste_description = "juicy berries and tangy citrus"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/electric_frost_berry
	name = "\improper Advanced GG, Electric Frost Berry"
	desc = "Zap your senses and supercharge your gameplay experience with a delicious blend of juicy berries and tangy citrus. Twitch star IFrostBolt helped us envision this bold mix of fresh berries, finished with a bracing jolt of citrus to round out the flavor. Feel your arm hairs raising yet? With nootropics, vitamins and clean energy, Electric Frost Berry FOCUS ensures peak performance — without any range anxiety. Plug in and power up!"
	icon_state = "electric_frost_berry"
	list_reagents = list(/datum/reagent/consumable/advancedgg/electric_frost_berry = 30)

/datum/reagent/consumable/advancedgg/blueberry_acai
	name = "Advanced GG, Blueberry Acai"
	color = "#7f13b1"
	taste_description = "sweet-tart blueberries"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/blueberry_acai
	name = "\improper Advanced GG, Blueberry Acai"
	desc = "Blueberry Acai FOCUS features an irresistible combo of tangy acai and sweet-tart blueberries. Acai (pronounced “ah-sai-EE”) berries are native to the Amazon and have a uniquely tart, earthy flavor that’s complemented by the sweetness of the berries. Our blend is based on two superfoods known for their health benefits — but only FOCUS has the nootropic effects to keep fragging noobs till the break of dawn!"
	icon_state = "blueberry_acai"
	list_reagents = list(/datum/reagent/consumable/advancedgg/blueberry_acai = 30)

/datum/reagent/consumable/advancedgg/peppermint_candy
	name = "Advanced GG, Peppermint Candy"
	color = "#dfcdcd"
	taste_description = "\a minty-fresh treat"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/peppermint_candy
	name = "\improper Advanced GG, Peppermint Candy"
	desc = "Limited Edition alert! End this year on a high note with Peppermint Candy ENERGY, an electrifying, minty-fresh treat that captures the essence of those iconic red and white candy swirls. Add milk or your favorite alternative to make it extra festive. Perfect for keeping your spirits bright through the holiday hustle and staying pepped-up into the new year. But hurry: it's only here for a merry moment!"
	icon_state = "peppermint_candy"
	list_reagents = list(/datum/reagent/consumable/advancedgg/peppermint_candy = 30)

/datum/reagent/consumable/advancedgg/rocket_pop
	name = "Advanced GG, Rocket Pop"
	color = "#2b82c9"
	taste_description = "nostalgic red, white, and blue"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/rocket_pop
	name = "\improper Advanced GG, Rocket Pop"
	desc = "Get ready to ride the nostalgia rocket featuring the flavors of those red, white and blue popsicles straight from the ice cream truck! This frosty fusion of cherry, lime and blue raspberry is a true crowd-pleaser, and it’ll help you stay energized during intense sessions of your favorite FPS!"
	icon_state = "rocket_pop"
	list_reagents = list(/datum/reagent/consumable/advancedgg/rocket_pop = 30)

/datum/reagent/consumable/advancedgg/guava_berry
	name = "Advanced GG, Guava Berry"
	color = "#3adf11"
	taste_description = "sweet guavas and plump raspberries"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/guava_berry
	name = "\improper Advanced GG, Guava Berry"
	desc = "Indulge your senses in the luscious sweetness of ripe guavas, harmoniously paired with the bold, juicy notes of plump raspberries. This enticing blend is destined to become your daily must-have, offering a captivating experience for your taste buds."
	icon_state = "guava_berry"
	list_reagents = list(/datum/reagent/consumable/advancedgg/guava_berry = 30)

/datum/reagent/consumable/advancedgg/water_melon_swirl
	name = "Advanced GG, Watermelon Swirl"
	color = "#c93333"
	taste_description = "crisp watermelons"
/obj/item/reagent_containers/cup/soda_cans/advancedgg/water_melon_swirl
	name = "\improper Advanced GG, Watermelon Swirl"
	desc = "Tantalize your taste buds with the refreshing and invigorating essence of juicy, sun-kissed watermelons. With each sip, you can taste the pure, crisp essence of watermelon, as if you were biting into the fruit itself. The drink is impeccably smooth, with a slight velvety texture that glides effortlessly over your tongue, leaving a lingering freshness behind making it the perfect companion for a relaxing day at the beach."
	icon_state = "water_melon_swirl"
	list_reagents = list(/datum/reagent/consumable/advancedgg/water_melon_swirl = 30)
