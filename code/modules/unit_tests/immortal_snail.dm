/datum/unit_test/immortal_snail_money
	var/datum/snail_debt/previous_ledger

/datum/unit_test/immortal_snail_money/Run()
	previous_ledger = GLOB.snail_debt
	var/datum/snail_debt/ledger = allocate(/datum/snail_debt, run_loc_floor_bottom_left)
	GLOB.snail_debt = ledger
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/holochip/prize = allocate(/obj/item/holochip, person, 100000)
	var/obj/item/holochip/split = allocate(/obj/item/holochip, person, 0)
	ledger.mark(prize, 100000)
	// Exercise the real spend path used by chip splitting.
	split.credits = prize.spend(25000, FALSE, split)
	TEST_ASSERT_EQUAL(ledger.claims[prize], 75000, null)
	TEST_ASSERT_EQUAL(ledger.claims[split], 25000, null)
	var/datum/bank_account/account = allocate(/datum/bank_account, "Snail test", null, 1, FALSE)
	account.account_balance = 1000
	var/obj/item/card/id/card = allocate(/obj/item/card/id, person)
	card.registered_account = account
	account.bank_cards += card
	TEST_ASSERT(card.insert_money(split, person), "Depositing cursed money failed")
	TEST_ASSERT_EQUAL(account.account_balance, 26000, null)
	var/obj/item/holochip/withdrawal = allocate(/obj/item/holochip, person, 10000)
	TEST_ASSERT(account.adjust_money(-10000, "Test withdrawal", withdrawal), "Withdrawal failed")
	TEST_ASSERT_EQUAL(ledger.claims[withdrawal], 10000, null)
	TEST_ASSERT_EQUAL(ledger.claims[account], 15000, null)
	ledger.collect(account)
	TEST_ASSERT_EQUAL(account.account_balance, 1000, "Unrelated funds must survive reclamation")
	// Spending only part of the cursed chip creates a personal death debt.
	TEST_ASSERT_EQUAL(withdrawal.spend(1), 1, null)
	TEST_ASSERT_EQUAL(ledger.claims[person], 1, null)
	withdrawal.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(ledger.claims[person], 1, "Dropping cash must not clear a spending debt")
	ledger.collect(withdrawal)
	TEST_ASSERT(QDELETED(withdrawal), "Reclaimed chip should disappear")
	TEST_ASSERT_EQUAL(ledger.claims[person], 1, "Collecting remaining money must not clear a spending debt")
	ledger.collect(person)
	TEST_ASSERT_EQUAL(person.stat, DEAD, null)
	ledger.collect(prize)
	TEST_ASSERT_EQUAL(ledger.recovered, 100000, "Every cursed credit must be accounted for exactly once")
	TEST_ASSERT_EQUAL(length(ledger.claims), 0, null)

/datum/unit_test/immortal_snail_money/Destroy()
	GLOB.snail_debt = previous_ledger
	return ..()

/datum/unit_test/immortal_snail_contact/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail, run_loc_floor_top_right)
	STOP_PROCESSING(SSprocessing, snail)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/holochip/cash = allocate(/obj/item/holochip, victim, 100000)
	snail.bind_target(victim, 100000)
	snail.contact(victim)
	TEST_ASSERT_EQUAL(victim.stat, DEAD, "A fully funded target must die")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_HUSK), "A fully funded target must be husked")
	TEST_ASSERT(snail.original_dead, "The snail must switch to recovery rather than disappear")
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human/consistent)
	snail.contact(bystander)
	TEST_ASSERT_EQUAL(bystander.stat, DEAD, "Bystander contact must be fatal")
	snail.curse_fulfilled = TRUE
	qdel(cash)

/datum/unit_test/immortal_snail_indestructible/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail, run_loc_floor_top_right)
	STOP_PROCESSING(SSprocessing, snail)
	snail.adjustBruteLoss(10000)
	snail.adjustFireLoss(10000)
	snail.ex_act(EXPLODE_DEVASTATE)
	snail.gib()
	snail.dust()
	snail.death()
	TEST_ASSERT(!QDELETED(snail), "Attacks, explosions, gibbing and dusting must not remove the snail")
	TEST_ASSERT_EQUAL(snail.stat, CONSCIOUS, "The snail must remain alive")
	TEST_ASSERT_EQUAL(snail.health, snail.maxHealth, "The snail must not take damage")

