/mob/living/basic/chicken/brown
	icon_suffix = "brown"

	breed_name = "Brown"
	egg_type = /obj/item/food/egg/brown
	chicken_path = /mob/living/basic/chicken/brown
	mutation_list = list(/datum/ranching_mutation/chicken/spicy, /datum/ranching_mutation/chicken/raptor, /datum/ranching_mutation/chicken/gold, /datum/ranching_mutation/chicken/robot) //when i get a better chicken robot will be moved
	liked_foods = list(/obj/item/food/grown/chili = 4)

	book_desc = "These chickens behave the same as White Chickens."
/obj/item/food/egg/brown
	name = "Brown Egg"
	icon_state = "chocolateegg"

	layer_hen_type = /mob/living/basic/chicken/brown
	turf_requirements = list(/turf/open/floor/grass, /turf/open/floor/sandy_dirt)
