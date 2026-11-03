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
	QDEL_NULL(snail.pursuit_driver)
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
	QDEL_NULL(snail.pursuit_driver)
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
	QDEL_NULL(snail.pursuit_driver)
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

/datum/unit_test/immortal_snail_ghost_spectating
	var/mob/dead/observer/test_ghost

/datum/unit_test/immortal_snail_ghost_spectating/Run()
	test_ghost = allocate(/mob/dead/observer)
	GLOB.player_list |= test_ghost
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail)
	QDEL_NULL(snail.pursuit_driver)
	var/datum/antagonist/immortal_snail/antag = snail.mind?.has_antag_datum(/datum/antagonist/immortal_snail)
	TEST_ASSERT(antag && antag.show_to_ghosts, "The autonomous snail must have a ghost-visible antagonist datum")
	var/atom/movable/screen/alert/notify_action/toast = test_ghost.alerts["[REF(snail)]_notify_action"]
	TEST_ASSERT(toast, "Spawning must give ghosts the same notification button as a singularity")
	TEST_ASSERT_EQUAL(toast.target, snail, "The notification must target the spawned snail")
	TEST_ASSERT_EQUAL(toast.action, NOTIFY_ORBIT, "The notification must let ghosts orbit the snail")
	var/list/orbit_data = GLOB.orbit_menu.ui_static_data(test_ghost)
	var/list/antagonists = orbit_data["antagonists"]
	var/found_snail = FALSE
	for(var/list/entry as anything in antagonists)
		if(entry["ref"] == REF(snail))
			found_snail = TRUE
			break
	TEST_ASSERT(found_snail, "The snail must appear in the ghost orbit menu's antagonist section")
	GLOB.player_list -= test_ghost

/datum/unit_test/immortal_snail_ghost_spectating/Destroy()
	GLOB.player_list -= test_ghost
	return ..()

/datum/unit_test/immortal_snail_pda_recovery/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail)
	QDEL_NULL(snail.pursuit_driver)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent, get_turf(snail))
	var/obj/item/modular_computer/pda/pda = allocate(/obj/item/modular_computer/pda, person)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	var/datum/bank_account/account = card.registered_account
	TEST_ASSERT(account && (card in account.bank_cards), "A fresh ID must register itself with its bank account")
	TEST_ASSERT(pda.insert_id(card), "The ID must fit into the PDA")
	account.adjust_money(500, "Uncursed test balance")
	var/datum/snail_debt/ledger = allocate(/datum/snail_debt, run_loc_floor_top_right)
	GLOB.snail_debt = ledger
	var/obj/item/holochip/chip = allocate(/obj/item/holochip, person, 100000)
	ledger.mark(chip, 100000)
	TEST_ASSERT(card.insert_money(chip, person), "Depositing the cursed payout must succeed")
	TEST_ASSERT_EQUAL(ledger.location_of(account), card, "Recovery must find the nested ID rather than the machine")
	TEST_ASSERT_EQUAL(ledger.carrier_of(account), person, "The PDA's carrier must remain liable")
	snail.bind_target(person, 100000)
	person.death()
	snail.next_step = 0
	snail.process(1)
	TEST_ASSERT_EQUAL(account.account_balance, 500, "Recovery through a PDA must remove only cursed credits")
	TEST_ASSERT_EQUAL(ledger.recovered, 100000, "The complete bank claim must be reclaimed")
	snail.process(1)
	TEST_ASSERT(QDELETED(snail), "The snail must disappear once the PDA's bank credits are reclaimed")

