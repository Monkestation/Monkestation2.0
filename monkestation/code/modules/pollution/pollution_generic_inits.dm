/obj/effect/decal/cleanable/greenglow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/chemical_vapors, 10)

/obj/effect/decal/cleanable/vomit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/obj/effect/decal/cleanable/insectguts/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/decaying_waste, 10)

/obj/effect/decal/cleanable/garbage/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/decaying_waste, 30)

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/decaying_waste, 30)

/obj/structure/moisture_trap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pollution_emitter, /datum/pollutant/decaying_waste, 30)

/obj/item/reagent_containers/cup/glass/coffee/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/coffee, 5, 3 MINUTES)

/obj/item/reagent_containers/cup/glass/mug/tea/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/tea, 5, 3 MINUTES)

/obj/item/reagent_containers/cup/glass/mug/coco/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/temporary_pollution_emission, /datum/pollutant/food/chocolate, 5, 3 MINUTES)
