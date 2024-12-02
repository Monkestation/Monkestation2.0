/obj/item/weapon/talisman
	name = "talisman"
	desc = "A tattered parchment. You feel a dark energy emanating from it."
	gender = NEUTER
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "talisman"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 1
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/linked_ui
	var/blood_text = ""
	var/obj/effect/new_rune/attuned_rune = null
	var/spell_type = null
	var/uses = 1

/obj/item/weapon/talisman/New()
	..()
	pixel_x = 0
	pixel_y = 0


/obj/item/weapon/talisman/salt_act()
	if (attuned_rune && attuned_rune.active_spell)
		attuned_rune.active_spell.salt_act(get_turf(src))
	fire_act(1000, 200)


/obj/item/weapon/talisman/proc/talisman_name()
	var/datum/rune_spell/instance = spell_type
	if (blood_text)
		return "\[blood message\]"
	if (instance)
		return initial(instance.name)
	else
		return "\[blank\]"

/obj/item/weapon/talisman/suicide_act(mob/living/user)
	to_chat(viewers(user), span_danger("[user] swallows \a [src] and appears to be choking on it! It looks like \he's trying to commit suicide.") )

/obj/item/weapon/talisman/examine(var/mob/user)
	..()
	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window = [name]")
		onclose(user, "[name]")
		return

	if (!spell_type)
		to_chat(user, span_info("This one, however, seems pretty unremarkable.") )
		return

	var/datum/rune_spell/instance = spell_type

	if (IS_CULTIST(user) || isobserver(user))
		if (attuned_rune)
			to_chat(user, span_info("This one was attuned to a <b>[initial(instance.name)]</b> rune. [initial(instance.desc_talisman)]") )
		else
			to_chat(user, span_info("This one was imbued with a <b>[initial(instance.name)]</b> rune. [initial(instance.desc_talisman)]") )
		if (uses > 1)
			to_chat(user, span_info("Its powers can be used [uses] more times.") )
	else
		to_chat(user, span_info("This one was some arcane drawings on it. You cannot read them.") )

/obj/item/weapon/talisman/attack_self(var/mob/living/user)
	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window = [name]")
		onclose(user, "[name]")
		onclose(user, "[name]")
		return

	if (IS_CULTIST(user))
		trigger(user)

/obj/item/weapon/talisman/attack(var/mob/living/target, var/mob/living/user)
	if(IS_CULTIST(user) && spell_type)
		var/datum/rune_spell/instance = spell_type
		if (initial(instance.touch_cast))
			new spell_type(user, src, "touch", target)
			qdel(src)
			return
	..()

/obj/item/weapon/talisman/proc/trigger(var/mob/user)
	if (!user)
		return

	if (blood_text)
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY text = #612014>[blood_text]</BODY></HTML>", "window = [name]")
		onclose(user, "[name]")
		return

	if (!spell_type)
		if (!(src in user.held_items))//triggering an empty rune from a tome removes it.
			if (istype(loc, /obj/item/weapon/tome))
				var/obj/item/weapon/tome/T = loc
				T.talismans.Remove(src)
				user << browse(T.tome_text(), "window = arcanetome;size = 900x600")
				user.put_in_hands(src)
		return

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if (C.occult_muted())
			to_chat(user, span_danger("You find yourself unable to focus your mind on the arcane words of the talisman.") )
			return

	if (attuned_rune)
		if (attuned_rune.loc)
			attuned_rune.trigger(user, 1)
		else//darn, the rune got destroyed one way or another
			attuned_rune = null
			to_chat(user, span_warning("The talisman disappears into dust. The rune it was attuned to appears to no longer exist.") )
	else
		new spell_type(user, src)

	uses--
	if (uses > 0)
		return

	if (istype(loc, /obj/item/weapon/tome))
		var/obj/item/weapon/tome/T = loc
		T.talismans.Remove(src)
	if (linked_ui)
		linked_ui.talisman = null
	qdel(src)

