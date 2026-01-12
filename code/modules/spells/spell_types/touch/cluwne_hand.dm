/datum/action/cooldown/spell/touch/cluwne
	name = "Cluwne Curse"
	desc = "This spell charges your hand with an unholy energy \
		that can be used to cause a touched victim to become a Cluwne."
	button_icon = 'icons/obj/clothing/masks.dmi'
	button_icon_state = "cluwne"
	sound = 'sound/misc/scary_horn.ogg'

	spell_requirements = NONE
	cooldown_time = 30 SECONDS

	invocation = "HONK!"

	hand_path = /obj/item/melee/touch_attack/cluwne


/datum/action/cooldown/spell/touch/cluwne/on_antimagic_triggered(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	caster.visible_message(
		span_warning("The feedback blows [caster]'s arm off!"),
		span_userdanger("The spell bounces from [victim]'s skin back into your arm!"),
	)
	// Off goes the arm we were casting with!
	var/obj/item/bodypart/to_dismember = caster.get_holding_bodypart_of_item(hand)
	to_dismember?.dismember()
	// And do the blind (us included)
	caster.flash_act()

/datum/action/cooldown/spell/touch/cluwne/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(!ishuman(victim))
		to_chat(caster, span_warning("This must be used on a human form!"))
		return
	if(victim.GetComponent(/datum/component/cluwne))
		to_chat(caster, span_warning("They have already been cursed!"))
		return
	if(!(locate(/datum/action/cooldown/spell/touch/cluwne) in victim.actions))
		var/datum/action/cooldown/spell/touch/cluwne/spread_curse = new /datum/action/cooldown/spell/touch/cluwne/(victim.mind || victim)
		spread_curse.Grant(victim)
	victim.AddComponent(/datum/component/cluwne, deconversion = CLUWNE_DECONVERT_ON_DIVINE_INTERVENTION)

	return TRUE

/obj/item/melee/touch_attack/cluwne
	name = "\improper stinky hand"
	desc = "This hand of mine glows and smells like glue.. what?"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "greyscale"
	inhand_icon_state = "greyscale"
	color = COLOR_VIBRANT_LIME

