/datum/rune_spell/summonrobes
	name = "Summon Robes"
	desc = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes."
	desc_talisman = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes. Using the tesseract will also give you the talisman back, granted it has some uses left."
	invocation = "Sa tatha najin"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/destroy
	word3 = /datum/rune_word/other
	talisman_uses = 5
	page = "This rune, which you have to stand above to use, equips your character in cult apparel. Namely, a hood, robes, shoes, gloves, and a backpack.\
		<br><br>Wearing cult gear speeds up channeling of Conversion and Raise Structures runes, but the hood can also be toggled to hide your face and voice, granting you sweet anonymity (so long as you don't forget to pocket your ID card).\
		<br><br>After using the rune, a Blood Tesseract appears in your hand, containing clothes that had to be swapped out because you were already wearing them in your head/suit slots. \
		You can use it to get your clothing back instantly, or throw the tesseract to break it and get its content back this way.\
		<br><br>Lastly, the talisman version has 5 uses, and gets back in your hand after you use the Blood Tesseract. The inventory of your backpack gets always gets transferred upon use.\
		<br><br>This rune persists upon use, allowing repeated usage."
	var/list/slots_to_store = list(
		ITEM_SLOT_FEET,
		ITEM_SLOT_HEAD,
		ITEM_SLOT_GLOVES,
		ITEM_SLOT_BACK,
		ITEM_SLOT_OCLOTHING,
		ITEM_SLOT_ICLOTHING,
		)

/datum/rune_spell/summonrobes/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()


	var/list/potential_targets = list()
	var/turf/TU = get_turf(spell_holder)

	for(var/mob/living/carbon/C in TU)
		potential_targets += C
	if(potential_targets.len == 0)
		to_chat(activator, span_warning("There needs to be someone standing or lying on top of the rune.") )
		qdel(src)
		return
	var/mob/living/carbon/target
	if(activator in potential_targets)
		target = activator
	else
		target = pick(potential_targets)

	if (!ishuman(target) && !ismonkey(target))
		qdel(src)
		return

	anim(target = target, a_icon = 'monkestation/code/modules/bloody_cult/icons/64x64.dmi', flick_anim = "rune_robes", offX = -32/2, offY = -32/2, plane = ABOVE_LIGHTING_PLANE)

	var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)
	cult_datum.gain_devotion(50, DEVOTION_TIER_0, "summon_robes", target)

	var/obj/item/weapon/blood_tesseract/BT = new(get_turf(activator))
	if (istype (spell_holder, /obj/item/weapon/talisman))
		var/obj/item/weapon/talisman/T = spell_holder
		if (!T.linked_ui)
			activator.dropItemToGround(spell_holder)
			if (T.uses > 1)
				BT.remaining = spell_holder
				spell_holder.forceMove(BT)

	for(var/slot in slots_to_store)
		var/obj/item/user_slot = target.get_item_by_slot(slot)
		if (user_slot)
			BT.stored_gear |= "[slot]"
			BT.stored_gear["[slot]"] = user_slot

	//looping again in case the suit had a stored item
	for(var/slot in BT.stored_gear)
		var/obj/item/user_slot = BT.stored_gear[slot]
		BT.stored_gear["[slot]"] = user_slot
		target.dropItemToGround(user_slot)
		user_slot.forceMove(BT)

		target.equip_to_slot_or_del(new /obj/item/clothing/under/color/black, ITEM_SLOT_ICLOTHING)
		target.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(target), ITEM_SLOT_OCLOTHING)
		target.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult/alt(target), ITEM_SLOT_FEET)
		target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black/cult(target), ITEM_SLOT_GLOVES)

	//transferring backpack items
	var/obj/item/storage/backpack/cultpack/new_pack = new (target)
	if ((ITEM_SLOT_BACK in BT.stored_gear))
		var/obj/item/stored_slot = BT.stored_gear[ITEM_SLOT_BACK]
		if (istype (stored_slot, /obj/item/storage/backpack))
			for(var/obj/item/I in stored_slot.contents)
				I.forceMove(new_pack)
	target.equip_to_slot_if_possible(new_pack, ITEM_SLOT_BACK)

	activator.put_in_hands(BT)
	target.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(target))
	if(IS_CULTIST(target))
		to_chat(target, span_notice("Robes and gear of the followers of Nar-Sie manifests around your body. You feel empowered.") )
	else
		to_chat(target, span_warning("Robes and gear of the followers of Nar-Sie manifests around your body. You feel sickened.") )
	to_chat(activator, span_notice("A [BT] materializes in your hand, you may use it to instantly swap back into your stored clothing.") )
	qdel(src)
