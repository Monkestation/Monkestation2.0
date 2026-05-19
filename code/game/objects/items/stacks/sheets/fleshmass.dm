/obj/item/stack/sheet/fleshmass
	name = "chunks of flesh"
	desc = "A solid chunk of flesh, with bits of bone sticking out."
	singular_name = "flesh chunk"
	icon_state = "sheet-fleshmass"
	merge_type = /obj/item/stack/sheet/fleshmass
	grind_results = list(/datum/reagent/blood = 20)
	novariants = TRUE

GLOBAL_LIST_INIT(fleshmass_recipes, list ( \
	new/datum/stack_recipe_list("Organs", list(
		new/datum/stack_recipe("human heart", /obj/item/organ/internal/heart, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human liver", /obj/item/organ/internal/liver, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human lungs", /obj/item/organ/internal/lungs, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human spleen", /obj/item/organ/internal/spleen, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human butt", /obj/item/organ/internal/butt, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human appendix", /obj/item/organ/internal/appendix, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human bladder", /obj/item/organ/internal/bladder, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human eyes", /obj/item/organ/internal/eyes, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human ears", /obj/item/organ/internal/ears, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human tongue", /obj/item/organ/internal/tongue, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("human stomach", /obj/item/organ/internal/stomach, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		new/datum/stack_recipe("monkey tail", /obj/item/organ/external/tail/monkey, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_ORGANS),
		)),	\
	new/datum/stack_recipe_list("Limbs", list(
		new/datum/stack_recipe("human left leg", /obj/item/bodypart/leg/left, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_LIMBS),
		new/datum/stack_recipe("human right leg", /obj/item/bodypart/leg/right, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_LIMBS),
		new/datum/stack_recipe("human left arm", /obj/item/bodypart/arm/left, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_LIMBS),
		new/datum/stack_recipe("human right arm", /obj/item/bodypart/arm/right, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_LIMBS),
		new/datum/stack_recipe("human head", /obj/item/bodypart/head, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_LIMBS),
		)),	\
	new/datum/stack_recipe("pile of gibs", /obj/effect/decal/cleanable/blood/gibs/core, 1, time = 0, one_per_turf = FALSE, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("pool of blood", /obj/effect/decal/cleanable/blood/splatter/stacking, 1, time = 0, one_per_turf = FALSE, on_solid_ground = TRUE, category = CAT_MISC), \
	new/datum/stack_recipe("slab of monkey meat", /obj/item/food/meat/slab/monkey, 1, time = 0, one_per_turf = FALSE, on_solid_ground = FALSE, category = CAT_MISC), \
	))

/obj/item/stack/sheet/fleshmass/get_main_recipes()
	. = ..()
	. += GLOB.fleshmass_recipes
