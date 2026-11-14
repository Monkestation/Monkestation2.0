/// The drain that completes a mutation's quota should be the same drain that rolls the mutation.
/datum/unit_test/slime_ranch_drain_rolls_on_same_bite

/datum/unit_test/slime_ranch_drain_rolls_on_same_bite/Run()
	SSmobs.pause()

	var/mob/living/basic/slime/rancher = allocate(/mob/living/basic/slime, run_loc_floor_bottom_left, /datum/slime_type/grey, SLIME_LIFE_STAGE_ADULT)
	var/mob/living/basic/cockroach/iceroach/lunch = allocate(/mob/living/basic/cockroach/iceroach)
	rancher.mutation_chance = 100
	rancher.set_slime_type(/datum/slime_type/grey)

	SEND_SIGNAL(rancher, COMSIG_SLIME_LATCH_DRAINED, lunch, SLIME_RANCH_EXTRACT_COST)

	TEST_ASSERT(rancher.has_status_effect(/datum/status_effect/slime_reproducing), "final iceroach drain did not start a mutation")
	TEST_ASSERT_EQUAL(rancher.queued_mutation, /datum/slime_type/blue, "mutation rolled something other than blue")
	TEST_ASSERT(isnull(locate(/obj/item/slime_extract) in run_loc_floor_bottom_left), "the drain spent its progress on an extract instead")

/datum/unit_test/slime_ranch_drain_rolls_on_same_bite/Destroy()
	SSmobs.ignite()
	return ..()

/// An interrupted ranch mutation keeps its rolled color, blocks new meals, and restarts itself from Life().
/datum/unit_test/slime_ranch_mutation_recovers

/datum/unit_test/slime_ranch_mutation_recovers/Run()
	SSmobs.pause()

	var/mob/living/basic/slime/rancher = allocate(/mob/living/basic/slime, run_loc_floor_bottom_left, /datum/slime_type/grey, SLIME_LIFE_STAGE_ADULT)
	var/mob/living/basic/cockroach/iceroach/lunch = allocate(/mob/living/basic/cockroach/iceroach)
	rancher.mutation_chance = 100
	SEND_SIGNAL(rancher, COMSIG_SLIME_LATCH_DRAINED, lunch, SLIME_RANCH_EXTRACT_COST)

	rancher.apply_damage(5, BRUTE)
	TEST_ASSERT(!rancher.has_status_effect(/datum/status_effect/slime_reproducing), "damage did not interrupt the mutation")
	TEST_ASSERT_EQUAL(rancher.pending_ranch_mutation, /datum/slime_type/blue, "the interrupted mutation forgot what it rolled")

	SEND_SIGNAL(rancher, COMSIG_SLIME_LATCH_DRAINED, lunch, SLIME_RANCH_EXTRACT_COST)
	TEST_ASSERT(isnull(locate(/obj/item/slime_extract) in run_loc_floor_bottom_left), "a stored mutation's progress got spent on an extract")

	TEST_ASSERT(rancher.can_feed_on(lunch, silent = TRUE), "feeding was blocked while the retry cooldown was still running")
	COOLDOWN_RESET(rancher, ranch_retry_cooldown)
	TEST_ASSERT(!rancher.can_feed_on(lunch, silent = TRUE), "a ready mutation did not block new meals")

	rancher.Life(SSMOBS_DT)
	TEST_ASSERT(rancher.has_status_effect(/datum/status_effect/slime_reproducing), "Life() did not restart the stored mutation")
	TEST_ASSERT_EQUAL(rancher.queued_mutation, /datum/slime_type/blue, "the restarted mutation rerolled its color")

	rancher.remove_status_effect(/datum/status_effect/slime_reproducing)
	TEST_ASSERT_EQUAL(rancher.slime_type.type, /datum/slime_type/blue, "the finished mutation did not turn the slime blue")
	TEST_ASSERT(isnull(rancher.pending_ranch_mutation), "the finished mutation was left stored")
	TEST_ASSERT(rancher.can_feed_on(lunch, silent = TRUE), "feeding stayed blocked after the mutation finished")

/datum/unit_test/slime_ranch_mutation_recovers/Destroy()
	SSmobs.ignite()
	return ..()

/// A primed split refused for growth retries on its own, with no further food.
/datum/unit_test/slime_ranch_split_retries_without_food

/datum/unit_test/slime_ranch_split_retries_without_food/Run()
	SSmobs.pause()

	var/mob/living/basic/slime/rancher = allocate(/mob/living/basic/slime, run_loc_floor_bottom_left, /datum/slime_type/grey, SLIME_LIFE_STAGE_ADULT)
	var/mob/living/basic/cockroach/iceroach/lunch = allocate(/mob/living/basic/cockroach/iceroach)
	rancher.amount_grown = 0
	rancher.set_primed_split_cost(SLIME_RANCH_COMMAND_SPLIT_COST)

	SEND_SIGNAL(rancher, COMSIG_SLIME_LATCH_DRAINED, lunch, SLIME_RANCH_COMMAND_SPLIT_COST)
	TEST_ASSERT(!rancher.has_status_effect(/datum/status_effect/slime_reproducing), "an ungrown slime started splitting anyway")

	rancher.amount_grown = SLIME_EVOLUTION_THRESHOLD
	rancher.Life(SSMOBS_DT)
	TEST_ASSERT(rancher.has_status_effect(/datum/status_effect/slime_reproducing), "Life() did not retry the funded split once it had grown")
	TEST_ASSERT_EQUAL(rancher.queued_mutation, /datum/slime_type/grey, "the retried split mutated instead of splitting")

