/datum/rune_spell/raisestructure
	name = "Raise Structure"
	desc = "Drag-in eldritch structures from the realm of Nar-Sie."
	desc_talisman = "Use to begin raising a structure where you stand."
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_upkeep = 1
	remaining_cost = 300
	accumulated_blood = 0
	page = "Channel this rune to create either an Altar, a Forge, or a Spire. You can speed up the ritual by having other cultist touch the rune, or by wearing cult garments. \
		<br><br>Altars let you commune with Nar-Sie, conjure soul gems, and keep tabs on the cult's members and activities over the station.\
		<br><br>Forges let you craft armors, powerful blades, as well as construct shells. Blades and shells can be combined with soul gems to great effect, \
		but note that Forges tend to sear those who stay near them too long. You can mitigate the effect with cult apparel, or use the Fervor rune to reset your temperature.\
		<br><br>Spires provide easy communication for the cult in the entire region. Use :x (or .x, or #x) to use cult chat after one is built."
	var/turf/loc_memory = null
	var/spawntype = /obj/structure/cult/altar
	var/structure

/datum/rune_spell/raisestructure/proc/proximity_check()
	var/obj/effect/new_rune/R = spell_holder
	if (locate(/obj/structure/cult) in range(R.loc, 0))
		abort(RITUALABORT_BLOCKED)
		return FALSE

	if (locate(/obj/machinery/door/airlock/cult) in range(R.loc, 1))
		abort(RITUALABORT_NEAR)
		return FALSE

	else return TRUE

/datum/rune_spell/raisestructure/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/mob/living/user = activator

	proximity_check() //See above

	var/list/choices = list(
		list("Altar", "radial_altar", "The nexus of a cult base. Lets you commune with Nar-Sie, conjure soul gems, and keep tabs on the cult's members and activities over the station."),
		list("Spire", "radial_spire", "Allows all cultists in the level to communicate with each others using :x"),
		list("Forge", "radial_forge", "Can be used to forge of cult blades and armor, as well as construct shells. Standing close for too long without proper cult attire can be a searing experience."),
		list("Pylon", "radial_pylon", "Provides some light in the surrounding area.")
	)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	structure = show_radial_menu(user, R.loc, made_choices ,tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')

	if(!R.Adjacent(user) || !structure )
		abort()
		return

	if(R.active_spell)
		to_chat(user, span_rose("A structure is already being raised from this rune, so you contribute to that instead.") )
		R.active_spell.midcast(user)
		return

	switch(structure)
		if("Altar")
			spawntype = /obj/structure/cult/altar
		if("Spire")
			spawntype = /obj/structure/cult/spire
		if("Forge")
			spawntype = /obj/structure/cult/forge
		if("Pylon")
			spawntype = /obj/structure/cult/pylon

	if(!spell_holder)
		return
	loc_memory = spell_holder.loc
	contributors.Add(user)
	update_progbar()
	if(user.client)
		user.client.images |= progbar
	spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	to_chat(activator, span_rose("This ritual can be sped up by having multiple cultists partake in it or by wearing cult attire.") )
	spawn()
		payment()

/datum/rune_spell/raisestructure/cast_talisman() //Raise structure talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)

/datum/rune_spell/raisestructure/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/raisestructure/abort(cause)
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	..()

/datum/rune_spell/raisestructure/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		var/summoners = 2//the higher, the easier it is to perform the ritual without many cultists. default = 2
		for(var/mob/living/L in contributors)
			if (IS_CULTIST(L) && (L in range(spell_holder, 1)) && (L.stat == CONSCIOUS))
				summoners++
				summoners += round(L.get_cult_power()/30)	//For every 30 cult power, you count as one additional cultist. So with Robes and Shoes, you already count as 3 cultists.
			else											//This makes using the rune alone hard at roundstart, but fairly easy later on.
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep, contributors[L])
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		if(amount_paid) //3 seconds without blood and the ritual fails.
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in loc_memory))
					var/obj/effect/decal/cleanable/blood/splatter/S = new (loc_memory)//splash
					S.count = 2
				abort(RITUALABORT_BLOOD)
				return

		switch(summoners)
			if (1)
				remaining_cost = 300
			if (2)
				remaining_cost = 120
			if (3)
				remaining_cost = 18
			if (4 to INFINITY)
				remaining_cost = 0

		if(accumulated_blood >= remaining_cost )
			proximity_check()
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/raisestructure/proc/success()
	for(var/mob/living/L in contributors)
		var/datum/antagonist/cult/cult_datum = L.mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", structure)
	new spawntype(spell_holder.loc)
	qdel(spell_holder) //Deletes the datum as well.
