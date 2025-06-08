
/datum/hover_data/convertability_data/setup_data(mob/living/carbon/source, mob/enterer)
	. = ..()
	if(IS_CULTIST(source))
		return

	var/image/new_image = new(source)
	new_image.appearance = source.update_convertibility()
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)

/mob/living/carbon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/hovering_information, /datum/hover_data/convertability_data, TRAIT_SEER)

/datum/rune_spell/seer
	name = "Seer"
	desc = "See the invisible, the dead, the concealed, and the propensity of the living to serve our agenda."
	desc_talisman = "For a whole minute, you may see the invisible, the dead, the concealed, and the propensity of the living to serve our agenda."
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."
	rune_flags = RUNE_STAND
	talisman_uses = 10
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/hell
	word3 = /datum/rune_word/join
	page = "This rune grants the ability to see invisible ghosts, runes, and structures, but most of all, it also reveals the willingness of crew members to accept conversion, indicated by marks over their heads:\
		<br><br><b>Green marks</b> indicate people who will always accept conversion.\
		<br><br><b>Yellow marks</b> indicate people who might either accept or refuse.\
		<br><br><b>Red marks with two spikes</b> indicate loyalty implanted crew members, who will thus automatically refuse conversion regardless of their will.\
		<br><br><b>Red marks with three spikes</b> indicate crew members who have pledged themselves to fight the cult, and while they might not automatically refuse conversion, are very unlikely to be develop into useful cultists.\
		<br><br>Also note that you can activate runes while they are concealed. In talisman form, it has 10 uses that last for a minute each. Activate the talisman before moving into a public area so nobody hears you whisper the invocation.\
		<br><br>This rune persists upon use, allowing repeated usage."
	cost_invoke = 5
	var/obj/effect/cult_ritual/seer/seer_ritual = null
	var/talisman_duration = 60 SECONDS

/datum/rune_spell/seer/Destroy()
	destroying_self = 1
	if (seer_ritual && !seer_ritual.talisman)
		qdel(seer_ritual)
	seer_ritual = null
	..()

/datum/rune_spell/seer/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		seer_ritual = new /obj/effect/cult_ritual/seer(R.loc, activator, src)
	else
		qdel(src)

/datum/rune_spell/seer/cast_talisman()
	var/mob/living/M = activator

	if (locate(/obj/effect/cult_ritual/seer) in M)
		var/obj/item/talisman/T = spell_holder
		T.uses++
		to_chat(M, span_warning("You are still under the effects of a Seer talisman.") )
		qdel(src)
		return

	M.see_invisible = SEE_INVISIBLE_OBSERVER
	anim(target = M, a_icon = 'monkestation/code/modules/bloody_cult/icons/160x160.dmi', a_icon_state = "rune_seer", lay = ABOVE_OBJ_LAYER, offX = -32*2, offY = -32*2, plane = GAME_PLANE, invis = INVISIBILITY_OBSERVER, alph = 200, sleeptime = talisman_duration, animate_movement = TRUE)
	new /obj/effect/cult_ritual/seer(activator, activator, null, TRUE, talisman_duration)
	qdel(src)

GLOBAL_LIST_EMPTY(seer_rituals)

/obj/effect/cult_ritual/seer
	anchored = 1
	icon = 'monkestation/code/modules/bloody_cult/icons/160x160.dmi'
	icon_state = "rune_seer"
	pixel_x = -32*2
	pixel_y = -32*2
	alpha = 200
	invisibility = INVISIBILITY_OBSERVER
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	mouse_opacity = 0
	var/mob/living/caster = null
	var/datum/rune_spell/seer/source = null
	var/list/propension = list()
	var/talisman = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/effect/cult_ritual/seer/New(turf/loc, mob/living/user, datum/rune_spell/seer/runespell, talisman_ritual = FALSE, talisman_duration = 60 SECONDS)
	..()
	proximity_monitor = new(src, 1)
	if(user)
		ADD_TRAIT(user, TRAIT_SEER, REF(src))
	LAZYADD(GLOB.seer_rituals, src)
	talisman = talisman_ritual
	caster = user
	caster.see_invisible = SEE_INVISIBLE_OBSERVER
	source = runespell
	if (!caster)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
		return
	to_chat(caster, span_notice("You find yourself able to see through the gaps in the veil. You can see and interact with the other side, and also find out the crew's propensity to be successfully converted, whether they are <b><font color = 'green'>Willing</font></b>, <b><font color = 'orange'>Uncertain</font></b>, or <b><font color = 'red'>Unconvertible</font></b>.") )
	if (talisman)
		spawn(talisman_duration)
			qdel(src)


/obj/effect/cult_ritual/seer/Destroy()
	LAZYREMOVE(GLOB.seer_rituals, src)
	if(caster)
		REMOVE_TRAIT(caster, TRAIT_SEER, REF(src))
		to_chat(caster, span_notice("You can no longer discern through the veil."))
		caster.see_invisible = SEE_INVISIBLE_LIVING
	caster = null
	if (source)
		source.abort()
	source = null
	..()

/obj/effect/cult_ritual/seer/HasProximity(atom/movable/AM)
	if (!talisman)
		if (!caster || caster.loc != loc)
			qdel(src)
