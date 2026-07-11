/datum/unit_test/ipc_brain_installation_rejects_occupied_shell

/datum/unit_test/ipc_brain_installation_rejects_occupied_shell/Run()
	var/mob/living/carbon/human/species/ipc/shell = allocate(/mob/living/carbon/human/species/ipc)
	shell.mind_initialize()
	var/datum/mind/original_personality = shell.mind
	var/obj/item/organ/internal/brain/original_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/bodypart/chest = shell.get_bodypart(BODY_ZONE_CHEST)

	var/obj/item/mmi/posibrain/incoming_mmi = allocate(/obj/item/mmi/posibrain)
	var/mob/living/brain/incoming_brainmob = incoming_mmi.brainmob
	incoming_brainmob.mind_initialize()
	var/datum/mind/incoming_personality = incoming_brainmob.mind
	var/atom/original_mmi_location = incoming_mmi.loc

	TEST_ASSERT(!incoming_mmi.attempt_become_ipc_organ(chest, shell, null), "An MMI was installed into an IPC shell whose brain slot was already occupied.")
	TEST_ASSERT_EQUAL(shell.get_organ_slot(ORGAN_SLOT_BRAIN), original_brain, "A rejected MMI installation replaced the IPC's existing brain.")
	TEST_ASSERT_EQUAL(shell.mind, original_personality, "A rejected MMI installation displaced the IPC's existing personality.")
	TEST_ASSERT_EQUAL(incoming_mmi.brainmob, incoming_brainmob, "A rejected MMI installation cleared the incoming MMI's brainmob.")
	TEST_ASSERT_EQUAL(incoming_personality.current, incoming_brainmob, "A rejected MMI installation transferred the incoming personality out of its brainmob.")
	TEST_ASSERT_EQUAL(incoming_mmi.loc, original_mmi_location, "A rejected MMI installation moved the incoming MMI.")

/datum/unit_test/positronic_ipc_binding_states

/datum/unit_test/positronic_ipc_binding_states/Run()
	var/mob/living/carbon/human/consistent/master = allocate(/mob/living/carbon/human/consistent)
	master.fully_replace_character_name(null, "Positronic Test Master")

	var/obj/item/mmi/posibrain/activated_unbound_posi = allocate(/obj/item/mmi/posibrain)
	activated_unbound_posi.personality_activated = TRUE
	activated_unbound_posi.attack_self_secondary(master)
	TEST_ASSERT_NULL(activated_unbound_posi.get_imprinted_master(), "A positronic brain accepted a new imprint after a personality had already activated.")

	var/mob/living/carbon/human/species/ipc/unbound_shell = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/organ/internal/brain/positronic/unbound_default_brain = unbound_shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	unbound_default_brain.Remove(unbound_shell, special = TRUE)
	qdel(unbound_default_brain)

	var/obj/item/mmi/posibrain/unbound_posi = allocate(/obj/item/mmi/posibrain)
	unbound_posi.brainmob.mind_initialize()
	var/datum/mind/unbound_personality = unbound_posi.brainmob.mind
	TEST_ASSERT_NULL(unbound_posi.get_ipc_brainwash_directive(unbound_shell, master), "An unbound positronic brain generated a master directive.")
	var/obj/item/bodypart/unbound_chest = unbound_shell.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(unbound_posi.attempt_become_ipc_organ(unbound_chest, unbound_shell, master), "An unbound positronic brain could not be installed into an IPC shell.")
	TEST_ASSERT_EQUAL(unbound_shell.mind, unbound_personality, "The unbound positronic personality was not transferred to its IPC shell.")
	TEST_ASSERT_NULL(unbound_personality.has_antag_datum(/datum/antagonist/brainwashed), "An unbound positronic IPC received a brainwashing directive.")

	var/mob/living/carbon/human/species/ipc/bound_shell = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/organ/internal/brain/positronic/bound_default_brain = bound_shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	bound_default_brain.Remove(bound_shell, special = TRUE)
	qdel(bound_default_brain)

	var/obj/item/mmi/posibrain/bound_posi = allocate(/obj/item/mmi/posibrain)
	bound_posi.brainmob.mind_initialize()
	var/datum/mind/bound_personality = bound_posi.brainmob.mind
	bound_posi.imprinted_master_ref = WEAKREF(master)
	var/bound_directive = bound_posi.get_ipc_brainwash_directive(bound_shell, master)
	TEST_ASSERT(findtext(bound_directive, master.real_name), "An imprinted positronic brain did not generate its master's directive.")
	TEST_ASSERT_EQUAL(bound_posi.get_ipc_brainwash_message(), "Your positronic imprint asserts itself, binding you to your master!", "An imprinted positronic brain used generic MMI installation feedback.")
	var/obj/item/bodypart/bound_chest = bound_shell.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(bound_posi.attempt_become_ipc_organ(bound_chest, bound_shell, master), "An imprinted positronic brain could not be installed into an IPC shell.")
	TEST_ASSERT_EQUAL(bound_shell.mind, bound_personality, "The imprinted positronic personality was not transferred to its IPC shell.")
	var/datum/antagonist/brainwashed/bound_brainwashing = bound_personality.has_antag_datum(/datum/antagonist/brainwashed)
	TEST_ASSERT_NOTNULL(bound_brainwashing, "An imprinted positronic IPC did not receive its master directive.")
	TEST_ASSERT_EQUAL(length(bound_brainwashing.objectives), 1, "An imprinted positronic IPC received duplicate directives.")
	bound_posi.try_unbrainwash_ipc(bound_shell)
	TEST_ASSERT_NULL(bound_personality.has_antag_datum(/datum/antagonist/brainwashed), "The positronic binding test left brainwashing active during test cleanup.")

