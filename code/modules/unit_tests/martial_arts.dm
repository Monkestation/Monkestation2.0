/// Martial arts have to catch a human's unarmed strikes and grabs, and let go of them once removed.
/datum/unit_test/martial_art_hooks

/datum/unit_test/martial_art_hooks/Run()
	var/mob/living/carbon/human/consistent/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/victim = allocate(/mob/living/carbon/human/consistent)
	attacker.mind_initialize()

	var/datum/martial_art/cqc/style = allocate(/datum/martial_art/cqc)
	TEST_ASSERT(style.teach(attacker), "CQC could not be taught")
	TEST_ASSERT_EQUAL(GET_ACTIVE_MARTIAL_ART(attacker), style, "CQC was not set as the attacker's martial art")

	attacker.istate = ISTATE_HARM
	attacker.UnarmedAttack(victim, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 13, "A CQC strike should deal its fixed 13 brute damage")

	style.reset_streak()
	attacker.istate = ISTATE_CONTROL
	attacker.UnarmedAttack(victim, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(attacker.pulling, victim, "A CQC grab should grab the victim")
	TEST_ASSERT_EQUAL(attacker.grab_state, GRAB_AGGRESSIVE, "A CQC grab should be instantly aggressive")

	attacker.stop_pulling()
	style.unlearn(attacker)
	TEST_ASSERT_NULL(GET_ACTIVE_MARTIAL_ART(attacker), "Removing CQC should leave no martial art behind")

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
	TEST_ASSERT_NULL(GET_ACTIVE_MARTIAL_ART(wearer), "Holding carp gloves should not teach sleeping carp")
	wearer.dropItemToGround(gloves)
	TEST_ASSERT_NULL(GET_ACTIVE_MARTIAL_ART(wearer), "Dropping carp gloves that were never worn should change nothing")

	wearer.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES)
	TEST_ASSERT(istype(GET_ACTIVE_MARTIAL_ART(wearer), /datum/martial_art/the_sleeping_carp), "Wearing carp gloves should teach sleeping carp")

	wearer.dropItemToGround(gloves)
	TEST_ASSERT_NULL(GET_ACTIVE_MARTIAL_ART(wearer), "Taking off carp gloves should remove sleeping carp")

	wearer.equip_to_slot_if_possible(gloves, ITEM_SLOT_GLOVES)
	qdel(gloves)
	TEST_ASSERT_NULL(GET_ACTIVE_MARTIAL_ART(wearer), "Deleting worn carp gloves should remove sleeping carp")

/// Knowing more than one martial art keeps the newest one active and falls back to the older one when it is forgotten.
/datum/unit_test/martial_art_swapping

/datum/unit_test/martial_art_swapping/Run()
	var/mob/living/carbon/human/consistent/student = allocate(/mob/living/carbon/human/consistent)
	var/datum/martial_art/cqc/cqc = allocate(/datum/martial_art/cqc)
	var/datum/martial_art/krav_maga/krav = allocate(/datum/martial_art/krav_maga)

	cqc.teach(student)
	krav.teach(student)
	TEST_ASSERT_EQUAL(GET_ACTIVE_MARTIAL_ART(student), krav, "The newest martial art should be the active one")
	TEST_ASSERT(krav.active && !cqc.active, "Only the active martial art should be marked as active")

	krav.unlearn(student)
	TEST_ASSERT_EQUAL(GET_ACTIVE_MARTIAL_ART(student), cqc, "Forgetting the active martial art should fall back to the older one")
	TEST_ASSERT(cqc.active, "The fallback martial art should become active")

/// Boxers can't grab, not even through the ctrl click pull fallback, and alternating buttons into the matching hand throws a slower hook.
/datum/unit_test/boxing_moves

