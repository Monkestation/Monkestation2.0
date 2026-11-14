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

/// Items with the martial_art_giver component teach their martial art only while worn.
/datum/unit_test/martial_art_giver

/datum/unit_test/martial_art_giver/Run()
	var/mob/living/carbon/human/consistent/wearer = allocate(/mob/living/carbon/human/consistent)
	wearer.mind_initialize()
	var/obj/item/clothing/gloves/the_sleeping_carp/gloves = allocate(/obj/item/clothing/gloves/the_sleeping_carp)

	wearer.put_in_active_hand(gloves, forced = TRUE)
	TEST_ASSERT_NULL(wearer.mind.martial_art, "Holding carp gloves should not teach sleeping carp")
	wearer.dropItemToGround(gloves)
	TEST_ASSERT_NULL(wearer.mind.martial_art, "Dropping carp gloves that were never worn should change nothing")

	wearer.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES)
	TEST_ASSERT(istype(wearer.mind.martial_art, /datum/martial_art/the_sleeping_carp), "Wearing carp gloves should teach sleeping carp")

	wearer.dropItemToGround(gloves)
	TEST_ASSERT_NULL(wearer.mind.martial_art, "Taking off carp gloves should remove sleeping carp")

	wearer.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES)
	qdel(gloves)
	TEST_ASSERT_NULL(wearer.mind.martial_art, "Deleting worn carp gloves should remove sleeping carp")
