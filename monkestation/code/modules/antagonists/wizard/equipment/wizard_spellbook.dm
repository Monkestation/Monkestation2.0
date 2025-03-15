/obj/item/spellbook
	var/gauntlet_flag = FALSE

/obj/item/spellbook/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/badmin_gauntlet))
		var/obj/item/badmin_gauntlet/badmingauntlet = O
		if(badmingauntlet.locked_on)
			to_chat(user, span_notice("You've put the gauntlet on already. No turning back now."))
			return
		to_chat(user, span_notice("On second thought, wiping out half the universe is possibly a bad idea. You refund your points."))
		uses += 10
		for(var/datum/spellbook_entry/item/badmin_gauntlet/badmin_gauntlet_entry in entries)
			if(!isnull(badmin_gauntlet_entry.limit))
				badmin_gauntlet_entry.limit++
		qdel(O)
		return
	return ..()

/obj/item/spellbook/proc/adjust_charge(adjust_by)
	log_spellbook("[src] charges adjusted by [adjust_by]. [usr ? "user: [usr]." : ""]")
	uses += adjust_by
	return TRUE
