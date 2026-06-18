
// Uncomment when sprites are done in part 2
// //Goblin cuisine is utilitarian, simple, and in most cases, toxic to non-goblins. The main livestock on Gatosh are glerms, and their meat is toxic to non-goblins
// /datum/reagent/toxin/glermtoxin
// 	name = "Glerm Toxin"
// 	description = "A fizzing liquid present in almost all parts of a glerm. Goblin livers are uniquely adapted to process it."
// 	color = "#3aeb23"
// 	taste_description = "sourness"
// 	taste_mult = 1.2
// 	harmful = TRUE
// 	evaporation_rate = 4
// 	toxpwr = 0.25

// /datum/reagent/toxin/glermtoxin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
// 	if(HAS_TRAIT(affected_mob, TRAIT_GOBLIN_METABOLISM))
// 		affected_mob.adjustToxLoss(-toxpwr * 2 * REM * normalise_creation_purity() * seconds_per_tick, FALSE, required_biotype = affected_biotype) //Goblins heal twice the toxpower from glerm toxin. Not a lot but a little flavor
// 		return
// 	..()

// /datum/reagent/toxin/bad_food/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) //Goblins eat a lot of gross stuff
// 	if(HAS_TRAIT(affected_mob, TRAIT_GOBLIN_METABOLISM))
// 		return
// 	..()

// ////////////- Glerm Meats -////////////

// /obj/item/food/meat/slab/glerm //Raw glerm meat
// 	name = "glerm meat"
// 	desc = "A slab of acidic meat."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "slab_raw"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 4,
// 		/datum/reagent/consumable/nutriment/vitamin = 2,
// 		/datum/reagent/toxin/glermtoxin = 4,
// 	)
// 	bite_consumption = 4
// 	tastes = list("meat" = 1, "acid" = 1)
// 	foodtypes = RAW | MEAT | TOXIC

// /obj/item/food/meat/slab/glerm/make_processable() //Slicing the glerm meat
// 	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/meat/rawcutlet/glerm, 3, 3 SECONDS, table_required = TRUE, screentip_verb = "Cut")

// /obj/item/food/meat/slab/glerm/make_grillable() //Grilling the glerm meat
// 	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/glerm, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE, /datum/pollutant/food/fried_meat)

// /obj/item/food/meat/steak/glerm //Cooked glerm meat
// 	name = "glerm steak"
// 	desc = "A slab of cooked acidic meat. Doesn't look any more edible."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "slab_cooked"
// 	tastes = list("meat" = 1, "acid" = 1)
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 7,
// 		/datum/reagent/consumable/nutriment/vitamin = 3,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 	)
// 	foodtypes = MEAT | TOXIC

// /obj/item/food/meat/rawcutlet/glerm //Raw glerm cutlet
// 	name = "raw glerm cutlet"
// 	desc = "A slice of acidic meat."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "cutlet_raw"
// 	tastes = list("meat" = 1, "acid" = 1)
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 1,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 	)
// 	foodtypes = RAW | MEAT | TOXIC

// /obj/item/food/meat/rawcutlet/glerm/make_grillable() //Grilling the glerm cutlet
// 	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/glerm, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE, /datum/pollutant/food/fried_meat)

// /obj/item/food/meat/cutlet/glerm //Cooked glerm cutlet
// 	name = "glerm cutlet"
// 	desc = "A slice of cooked acidic meat. This too doesn't look any more edible."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "cutlet_cooked"
// 	tastes = list("meat" = 1, "acid" = 1)
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 2,
// 		/datum/reagent/toxin/glermtoxin = 1,
// 	)
// 	foodtypes = MEAT | TOXIC

// /obj/item/food/glermjerky //Glerm jerky
// 	name = "glerm jerky"
// 	desc = "Glerm-flesh dried in the heat of a desert planet. Or a drying rack"
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "jerky"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 5,
// 		/datum/reagent/consumable/nutriment/vitamin = 2,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 	)
// 	junkiness = 0
// 	foodtypes = MEAT | TOXIC

// /datum/crafting_recipe/food/drying/glermjerky //Drying the glerm cutlet
// 	reqs = list(/obj/item/food/meat/cutlet/glerm = 1)
// 	result = /obj/item/food/glermjerky
// 	category = CAT_GOBFOOD