/datum/unit_test/boxing_moves/Run()
	var/mob/living/carbon/human/consistent/boxer = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/sparring_partner = allocate(/mob/living/carbon/human/consistent)
	boxer.mind_initialize()
	var/datum/martial_art/boxing/style = allocate(/datum/martial_art/boxing)
	var/datum/martial_art/boxing/partner_style = allocate(/datum/martial_art/boxing)
	style.teach(boxer)
	partner_style.teach(sparring_partner)

	TEST_ASSERT_EQUAL(boxer.grab(sparring_partner), GRAB_FAILURE, "A boxer's grab should fail")
	boxer.base_click_ctrl(sparring_partner)
	TEST_ASSERT_NULL(boxer.pulling, "A failed boxing grab should not fall back to pulling")

	boxer.swap_hand(1, silent = TRUE)
	boxer.istate = ISTATE_HARM
	boxer.UnarmedAttack(sparring_partner, proximity_flag = TRUE)
	var/punch_time = world.time
	boxer.UnarmedAttack(sparring_partner, proximity_flag = TRUE)
	TEST_ASSERT_EQUAL(boxer.next_move, punch_time + CLICK_CD_MELEE, "A straight punch should not slow down the next punch")

	boxer.UnarmedAttack(sparring_partner, proximity_flag = TRUE)
	boxer.istate = ISTATE_SECONDARY
	punch_time = world.time
	boxer.UnarmedAttack(sparring_partner, proximity_flag = TRUE)
	TEST_ASSERT(sparring_partner.getStaminaLoss() > 0, "Boxing punches should deal stamina damage")
	TEST_ASSERT_EQUAL(boxer.next_move, punch_time + CLICK_CD_MELEE * 1.5, "A left hook should slow down the next punch")

/// Punching mitts teach hunter boxing, which is allowed to grab and punches wildlife for brute damage.
/datum/unit_test/hunter_boxing

/datum/unit_test/hunter_boxing/Run()
	var/mob/living/carbon/human/consistent/hunter = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/bystander = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/basic/carp/prey = allocate(/mob/living/basic/carp)
	QDEL_NULL(prey.ai_controller)
	hunter.mind_initialize()
	var/obj/item/clothing/gloves/fingerless/punch_mitts/mitts = allocate(/obj/item/clothing/gloves/fingerless/punch_mitts)

	hunter.equip_to_slot_if_possible(mitts, ITEM_SLOT_GLOVES)
	TEST_ASSERT(istype(GET_ACTIVE_MARTIAL_ART(hunter), /datum/martial_art/boxing/hunter), "Wearing punching mitts should teach hunter boxing")

	TEST_ASSERT_EQUAL(hunter.grab(bystander), GRAB_SUCCESS, "A hunter boxer should be able to grab")
	hunter.stop_pulling()

	hunter.swap_hand(1, silent = TRUE)
	hunter.istate = ISTATE_HARM
	hunter.UnarmedAttack(prey, proximity_flag = TRUE)
	hunter.UnarmedAttack(prey, proximity_flag = TRUE)
	TEST_ASSERT(prey.health < prey.maxHealth, "A straight punch from a hunter boxer should hurt a carp")
	TEST_ASSERT_EQUAL(prey.getStaminaLoss(), 0, "Hunter boxing should deal brute damage to wildlife, not stamina")

/// CQC kicks only knock out a floored target that is already in stamina crit, and leg sweeps knock down instead of paralyzing.
/datum/unit_test/cqc_kicks

/datum/unit_test/cqc_kicks/Run()
	var/mob/living/carbon/human/consistent/attacker = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/victim = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/consistent/sweep_victim = allocate(/mob/living/carbon/human/consistent)
	attacker.mind_initialize()
	var/datum/martial_art/cqc/style = allocate(/datum/martial_art/cqc)
	style.teach(attacker)

	style.Slam(attacker, victim)
	TEST_ASSERT_EQUAL(victim.body_position, LYING_DOWN, "A CQC slam should put the victim on the floor")
	style.Kick(attacker, victim)
	TEST_ASSERT(!victim.IsUnconscious() && !victim.IsSleeping(), "A CQC kick right after a slam should not knock the victim out")
	TEST_ASSERT_EQUAL(victim.getStaminaLoss(), 45, "A CQC kick on a floored victim should deal 45 stamina damage")

	victim.setStaminaLoss(100)
	style.Kick(attacker, victim)
	TEST_ASSERT(victim.IsUnconscious(), "A CQC kick on a floored victim in stamina crit should knock them out")

	attacker.set_resting(TRUE, silent = TRUE, instant = TRUE)
	attacker.istate = ISTATE_HARM
	attacker.UnarmedAttack(sweep_victim, proximity_flag = TRUE)
	TEST_ASSERT(sweep_victim.IsKnockdown(), "A CQC leg sweep should knock the victim down")
	TEST_ASSERT(!sweep_victim.IsParalyzed(), "A CQC leg sweep should not paralyze the victim")
	TEST_ASSERT_EQUAL(sweep_victim.getBruteLoss(), 10, "A CQC leg sweep should deal 10 brute damage")
