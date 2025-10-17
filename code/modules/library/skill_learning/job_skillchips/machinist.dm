/obj/item/skillchip/job/machinist
	name = "Engineering MCHN-1-ST skillchip"
	desc = "Knowledgebanks filled with memories of engineers gone by."
	auto_traits = list(TRAIT_KNOW_ENGI_WIRES)
	skill_name = "Machinery Foreknowledge"
	skill_description = "Gives access to knowledge banks pertaining to machining, increasing your machining and smithing skills."
	skill_icon = "sitemap"
	activate_message = span_notice("Your mind is dazed with schematics and experiences of dealing with machining flooding your mind.")
	deactivate_message = span_notice("Your mind is dazed with schematics and experiences of dealing with machining leaving your mind.")

/obj/item/skillchip/job/machinist/on_implant()
	. = ..()

	if(!holding_brain.owner.mind)
		return
	var/datum/mind/brain_mind = holding_brain.owner.mind
	brain_mind.adjust_experience(/datum/skill/machinist, 250, FALSE)
	brain_mind.adjust_experience(/datum/skill/smithing, 250, FALSE)

/obj/item/skillchip/job/machinist/on_removal()
	. = ..()

	if(!holding_brain.owner.mind)
		return
	var/datum/mind/brain_mind = holding_brain.owner.mind
	brain_mind.adjust_experience(/datum/skill/machinist, -250, FALSE)
	brain_mind.adjust_experience(/datum/skill/smithing, -250, FALSE)