// ////////////- Glerm Milk & Cheese -////////////

// /datum/reagent/consumable/milk/glerm //Glerm milk
// 	name = "Glerm \"milk\""
// 	description = "A pale green and creamy liquid."
// 	nutriment_factor = 5 * REAGENTS_METABOLISM
// 	color = "#e6ffe5"
// 	taste_mult = 5
// 	taste_description = "creamy and acidic"
// 	var/toxpwr = 0.1

// /datum/reagent/consumable/milk/glerm/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
// 	if(HAS_TRAIT(affected_mob, TRAIT_GOBLIN_METABOLISM))
// 		affected_mob.adjustToxLoss(-toxpwr * 2 * REM * normalise_creation_purity() * seconds_per_tick, FALSE, required_biotype = affected_biotype)
// 	else
// 		affected_mob.adjustToxLoss(toxpwr * REM * normalise_creation_purity() * seconds_per_tick, FALSE, required_biotype = affected_biotype)

// /obj/item/reagent_containers/condiment/glermmilk //Congealed glerm toxin
// 	name = "glerm \"milk\" carton"
// 	desc = "Sour and creamy \"milk\" extracted from an adult glerm."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "glermmilk"
// 	list_reagents = list(/datum/reagent/consumable/milk/glerm = 50)

// /datum/orderable_item/reagents/glermmilk
// 	name = "Glerm \"Milk\""
// 	item_path = /obj/item/reagent_containers/condiment/glermmilk
// 	cost_per_order = 80

// /obj/item/food/cheese/wheel/glerm //Glerm cheese "wheel"
// 	name = "glerm \"cheese\" mass"
// 	desc = "Some sort of solidified protein extracted from an adult glerm."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "cheese_wheel"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 10,
// 		/datum/reagent/consumable/nutriment/protein = 5,
// 		/datum/reagent/consumable/nutriment/vitamin = 5,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 	)
// 	foodtypes = TOXIC | DAIRY

// /obj/item/food/cheese/wheel/glerm/make_processable()
// 	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cheese/wedge/glerm, 3, 3 SECONDS, table_required = TRUE, screentip_verb = "Cut")

// /obj/item/food/cheese/wedge/glerm //Glerm cheese slice
// 	name = "glerm \"cheese\" slice"
// 	desc = "A slice of glerm \"cheese\"."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "cheese_slice"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 2,
// 		/datum/reagent/consumable/nutriment/protein = 1,
// 		/datum/reagent/consumable/nutriment/vitamin = 1,
// 		/datum/reagent/toxin/glermtoxin = 1,
// 	)
// 	foodtypes = TOXIC | DAIRY

// /datum/chemical_reaction/food/cheesewheel/glerm //Recipe for making glerm cheese
// 	required_reagents = list(/datum/reagent/consumable/milk/glerm = 40)
// 	required_catalysts = list(/datum/reagent/consumable/enzyme = 5)

// 	resulting_food_path = /obj/item/food/cheese/wheel/glerm

// ////////////- Miscellaneous Food -////////////

// /obj/item/food/canned/wutchacalitz //Shelf stable, highly nutritious, but boring tasting packaged food from the previous civilization on Gatosh. The production method has been lost to time, and as such it is a rare commodity
// 	name = "canned wutchacalitz"
// 	desc = "A can of...something. The writing is in a language you don't understand, but it has a picture of a fork and knife on it."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "wutchacalitz"
// 	trash_type = /obj/item/trash/can/food/wutchacalitz
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 10,
// 		/datum/reagent/consumable/nutriment/protein = 20,
// 		/datum/reagent/consumable/nutriment/vitamin = 7,
// 		/datum/reagent/medicine/granibitaluri = 5,
// 	)
// 	tastes = list("something" = 1, "everything" = 1, "nothing" = 1)
// 	foodtypes = NONE
// 	venue_value = FOOD_PRICE_EXOTIC

// /obj/item/trash/can/food/wutchacalitz
// 	name = "empty can of wutchacalitz"
// 	desc = "An empty can. The writing is in a language you don't understand, but it has a picture of a fork and knife on it."
// 	icon_state = "wutchacalitz_empty"