/datum/unit_test/immortal_snail_pursuit/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail)
	QDEL_NULL(snail.pursuit_driver)
	var/obj/machinery/door/airlock/public_door = allocate(/obj/machinery/door/airlock, get_step(snail, NORTH))
	public_door.machine_stat &= ~NOPOWER
	TEST_ASSERT(public_door.hasPower(), "The public-airlock test requires a powered door")
	snail.chemically_breach(public_door)
	TEST_ASSERT(!public_door.density || public_door.operating, "An accessible airlock must open normally")
	TEST_ASSERT(!public_door.GetComponent(/datum/component/acid), "An accessible airlock must not be dissolved")
	qdel(public_door)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	var/turf/starting = get_turf(snail)
	var/turf/door_turf = get_step(starting, EAST)
	var/list/surrounding_types = list()
	for(var/turf/neighbor in orange(1, starting))
		if(neighbor == door_turf)
			continue
		surrounding_types[neighbor] = neighbor.type
		neighbor.ChangeTurf(/turf/closed/wall)
	var/obj/machinery/door/airlock/locked_door = allocate(/obj/machinery/door/airlock, door_turf)
	locked_door.req_access = list(ACCESS_CAPTAIN)
	var/turf/target_snapshot = get_turf(person)
	snail.prefetch_route(person)
	person.forceMove(get_step(person, SOUTH))
	UNTIL(!snail.route_pending)
	TEST_ASSERT_EQUAL(get_turf(snail), starting, "Preparing the next route must not move the snail early")
	TEST_ASSERT(length(snail.route), "The route must be ready before movement starts")
	TEST_ASSERT_EQUAL(snail.route[1], door_turf, "Locked doors must be considered before demolishing surrounding walls")
	TEST_ASSERT_EQUAL(snail.route_destination, target_snapshot, "A moving target must not discard a usable prepared route")
	snail.pursue(person)
	TEST_ASSERT_EQUAL(get_turf(snail), starting, "The snail must let its chemistry breach a closed door first")
	var/datum/component/acid/door_acid = locked_door.GetComponent(/datum/component/acid)
	TEST_ASSERT(door_acid, "The snail must use real acid on the locked door")
	door_acid.process_movable(locked_door, 60)
	TEST_ASSERT(QDELETED(locked_door), "The acid must destroy the door through normal integrity damage")
	// Native door destruction can leave a dense assembly; dissolve that too.
	for(var/attempt in 1 to 4)
		snail.pursue(person)
		if(get_turf(snail) != starting)
			break
		for(var/obj/debris in door_turf)
			if(!debris.density)
				continue
			var/datum/component/acid/debris_acid = debris.GetComponent(/datum/component/acid)
			TEST_ASSERT(debris_acid, "Dense door remains must also receive acid")
			debris_acid.process_movable(debris, 60)
	TEST_ASSERT(get_turf(snail) != starting, "The snail must continue moving once the door is dissolved")
	for(var/turf/neighbor as anything in surrounding_types)
		neighbor.ChangeTurf(surrounding_types[neighbor])
	TEST_ASSERT_EQUAL(snail.glide_size, MOVEMENT_ADJUSTED_GLIDE_SIZE(snail.move_interval, 1), "Gliding must last the entire movement interval")
	TEST_ASSERT_EQUAL(snail.next_step, world.time + snail.move_interval, "The next tile must follow the completed glide")
	TEST_ASSERT(length(snail.route), "The pathfinder should have returned a route")
	var/turf/blocked = snail.route[1]
	var/original_type = blocked.type
	blocked = blocked.ChangeTurf(/turf/closed/wall/r_wall)
	snail.pursue(person)
	TEST_ASSERT(!blocked.GetComponent(/datum/component/thermite), "A wall on a stale route must be bypassed when another path exists")
	TEST_ASSERT(get_turf(snail) != blocked, "The snail must use the detour")
	snail.chemically_breach(blocked)
	var/datum/component/thermite/wall_thermite = blocked.GetComponent(/datum/component/thermite)
	TEST_ASSERT(wall_thermite, "Reinforced walls must receive actual thermite")
	TEST_ASSERT_EQUAL(wall_thermite.amount, 50, "Reinforced walls need the stronger thermite dose")
	TEST_ASSERT(wall_thermite.burn_timer, "The thermite must be ignited")
	deltimer(wall_thermite.burn_timer)
	wall_thermite.burn_parent(snail)
	TEST_ASSERT(!iswallturf(blocked), "Thermite must melt the reinforced wall through its native reaction")
	blocked.ChangeTurf(original_type)
	blocked = snail.route[1]
	original_type = blocked.type
	blocked = blocked.ChangeTurf(/turf/closed/indestructible)
	snail.chemically_breach(blocked)
	snail.chemical_started = world.time - 17.5 SECONDS
	snail.chemically_breach(blocked)
	TEST_ASSERT(!isclosedturf(blocked), "Indestructible map walls must not trap the snail")
	blocked.ChangeTurf(original_type)
	var/obj/structure/closet/barrier = allocate(/obj/structure/closet, snail.route[1])
	barrier.resistance_flags |= INDESTRUCTIBLE
	snail.chemically_breach(barrier)
	TEST_ASSERT(barrier.GetComponent(/datum/component/acid), "Even resistant obstacles must receive chemical attacks first")
	var/turf/barrier_floor = get_turf(barrier)
	var/barrier_floor_type = barrier_floor.type
	snail.chemical_started = world.time - 4.2 SECONDS
	snail.chemically_breach(barrier)
	TEST_ASSERT(snail.chemical_escalated, "Resistant objects must trigger chlorine trifluoride escalation")
	TEST_ASSERT_EQUAL(barrier_floor.type, barrier_floor_type, "Burning a locker must preserve its floor tile")
	TEST_ASSERT(!(locate(/obj/effect/hotspot) in barrier_floor), "Breaching a locker must not ignite a floor fire")
	snail.chemical_started = world.time - 17.5 SECONDS
	snail.chemically_breach(barrier)
	TEST_ASSERT(QDELETED(barrier), "Indestructible dense objects must not trap the snail")
	var/list/sealed_surroundings = list()
	for(var/turf/neighbor in orange(1, snail))
		sealed_surroundings[neighbor] = neighbor.type
		neighbor.ChangeTurf(/turf/closed/wall/r_wall)
	snail.route.Cut()
	snail.pursue(person)
	var/turf/breach_target = snail.chemical_target?.resolve()
	TEST_ASSERT(breach_target && breach_target.GetComponent(/datum/component/thermite), "With no usable path or door, the snail must chemically breach a wall")
	for(var/turf/neighbor as anything in sealed_surroundings)
		neighbor.ChangeTurf(sealed_surroundings[neighbor])
	var/turf/other_level = locate(1, 1, snail.z == 1 ? 2 : 1)
	TEST_ASSERT(other_level, "A second z level is required for the pursuit test")
	person.forceMove(other_level)
	snail.pursue(person)
	TEST_ASSERT_EQUAL(snail.z, person.z, "The snail must follow between z levels")
	TEST_ASSERT(get_dist(snail, person) >= 10, "Z travel must reappear at a distance, not on the victim")

