/// Check that flipping a hood up over a hat tucks the hat into the hood, and that flipping it back down puts the hat back on
/datum/unit_test/hood_overslot

/datum/unit_test/hood_overslot/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/suit/hooded/wintercoat/coat = allocate(/obj/item/clothing/suit/hooded/wintercoat)
	var/datum/component/toggle_attached_clothing/toggle = coat.GetComponent(/datum/component/toggle_attached_clothing)
	var/obj/item/clothing/head/soft/hat = allocate(/obj/item/clothing/head/soft)
	person.equip_to_slot(coat, ITEM_SLOT_OCLOTHING)
	person.equip_to_slot(hat, ITEM_SLOT_HEAD)
	toggle.toggle_deployable()
	TEST_ASSERT_EQUAL(person.head, coat.hood, "Person toggled their hood while wearing a hat, but the hood didn't go on their head.")
	TEST_ASSERT_EQUAL(hat.loc, coat.hood, "Person toggled their hood while wearing a hat, but the hat wasn't tucked into the hood.")
	toggle.toggle_deployable()
	TEST_ASSERT_EQUAL(person.head, hat, "Person lowered their hood, but their hat didn't go back on their head.")

/// Same as above, but for hoods that get deleted when they're lowered, so the hat doesn't get thanos snapped too
/datum/unit_test/hood_overslot_deleted_hood

/datum/unit_test/hood_overslot_deleted_hood/Run()
	var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/suit/hooded/wintercoat/deletes_hood/coat = allocate(/obj/item/clothing/suit/hooded/wintercoat/deletes_hood)
	var/datum/component/toggle_attached_clothing/toggle = coat.GetComponent(/datum/component/toggle_attached_clothing)
	var/obj/item/clothing/head/soft/hat = allocate(/obj/item/clothing/head/soft)
	person.equip_to_slot(coat, ITEM_SLOT_OCLOTHING)
	person.equip_to_slot(hat, ITEM_SLOT_HEAD)
	toggle.toggle_deployable()
	var/obj/item/clothing/head/hooded/hood = coat.hood
	TEST_ASSERT_NOTNULL(hood, "Person toggled their hood while wearing a hat, but no hood was made.")
	TEST_ASSERT_EQUAL(person.head, hood, "Person toggled their hood while wearing a hat, but the hood didn't go on their head.")
	TEST_ASSERT_EQUAL(hat.loc, hood, "Person toggled their hood while wearing a hat, but the hat wasn't tucked into the hood.")
	toggle.toggle_deployable()
	TEST_ASSERT(QDELETED(hood), "Person lowered their hood, but the hood wasn't deleted.")
	TEST_ASSERT(!QDELETED(hat), "Person lowered their hood, and the hat got deleted along with the hood.")
	TEST_ASSERT_EQUAL(person.head, hat, "Person lowered their hood, but their hat didn't go back on their head.")

/obj/item/clothing/suit/hooded/wintercoat/deletes_hood
	alternative_mode = TRUE
