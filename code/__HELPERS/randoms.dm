///Get a random food item exluding the blocked ones
/proc/get_random_food()
	var/static/list/allowed_food = list()

	if(!LAZYLEN(allowed_food)) //it's static so we only ever do this once
		var/list/blocked = list(
			/obj/item/food/bowled,
			/obj/item/food/bread,
			/obj/item/food/breadslice,
			/obj/item/food/cake,
			/obj/item/food/cakeslice,
			/obj/item/food/clothing,
			/obj/item/food/drug,
			/obj/item/food/grown,
			/obj/item/food/grown/ash_flora,
			/obj/item/food/grown/mushroom,
			/obj/item/food/grown/nettle,
			/obj/item/food/grown/shell,
			/obj/item/food/kebab,
			/obj/item/food/meat,
			/obj/item/food/meat/slab,
			/obj/item/food/meat/slab/human/mutant,
			/obj/item/food/pie,
			/obj/item/food/pieslice,
			/obj/item/food/pizza,
			/obj/item/food/pizzaslice,
			/obj/item/food/salad,
			/obj/item/food/spaghetti,
		)

		allowed_food = get_sane_item_types(/obj/item/food) - blocked

	return pick(allowed_food)

///Gets a random drink excluding the blocked type
/proc/get_random_drink()
	var/static/list/allowed_drinks = list()

	if(!LAZYLEN(allowed_drinks))
		var/list/blocked = list(
			/obj/item/reagent_containers/cup/glass/bottle
		)

		allowed_drinks = get_sane_item_types(/obj/item/reagent_containers/cup/glass) + get_sane_item_types(/obj/item/reagent_containers/cup/soda_cans) - blocked

	return pick(allowed_drinks)

///Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ion_num() //! is at the start to prevent us from changing say modes via get_message_mode()
	return "![pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

///Returns a string for a random nuke code, we exclude 0 from the results due to messiness with TGUI.
/proc/random_nukecode(max_length = 5)
	var/val = rand(1, (10 ** max_length - 1))
	var/str = "[val]"
	while(length(str) < max_length)
		str = "0" + str
	. = str
