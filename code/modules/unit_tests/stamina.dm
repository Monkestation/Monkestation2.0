/// Stamina damage helpers, the fatigue percentage and stamcrit entry/exit.
/datum/unit_test/stamina_loss

/datum/unit_test/stamina_loss/Run()
	var/mob/living/carbon/human/consistent/tired = allocate(/mob/living/carbon/human/consistent)

	tired.adjustStaminaLoss(30)
	TEST_ASSERT_EQUAL(tired.getStaminaLoss(), 30, "adjustStaminaLoss(30) should deal 30 stamina damage")
	TEST_ASSERT_EQUAL(tired.stamina.loss_as_percent, 30, "30 stamina damage should be 30% fatigue")

	tired.adjustStaminaLoss(-10)
	TEST_ASSERT_EQUAL(tired.getStaminaLoss(), 20, "negative adjustStaminaLoss should heal")

	tired.setStaminaLoss(tired.stamina.maximum)
	TEST_ASSERT_EQUAL(tired.stamina.loss_as_percent, 100, "running out of stamina should be 100% fatigue")
	TEST_ASSERT(HAS_TRAIT_FROM(tired, TRAIT_INCAPACITATED, STAMINA), "running out of stamina should stamcrit")
	TEST_ASSERT(HAS_TRAIT_FROM(tired, TRAIT_NO_SPRINT, STAMINA), "running out of stamina should stop sprinting")

	tired.setStaminaLoss(0)
	TEST_ASSERT_EQUAL(tired.getStaminaLoss(), 0, "setStaminaLoss(0) should clear stamina damage")
	TEST_ASSERT(!HAS_TRAIT_FROM(tired, TRAIT_INCAPACITATED, STAMINA), "full stamina should end stamcrit")
	TEST_ASSERT(!HAS_TRAIT_FROM(tired, TRAIT_NO_SPRINT, STAMINA), "full stamina should allow sprinting again")

	tired.stamina.set_maximum(50)
	tired.setStaminaLoss(0)
	tired.stamina.set_maximum(25)
	TEST_ASSERT(tired.stamina.current <= tired.stamina.maximum, "lowering the maximum should clamp current stamina")
	tired.stamina.set_maximum(STAMINA_MAX)
