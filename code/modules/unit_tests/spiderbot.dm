/datum/unit_test/spiderbot_personality_round_trip

/datum/unit_test/spiderbot_personality_round_trip/Run()
	var/mob/living/basic/spiderbot/spiderbot = allocate(/mob/living/basic/spiderbot)
	var/obj/item/mmi/posibrain/installed_mmi = allocate(/obj/item/mmi/posibrain)
	var/mob/living/brain/brainmob = installed_mmi.brainmob
	brainmob.mind_initialize()
	var/datum/mind/personality = brainmob.mind

	installed_mmi.forceMove(spiderbot)
	spiderbot.mmi = installed_mmi

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/modular_computer/pda/pda_without_id = allocate(/obj/item/modular_computer/pda)
	var/interaction_result = spiderbot.item_interaction(user, pda_without_id, list())
	TEST_ASSERT_EQUAL(interaction_result, ITEM_INTERACT_BLOCKING, "An ID-less PDA should be handled without ejecting the MMI.")
	TEST_ASSERT_EQUAL(spiderbot.mmi, installed_mmi, "An ID-less PDA ejected the spiderbot's MMI.")

	spiderbot.transfer_personality(installed_mmi)
	TEST_ASSERT_EQUAL(spiderbot.mind, personality, "The spiderbot did not receive the MMI occupant's mind.")
	TEST_ASSERT_EQUAL(personality.current, spiderbot, "The transferred mind still considers the brainmob its current body.")
	TEST_ASSERT_NULL(brainmob.mind, "The brainmob retained the transferred mind.")

	var/obj/item/mmi/ejected_mmi = spiderbot.eject_brain()
	TEST_ASSERT_EQUAL(ejected_mmi, installed_mmi, "The spiderbot did not return its installed MMI on ejection.")
	TEST_ASSERT_NULL(spiderbot.mmi, "The spiderbot retained its MMI reference after ejection.")
	TEST_ASSERT_NULL(spiderbot.mind, "The spiderbot retained the ejected personality's mind.")
	TEST_ASSERT_EQUAL(brainmob.mind, personality, "The ejected brainmob did not recover its mind.")
	TEST_ASSERT_EQUAL(personality.current, brainmob, "The ejected mind does not consider the brainmob its current body.")
	TEST_ASSERT_EQUAL(installed_mmi.loc, spiderbot.drop_location(), "The ejected MMI was not moved to the spiderbot's drop location.")
