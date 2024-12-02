// Tattoos are currently unobtainable and being reworked. Blood Daggers and Cult Chat will be available to cultists in other ways until then.

/datum/cult_tattoo
	var/name = "cult tattoo"
	var/desc = ""
	var/tier = 0//1, 2 or 3
	var/icon_state = ""
	var/mob/bearer = null
	var/blood_cost = 0

/datum/cult_tattoo/proc/getTattoo(var/mob/M)
	bearer = M

/datum/cult_tattoo/proc/Display()
	return TRUE

/mob/proc/checkTattoo(var/tattoo_name)
	if (!tattoo_name)
		return
	if (!IS_CULTIST(src))
		return
	var/datum/antagonist/cult/cult_datum = mind?.has_antag_datum(/datum/antagonist/cult)
	for (var/tattoo in cult_datum.tattoos)
		var/datum/cult_tattoo/CT = cult_datum.tattoos[tattoo]
		if (CT.name == tattoo_name)
			return CT
	return null

///////////////////////////
//                       //
//        TIER 1         //
//                       //
///////////////////////////

/datum/cult_tattoo/bloodpool
	name = TATTOO_POOL
	desc = "All blood costs reduced by 20%. Tributes are split with other bearers of this mark."
	icon_state = "bloodpool"
	tier = 1

/datum/cult_tattoo/bloodpool/getTattoo(var/mob/M)
	..()
	var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		GLOB.blood_communion.Add(cult_datum)
		cult_datum.blood_pool = TRUE

/datum/cult_tattoo/bloodpool/Display()//Since that tattoo is now unlocked fairly early, better let cultists hide it easily by leaving the pool
	var/datum/antagonist/cult/cult_datum = bearer.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		return cult_datum.blood_pool

/datum/cult_tattoo/silent
	name = TATTOO_SILENT
	desc = "Cast runes and talismans without having to mouth the invocation."
	icon_state = "silent"
	tier = 1

/datum/cult_tattoo/dagger
	name = TATTOO_DAGGER
	desc = "Materialize a sharp dagger in your hand for a small cost in blood. Use to retrieve."
	icon_state = "dagger"
	tier = 1

///////////////////////////
//                       //
//        TIER 2         //
//                       //
///////////////////////////

/datum/cult_tattoo/holy // doesn't actually do anything right now beside give you a cool tattoo
	name = TATTOO_HOLY
	desc = "Holy water will now only slow you down a bit, and no longer prevent you from casting."
	icon_state = "holy"
	tier = 2

/datum/cult_tattoo/memorize
	name = TATTOO_MEMORIZE//Arcane Dimension
	desc = "Allows you to hide a tome into thin air, and pull it out whenever you want."
	icon_state = "memorize"
	tier = 2

/datum/cult_tattoo/memorize/getTattoo(mob/M)
	..()
	if (IS_CULTIST(M))
		var/datum/action/cooldown/spell/cult/arcane_dimension/new_spell = new
		new_spell.Grant(M)


/datum/cult_tattoo/rune_store
	name = TATTOO_RUNESTORE
	desc = "Allows you to trace a rune onto your skin and activate it at will."
	icon_state = "rune"
	tier = 2


///////////////////////////
//                       //
//        TIER 3         //
//                       //
///////////////////////////

/datum/cult_tattoo/manifest
	name = TATTOO_MANIFEST
	desc = "Acquire a new, fully healed body that cannot feel pain."
	icon_state = "manifest"
	tier = 3


/datum/cult_tattoo/manifest/getTattoo(var/mob/M)
	..()
	var/mob/living/carbon/human/H = bearer
	if (!istype(H))
		return
	H.revive(0)
	H.status_flags &= ~GODMODE
	H.status_flags &= ~CANSTUN
	H.status_flags &= ~CANKNOCKDOWN
	H.regenerate_icons()

/datum/cult_tattoo/shortcut
	name = TATTOO_SHORTCUT
	desc = "Place sigils on walls that allows cultists to jump right through."
	icon_state = "shortcut"
	tier = 3
	blood_cost = 5

/turf/closed/wall/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(IS_CULTIST(user) && !(locate(/obj/effect/cult_shortcut) in src))
		var/datum/cult_tattoo/CT = user.checkTattoo(TATTOO_SHORTCUT)
		if(!CT)
			return
		var/mob/living/carbon/carbon = user
		if(carbon.occult_muted())
			return
		var/data = use_available_blood(user, CT.blood_cost)
		if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
			return
		if(!do_after(user, 30, src))
			return
		new /obj/effect/cult_shortcut(src)
		user.visible_message("<span class='warning'>[user] has painted a strange sigil on \the [src].</span>", \
						"<span class='notice'>You finish drawing the sigil.</span>")
		var/datum/antagonist/cult/cultist = user.mind?.has_antag_datum(/datum/antagonist/cult)
		cultist.gain_devotion(5, DEVOTION_TIER_4, "shortcut_sigil", src)
