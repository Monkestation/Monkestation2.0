/// Check that toggling headgear on a suit tucks a worn hat into it, and that lowering it puts the hat back on (and doesn't delete it along with headgear that gets deleted)
/datum/unit_test/headgear_overslot

/datum/unit_test/headgear_overslot/Run()
	var/list/suit_types = list(
		/obj/item/clothing/suit/hooded/wintercoat,
		/obj/item/clothing/suit/hooded/wintercoat/deletes_hood,
		/obj/item/clothing/suit/space/hardsuit,
		/obj/item/clothing/suit/egosuits/realized/prophet,
	)
	for(var/suit_type in suit_types)
		var/mob/living/carbon/human/person = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/clothing/suit/suit = allocate(suit_type)
		var/datum/component/toggle_attached_clothing/toggle = suit.GetComponent(/datum/component/toggle_attached_clothing)
		var/obj/item/clothing/head/soft/hat = allocate(/obj/item/clothing/head/soft)
		person.equip_to_slot(suit, ITEM_SLOT_OCLOTHING)
		person.equip_to_slot(hat, ITEM_SLOT_HEAD)
		toggle.toggle_deployable()
		TEST_ASSERT_NOTNULL(toggle.deployable, "[suit_type] was toggled while wearing a hat, but no headgear was made.")
		TEST_ASSERT_EQUAL(person.head, toggle.deployable, "[suit_type] was toggled while wearing a hat, but its headgear didn't go on their head.")
		TEST_ASSERT_EQUAL(hat.loc, toggle.deployable, "[suit_type] was toggled while wearing a hat, but the hat wasn't tucked into its headgear.")
		toggle.toggle_deployable()
		TEST_ASSERT(!QDELETED(hat), "[suit_type] had its headgear lowered, but the hat got deleted along with it.")
		TEST_ASSERT_EQUAL(person.head, hat, "[suit_type] had its headgear lowered, but the hat didn't go back on their head.")

/obj/item/clothing/suit/hooded/wintercoat/deletes_hood
	alternative_mode = TRUE
