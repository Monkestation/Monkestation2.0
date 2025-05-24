/mob/living/carbon/human/death(gibbed, cause_of_death)
	. = ..()
	if(!client || !IS_CULTIST(src))
		return
	var/mob/living/basic/shade/shade = new (get_turf(src))
	shade.name = "[real_name] the Shade"
	shade.real_name = "[real_name]"
	mind.transfer_to(shade)

	to_chat(shade, span_cult("Dark energies rip your dying body appart, anchoring your soul inside the form of a Shade. You retain your memories, and devotion to the cult."))
	shade.body = src
	src.forceMove(shade)

/datum/rune_spell/reincarnation
	name = "Reincarnation"
	desc = "Provide shades with a replica of their original body."
	desc_talisman = "Provide shades with a replica of their original body."
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/hell
	page = "This rune lets you provide a shade with a body replicated from the one they originally had (or at least the one their soul remembers them having)\
		<br><br>The shade must stand above the rune for the ritual to begin. However mind that this rune has a very steep cost in blood of 300u that have to be paid over 60 seconds of channeling. \
		Other cultists can join in the ritual to help you share the burden you might prefer having a construct use their connection to the other side to bypass the blood cost entirely.\
		<br><br>Note that the resulting body might look much paler than the original, this is an unfortunate side-effect that you may have to resolve on your own.\
		<br><br>This rune persists upon use, allowing repeated usage."
	cost_upkeep = 5
	remaining_cost = 300
	var/obj/effect/cult_ritual/resurrect/husk = null
	var/mob/living/basic/shade/shade = null

/datum/rune_spell/reincarnation/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	shade = locate(/mob/living/basic/shade) in R.loc
	if (!shade)
		to_chat(activator, span_warning("There needs to be a shade standing above the rune.") )
		qdel(src)
		return

	husk = new (R.loc)
	flick("rune_resurrect_start", husk)
	shade.forceMove(husk)

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build")
	to_chat(activator, span_rose("This ritual has a very high blood cost per second, but it can be completed faster by having multiple cultists partake in it.") )
	spawn()
		payment()

/datum/rune_spell/reincarnation/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)

/datum/rune_spell/reincarnation/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/reincarnation/abort(cause)
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build")
	if (shade)
		shade.forceMove(get_turf(husk))
	if (husk)
		qdel(husk)
	if (spell_holder.loc && (!cause || cause != RITUALABORT_MISSING))
		new /obj/effect/gibspawner/human(spell_holder.loc)
	..()

/datum/rune_spell/reincarnation/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		for(var/mob/living/L in contributors)
			if (!IS_CULTIST(L) || !(L in range(spell_holder, 1)) || (L.stat != CONSCIOUS))
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep, contributors[L])
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc, spell_holder, 1, "soul2", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				abort(RITUALABORT_BLOOD)
				return

		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/reincarnation/proc/success()
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "build")
	var/resurrector = activator.real_name
	if (shade && husk)
		shade.forceMove(get_turf(husk))
		var/mob/living/carbon/human/M
		if(shade.body)
			shade.mind.transfer_to(shade.body)
			shade.body?.forceMove(shade.loc)
			shade.body?.fully_heal()
			shade.body?.revive()
			M = shade.body
		else
			M = new(get_turf(shade))
			shade.client?.prefs.apply_prefs_to(M)
			shade.mind.transfer_to(M)

		if(HAS_TRAIT(shade.body, TRAIT_USES_SKINTONES)) // make them deathly white, afterall they dont have a soul anymore
			shade.body.skin_tone = "albino"
		else
			var/datum/color_palette/generic_colors/located = shade.body.dna.color_palettes[/datum/color_palette/generic_colors]
			located.mutant_color = "#FFFFFF"
		shade.body = null
		qdel(husk)
		qdel(shade)
		playsound(M, 'monkestation/code/modules/bloody_cult/sound/spawn.ogg', 50, 0, 0)
		var/datum/antagonist/cult/newCultist = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (!newCultist)
			newCultist = new(M?.mind)
			var/datum/team/cult/cult = locate_team(/datum/team/cult)
			cult.HandleRecruitedRole(newCultist)
			newCultist.conversion["resurrected"] = resurrector

		/*
		if (ishuman(M))
			// purely cosmetic tattoos. giving cultists some way to have tattoos until those get reworked
			newCultist.tattoos[TATTOO_POOL] = new /datum/cult_tattoo/bloodpool()
			newCultist.tattoos[TATTOO_HOLY] = new /datum/cult_tattoo/holy()
			newCultist.tattoos[TATTOO_MANIFEST] = new /datum/cult_tattoo/manifest()
		*/

		M.regenerate_icons()
		M.update_body(is_creating = TRUE)
		newCultist.update_cult_hud()

		for(var/mob/living/L in contributors)
			var/datum/antagonist/cult/cult_datum = L.mind.has_antag_datum(/datum/antagonist/cult)
			cult_datum.gain_devotion(200, DEVOTION_TIER_3, "reincarnation", M)

	else
		for(var/mob/living/L in contributors)
			to_chat(L, span_warning("Something went wrong with the ritual, the shade appears to have vanished.") )


	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/obj/effect/cult_ritual/resurrect
	anchored = 1
	icon_state = "rune_resurrect"
	plane = ABOVE_GAME_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/resurrect/New(turf/loc)
	..()
	overlays += "summoning"
