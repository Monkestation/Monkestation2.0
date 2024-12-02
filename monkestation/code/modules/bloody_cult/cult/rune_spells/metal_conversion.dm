/datum/rune_spell/metal_conversion
	name = "Metal Conversion"
	desc = "Converts all Iron on the ritual area into runed metal."
	invocation = "Khari'd! Eske'te Sum!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/technology
	talisman_absorb = RUNE_CANNOT
	page = "This rune converts all iron on top of it into iron."
	cost_invoke = 10

/datum/rune_spell/metal_conversion/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		var/turf/host_turf = get_turf(spell_holder)
		for(var/obj/item/stack/sheet/iron/iron_stack as anything in host_turf.contents)
			if(!istype(iron_stack, /obj/item/stack/sheet/iron))
				continue
			var/obj/item/stack/sheet/runed_metal/converted = new (host_turf)
			converted.amount = iron_stack.amount
			qdel(iron_stack)
		qdel(spell_holder)
	qdel(src)
