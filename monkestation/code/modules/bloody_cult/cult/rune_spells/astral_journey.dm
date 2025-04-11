
/datum/rune_spell/astraljourney
	name = "Astral Journey"
	desc = "Channel a fragment of your soul into an astral projection so you can spy on the crew and communicate your findings with the rest of the cult."
	desc_talisman = "Leave your body so you can go spy on your enemies."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	page = "Upon use, your soul will float above your body, allowing you to freely move invisibly around the Z-Level. Words you speak while in this state will be heard by everyone in the cult. You can also become tangible which lets you converse with people, but taking any damage while in this state will end the ritual. Your body being moved away from the rune will also end the ritual.\
		<br><br>Should your body die while you were still using the rune, a shade will form wherever your astral projection stands.\
		<br><br>This rune persists upon use, allowing repeated usage."
	rune_flags = RUNE_STAND
	var/mob/living/basic/astral_projection/astral = null
	var/cultist_key = ""
	var/list/restricted_verbs = list()

/datum/rune_spell/astraljourney/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	cultist_key = activator.key

	to_chat(activator, span_notice("As you recite the invocation, you feel your consciousness rise up in the air above your body.") )
	//astral = activator.ghostize(1, 1)
	astral = new(activator.loc)
	astral.ascend(activator)
	activator.ajourn = src

	step(astral, NORTH)
	astral.dir = SOUTH

	spawn()
		handle_astral()

/datum/rune_spell/astraljourney/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)


/datum/rune_spell/astraljourney/abort(var/cause)
	qdel(astral)
	..()

/datum/rune_spell/astraljourney/proc/handle_astral()
	while(!destroying_self && activator && activator.stat != DEAD && astral && astral.loc && activator.loc == spell_holder.loc)
		sleep(10)
	abort()

/datum/rune_spell/astraljourney/Removed(var/mob/M)
	if (M == activator)
		abort(RITUALABORT_GONE)