/datum/unit_test/syndicate_mmi_ipc_brainwashing_lifecycle

/datum/unit_test/syndicate_mmi_ipc_brainwashing_lifecycle/Run()
	var/mob/living/carbon/human/species/ipc/shell = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/organ/internal/brain/positronic/default_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	default_brain.Remove(shell, special = TRUE)
	qdel(default_brain)
	TEST_ASSERT_NULL(shell.get_organ_slot(ORGAN_SLOT_BRAIN), "The IPC test shell retained its default brain.")

	var/obj/item/mmi/syndie/syndicate_mmi = allocate(/obj/item/mmi/syndie)
	var/mob/living/brain/incoming_brainmob = allocate(/mob/living/brain)
	incoming_brainmob.mind_initialize()
	var/datum/mind/incoming_personality = incoming_brainmob.mind
	syndicate_mmi.set_brainmob(incoming_brainmob)
	incoming_brainmob.forceMove(syndicate_mmi)
	incoming_brainmob.container = syndicate_mmi

	var/original_directive = "Continue serving the Syndicate while contained by this MMI."
	syndicate_mmi.brainwash_directive = original_directive
	syndicate_mmi.brainwash_objectives = brainwash(incoming_brainmob, original_directive, syndicate_mmi)

	var/mob/living/carbon/human/installer = allocate(/mob/living/carbon/human/consistent)
	installer.fully_replace_character_name(null, "Unit Test Installer")
	var/ipc_directive = syndicate_mmi.get_ipc_brainwash_directive(shell, installer)
	TEST_ASSERT_NULL(ipc_directive, "A Syndicate MMI with existing brainwashing generated a duplicate IPC directive.")

	syndicate_mmi.try_brainwash(installer)
	TEST_ASSERT_EQUAL(length(syndicate_mmi.brainwash_objectives), 1, "Reapplying Syndicate MMI brainwashing duplicated its tracked objective.")

	var/obj/item/bodypart/chest = shell.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(syndicate_mmi.attempt_become_ipc_organ(chest, shell, installer), "The occupied Syndicate MMI could not be installed into an empty IPC shell.")
	TEST_ASSERT_EQUAL(shell.mind, incoming_personality, "The incoming MMI personality was not transferred to the IPC shell.")
	TEST_ASSERT_EQUAL(syndicate_mmi.brainwash_directive, original_directive, "IPC installation overwrote the MMI's persistent brainwashing directive.")
	TEST_ASSERT_EQUAL(length(syndicate_mmi.brainwash_objectives), 1, "IPC installation altered the MMI's normal brainwashing objective tracking.")
	TEST_ASSERT_NULL(syndicate_mmi.ipc_brainwash_objectives, "IPC installation created a redundant Syndicate MMI directive.")

	var/datum/antagonist/brainwashed/installed_brainwashing = shell.mind.has_antag_datum(/datum/antagonist/brainwashed)
	TEST_ASSERT_NOTNULL(installed_brainwashing, "The installed IPC did not retain its Syndicate MMI brainwashing.")
	TEST_ASSERT_EQUAL(length(installed_brainwashing.objectives), 1, "The installed IPC received duplicate Syndicate MMI directives.")

	shell.Sleeping(5 MINUTES)
	TEST_ASSERT(shell.IsSleeping(), "The IPC test shell did not enter sleep before brain extraction.")
	var/obj/item/organ/internal/brain/positronic/installed_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	installed_brain.surgical_extraction = TRUE
	var/obj/item/mmi/extracted_mmi = installed_brain.Remove(shell)
	TEST_ASSERT_EQUAL(extracted_mmi, syndicate_mmi, "Surgical extraction did not return the installed Syndicate MMI.")
	TEST_ASSERT_EQUAL(syndicate_mmi.brainmob?.mind, incoming_personality, "The extracted MMI did not recover the IPC's personality.")
	TEST_ASSERT_NULL(syndicate_mmi.ipc_brainwash_objectives, "Surgical extraction retained IPC-only brainwashing tracking.")
	TEST_ASSERT_EQUAL(length(syndicate_mmi.brainwash_objectives), 1, "Surgical extraction removed the Syndicate MMI's normal objective tracking.")
	TEST_ASSERT(!shell.IsSleeping(), "An empty IPC shell retained its sleeping status and could continue producing snore emotes.")

	var/datum/antagonist/brainwashed/extracted_brainwashing = incoming_personality.has_antag_datum(/datum/antagonist/brainwashed)
	TEST_ASSERT_NOTNULL(extracted_brainwashing, "Extracting the MMI removed its normal Syndicate brainwashing.")
	TEST_ASSERT_EQUAL(length(extracted_brainwashing.objectives), 1, "Extracting the MMI changed its normal Syndicate directive count.")

	syndicate_mmi.try_unbrainwash()
	TEST_ASSERT_NULL(incoming_personality.has_antag_datum(/datum/antagonist/brainwashed), "Removing the remaining normal MMI brainwashing left a brainwashed antagonist datum behind.")

