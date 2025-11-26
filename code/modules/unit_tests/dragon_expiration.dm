/// Unit test for the contents barfer element
/datum/unit_test/contents_barfer

/datum/unit_test/contents_barfer/Run()
	var/mob/living/basic/space_dragon/dragon_time = allocate(/mob/living/basic/space_dragon)
	var/mob/living/carbon/human/to_be_consumed = allocate(/mob/living/carbon/human/consistent)
	to_be_consumed.adjust_fire_stacks(5)
	to_be_consumed.ignite_mob()
	TEST_ASSERT(dragon_time.eat(to_be_consumed), "The space dragon failed to consume the dummy!")
	TEST_ASSERT(!to_be_consumed.has_status_effect(/datum/status_effect/fire_handler/fire_stacks), "The space dragon failed to extinguish the dummy!")
	TEST_ASSERT_EQUAL(to_be_consumed.loc, dragon_time, "The dummy's location, after being successfuly consumed, was not within the space dragon's contents!")
	dragon_time.death()
	TEST_ASSERT(isturf(to_be_consumed.loc), "After dying, the space dragon did not eject the consumed dummy content barfer element.")