// /obj/item/food/glermtail/raw //Raw glerm tail
// 	name = "glerm tail"
// 	desc = "The wriggling tail of a glerm."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "glermtail_raw"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 4,
// 		/datum/reagent/consumable/nutriment/vitamin = 2,
// 		/datum/reagent/toxin/glermtoxin = 4,
// 	)
// 	bite_consumption = 4
// 	tastes = list("meat" = 1, "acid" = 1)
// 	foodtypes = RAW | MEAT | TOXIC

// /obj/item/food/glermtail/raw/make_grillable() //Grilling the glerm tail
// 	AddComponent(/datum/component/grillable, /obj/item/food/glermtail/cooked, rand(25 SECONDS, 40 SECONDS), TRUE, TRUE, /datum/pollutant/food/fried_meat)

// /obj/item/food/glermtail/cooked //Cooked glerm tail
// 	name = "roasted glerm tail"
// 	desc = "A chewy and sour meal. At least it's stopped wriggling."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "glermtail"
// 	tastes = list("meat" = 1, "acid" = 1)
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment/protein = 7,
// 		/datum/reagent/consumable/nutriment/vitamin = 3,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 	)
// 	foodtypes = MEAT | TOXIC

// /obj/item/reagent_containers/condiment/glermpaste //Congealed glerm toxin
// 	name = "glerm acid paste"
// 	desc = "Green and acrid paste. How many glerms did you kill to get this much."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "glermpaste"
// 	list_reagents = list(/datum/reagent/consumable/glermpaste = 50)

// /datum/reagent/consumable/glermpaste //The actual reagent
// 	name = "Glerm acid paste"
// 	description = "Green and acrid paste. Commonly smeared on bread."
// 	nutriment_factor = 5 * REAGENTS_METABOLISM
// 	color = "#29c514"
// 	taste_mult = 5
// 	taste_description = "bitter and acidic"
// 	default_container = /obj/item/reagent_containers/condiment/glermpaste

// /datum/orderable_item/reagents/glermpaste
// 	name = "Glerm Acid Paste"
// 	item_path = /obj/item/reagent_containers/condiment/glermpaste
// 	cost_per_order = 80

// ////////////- Gatosh Plants -////////////

// //Bopwheat, easy to grow wheat-like plant
// /obj/item/food/grown/bopwheat
// 	seed = /obj/item/seeds/bopwheat
// 	name = "bopwheat bundle"
// 	desc = "A bundle of red stalks."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "bopwheat"
// 	bite_consumption_mod = 3
// 	foodtypes = VEGETABLES
// 	tastes = list("grain" = 1)

// /datum/reagent/consumable/bopflour //comes from ground bopwheat
// 	name = "Bopwheat flour"
// 	description = "A pale red powder. Smells bready."
// 	nutriment_factor = 5 * REAGENTS_METABOLISM
// 	color = "#fdb7b7"
// 	taste_mult = 1
// 	taste_description = "dry and bready"

// //Dewcress, mixed greens asparagus type plant
// /obj/item/food/grown/dewcress
// 	seed = /obj/item/seeds/dewcress
// 	name = "dewcress bundle"
// 	desc = "A bundle of green stalks."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "dewcress"
// 	bite_consumption_mod = 3
// 	foodtypes = VEGETABLES
// 	tastes = list("green" = 1)

// /obj/item/food/grown/dewcress/make_grillable()
// 	AddComponent(/datum/component/grillable, /obj/item/food/grilleddewcress, rand(40 SECONDS, 70 SECONDS), TRUE, TRUE, /datum/pollutant/food/fried_meat)

// /obj/item/food/grilleddewcress
// 	name = "grilled dewcress"
// 	desc = "A bundle of crunchy green stalks."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "dewcress_grilled"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 5,
// 		/datum/reagent/consumable/nutriment/vitamin = 5,
// 	)
// 	w_class = WEIGHT_CLASS_SMALL
// 	foodtypes = VEGETABLES
// 	tastes = list("green" = 1)

// //Awlberry, generic berry fruit
// /obj/item/food/grown/awlberry
// 	seed = /obj/item/seeds/awlberry
// 	name = "awlberry bunch"
// 	desc = "A bunch of purple berries."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "awlberry"
// 	bite_consumption_mod = 2
// 	foodtypes = FRUIT
// 	tastes = list("everything" = 1)

