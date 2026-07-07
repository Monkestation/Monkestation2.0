/obj/item/stack/sheet/fleshmass
	name = "chunks of flesh"
	desc = "A solid chunk of flesh, with bits of bone sticking out."
	singular_name = "flesh chunk"
	icon_state = "sheet-fleshmass"
	merge_type = /obj/item/stack/sheet/fleshmass
	grind_results = list(/datum/reagent/blood = 20)
	novariants = TRUE

GLOBAL_LIST_INIT(fleshmass_recipes, list ( \
	new/datum/stack_recipe("pile of gibs", /obj/effect/decal/cleanable/blood/gibs/core, 3, time = 0, one_per_turf = FALSE, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("pool of blood", /obj/effect/decal/cleanable/blood/splatter/stacking, 2, time = 0, one_per_turf = FALSE, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("slab of monkey meat", /obj/item/food/meat/slab/monkey, 2, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_MISC), \
))

/obj/item/stack/sheet/fleshmass/get_main_recipes()
	. = ..()
	. += GLOB.fleshmass_recipes

/obj/item/stack/sheet/fleshmass/examine(mob/user)
	. = ..()
	. += span_notice("You can craft limbs and organs via the crafting menu, or use the chunks inhand to create slab of meat or gore.")
