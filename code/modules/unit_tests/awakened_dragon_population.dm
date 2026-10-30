/// Checks that the Scroll of the Awakened Dragon can't be bought with too few living players, and can be once there are enough
/datum/unit_test/awakened_dragon_population

/datum/unit_test/awakened_dragon_population/Run()
	var/mob/living/carbon/human/consistent/buyer = allocate(/mob/living/carbon/human/consistent)
	buyer.mind_initialize()
	var/datum/antagonist/traitor/traitor = buyer.mind.add_antag_datum(/datum/antagonist/traitor)
	var/datum/uplink_handler/handler = traitor.uplink_handler
	TEST_ASSERT_NOTNULL(handler, "Traitor has no uplink handler")
	// The uplink device normally gives the handler its purchase log
	handler.purchase_log = allocate(/datum/uplink_purchase_log)
	var/datum/uplink_item/melees/martialarts/advanced/scroll = SStraitor.uplink_items_by_type[/datum/uplink_item/melees/martialarts/advanced]
	TEST_ASSERT_NOTNULL(scroll, "Couldn't find the Awakened Dragon uplink item")

	var/list/old_alive_players = GLOB.alive_player_list
	handler.telecrystals = 50

	GLOB.alive_player_list = list()
	TEST_ASSERT(handler.not_enough_population(scroll), "The uplink thinks there's enough living players with none")
	TEST_ASSERT(!handler.purchase_item(buyer, scroll), "The scroll could be bought with no living players")
	TEST_ASSERT_EQUAL(handler.telecrystals, 50, "Telecrystals were spent on a purchase that should have failed")

	var/list/enough_players = list()
	for(var/i in 1 to scroll.population_minimum)
		enough_players += buyer
	GLOB.alive_player_list = enough_players
	TEST_ASSERT(!handler.not_enough_population(scroll), "The uplink thinks there aren't enough living players with [scroll.population_minimum]")
	TEST_ASSERT(handler.purchase_item(buyer, scroll), "The scroll couldn't be bought with [scroll.population_minimum] living players")
	TEST_ASSERT_EQUAL(handler.telecrystals, 50 - scroll.cost, "Buying the scroll didn't cost the right amount of telecrystals")

	GLOB.alive_player_list = old_alive_players
	for(var/obj/item/book/granter/martial/carp/true/bought in buyer.get_all_contents() + range(1, buyer))
		qdel(bought)
