/datum/quirk/psychic_blank
	name = "Psychic Blank"
	desc = "You are resistant to mental magics! You also can't cast them, so, yknow. Double edged sword and all that."
	icon = FA_ICON_BRAIN
	value = 8
	mob_trait = TRAIT_PSYCHIC_BLANK
	quirk_flags = QUIRK_HUMAN_ONLY
	medical_record_text = "Patient is unreceptive to mental magicks."
	mail_goodies = list(/obj/item/clothing/head/costume/foilhat)

/datum/quirk/psychic_blank/add(client/client_source)
	. = ..()
	quirk_holder.AddComponentFrom(QUIRK_TRAIT, /datum/component/anti_magic, antimagic_flags = MAGIC_RESISTANCE_MIND)

/datum/quirk/psychic_blank/remove()
	. = ..()
	quirk_holder.RemoveComponentSource(QUIRK_TRAIT, /datum/component/anti_magic)
