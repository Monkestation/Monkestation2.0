
/datum/rune_spell/paraphernalia
	name = "Paraphernalia"
	desc = "Produce various apparatus such as talismans."
	desc_talisman = "LIKE, HOW, NO SERIOUSLY CALL AN ADMIN."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_invoke = 2
	cost_upkeep = 1
	remaining_cost = 5
	talisman_absorb = RUNE_CANNOT
	var/obj/item/tome/target = null
	var/obj/item/talisman/tool = null
	page = "This rune lets you conjure occult items carefully crafted in the realm of Nar-Sie, such as the tome you are currently holding, or talismans that let you carry a rune's power in your pocket.\
		<br><br>Each conjured item takes a small drop of your blood so be sure to manage yourself.\
		<br><br>Once you've imbued a rune into a talisman, you can then place the talisman back on top of this rune and activate it again to send it to one of your fellow cultist's arcane tome should they carry one.\
		<br><br>This rune persists upon use, allowing repeated usage."


/datum/rune_spell/paraphernalia/cast()
	var/obj/effect/new_rune/R = spell_holder
	var/obj/item/talisman/AT = locate() in get_turf(spell_holder)
	if (AT)
		if (AT.spell_type)
			var/mob/living/user = activator
			var/list/valid_tomes = list()
			var/i = 0
			for (var/obj/item/tome/T in GLOB.arcane_tomes)
				var/mob/M = locate(/mob/living) in T.contents
				if (M && IS_CULTIST(M))
					i++
					valid_tomes["[i] - Tome carried by [M.real_name] ([T.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = T

			for (var/datum/action/cooldown/spell/cult/arcane_dimension/A in GLOB.arcane_pockets)
				if (A.owner && A.owner.loc && ismob(A.owner) && A.stored_tome)
					i++
					var/mob/M = A.owner
					valid_tomes["[i] - Tome in [M.real_name]'s arcane dimension ([A.stored_tome.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = A.stored_tome

			if (valid_tomes.len <= 0)
				to_chat(user, span_warning("No cultists are currently carrying a tome.") )
				qdel(src)
				return

			var/datum/rune_spell/spell = AT.spell_type
			var/chosen_tome = input(user, "Choose a tome where to transfer this [initial(spell.name)] talisman.", "Transfer talisman", null) as null|anything in valid_tomes
			if (!chosen_tome)
				qdel(src)
				return

			target = valid_tomes[chosen_tome]
			tool = AT

			if (target.talismans.len >= MAX_TALISMAN_PER_TOME)
				to_chat(activator, span_warning("This tome cannot contain any more talismans.") )
				abort(RITUALABORT_FULL)
				return

			R.one_pulse()
			contributors.Add(user)
			update_progbar()
			if (user.client)
				user.client.images |= progbar
			spell_holder.overlays += image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
			spawn()
				payment()
		else
			to_chat(activator, span_warning("You may only transfer an imbued or attuned talisman.") )
			qdel(src)
	else
		var/list/choices = list(
			list("Talisman", "radial_paraphernalia_talisman", "Can absorb runes (or attune to them in some cases), allowing you to carry their power in your pocket. Has a few other miscellaneous uses."),
			list("Blood Candle", "radial_paraphernalia_candle", "A candle that can burn up to a full hour. Offers moody lighting."),
			list("Tempting Goblet", "radial_paraphernalia_goblet", "A classy holder for your beverage of choice. Prank your enemies by hitting them with a goblet full of blood."),
			list("Ritual Knife", "radial_paraphernalia_knife", "A long time ago a wizard enchanted one of those to infiltrate the realm of Nar-Sie and steal some soul stone shards. Now it's just a cool knife. Don't rely on it in a fight though."),
			list("Arcane Tome", "radial_paraphernalia_tome", "Bring forth an arcane tome filled with Nar-Sie's knowledge. Contains a wealth of information regarding each runes, along with many other aspects of the cult."),
			)
		var/list/made_choices = list()
		for(var/list/choice in choices)
			var/datum/radial_menu_choice/option = new
			option.image = image(icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi', icon_state = choice[2])
			option.info = span_boldnotice(choice[3])
			made_choices[choice[1]] = option
		var/task = show_radial_menu(activator, get_turf(spell_holder), made_choices, tooltips = TRUE, radial_icon = 'monkestation/code/modules/bloody_cult/icons/cult_radial3.dmi')
		if (!spell_holder.Adjacent(activator) || !task || QDELETED(src))
			qdel(src)
			return
		if (pay_blood())
			R.one_pulse()
			var/datum/antagonist/cult/cult_datum = activator.mind.has_antag_datum(/datum/antagonist/cult)
			cult_datum.gain_devotion(10, DEVOTION_TIER_0, "conjure_paraphernalia", task)
			var/obj/spawned_object
			var/turf/T = get_turf(spell_holder)
			switch (task)
				if ("Talisman")
					spawned_object = new /obj/item/talisman(T)
				if ("Blood Candle")
					spawned_object = new /obj/item/candle/blood(T)
				if ("Tempting Goblet")
					spawned_object = new /obj/item/reagent_containers/cup/cult(T)
				if ("Ritual Knife")
					spawned_object = new /obj/item/knife/ritual(T)
				if ("Arcane Tome")
					spawned_object = new /obj/item/tome(T)
			spell_holder.visible_message(span_rose("The blood drops merge into the rune, and \a [spawned_object] materializes on top.") )
			anim(target = spawned_object, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_imbue")
			new /obj/effect/afterimage/black(T, spawned_object)
			qdel(src)


/datum/rune_spell/paraphernalia/midcast(mob/add_cultist) // failsafe should someone be hogging the radial menu.
	var/obj/effect/new_rune/R = spell_holder
	R.active_spell = null
	R.trigger(add_cultist)
	qdel(src)

/datum/rune_spell/paraphernalia/abort(cause)
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")
	..()


/datum/rune_spell/paraphernalia/cast_talisman()//there should be no ways for this to ever proc
	return


/datum/rune_spell/paraphernalia/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++

		if (tool && tool.loc != spell_holder.loc)
			abort(RITUALABORT_TOOLS)

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
				make_tracker_effects(L.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

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

/datum/rune_spell/paraphernalia/proc/success()
	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)
	if (progbar)
		progbar.loc = null
	spell_holder.overlays -= image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "runetrigger-build")

	if (target.talismans.len < MAX_TALISMAN_PER_TOME)
		target.talismans.Add(tool)
		tool.forceMove(target)
		to_chat(activator, span_notice("You slip \the [tool] into \the [target].") )
		if (target.state == TOME_OPEN && ismob(target.loc))
			var/mob/M = target.loc
			M << browse(target.tome_text(), "window = arcanetome;size = 537x375")
	else
		to_chat(activator, span_warning("This tome cannot contain any more talismans.") )
	qdel(src)
