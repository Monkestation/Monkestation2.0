/* /datum/quirk/item_quirk/settler - monkestation disabled for now
	name = "Settler"
	desc = "You are from a lineage of the earliest space settlers! While your family's generational exposure to varying gravity \
		has resulted in a ... smaller height than is typical for your species, you make up for it by being much better at outdoorsmanship and \
		carrying heavy equipment. You also get along great with animals. However, you are a bit on the slow side due to your small legs."
	gain_text = span_bold("You feel like the world is your oyster!")
	lose_text = span_danger("You think you might stay home today.")
	icon = FA_ICON_HOUSE
	value = 4
	mob_trait = TRAIT_SETTLER
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE
	medical_record_text = "Patient appears to be abnormally stout."
	mail_goodies = list(
		/obj/item/clothing/shoes/workboots/mining,
		/obj/item/gps,
	)

/datum/quirk/item_quirk/settler/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/box/papersack/wheat, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/storage/toolbox/fishing/small, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	human_quirkholder.set_mob_height(HUMAN_HEIGHT_SHORTEST)
	human_quirkholder.add_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.physiology.hunger_mod *= 0.5 //good for you, shortass, you don't get hungry nearly as often

/datum/quirk/item_quirk/settler/remove()
	if(QDELING(quirk_holder))
		return
	var/mob/living/carbon/human/human_quirkholder = quirk_holder
	human_quirkholder.set_mob_height(HUMAN_HEIGHT_MEDIUM)
	human_quirkholder.remove_movespeed_modifier(/datum/movespeed_modifier/settler)
	human_quirkholder.physiology.hunger_mod *= 2
 */
