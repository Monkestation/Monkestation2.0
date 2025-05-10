GLOBAL_LIST_INIT(bloodcult_exitportals, list())

/datum/rune_spell/portalexit
	name = "Path Exit"
	desc = "We hope you enjoyed your flight with Air Nar-Sie."//might change it later or not.
	desc_talisman = "Use to immediately jaunt through the Path."
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_IMBUE
	can_conceal = 1
	page = "This rune lets you set free teleports between any two tiles in the worlds, when used in combination with the Path Entrance rune. \
		Upon its first use, the rune asks you to set a path for it to attune to. There are 10 possible paths, each corresponding to a cult word.\
		<br><br>Unlike for entrances, there may only exist 1 exit for each path.\
		<br><br>By using a talisman on an attuned rune, the talisman will teleport you to that rune immediately upon use.\
		<br><br>By using a talisman on a non-attuned rune, the rune will be absorbed instead, and you'll be able to set a destination path on the talisman, allowing you to check which path exits currently exist.\
		<br><br>You can deactivate a Path Exit by simply using the Erase Word spell on it once, and rewrite Self afterwards.\
		<br><br>Lastly if an empty jaunt bubble pops over the rune with an ominous noise, that means a corresponding path entrance has been destroyed and the location of this rune might end up compromised."
	var/network = ""

/datum/rune_spell/portalexit/New()
	..()
	GLOB.bloodcult_exitportals.Add(src)

/datum/rune_spell/portalexit/Destroy()
	GLOB.bloodcult_exitportals.Remove(src)
	..()

/datum/rune_spell/portalexit/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = GLOB.rune_words_english.Copy()
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network)
			available_networks -= P.network

	if (available_networks.len <= 0)
		to_chat(activator, span_warning("There is no room for any more Paths through the veil.") )
		qdel(src)
		return

	network = input(activator, "Choose an available Path, you may free the path later by erasing the rune.", "Path Exit") as null|anything in available_networks
	if (!network)
		qdel(src)
		return

	var/datum/holomap_marker/marker = new(R)
	marker.id = HOLOMAP_MARKER_CULT_EXIT
	marker.filter = HOLOMAP_FILTER_CULT
	marker.x = R.x
	marker.y = R.y
	marker.z = R.z
	marker.icon = 'monkestation/code/modules/bloody_cult/icons/holomap_markers.dmi'
	marker.icon_state = "path_exit"


	var/datum/rune_word/W = GLOB.rune_words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "path_crystals")
	SET_PLANE_EXPLICIT(I_crystals, GAME_PLANE, spell_holder)
	var/image/I_stone = image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "path_stone")
	SET_PLANE_EXPLICIT(I_stone, GAME_PLANE, spell_holder)
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.english]-0-[COLOR_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in rune_appearances_cache)
		I_network = image(rune_appearances_cache[lookup])
	else
		I_network = image('monkestation/code/modules/bloody_cult/icons/deityrunes.dmi', src, W.english)
		I_network.color = COLOR_BLOOD
	SET_PLANE_EXPLICIT(I_network, GAME_PLANE, spell_holder)
	I_network.transform /= 1.5
	I_network.pixel_x = round(W.offset_x*0.75)
	I_network.pixel_y = -3 + round(W.offset_y*0.75)

	spell_holder.overlays.len = 0
	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network
	custom_rune = TRUE

	to_chat(activator, span_notice("This rune will now serve as a destination for the \"[network]\" Path.") )

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	cult_datum?.gain_devotion(30, DEVOTION_TIER_1, "new_path_exit", R)

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/portalexit/midcast(mob/add_cultist)
	to_chat(add_cultist, span_notice("You may teleport to this rune by using a Path Entrance, or a talisman attuned to it.") )

/datum/rune_spell/portalexit/midcast_talisman(var/mob/add_cultist)
	var/turf/T = get_turf(add_cultist)
	invoke(add_cultist, invocation, 1)
	anim(target = T, a_icon = 'monkestation/code/modules/bloody_cult/icons/effects.dmi', flick_anim = "rune_teleport")
	new /obj/effect/bloodcult_jaunt (T, add_cultist, get_turf(spell_holder))

/datum/rune_spell/portalexit/cast_talisman()
	var/obj/item/talisman/T = spell_holder
	T.uses++//so the talisman isn't deleted when setting the network
	var/list/valid_choices = list()
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network)
			valid_choices.Add(P.network)
			valid_choices[P.network] = P
	if (valid_choices.len <= 0)
		to_chat(activator, span_warning("There are currently no Paths through the veil.") )
		qdel(src)
		return
	var/network = input(activator, "Choose an available Path.", "Path Talisman") as null|anything in valid_choices
	if (!network)
		qdel(src)
		return

	invoke(activator, "[GLOB.rune_words_english[network]]!", 1)

	to_chat(activator, span_notice("This talisman will now serve as a key to the \"[network]\" Path.") )

	var/datum/rune_spell/portalexit/PE = valid_choices[network]

	T.attuned_rune = PE.spell_holder
	T.word_pulse(GLOB.rune_words[network])

/datum/rune_spell/portalexit/salt_act(var/turf/T)
	if (T != spell_holder.loc)
		var/turf/destination = null
		for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
			if (P.network == network)
				destination = get_turf(P.spell_holder)
			new /obj/effect/bloodcult_jaunt/traitor(T, null, destination, null)
			break