// //Wonder root, like a druggy potato
// /obj/item/food/grown/wonderroot
// 	seed = /obj/item/seeds/wonderroot
// 	name = "wonder root"
// 	desc = "A blue and sparkley tuber."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "wonderroot"
// 	bite_consumption_mod = 3
// 	foodtypes = VEGETABLES
// 	tastes = list("wonder" = 1)

// ////////////- Bopwheat and Bopbread -////////////

// //Bopwheat dough recipe
// /datum/chemical_reaction/food/dough/bopflour
// 	required_reagents = list(
// 		/datum/reagent/water = 10,
// 		/datum/reagent/consumable/bopflour = 15
// 	)
// 	mix_message = "The ingredients form a dough."

// 	resulting_food_path = /obj/item/food/bopdough

// //Bopwheat dough
// /obj/item/food/bopdough
// 	name = "bop-dough"
// 	desc = "A piece of reddish dough."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "bopdough"
// 	w_class = WEIGHT_CLASS_SMALL
// 	tastes = list("dough" = 1)
// 	foodtypes = GRAIN | RAW

// /obj/item/food/bopdough/make_bakeable()
// 	AddComponent(/datum/component/bakeable, /obj/item/food/bopbun, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

// //Baked bopwheat dough
// /obj/item/food/bopbun
// 	name = "bopbun"
// 	desc = "A soft and flaky red bun."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "bopbun"
// 	food_reagents = list(/datum/reagent/consumable/nutriment = 6)
// 	w_class = WEIGHT_CLASS_SMALL
// 	tastes = list("bun" = 1) // the bun tastes of bun.
// 	foodtypes = GRAIN
// 	burns_in_oven = TRUE

// /obj/item/food/bopbun/make_processable()
// 	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/bopbun/slice, 3, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice")

// //Better than sliced bread
// /obj/item/food/bopbun/slice
// 	name = "sliced bopbun"
// 	desc = "A slice of flaky bopbread"
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "bopslice"
// 	food_reagents = list(/datum/reagent/consumable/nutriment = 2)
// 	tastes = list("bread" = 1)

// /datum/crafting_recipe/food/gobtoast
// 	reqs = list(
// 		/obj/item/food/bopbun/slice = 1,
// 		/datum/reagent/consumable/glermpaste = 3,
// 	)
// 	result = /obj/item/food/bopbun/slice/toast
// 	category = CAT_GOBFOOD

// /obj/item/food/bopbun/slice/toast
// 	name = "sliced bopbun"
// 	desc = "A slice of flaky bopbread smeared with green paste."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "boptoast"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 2,
// 		/datum/reagent/consumable/nutriment/vitamin = 3,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 		)
// 	tastes = list("bread" = 1, "acid" = 1)

// ////////////- Goblin Sandwiches -////////////
// /datum/crafting_recipe/food/gobsandwich/deh
// 	name = "Uncooked Deh-bun"
// 	reqs = list(
// 		/obj/item/food/bopdough = 1,
// 		/obj/item/food/meat/cutlet/glerm = 1,
// 	)
// 	result = /obj/item/food/dehbun/raw
// 	category = CAT_GOBFOOD

// //Tier one sangwitch
// /obj/item/food/dehbun/raw
// 	name = "uncooked deh-bun"
// 	desc = "A ball of red dough full of meat."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "dehbun_raw"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 6,
// 		/datum/reagent/consumable/nutriment/protein = 2,
// 		/datum/reagent/toxin/glermtoxin = 2)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC | RAW

// /obj/item/food/dehbun/raw/make_bakeable()
// 	AddComponent(/datum/component/bakeable, /obj/item/food/dehbun/baked, rand(30 SECONDS, 45 SECONDS), TRUE, TRUE)

// /obj/item/food/dehbun/baked
// 	name = "deh-bun"
// 	desc = "A soft and flaky red bun full of glerm-meat."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "dehbun"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 10,
// 		/datum/reagent/consumable/nutriment/protein = 5,
// 		/datum/reagent/toxin/glermtoxin = 1)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC
// 	burns_in_oven = TRUE
// 	food_buffs = STATUS_EFFECT_FOOD_RESISTANCE