/obj/item/weapon/talisman/proc/imbue(var/mob/user, var/obj/effect/new_rune/R)
	if (!user || !R)
		return

	if (blood_text)
		to_chat(user, span_warning("You can't imbue a talisman that has been written on.") )
		return

	var/datum/rune_spell/spell = get_rune_spell(user, null, "examine", R.word1, R.word2, R.word3)
	if(initial(spell.talisman_absorb) == RUNE_CANNOT)//placing a talisman on a Conjure Talisman rune to try and fax it
		user.dropItemToGround(src)
		src.forceMove(get_turf(R))
		R.attack_hand(user)
	else
		if (attuned_rune)
			to_chat(user, span_warning("\The [src] is already imbued with the power of a rune.") )
			return

		if (!spell)
			to_chat(user, span_warning("There is no power in those runes. \The [src] isn't reacting to it.") )
			return

		//blood markings
		overlays += image(icon, "talisman-[R.word1.icon_state]a")
		overlays += image(icon, "talisman-[R.word2.icon_state]a")
		overlays += image(icon, "talisman-[R.word3.icon_state]a")
		//black markings
		overlays += image(icon, "talisman-[R.word1.icon_state]")
		overlays += image(icon, "talisman-[R.word2.icon_state]")
		overlays += image(icon, "talisman-[R.word3.icon_state]")

		spell_type = spell
		uses = initial(spell.talisman_uses)

		var/talisman_interaction = initial(spell.talisman_absorb)
		var/datum/rune_spell/active_spell = R.active_spell
		if(!istype(R))
			return
		if (active_spell)//some runes may change their interaction type dynamically (ie: Path Exit runes)
			talisman_interaction = active_spell.talisman_absorb
			if (istype(active_spell, /datum/rune_spell/portalentrance))
				var/datum/rune_spell/portalentrance/entrance = active_spell
				if (entrance.network)
					word_pulse(GLOB.rune_words[entrance.network])
			else if (istype(active_spell, /datum/rune_spell/portalexit))
				var/datum/rune_spell/portalentrance/exit = active_spell
				if (exit.network)
					word_pulse(GLOB.rune_words[exit.network])

		switch(talisman_interaction)
			if (RUNE_CAN_ATTUNE)
				playsound(src, 'monkestation/code/modules/bloody_cult/sound/talisman_attune.ogg', 50, 0, -5)
				to_chat(user, span_notice("\The [src] can now remotely trigger the [initial(spell.name)] rune.") )
				attuned_rune = R
			if (RUNE_CAN_IMBUE)
				playsound(src, 'monkestation/code/modules/bloody_cult/sound/talisman_imbue.ogg', 50, 0, -5)
				to_chat(user, span_notice("\The [src] absorbs the power of the [initial(spell.name)] rune.") )
				qdel(R)
			if (RUNE_CANNOT)//like, that shouldn't even be possible because of the earlier if() check, but just in case.
				message_admins("Error! ([key_name(user)]) managed to imbue a Conjure Talisman rune. That shouldn't be possible!")
				return

/obj/item/weapon/talisman/proc/word_pulse(var/datum/rune_word/W)
	var/image/I1 = image(icon, "talisman-[W.icon_state]a")
	animate(I1, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5, loop = -1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	overlays += I1
	var/image/I2 = image(icon, "talisman-[W.icon_state]")
	animate(I2, color = list(2, 0.67, 0.27, 0, 0.27, 2, 0.67, 0, 0.67, 0.27, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 5, loop = -1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.625, 0.35, 0.06, 0, 0.06, 1.625, 0.35, 0, 0.35, 0.06, 1.625, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.75, 0.45, 0.12, 0, 0.12, 1.75, 0.45, 0, 0.45, 0.12, 1.75, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	animate(color = list(1.875, 0.56, 0.19, 0, 0.19, 1.875, 0.56, 0, 0.56, 0.19, 1.875, 0, 0, 0, 0, 1, 0, 0, 0, 0), time = 1)
	overlays += I2