/datum/unit_test/immortal_snail_trail/Run()
	var/mob/living/basic/immortal_snail/snail = allocate(/mob/living/basic/immortal_snail)
	QDEL_NULL(snail.pursuit_driver)
	var/turf/starting = get_turf(snail)
	snail.forceMove(get_step(starting, EAST))
	var/obj/effect/decal/cleanable/immortal_snail_slime/first_patch = locate() in starting
	TEST_ASSERT(first_patch, "Slime must appear on the tile the snail leaves")
	TEST_ASSERT(first_patch.GetComponent(/datum/component/slippery), "The slime must be slippery")
	TEST_ASSERT(!(locate(/obj/effect/decal/cleanable/immortal_snail_slime) in snail.loc), "Slime must trail behind the snail")
	for(var/step in 1 to 3)
		snail.forceMove(get_step(snail, EAST))
	TEST_ASSERT_EQUAL(length(snail.slime_trail), 3, "Only the last three vacated tiles should retain slime")
	TEST_ASSERT(QDELETED(first_patch), "The fourth-oldest patch must disappear")
	// Doubling back must remove slime from under the snail, too.
	snail.forceMove(get_step(snail, WEST))
	TEST_ASSERT(!(locate(/obj/effect/decal/cleanable/immortal_snail_slime) in snail.loc), "Turning back must still leave slime behind")
	var/list/old_trail = snail.slime_trail.Copy()
	snail.forceMove(starting)
	TEST_ASSERT(!length(snail.slime_trail), "Teleporting must clear the old trail")
	for(var/obj/effect/decal/cleanable/immortal_snail_slime/patch as anything in old_trail)
		TEST_ASSERT(QDELETED(patch), "Teleporting must remove old slime objects")
	snail.forceMove(get_step(starting, EAST))
	first_patch = snail.slime_trail[1]
	qdel(snail, TRUE)
	TEST_ASSERT(QDELETED(first_patch), "Fulfilling or removing the curse must clean up its slime")

/datum/unit_test/immortal_snail_scheduled_pursuit
	var/mob/living/basic/immortal_snail/test_snail

