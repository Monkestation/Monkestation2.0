/datum/unit_test/ipc_construction_head_validation

/datum/unit_test/ipc_construction_head_validation/Run()
	var/obj/item/ipc_core/core = allocate(/obj/item/ipc_core)
	core.stomach = new /obj/item/organ/internal/stomach/synth(core)
	core.lungs = new /obj/item/organ/internal/lungs/synth(core)
	core.heart = new /obj/item/organ/internal/heart/synth(core)
	core.liver = new /obj/item/organ/internal/liver/synth(core)
	core.core_wired = TRUE
	core.core_secured = TRUE
	core.l_arm = new /obj/item/bodypart/arm/left/ipc(core)
	core.r_arm = new /obj/item/bodypart/arm/right/ipc(core)
	core.l_leg = new /obj/item/bodypart/leg/left/ipc(core)
	core.r_leg = new /obj/item/bodypart/leg/right/ipc(core)

	var/obj/item/bodypart/head/ipc/head = new(core)
	core.head = head
	var/obj/item/organ/internal/eyes/synth/eyes = allocate(/obj/item/organ/internal/eyes/synth)
	eyes.forceMove(head)
	head.ipc_eyes = eyes
	head.ipc_ears = new /obj/item/organ/internal/ears/synth(head)
	head.ipc_tongue = new /obj/item/organ/internal/tongue/robot/synth(head)
	head.antennae = new /obj/item/organ/external/antennae/ipc(head)
	head.wired = TRUE
	head.secured = TRUE

	TEST_ASSERT(head.check_completion(), "A fully populated IPC head did not report complete.")
	TEST_ASSERT(core.check_body_completion(), "A fully populated IPC core did not accept its completed head.")

	var/obj/item/organ/internal/eyes/synth/removed_eyes = head.ipc_eyes
	removed_eyes.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!head.secured, "Removing a component from a secured IPC head did not invalidate its secured state.")

	// A stale or externally modified secured flag must not let a stripped head pass chassis validation.
	head.secured = TRUE
	TEST_ASSERT(!head.check_completion(), "An IPC head missing its eyes still reported complete.")
	TEST_ASSERT(!core.check_body_completion(), "An IPC core accepted a stripped head solely because its secured flag was set.")

/datum/unit_test/ipc_construction_augment_policy

/datum/unit_test/ipc_construction_augment_policy/Run()
	var/mob/living/carbon/human/species/ipc/roundstart_ipc = allocate(/mob/living/carbon/human/species/ipc, run_loc_floor_top_right)
	TEST_ASSERT_NOTNULL(roundstart_ipc.get_organ_by_type(/obj/item/organ/internal/cyberimp/arm/item_set/power_cord), "A naturally initialized IPC did not receive its roundstart power cord.")

	var/obj/item/ipc_core/core = allocate(/obj/item/ipc_core, run_loc_floor_bottom_left)
	core.stomach = new /obj/item/organ/internal/stomach/synth(core)
	core.lungs = new /obj/item/organ/internal/lungs/synth(core)
	core.heart = new /obj/item/organ/internal/heart/synth(core)
	core.liver = new /obj/item/organ/internal/liver/synth(core)
	core.core_wired = TRUE
	core.core_secured = TRUE
	core.l_arm = new /obj/item/bodypart/arm/left/ipc(core)
	core.r_arm = new /obj/item/bodypart/arm/right/ipc(core)
	core.l_leg = new /obj/item/bodypart/leg/left/ipc(core)
	core.r_leg = new /obj/item/bodypart/leg/right/ipc(core)

	var/obj/item/bodypart/head/ipc/head = new(core)
	core.head = head
	var/obj/item/organ/internal/eyes/synth/eyes = new(head)
	head.ipc_eyes = eyes
	head.ipc_ears = new /obj/item/organ/internal/ears/synth(head)
	head.ipc_tongue = new /obj/item/organ/internal/tongue/robot/synth(head)
	head.antennae = new /obj/item/organ/external/antennae/ipc(head)
	head.wired = TRUE
	head.secured = TRUE

	core.screen = new /obj/item/organ/external/ipc_screen(core)
	core.screen_wired = TRUE
	core.screen_secured = TRUE

	var/mob/living/carbon/human/consistent/builder = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	TEST_ASSERT(core.build_ipc_body(builder), "A complete IPC core failed to produce a constructed shell.")
	var/mob/living/carbon/human/species/ipc/constructed_shell = locate(/mob/living/carbon/human/species/ipc) in run_loc_floor_bottom_left
	TEST_ASSERT_NOTNULL(constructed_shell, "The completed IPC shell was not present on the construction turf.")

	TEST_ASSERT_NULL(constructed_shell.get_organ_by_type(/obj/item/organ/internal/cyberimp/arm/item_set/power_cord), "A constructed IPC shell retained the roundstart power cord augment.")
	TEST_ASSERT_NOTNULL(constructed_shell.get_organ_by_type(/obj/item/organ/internal/butt/iron), "A constructed IPC shell lost its naturally initialized iron butt.")
	// Exclude the head and core so this focused check does not generate a brain and revive the intentionally inert shell.
	constructed_shell.dna.species.regenerate_organs(constructed_shell, replace_current = FALSE, excluded_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
	TEST_ASSERT_NULL(constructed_shell.get_organ_by_type(/obj/item/organ/internal/cyberimp/arm/item_set/power_cord), "Organ regeneration restored the roundstart power cord to a constructed IPC shell.")

	var/mob/living/carbon/human/species/ipc/later_roundstart_ipc = allocate(/mob/living/carbon/human/species/ipc)
	TEST_ASSERT_NOTNULL(later_roundstart_ipc.get_organ_by_type(/obj/item/organ/internal/cyberimp/arm/item_set/power_cord), "Constructing an IPC shell removed the power cord from later roundstart IPCs.")
	qdel(constructed_shell)