/datum/unit_test/immortal_snail_unrecoverable
	parent_type = /datum/unit_test/immortal_snail_money

/datum/unit_test/immortal_snail_unrecoverable/Run()
	previous_ledger = GLOB.snail_debt
	var/datum/snail_debt/ledger = allocate(/datum/snail_debt, run_loc_floor_bottom_left)
	GLOB.snail_debt = ledger
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/holochip/chip = allocate(/obj/item/holochip, person, 100)
	ledger.mark(chip, 100)
	chip.forceMove(run_loc_floor_bottom_left)
	qdel(chip)
	TEST_ASSERT_EQUAL(ledger.claims[person], 100, "Destroying dropped funds must leave their last carrier liable")
	var/datum/bank_account/account = allocate(/datum/bank_account, "Snail sender", null, 1, FALSE)
	var/datum/bank_account/remote/cc = allocate(/datum/bank_account/remote, "CC", null, 1, FALSE)
	var/obj/item/card/id/card = allocate(/obj/item/card/id, person)
	card.registered_account = account
	account.bank_cards += card
	account.account_balance = 100
	ledger.mark(account, 100)
	TEST_ASSERT(cc.transfer_money(account, 1), "Transfer to CC failed")
	TEST_ASSERT_EQUAL(ledger.claims[person], 101, "Sending even one cursed credit to CC must mark the sender")
	ledger.collect(account)
	TEST_ASSERT_EQUAL(ledger.claims[person], 101, "Recovering the other credits must not clear the death debt")
	ledger.collect(person)
	TEST_ASSERT_EQUAL(person.stat, DEAD, null)
	TEST_ASSERT_EQUAL(ledger.recovered, 200, null)

/datum/unit_test/immortal_snail_fulfillment/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail, run_loc_floor_top_right)
	STOP_PROCESSING(SSprocessing, snail)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	snail.bind_target(person, 100)
	qdel(snail)
	TEST_ASSERT(!QDELETED(snail), "An unfulfilled curse must prevent ordinary deletion")
	GLOB.snail_debt = allocate(/datum/snail_debt, run_loc_floor_bottom_left)
	var/obj/item/holochip/chip = allocate(/obj/item/holochip, person, 100)
	GLOB.snail_debt.mark(chip, 100)
	person.death()
	chip.forceMove(get_turf(snail))
	snail.next_step = 0
	snail.process(1)
	TEST_ASSERT(!QDELETED(snail), "The snail must survive until recovery is finished")
	TEST_ASSERT(QDELETED(chip), "Dropped cursed money must be collected")
	snail.process(1)
	TEST_ASSERT(QDELETED(snail), "The snail must disappear once the curse is fulfilled")

/datum/unit_test/immortal_snail_pursuit/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail)
	STOP_PROCESSING(SSprocessing, snail)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	var/turf/starting = get_turf(snail)
	snail.pursue(person)
	TEST_ASSERT(get_turf(snail) != starting, "The snail must move using the pathfinder")
	TEST_ASSERT(length(snail.route), "The pathfinder should have returned a route")
	var/turf/blocked = snail.route[1]
	var/original_type = blocked.type
	blocked = blocked.ChangeTurf(/turf/closed/wall)
	snail.pursue(person)
	TEST_ASSERT(!iswallturf(blocked), "A wall appearing on the route must be demolished")
	blocked.ChangeTurf(original_type)
	blocked = snail.route[1]
	original_type = blocked.type
	blocked = blocked.ChangeTurf(/turf/closed/indestructible)
	snail.pursue(person)
	TEST_ASSERT(!isclosedturf(blocked), "Indestructible map walls must not trap the snail")
	blocked.ChangeTurf(original_type)
	var/obj/structure/closet/barrier = allocate(/obj/structure/closet, snail.route[1])
	barrier.resistance_flags |= INDESTRUCTIBLE
	snail.pursue(person)
	TEST_ASSERT(QDELETED(barrier), "Indestructible dense objects must not trap the snail")
	var/turf/other_level = locate(1, 1, snail.z == 1 ? 2 : 1)
	TEST_ASSERT(other_level, "A second z level is required for the pursuit test")
	person.forceMove(other_level)
	snail.pursue(person)
	TEST_ASSERT_EQUAL(snail.z, person.z, "The snail must follow between z levels")
	TEST_ASSERT(get_dist(snail, person) >= 10, "Z travel must reappear at a distance, not on the victim")
