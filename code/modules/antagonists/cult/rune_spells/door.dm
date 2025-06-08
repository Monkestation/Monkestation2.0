
/datum/rune_spell/door
	name = "Door"
	desc = "Raise a door to impede your enemies. It automatically opens and closes behind you, but the others may eventually break it down."
	desc_talisman = "Use to remotely trigger the rune and have it spawn a door to block your enemies."
	invocation = "Khari'd! Eske'te tannin!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "This rune spawns a Cult Door immediately upon use, for a cost of 10u of blood.\
		<br><br>This rune cannot be activated if there's another cult door currently adjacent to it.\
		<br><br>Cult doors can be broken down relatively quickly with weapons, but let cultist move through them with barely any slowdown, making them great to retreat. Spawning them in maintenance will exasperate the crew.\
		<br><br>Lastly, the rune can be attuned to a talisman to be remotely activated. Allowing for interesting traps if the rune was concealed."
	cost_invoke = 10

/datum/rune_spell/door/cast()
	var/obj/effect/new_rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		if (locate(/obj/machinery/door/airlock/cult) in range(spell_holder, 1))
			abort(RITUALABORT_NEAR)
		else
			var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)
			var/obj/machinery/door/airlock/cult/new_door = new /obj/machinery/door/airlock/cult(get_turf(spell_holder))
			cult_datum.gain_devotion(10, DEVOTION_TIER_1, "summon_door", new_door)
			qdel(spell_holder)
	qdel(src)
