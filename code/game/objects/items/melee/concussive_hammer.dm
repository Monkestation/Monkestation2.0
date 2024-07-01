/obj/item/melee/concussive_hammer
	name = "concussive hammer"
	desc = "A pneumatic hammer with a soft rubber head encompassing the front, for syndicate agents who are against murder."
	icon = 'icons/obj/weapons/cleric_mace.dmi' //Placeholder
	icon_state = "default"
	inhand_icon_state = "default"
	attack_verb_continuous = list("strikes")
	attack_verb_simple = list("strike")
	slot_flags = ITEM_SLOT_BELT + ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	var/datum/action/cooldown/spell/pointed/concuss = new

/obj/item/melee/concussive_hammer/Destroy()
	qdel(concuss)
	return ..()

/datum/action/cooldown/spell/pointed/concuss
	name = "Concuss"
	desc = "TBD"
	background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND
	spell_requirements = SPELL_REQUIRES_HUMAN
	antimagic_flags = NONE
	cooldown_time = 10 //Subject to balancing
	spell_max_level = 1
	cast_range = 1 //I know this looks horrible but this isn't possible with touch spell as both hands are holding the item
	overlay_icon_state = "bg_default_border"

/obj/item/melee/concussive_hammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/melee/concussive_hammer/equipped(mob/living/owner, slot)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		concuss.Grant(owner)

/obj/item/melee/concussive_hammer/dropped(mob/living/owner, slot)
	. = ..()
	if(owner.get_item_by_slot(ITEM_SLOT_HANDS) == src)
		concuss.Remove(owner)

