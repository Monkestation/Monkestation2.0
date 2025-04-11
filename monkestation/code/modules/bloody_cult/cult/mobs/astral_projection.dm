/mob
	var/obj/effect/new_rune/ajourn

////////////////////////////////////////////////////////////////////////////////////////
GLOBAL_LIST_INIT(astral_projections, list())

/mob/living/basic/astral_projection
	name = "astral projection"
	real_name = "astral projection"
	desc = "A fragment of a cultist's soul, freed from the laws of physics."
	icon = 'monkestation/code/modules/bloody_cult/icons/mob.dmi'
	icon_state = "ghost-narsie"
	icon_living = "ghost-narsie"
	icon_dead = "ghost-narsie"
	movement_type = FLYING
	maxHealth = 1
	health = 1
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = 1
	faction = list("cult")
	speed = 0.5
	density = 0
	plane = GHOST_PLANE
	invisibility = INVISIBILITY_REVENANT
	see_invisible = INVISIBILITY_REVENANT
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	alpha = 127
	now_pushing = 1 //prevents pushing atoms

	//keeps track of whether we're in "ghost" form or "slightly less ghost" form
	var/tangibility = FALSE

	//the cultist's original body
	var/mob/living/anchor

	var/image/incorporeal_appearance
	var/image/tangible_appearance

	var/time_last_speech = 0//speech bubble cooldown

	//sechud stuff
	var/cardjob = "hudunknown"

	//convertibility HUD
	var/list/propension = list()

	var/projection_destroyed = FALSE
	var/direct_delete = FALSE

	var/image/hudicon

	var/last_devotion_gain = 0
	var/devotion_gain_delay = 60 SECONDS

	var/datum/action/cooldown/spell/astral_return/astral_return
	var/datum/action/cooldown/spell/astral_toggle/astral_toggle

/mob/living/basic/astral_projection/New()
	..()
	ADD_TRAIT(src, TRAIT_GODMODE, type)
	GLOB.astral_projections += src
	last_devotion_gain = world.time
	incorporeal_appearance = image('monkestation/code/modules/bloody_cult/icons/mob.dmi', "blank")
	tangible_appearance = image('monkestation/code/modules/bloody_cult/icons/mob.dmi', "blank")
	see_in_dark = 100

	astral_return = new
	astral_toggle = new

	astral_return.Grant(src)
	astral_toggle.Grant(src)

/mob/living/basic/astral_projection/Login()
	..()

	if (!tangibility)
		overlay_fullscreen("astralborder", /atom/movable/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)