/datum/unit_test/immortal_snail_scheduled_pursuit/Run()
	test_snail = allocate(/mob/living/basic/immortal_snail)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	test_snail.bind_target(person, 100000)
	test_snail.next_step = world.time
	var/datum/immortal_snail_pursuit/driver = test_snail.pursuit_driver
	TEST_ASSERT(driver in SSfastprocess.processing, "Movement must actually be registered with the fast processor")
	var/datum/controller/subsystem/mobs/life_processor = locate(test_snail.life_subsystem_type) in Master.subsystems
	TEST_ASSERT(test_snail in life_processor.processing, "Movement registration must preserve its configured mob life processing")
	var/turf/starting = get_turf(test_snail)
	var/deadline = world.time + 7 SECONDS
	// Do not call process() or pursue(): let the real scheduler make two moves.
	UNTIL(get_dist(starting, test_snail) >= 2 || world.time >= deadline)
	TEST_ASSERT(get_dist(starting, test_snail) >= 2, "The scheduler must autonomously move the snail more than once")
	qdel(test_snail, TRUE)
	TEST_ASSERT(QDELETED(driver), "Deleting the snail must delete its movement driver")
	TEST_ASSERT(!(driver in SSfastprocess.processing), "Deleted movement drivers must leave the processor")

/datum/unit_test/immortal_snail_scheduled_pursuit/Destroy()
	if(test_snail)
		test_snail.curse_fulfilled = TRUE
	return ..()

/datum/unit_test/immortal_snail_remote_spawn
	var/mob/living/basic/immortal_snail/spawned_snail
	var/obj/machinery/computer/slot_machine/normal_machine
	var/datum/snail_debt/previous_ledger
	var/turf/far_floor
	var/original_far_type

/datum/unit_test/immortal_snail_remote_spawn/Run()
	previous_ledger = GLOB.snail_debt
	var/obj/machinery/computer/slot_machine/immortal_snail/machine = allocate(/obj/machinery/computer/slot_machine/immortal_snail)
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	machine.minimum_spawn_distance = world.maxx + world.maxy
	TEST_ASSERT(!machine.claim_offer(person), "An unavailable distant spawn must not accept the offer")
	TEST_ASSERT(!machine.claimed, "A failed spawn must leave the offer unclaimed")
	TEST_ASSERT_EQUAL(GLOB.snail_debt, previous_ledger, "A failed spawn must not create a debt")
	machine.minimum_spawn_distance = 20
	far_floor = locate(machine.x + 25, machine.y, machine.z)
	original_far_type = far_floor.type
	far_floor = far_floor.ChangeTurf(/turf/open/floor/plating)
	var/turf/machine_turf = get_turf(machine)
	var/offer = machine.offer
	var/accepted = machine.claim_offer(person)
	for(var/obj/machinery/computer/slot_machine/replacement in machine_turf)
		if(replacement.type == /obj/machinery/computer/slot_machine)
			normal_machine = replacement
			break
	TEST_ASSERT(QDELETED(machine) && normal_machine, "Accepting must replace the cursed machine with a normal slot machine")
	TEST_ASSERT(locate(/obj/effect/temp_visual/small_smoke) in machine_turf, "Smoke must hide the machine's transformation")
	for(var/mob/living/basic/immortal_snail/snail in GLOB.mob_living_list)
		if(snail.original_target() == person)
			spawned_snail = snail
			break
	TEST_ASSERT(accepted && spawned_snail, "Accepting must create the distant pursuer")
	TEST_ASSERT_EQUAL(spawned_snail.z, person.z, "The initial pursuer must spawn on the same level")
	TEST_ASSERT(get_dist(spawned_snail, machine_turf) >= 20, "The snail must not spawn at or near the machine")
	TEST_ASSERT(get_dist(spawned_snail, person) >= 20, "The snail must start away from its target")
	TEST_ASSERT(get_dist(spawned_snail, machine_turf) <= 35, "The initial spawn must respect the search radius")
	TEST_ASSERT(isfloorturf(get_turf(spawned_snail)), "The initial spawn must be on a floor")
	TEST_ASSERT(spawned_snail.next_step <= world.time, "A distant pursuer must start immediately")
	TEST_ASSERT_EQUAL(spawned_snail.available_credits(person), offer, "The offer must still pay the full amount")

/datum/unit_test/immortal_snail_remote_spawn/Destroy()
	QDEL_NULL(normal_machine)
	if(spawned_snail)
		qdel(spawned_snail, TRUE)
	if(far_floor && original_far_type)
		far_floor.ChangeTurf(original_far_type)
	. = ..()
	GLOB.snail_debt = previous_ledger
