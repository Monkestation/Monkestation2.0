/// Martial arts have to catch a human's unarmed strikes and grabs, and let go of them once removed.
/datum/unit_test/martial_art_hooks

/datum/unit_test/martial_art_hooks/Run()
	var/mob/living/carbon/human/consistent/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/victim = allocate(/mob/living/carbon/human/consistent)
	attacker.mind_initialize()

	var/datum/martial_art/cqc/style = allocate(/datum/martial_art/cqc)
	TEST_ASSERT(style.teach(attacker), "CQC could not be taught")
	TEST_ASSERT_EQUAL(attacker.mind.martial_art, style, "CQC was not set as the attacker's martial art")

	attacker.istate = ISTATE_HARM
	attacker.UnarmedAttack(victim, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 13, "A CQC strike should deal its fixed 13 brute damage")

	style.reset_streak()
	attacker.istate = ISTATE_CONTROL
	attacker.UnarmedAttack(victim, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(attacker.pulling, victim, "A CQC grab should grab the victim")
	TEST_ASSERT_EQUAL(attacker.grab_state, GRAB_AGGRESSIVE, "A CQC grab should be instantly aggressive")

	attacker.stop_pulling()
	style.remove(attacker)
	TEST_ASSERT_NULL(attacker.mind.martial_art, "Removing CQC should leave no martial art behind")

	attacker.UnarmedAttack(victim, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(attacker.pulling, victim, "A normal grab should still grab the victim")
	TEST_ASSERT_EQUAL(attacker.grab_state, GRAB_PASSIVE, "A normal grab should start passive")