/mob/living/basic/astral_projection/proc/destroy_projection()
	if (projection_destroyed)
		return
	projection_destroyed = TRUE
	GLOB.astral_projections -= src
	//the projection has ended, let's return to our body
	if (anchor && anchor.stat != DEAD && client)
		if (key)
			if (tangibility)
				var/obj/effect/afterimage/A = new (loc, anchor, 10)
				A.dir = dir
				for(var/mob/M in dview(world.view, loc, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(loc, get_sfx("disappear_sound"), 75, 0, -2)
			anchor.key = key
			to_chat(anchor, span_notice("You reconnect with your body.") )
			anchor.ajourn = null
	//if our body was somehow already destroyed however, we'll become a shade right here
	else if(client)
		var/turf/T = get_turf(src)
		if (T)
			var/mob/living/basic/shade/shade = new (T)
			playsound(T, 'sound/hallucinations/growl1.ogg', 50, 1)
			shade.name = "[real_name] the Shade"
			shade.real_name = "[real_name]"
			mind.transfer_to(shade)
			shade.key = key
			to_chat(shade, span_cult("It appears your body was unfortunately destroyed. The remains of your soul made their way to your astral projection where they merge together, forming a shade.") )
	invisibility = 101
	set_density(FALSE)
	sleep(20)
	if (!direct_delete)
		qdel(src)

/mob/living/basic/astral_projection/Destroy()
	if (!projection_destroyed)
		direct_delete = TRUE
		INVOKE_ASYNC(src, PROC_REF(destroy_projection))
	..()

/mob/living/basic/astral_projection/Life()
	. = ..()

	if (anchor)
		var/turf/T = get_turf(anchor)
		var/turf/U = get_turf(src)
		if (T.z != U.z)
			to_chat(src, span_warning("You cannot sustain the astral projection at such a distance.") )
			death()
			return
	else
		death()
		return

	if (world.time >= (last_devotion_gain + devotion_gain_delay))
		last_devotion_gain += devotion_gain_delay
		var/datum/antagonist/cult/cult_datum = mind.has_antag_datum(/datum/antagonist/cult)
		cult_datum.gain_devotion(50, DEVOTION_TIER_2, "astral_journey")


/mob/living/basic/astral_projection/death(var/gibbed = FALSE)
	spawn()
		destroy_projection(src)

/mob/living/basic/astral_projection/examine(mob/user)
	if (!tangibility)
		if ((user == src) && anchor)
			to_chat(user, span_notice("You check yourself to see how others would see you were you tangible:") )
			anchor.examine(user)
		else if (IS_CULTIST(user))
			to_chat(user, span_notice("It's an astral projection.") )
		else
			to_chat(user, span_cult("Wait something's not right here.") )//it's a g-g-g-g-ghost!
	else if (anchor)
		anchor.examine(user)//examining the astral projection alone won't be enough to see through it, although the user might want to make sure they cannot be identified first.

//no pulling stuff around
/mob/living/basic/astral_projection/start_pulling(atom/movable/AM, 	state, force = pull_force, supress_message = FALSE)
	return


//this should prevent most other edge cases
/mob/living/basic/astral_projection/incapacitated()
	return TRUE

//bullets instantly end us
/mob/living/basic/astral_projection/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	. = ..()
	if (tangibility)
		death()


/mob/living/basic/astral_projection/ex_act(var/severity)
	if(tangibility)
		death()


//called once when we are created, shapes our appearance in the image of our anchor
/mob/living/basic/astral_projection/proc/ascend(var/mob/living/body)
	if (!body)
		return
	anchor = body
	//memorizing our anchor's appearance so we can toggle to it
	tangible_appearance = body.appearance

	//getting our ghostly looks
	overlays.len = 0
	if (ishuman(body))
		var/mob/living/carbon/human/H = body
		//instead of just adding an overlay of the body's uniform and suit, we'll first process them a bit so the leg part is mostly erased, for a ghostly look.
		//overlays += crop_human_suit_and_uniform(body)
		overlays += H.overlays_standing[ID_LAYER]
		overlays += H.overlays_standing[EARS_LAYER]
		overlays += H.overlays_standing[GLASSES_LAYER]
		overlays += H.overlays_standing[BELT_LAYER]
		overlays += H.overlays_standing[BACK_LAYER]
		overlays += H.overlays_standing[HEAD_LAYER]
		overlays += H.overlays_standing[HANDCUFF_LAYER]

	//giving control to the player
	key = body.key

	//name  & examine stuff
	desc = body.desc
	gender = body.gender
	if(body.mind && body.mind.name)
		name = body.mind.name
	else
		if(body.real_name)
			name = body.real_name
		else
			if(gender == MALE)
				name = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
			else
				name = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	real_name = name

	//important to trick sechuds
	var/list/target_id_cards = body.get_all_contents_type(/obj/item/card/id)
	var/obj/item/card/id/card = target_id_cards[1]
	if(card)
		cardjob = card.assignment

	//memorizing our current appearance so we can toggle back to it later. Has to be done AFTER setting our new name.
	incorporeal_appearance = appearance

	//we don't transfer the mind but we keep a reference to it.
	mind = body.mind

/mob/living/basic/astral_projection/proc/toggle_tangibility()
	if (tangibility)
		set_density(FALSE)
		appearance = incorporeal_appearance
		movement_type = FLYING
		incorporeal_move = 1
		speed = 0.5
		overlay_fullscreen("astralborder", /atom/movable/screen/fullscreen/astral_border)
		update_fullscreen_alpha("astralborder", 255, 5)
		var/obj/effect/afterimage/A = new (loc, anchor, 10)
		A.dir = dir
	else
		set_density(TRUE)
		appearance = tangible_appearance
		incorporeal_move = 0
		movement_type = GROUND
		see_invisible = SEE_INVISIBLE_OBSERVER
		speed = 1
		clear_fullscreen("astralborder", animated = 5)
		alpha = 0
		animate(src, alpha = 255, time = 10)

	tangibility = !tangibility

//saycode
/mob/living/basic/astral_projection/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	. = ..(tangibility ? "[message]" : "..[message]", tangibility ? "" : "C")
