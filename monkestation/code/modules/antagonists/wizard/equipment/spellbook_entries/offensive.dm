/datum/spellbook_entry/summon_mjollnir //replacement for the majollnir item
	name = "Summon Mjollnir"
	desc = "Summons the mighty Mjollnir to you for a limited time."
	spell_type = /datum/action/cooldown/spell/conjure_item/summon_mjollnir
	category = "Offensive"
	cost = 2

/datum/spellbook_entry/smite
	name = "Smite"
	desc = "Allows you to call in a favor from the gods upon your foe."
	spell_type = /datum/action/cooldown/spell/pointed/smite
	category = "Offensive"

/datum/spellbook_entry/item/badmin_gauntlet
	name = "Badmin Gauntlet"
	desc = "A gauntlet capable of holding the Badmin Stones. Wearing this will trigger a war declaration!. \
			Before you wear it, you can refund it by hitting it against the spellbook. \
			You cannot buy this if you have bought anything else! \
			Requires 27+ crew."
	item_path = /obj/item/badmin_gauntlet
	category = "Rituals"
	refundable = TRUE
	cost = 10

/datum/spellbook_entry/item/badmin_gauntlet/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy)
	. = ..()
	book.uses = 0

/datum/spellbook_entry/item/badmin_gauntlet/can_buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return ..() && !book.gauntlet_flag && (GLOB.Debug2 || GLOB.joined_player_list.len >= 27)