// /datum/crafting_recipe/food/gobsandwich/keh
// 	name = "Uncooked Keh-bun"
// 	reqs = list(
// 		/obj/item/food/bopdough = 1,
// 		/obj/item/food/meat/cutlet/glerm = 1,
// 		/obj/item/food/cheese/wedge/glerm = 1,
// 	)
// 	result = /obj/item/food/kehbun/raw
// 	category = CAT_GOBFOOD

// //Tier two sangwitch
// /obj/item/food/kehbun/raw
// 	name = "uncooked keh-bun"
// 	desc = "A ball of red dough full of meat and cheese."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "kehbun_raw"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 7,
// 		/datum/reagent/consumable/nutriment/protein = 3,
// 		/datum/reagent/toxin/glermtoxin = 3,
// 		/datum/reagent/consumable/nutriment/vitamin = 1)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1, "cheese" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC | DAIRY | RAW

// /obj/item/food/kehbun/raw/make_bakeable()
// 	AddComponent(/datum/component/bakeable, /obj/item/food/kehbun/baked, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

// /obj/item/food/kehbun/baked
// 	name = "keh-bun"
// 	desc = "A soft and flaky red bun full of glerm-meat and melted cheese."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "kehbun"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 15,
// 		/datum/reagent/consumable/nutriment/protein = 7,
// 		/datum/reagent/toxin/glermtoxin = 2,
// 		/datum/reagent/consumable/nutriment/vitamin = 2)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1, "cheese" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC | DAIRY
// 	burns_in_oven = TRUE
// 	food_buffs = list(STATUS_EFFECT_FOOD_RESISTANCE, STATUS_EFFECT_FOOD_HEALTH_TINY)

// /datum/crafting_recipe/food/gobsandwich/leh
// 	name = "Uncooked Leh-bun"
// 	reqs = list(
// 		/obj/item/food/bopdough = 1,
// 		/obj/item/food/meat/cutlet/glerm = 1,
// 		/obj/item/food/cheese/wedge/glerm = 1,
// 		/obj/item/food/grilleddewcress = 1,
// 		/datum/reagent/consumable/glermpaste = 5,
// 	)
// 	result = /obj/item/food/lehbun/raw
// 	category = CAT_GOBFOOD

// //Tier three sangwitch
// /obj/item/food/lehbun/raw
// 	name = "uncooked leh-bun"
// 	desc = "A ball of red dough full of meat, cheese, and crunchy dewcress."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "lehbun_raw"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 8,
// 		/datum/reagent/consumable/nutriment/protein = 3,
// 		/datum/reagent/toxin/glermtoxin = 7,
// 		/datum/reagent/consumable/nutriment/vitamin = 3)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1, "cheese" = 1, "green" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC | DAIRY | VEGETABLES | RAW

// /obj/item/food/lehbun/raw/make_bakeable()
// 	AddComponent(/datum/component/bakeable, /obj/item/food/lehbun/baked, rand(40 SECONDS, 55 SECONDS), TRUE, TRUE)

// /obj/item/food/lehbun/baked
// 	name = "leh-bun"
// 	desc = "A soft and flaky red bun full of meat, cheese, fried dewcress, and drizzled with acidic glerm-paste."
// 	icon = 'monkestation/icons/obj/food/goblinfood.dmi'
// 	icon_state = "lehbun"
// 	food_reagents = list(
// 		/datum/reagent/consumable/nutriment = 25,
// 		/datum/reagent/consumable/nutriment/protein = 10,
// 		/datum/reagent/toxin/glermtoxin = 6,
// 		/datum/reagent/consumable/nutriment/vitamin = 3)
// 	w_class = WEIGHT_CLASS_NORMAL
// 	tastes = list("bun" = 1, "meat" = 1, "acid" = 1, "green" = 1)
// 	foodtypes = GRAIN | MEAT | TOXIC | DAIRY | VEGETABLES
// 	burns_in_oven = TRUE
// 	food_buffs = list(STATUS_EFFECT_FOOD_RESISTANCE, STATUS_EFFECT_FOOD_HEALTH_TINY, STATUS_EFFECT_STAM_REGEN_SMALL)
