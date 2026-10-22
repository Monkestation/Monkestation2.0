/obj/item/organ/internal/heart/gland/slime
	abductor_hint = "gastric animation galvanizer. The abductee occasionally vomits slimes. Slimes will no longer attack the abductee."
	cooldown_low = 1 MINUTES
	cooldown_high = 2 MINUTES
	uses = -1
	icon_state = "slime"
	mind_control_uses = 1
	mind_control_duration = 4 MINUTES
	/// Whether the slime faction was given to the owner of this gland or not.
	/// Used so we don't take the slime faction away from someone who had it anyways
	var/gave_faction = FALSE

/obj/item/organ/internal/heart/gland/slime/on_insert(mob/living/carbon/gland_owner)
	. = ..()
	if(!(FACTION_SLIME in gland_owner.faction))
		gland_owner.faction |= FACTION_SLIME
		gave_faction = TRUE
	gland_owner.grant_language(/datum/language/slime, source = LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/on_remove(mob/living/carbon/gland_owner)
	. = ..()
	if(gave_faction)
		gland_owner.faction -= FACTION_SLIME
	gland_owner.remove_language(/datum/language/slime, source = LANGUAGE_GLAND)

/obj/item/organ/internal/heart/gland/slime/activate()
	owner.balloon_alert(owner, "you feel nauseous")
	owner.vomit(20)

	var/mob/living/basic/slime/friend = new(owner.drop_location())
	SEND_SIGNAL(friend, COMSIG_FRIENDSHIP_CHANGE, owner, 110)