/datum/unit_test/slime_ranch_split_retries_without_food/Destroy()
	SSmobs.ignite()
	return ..()

/// A critter whose drain quota is already finished stays worth chasing, so critter-only pens can still feed a slime.
/datum/unit_test/slime_ranch_finished_quota_critter_stays_food

/datum/unit_test/slime_ranch_finished_quota_critter_stays_food/Run()
	SSmobs.pause()

	var/mob/living/basic/slime/rancher = allocate(/mob/living/basic/slime, run_loc_floor_bottom_left, /datum/slime_type/grey, SLIME_LIFE_STAGE_BABY)
	var/mob/living/basic/cockroach/iceroach/lunch = allocate(/mob/living/basic/cockroach/iceroach)
	SEND_SIGNAL(rancher, COMSIG_SLIME_LATCH_DRAINED, lunch, SLIME_RANCH_EXTRACT_COST)

	var/datum/targeting_strategy/slime_food/appetite = GET_TARGETING_STRATEGY(/datum/targeting_strategy/slime_food)
	TEST_ASSERT(appetite.can_attack(rancher, lunch, 7), "a drained-out iceroach stopped counting as slime food")

/datum/unit_test/slime_ranch_finished_quota_critter_stays_food/Destroy()
	SSmobs.ignite()
	return ..()

/// Coming back out of a vacuum pack shakes a slime off whatever it was fixated on.
/datum/unit_test/slime_vacuum_release_resets_ai

/datum/unit_test/slime_vacuum_release_resets_ai/Run()
	var/mob/living/basic/slime/rancher = allocate(/mob/living/basic/slime, run_loc_floor_bottom_left, /datum/slime_type/grey, SLIME_LIFE_STAGE_ADULT)
	var/mob/living/basic/cockroach/iceroach/quarry = allocate(/mob/living/basic/cockroach/iceroach)
	var/obj/item/vacuum_pack/pack = allocate(/obj/item/vacuum_pack)

	rancher.ai_controller.set_blackboard_key(BB_SLIME_EAT_TARGET, quarry)
	rancher.ai_controller.set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, quarry, world.time + SLIME_CHASE_GIVE_UP_TIME)
	COOLDOWN_START(rancher, ranch_retry_cooldown, SLIME_RANCH_RETRY_COOLDOWN)
	rancher.forceMove(pack)

	TEST_ASSERT(pack.release(rancher, run_loc_floor_bottom_left), "the slime did not come back out of the pack")
	TEST_ASSERT(isnull(rancher.ai_controller.blackboard[BB_SLIME_EAT_TARGET]), "the released slime kept chasing its old target")
	TEST_ASSERT(!length(rancher.ai_controller.blackboard[BB_TEMPORARY_IGNORE_LIST]), "the released slime kept ignoring what it had given up on")
	TEST_ASSERT(COOLDOWN_FINISHED(rancher, ranch_retry_cooldown), "the released slime still had to wait out its ranch retry cooldown")

/// A radio in a warped room is on the z-levels of its runes for telecomms, even through a rune drawn inside another room.
/datum/unit_test/warped_room_telecomms

/datum/unit_test/warped_room_telecomms/Run()
	var/obj/effect/warped_rune/rainbowspace/station_rune = allocate(/obj/effect/warped_rune/rainbowspace, run_loc_floor_bottom_left, /datum/slime_type/grey)
	UNTIL(station_rune.room.exit_door)
	var/obj/effect/warped_rune/rainbowspace/nested_rune = allocate(/obj/effect/warped_rune/rainbowspace, get_turf(station_rune.room.exit_door), /datum/slime_type/orange)
	UNTIL(nested_rune.room.exit_door)
	var/obj/item/radio/radio = allocate(/obj/item/radio, get_turf(nested_rune.room.exit_door))
	var/list/station_levels = list(run_loc_floor_bottom_left.z)

	TEST_ASSERT(radio.can_receive(FREQ_COMMON, station_levels), "a radio two rooms deep could not hear the level the outer rune is on")
	TEST_ASSERT((run_loc_floor_bottom_left.z in get_telecomms_levels(get_turf(radio))), "a signal from two rooms deep did not start on the level the outer rune is on")

	qdel(station_rune)
	TEST_ASSERT(!radio.can_receive(FREQ_COMMON, station_levels), "the radio still heard that level after its only way out was erased")
