/obj/item/organ/internal/heart/gland/ventcrawling
	abductor_hint = "pliant cartilage enabler. The abductee can crawl through vents without trouble."
	cooldown_low = 3 MINUTES
	cooldown_high = 4 MINUTES
	uses = 1
	icon_state = "vent"
	mind_control_uses = 4
	mind_control_duration = 3 MINUTES

/obj/item/organ/internal/heart/gland/ventcrawling/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	organ_owner.AddComponentFrom(REF(src), /datum/component/vent_safety)

/obj/item/organ/internal/heart/gland/ventcrawling/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	organ_owner.RemoveComponentSource(REF(src), /datum/component/vent_safety)

/obj/item/organ/internal/heart/gland/ventcrawling/activate()
	to_chat(owner, span_notice("You feel very stretchy."))
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_ALWAYS, ABDUCTOR_GLAND_TRAIT)