/datum/unit_test/syndicate_mmi_ipc_special_removal_cleans_brainwashing

/datum/unit_test/syndicate_mmi_ipc_special_removal_cleans_brainwashing/Run()
	var/mob/living/carbon/human/species/ipc/shell = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/organ/internal/brain/positronic/default_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	default_brain.Remove(shell, special = TRUE)
	qdel(default_brain)

	var/obj/item/mmi/syndie/syndicate_mmi = allocate(/obj/item/mmi/syndie)
	var/mob/living/brain/incoming_brainmob = allocate(/mob/living/brain)
	incoming_brainmob.mind_initialize()
	var/datum/mind/incoming_personality = incoming_brainmob.mind
	syndicate_mmi.set_brainmob(incoming_brainmob)
	incoming_brainmob.forceMove(syndicate_mmi)
	incoming_brainmob.container = syndicate_mmi

	var/original_directive = "Continue serving the Syndicate while contained by this MMI."
	syndicate_mmi.brainwash_directive = original_directive
	syndicate_mmi.brainwash_objectives = brainwash(incoming_brainmob, original_directive, syndicate_mmi)

	var/mob/living/carbon/human/installer = allocate(/mob/living/carbon/human/consistent)
	installer.fully_replace_character_name(null, "Special Removal Test Installer")
	var/obj/item/bodypart/chest = shell.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(syndicate_mmi.attempt_become_ipc_organ(chest, shell, installer), "The Syndicate MMI could not be installed for the special-removal test.")

	var/datum/antagonist/brainwashed/installed_brainwashing = shell.mind.has_antag_datum(/datum/antagonist/brainwashed)
	TEST_ASSERT_NOTNULL(installed_brainwashing, "The installed IPC was not brainwashed before special removal.")
	TEST_ASSERT_EQUAL(length(installed_brainwashing.objectives), 1, "The installed IPC began with duplicate Syndicate MMI directives.")

	var/obj/item/organ/internal/brain/positronic/installed_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	installed_brain.Remove(shell, special = TRUE)
	TEST_ASSERT_EQUAL(shell.mind, incoming_personality, "Special brain removal unexpectedly displaced the IPC's personality.")
	TEST_ASSERT_NULL(incoming_personality.has_antag_datum(/datum/antagonist/brainwashed), "Special brain removal left MMI brainwashing attached to the IPC's mind.")
	TEST_ASSERT_NULL(syndicate_mmi.brainwash_objectives, "Special brain removal retained normal MMI objective tracking.")
	TEST_ASSERT_NULL(syndicate_mmi.ipc_brainwash_objectives, "Special brain removal retained IPC-only objective tracking.")
	qdel(installed_brain)

/datum/unit_test/syndicate_mmi_ipc_direct_deletion_cleans_brainwashing

/datum/unit_test/syndicate_mmi_ipc_direct_deletion_cleans_brainwashing/Run()
	var/mob/living/carbon/human/species/ipc/shell = allocate(/mob/living/carbon/human/species/ipc)
	var/obj/item/organ/internal/brain/positronic/default_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	default_brain.Remove(shell, special = TRUE)
	qdel(default_brain)

	var/obj/item/mmi/syndie/syndicate_mmi = allocate(/obj/item/mmi/syndie)
	var/mob/living/brain/incoming_brainmob = allocate(/mob/living/brain)
	incoming_brainmob.mind_initialize()
	var/datum/mind/incoming_personality = incoming_brainmob.mind
	syndicate_mmi.set_brainmob(incoming_brainmob)
	incoming_brainmob.forceMove(syndicate_mmi)
	incoming_brainmob.container = syndicate_mmi

	var/original_directive = "Continue serving the Syndicate while contained by this MMI."
	syndicate_mmi.brainwash_directive = original_directive
	syndicate_mmi.brainwash_objectives = brainwash(incoming_brainmob, original_directive, syndicate_mmi)

	var/mob/living/carbon/human/installer = allocate(/mob/living/carbon/human/consistent)
	installer.fully_replace_character_name(null, "Direct Deletion Test Installer")
	var/obj/item/bodypart/chest = shell.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(syndicate_mmi.attempt_become_ipc_organ(chest, shell, installer), "The Syndicate MMI could not be installed for the direct-deletion test.")

	var/datum/antagonist/brainwashed/installed_brainwashing = shell.mind.has_antag_datum(/datum/antagonist/brainwashed)
	TEST_ASSERT_NOTNULL(installed_brainwashing, "The installed IPC was not brainwashed before direct brain deletion.")
	TEST_ASSERT_EQUAL(length(installed_brainwashing.objectives), 1, "The installed IPC began with duplicate Syndicate MMI directives.")

	var/obj/item/organ/internal/brain/positronic/installed_brain = shell.get_organ_slot(ORGAN_SLOT_BRAIN)
	qdel(installed_brain)
	TEST_ASSERT_NULL(shell.get_organ_slot(ORGAN_SLOT_BRAIN), "Direct brain deletion left the deleted organ in the IPC brain slot.")
	TEST_ASSERT_EQUAL(shell.mind, incoming_personality, "Direct brain deletion unexpectedly displaced the IPC's personality.")
	TEST_ASSERT_NULL(incoming_personality.has_antag_datum(/datum/antagonist/brainwashed), "Direct brain deletion left MMI brainwashing attached to the IPC's mind.")
	TEST_ASSERT(QDELETED(syndicate_mmi), "Direct brain deletion did not delete the stored MMI.")
