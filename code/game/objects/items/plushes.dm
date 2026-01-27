/obj/item/toy/plush
	name = "plush"
	desc = "This is the special coder plush, do not steal."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "debug"
	worn_icon_state = "plushie"
	attack_verb_continuous = list("thumps", "whomps", "bumps")
	attack_verb_simple = list("thump", "whomp", "bump")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/list/squeak_override //Weighted list; If you want your plush to have different squeak sounds use this
	var/stuffed = TRUE //If the plushie has stuffing in it
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	var/list/plush_traits = list()
	var/list/starting_traits = list()
	var/plush_flags
	var/has_heartstring = TRUE
	var/list/gets_random_traits = list(PLUSH_TRAIT_CATEGORY_PERSONALITY, PLUSH_TRAIT_CATEGORY_PHYSICALITY)
	//--love ~<3--
	gender = NEUTER
	var/obj/item/toy/plush/lover
	var/obj/item/toy/plush/partner
	var/obj/item/toy/plush/plush_child
	var/obj/item/toy/plush/paternal_parent //who initiated creation
	var/obj/item/toy/plush/maternal_parent //who owns, see love()
	var/static/list/breeding_blacklist = typecacheof(/obj/item/toy/plush/carpplushie/dehy_carp)
	var/list/scorned = list() //who the plush hates
	var/list/scorned_by = list() //who hates the plush, to remove external references on Destroy()
	var/heartbroken = FALSE
	var/vowbroken = FALSE
	var/young = FALSE
///Prevents players from cutting stuffing out of a plushie if true
	var/divine = FALSE
	var/mood_message
	var/list/love_message
	var/list/partner_message
	var/list/heartbroken_message
	var/list/vowbroken_message
	var/list/parent_message
	var/normal_desc
	//--end of love :'(--

///Unique pet message
	var/pet_message

/*
** If you add a new plushie please add it to the lists at both:
** /obj/effect/spawner/random/entertainment/plushie
** /obj/effect/spawner/random/entertainment/plushie_delux
*/

/obj/item/toy/plush/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_override)
	AddElement(/datum/element/bed_tuckable, 6, -5, 90)

	//have we decided if Pinocchio goes in the blue or pink aisle yet?
	if(gender == NEUTER)
		if(prob(50))
			gender = FEMALE
		else
			gender = MALE

	love_message = list("[p_they(TRUE)] [p_are()] so happy, [p_they()] could rip a seam!")
	heartbroken_message = list("[p_they(TRUE)] look\s so sad.")
	vowbroken_message = list("[p_they(TRUE)] threw away [p_their()] wedding ring...")
	parent_message = list("[p_they(TRUE)] can't remember what sleep is.")

	normal_desc = desc
	if(starting_traits)
		for(var/trait in starting_traits)
			if(prob(starting_traits[trait]))
				var/datum/plush_trait/new_trait = new trait()
				plush_traits += new_trait
				new_trait.activate(src)
	addtimer(CALLBACK(src, PROC_REF(rand_traits)), 0.5 SECONDS) // god strike me down, this WORKS. Okay? it WORKS. shut up.


/obj/item/toy/plush/proc/rand_traits() // god help me.
	if(gets_random_traits && (maternal_parent == null))
		var/list/traits_to_add = list()
		for(var/the_category in gets_random_traits)
			visible_message(span_notice("[the_category]"))
			var/list/possibilities = list()
			for(var/datum/plush_trait/trait as anything in subtypesof(/datum/plush_trait))
				visible_message(span_notice("[trait::name] bbbbb"))
				if((trait::category == the_category) && !(is_type_in_list(trait, plush_traits)) && !(is_type_in_list(trait, traits_to_add)) && (trait::tier == 1))
					possibilities += trait
					visible_message(span_notice("[trait::name] cccc"))
			traits_to_add += pick(possibilities)
		for(var/datum/plush_trait/trait_to_add as anything in traits_to_add)
			var/datum/plush_trait/new_trait = new trait_to_add()
			plush_traits += new_trait
			new_trait.activate(src)

/obj/item/toy/plush/Destroy()
	QDEL_NULL(grenade)

	//inform next of kin and... acquaintances
	if(partner)
		partner.bad_news(src)
		partner = null
		lover = null
	else if(lover)
		lover.bad_news(src)
		lover = null

	if(paternal_parent)
		paternal_parent.bad_news(src)
		paternal_parent = null

	if(maternal_parent)
		maternal_parent.bad_news(src)
		maternal_parent = null

	if(plush_child)
		plush_child.bad_news(src)
		plush_child = null

	var/i
	var/obj/item/toy/plush/P
	for(i=1, i <= scorned.len, i++)
		P = scorned[i]
		P.bad_news(src)
	scorned = null

	for(i=1, i <= scorned_by.len, i++)
		P = scorned_by[i]
		P.bad_news(src)
	scorned_by = null

	//null remaining lists
	squeak_override = null

	love_message = null
	partner_message = null
	heartbroken_message = null
	vowbroken_message = null
	parent_message = null

	return ..()

/obj/item/toy/plush/handle_atom_del(atom/A)
	if(A == grenade)
		grenade = null
	..()

/obj/item/toy/plush/examine(mob/user)
	. = ..()
	if(has_heartstring == FALSE)
		. += "\nIt looks deeply and apatheticaly sad, somehow. [span_hypnophrase("SOULLESS")], even."
	if(mood_message)
		. += "\n[mood_message]"


/obj/item/toy/plush/attack_self(mob/user)
	. = ..()
	if(stuffed || grenade)
		to_chat(user, span_notice("[pet_message ? pet_message : "You pet [src]. D'awww."]"))
		for(var/datum/plush_trait/thingy in plush_traits)
			thingy.squeezed(src, user)
		if(grenade && !grenade.active)
			user.log_message("activated a hidden grenade in [src].", LOG_VICTIM)
			grenade.arm_grenade(user, msg = FALSE, volume = 10)
	else
		to_chat(user, span_notice("You try to pet [src], but it has no stuffing. Aww..."))

/obj/item/toy/plush/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/heartstring) && !has_heartstring)
		var/obj/item/heartstring/new_heartstring = attacking_item
		if(new_heartstring.our_plush.resolve() != src)
			to_chat(user, span_warning("You're trying to replace the essential soul and spirit of one plush with that of another, which is metaphysically impossible. You'll need to use the plushie's original bundle of Heart-strings."))
			return
		user.visible_message(span_notice("[user] begins inserting [new_heartstring] into [src]."), span_notice("You begin the delicate process of rejoining the Heart-string bundle of [src] with [p_their()] stuffing."))
		if(do_after(user, 5 SECONDS, src))
			for(var/datum/plush_trait/plush_trait in new_heartstring.shape_strings)
				plush_traits += plush_trait
				plush_trait.activate(src)
				if(plush_trait.processes)
					START_PROCESSING(SSobj, src)
				new_heartstring.shape_strings.Remove(plush_trait)
			user.visible_message(span_notice("[user] inserts [new_heartstring] into [src]. It looks happier, somehow."), span_notice("[src] seems happier with [p_their()] Heart-strings back."))
			qdel(new_heartstring)
			has_heartstring = TRUE
	if(attacking_item.get_sharpness())
		if(istype(attacking_item, /obj/item/heartstring_extractor))
			if(has_heartstring)
				user.visible_message(span_notice("[user] begins cutting into [src] with [attacking_item], attempting to remove [p_their()] Heart-strings."), span_notice("You begin to excise [src]'s Heart-strings."))
				if(do_after(user, 3 SECONDS, src))
					var/obj/item/heartstring/excised_heartstring = new(get_turf(src))
					STOP_PROCESSING(SSobj, src)
					for(var/datum/plush_trait/trait in plush_traits)
						trait.deactivate(src)
						plush_traits.Remove(trait)
						excised_heartstring.shape_strings += trait
					excised_heartstring.our_plush = WEAKREF(src)
					has_heartstring = FALSE
					return
				else
					return

			else
				to_chat(user, span_warning("[src] has no Heart-strings to excise!"))
				return
		if(!grenade)
			if(!stuffed)
				to_chat(user, span_warning("You already murdered it!"))
				return
			if(!divine)
				user.visible_message(span_notice("[user] tears out the stuffing from [src]!"), span_notice("You rip a bunch of the stuffing from [src]. Murderer."))
				attacking_item.play_tool_sound(src)
				stuffed = FALSE
			else
				to_chat(user, span_notice("What a fool you are. [src] is a god, how can you kill a god? What a grand and intoxicating innocence."))
				if(isliving(user))
					var/mob/living/living_user = user
					living_user.adjust_drunk_effect(20, up_to = 50)

				var/turf/current_location = get_turf(user)
				var/area/current_area = current_location.loc //copied from hand tele code
				if(current_location && current_area && (current_area.area_flags & NOTELEPORT))
					to_chat(user, span_notice("There is no escape. No recall or intervention can work in this place."))
				else
					to_chat(user, span_notice("There is no escape. Although recall or intervention can work in this place, attempting to flee from [src]'s immense power would be futile."))
				user.visible_message(span_notice("[user] lays down their weapons and begs for [src]'s mercy!"), span_notice("You lay down your weapons and beg for [src]'s mercy."))
				user.drop_all_held_items()
		else
			to_chat(user, span_notice("You remove the grenade from [src]."))
			user.put_in_hands(grenade)
			grenade = null
		return
	if(isgrenade(attacking_item))
		if(stuffed)
			to_chat(user, span_warning("You need to remove some stuffing first!"))
			return
		if(grenade)
			to_chat(user, span_warning("[src] already has a grenade!"))
			return
		if(!user.transferItemToLoc(attacking_item, src))
			return
		user.visible_message(span_warning("[user] slides [grenade] into [src]."), \
		span_danger("You slide [attacking_item] into [src]."))
		grenade = attacking_item
		user.log_message("added a grenade ([attacking_item.name]) to [src]", LOG_GAME)
		return
	if(istype(attacking_item, /obj/item/toy/plush))
		love(attacking_item, user)
		return
	return ..()

/obj/item/toy/plush/process(seconds_per_tick)
	. = ..()
	for(var/datum/plush_trait/trait in plush_traits)
		if(trait.processes)
			trait.process_trigger(src)

/obj/item/toy/plush/proc/love(obj/item/toy/plush/Kisser, mob/living/user) //~<3
	var/chance = 100 //to steal a kiss, surely there's a 100% chance no-one would reject a plush such as I?
	var/concern = 20 //perhaps something might cloud true love with doubt
	var/loyalty = 30 //why should another get between us?
	var/duty = 50 //conquering another's is what I live for
	if((PLUSH_FUGLY & Kisser.plush_flags) && !(PLUSH_KIND & plush_flags))
		chance -= 50
	//we are not catholic
	if(young == TRUE || Kisser.young == TRUE)
		user.show_message(span_notice("[src] plays tag with [Kisser]."), MSG_VISUAL,
			span_notice("They're happy."), NONE)
		Kisser.cheer_up()
		cheer_up()

	//nor are we incestuous.
	if((Kisser.plush_child == src || plush_child == Kisser))
		user.show_message(span_notice("[src] talks with [Kisser]."), MSG_VISUAL,
			span_notice("They're happy."), NONE)
		Kisser.cheer_up()
		cheer_up()

	//never again
	else if(Kisser in scorned)
		//message, visible, alternate message, neither visible nor audible
		user.show_message(span_notice("[src] rejects the advances of [Kisser]!"), MSG_VISUAL,
			span_notice("That didn't feel like it worked."), NONE)
	else if(src in Kisser.scorned)
		user.show_message(span_notice("[Kisser] realises who [src] is and turns away."), MSG_VISUAL,
			span_notice("That didn't feel like it worked."), NONE)

	//first comes love
	else if(Kisser.lover != src && Kisser.partner != src) //cannot be lovers or married
		if(Kisser.lover) //if the initiator has a lover
			Kisser.lover.heartbreak(Kisser) //the old lover can get over the kiss-and-run whilst the kisser has some fun
		if(!(Kisser.plush_flags & PLUSH_PROMISCUOUS))
			chance -= concern //one heart already broken, what does another mean?
		if(lover) //if the recipient has a lover
			if(!(plush_flags & PLUSH_PROMISCUOUS))
				chance -= loyalty //mustn't... but those lips
		if(partner) //if the recipient has a partner
			if(!(plush_flags & PLUSH_PROMISCUOUS))
				chance -= duty //do we mate for life?

		if(prob(clamp(chance, 0, 100))) //did we bag a date?
			user.visible_message(span_notice("[user] makes [Kisser] kiss [src]!"),
									span_notice("You make [Kisser] kiss [src]!"))
			if(lover) //who cares for the past, we live in the present
				lover.heartbreak(src)
			new_lover(Kisser)
			Kisser.new_lover(src)
			new /obj/effect/temp_visual/heart(loc)
		else
			user.show_message(span_notice("[src] rejects the advances of [Kisser], maybe next time?"), MSG_VISUAL,
								span_notice("That didn't feel like it worked, this time."), NONE)
			new /obj/effect/temp_visual/annoyed(loc)
	//then comes marriage
	else if(Kisser.lover == src && Kisser.partner != src) //need to be lovers (assumes loving is a two way street) but not married (also assumes similar)
		user.visible_message(span_notice("[user] pronounces [Kisser] and [src] married! D'aw."),
									span_notice("You pronounce [Kisser] and [src] married!"))
		new_partner(Kisser)
		Kisser.new_partner(src)
		new /obj/effect/temp_visual/heart(loc)

	//then comes a baby in a baby's carriage, or an adoption in an adoption's orphanage
	else if(Kisser.partner == src && !plush_child) //the one advancing does not take ownership of the child and we have a one child policy in the toyshop
		user.visible_message(span_notice("[user] is going to break [Kisser] and [src] by bashing them like that."),
									span_notice("[Kisser] passionately embraces [src] in your hands. Look away, you perv!"))
		user.client.give_award(/datum/award/achievement/misc/rule8, user)
		if(plop(Kisser))
			user.visible_message(span_notice("Something drops at the feet of [user]."),
							span_notice("The miracle of oh god did that just come out of [src]?!"))
			new /obj/effect/temp_visual/heart(loc) //wuv

	//then comes protection, or abstinence if we are catholic
	else if(Kisser.partner == src && plush_child)
		user.visible_message(span_notice("[user] makes [Kisser] nuzzle [src]!"),
									span_notice("You make [Kisser] nuzzle [src]!"))

	//then oh fuck something unexpected happened
	else
		user.show_message(span_warning("[Kisser] and [src] don't know what to do with one another."), NONE)

/obj/item/toy/plush/proc/heartbreak(obj/item/toy/plush/Brutus)
	if(lover != Brutus)
		CRASH("plushie heartbroken by a plushie that is not their lover")
	mood_message = "[p_they(TRUE)] look bored."
	if(!(plush_traits & PLUSH_STOIC))
		scorned.Add(Brutus)
		Brutus.scorned_by(src)
		heartbroken = TRUE
		mood_message = pick(heartbroken_message)

	lover = null
	Brutus.lover = null //feeling's mutual

	if(partner == Brutus) //oh dear...
		partner = null
		Brutus.partner = null //it'd be weird otherwise
		if(!(plush_traits & PLUSH_STOIC))
			vowbroken = TRUE
			mood_message = pick(vowbroken_message)


/obj/item/toy/plush/proc/scorned_by(obj/item/toy/plush/Outmoded)
	scorned_by.Add(Outmoded)

/obj/item/toy/plush/proc/new_lover(obj/item/toy/plush/Juliet)
	if(lover == Juliet)
		return //nice try
	lover = Juliet

	cheer_up()
	lover.cheer_up()

	mood_message = pick(love_message)

	if(partner) //who?
		partner = null //more like who cares

/obj/item/toy/plush/proc/new_partner(obj/item/toy/plush/Apple_of_my_eye)
	if(partner == Apple_of_my_eye)
		return //double marriage is just insecurity
	if(lover != Apple_of_my_eye)
		return //union not born out of love will falter

	partner = Apple_of_my_eye

	heal_memories()
	partner.heal_memories()

	partner_message = list("[p_they(TRUE)] [p_have()] a ring on [p_their()] finger! It says 'Bound to my dear [partner.name].'")
	mood_message = pick(partner_message)

/obj/item/toy/plush/proc/plop(obj/item/toy/plush/Daddy)
	if(partner != Daddy)
		return FALSE //we do not have bastards in our toyshop

	if(is_type_in_typecache(Daddy, breeding_blacklist))
		return FALSE // some love is forbidden

	if(prob(50)) //it has my eyes
		plush_child = new type(get_turf(loc))
	else //it has your eyes
		plush_child = new Daddy.type(get_turf(loc))

	var/all_traits = subtypesof(/datum/plush_trait)

	for(var/datum/plush_trait/inhereted in Daddy.plush_traits)
		if(is_type_in_list(inhereted, plush_child.plush_traits))
			continue

		var/datum/plush_trait/added_trait = new inhereted.type()
		plush_child.plush_traits += added_trait
		added_trait.activate(plush_child)

	for(var/datum/plush_trait/inhereted in plush_traits) // yes i know this is copied shut up
		if(is_type_in_list(inhereted, plush_child.plush_traits))
			continue

		var/datum/plush_trait/added_trait = new inhereted.type()
		plush_child.plush_traits += added_trait
		added_trait.activate(plush_child)

	for(var/datum/plush_trait/possible as anything in all_traits)
		if(possible::recipe == list())
			continue
		var/could_we = TRUE
		for(var/datum/plush_trait/needed in possible::recipe)
			if(!is_type_in_list(needed, plush_child.plush_traits))
				could_we = FALSE
		if(is_type_in_list(possible, plush_child.plush_traits))
			continue
		if(could_we)
			var/datum/plush_trait/created = new possible()
			plush_child.plush_traits += created
			created.activate(plush_child)
			for(var/datum/plush_trait/consumed in plush_child.plush_traits)
				if(is_type_in_list(consumed, possible::recipe))
					consumed.deactivate(plush_child)
					plush_child.plush_traits -= consumed
					qdel(consumed)


	plush_child.make_young(src, Daddy)

/obj/item/toy/plush/proc/make_young(obj/item/toy/plush/Mama, obj/item/toy/plush/Dada)
	if(Mama == Dada)
		return //cloning is reserved for plants and spacemen

	maternal_parent = Mama
	paternal_parent = Dada
	young = TRUE
	var/mommy_or_daddy = pick(list(Mama.name, Dada.name))
	var/iceland = replacetext(replacetext(mommy_or_daddy, " plushie", ""), "-", "")
	var/nominative_gender = "child"
	switch(src.gender)
		if(MALE)
			nominative_gender = "son"
		if(FEMALE)
			nominative_gender = "daughter"
	name = "[iceland]-[nominative_gender]" //Icelandic naming convention no longer pending
	normal_desc = "[src] [p_are()] the [nominative_gender] of [maternal_parent] and [paternal_parent]." //original desc won't be used so the child can have moods
	transform *= 0.75

	Mama.mood_message = pick(Mama.parent_message)
	Dada.mood_message = pick(Dada.parent_message)

/obj/item/toy/plush/proc/grow_up()
	if(!young)
		return
	transform *= (4/3)
	young = FALSE
	visible_message(span_notice("[src] grows up."))

/obj/item/toy/plush/proc/bad_news(obj/item/toy/plush/Deceased) //cotton to cotton, sawdust to sawdust
	var/is_that_letter_for_me = FALSE
	if(partner == Deceased) //covers marriage
		is_that_letter_for_me = TRUE
		partner = null
		lover = null
	else if(lover == Deceased) //covers lovers
		is_that_letter_for_me = TRUE
		lover = null

	//covers children
	if(maternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		maternal_parent = null

	if(paternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		paternal_parent = null

	//covers parents
	if(plush_child == Deceased)
		is_that_letter_for_me = TRUE
		plush_child = null

	//covers bad memories
	if(Deceased in scorned)
		scorned.Remove(Deceased)
		cheer_up() //what cold button eyes you have

	if(Deceased in scorned_by)
		scorned_by.Remove(Deceased)

	//all references to the departed should be cleaned up by now

	if(is_that_letter_for_me)
		heartbroken = TRUE
		mood_message = pick(heartbroken_message)

/obj/item/toy/plush/proc/cheer_up() //it'll be all right
	if(!heartbroken)
		return //you cannot make smile what is already
	if(vowbroken)
		return //it's a pretty big deal

	heartbroken = !heartbroken

	if(mood_message in heartbroken_message)
		mood_message = null

/obj/item/toy/plush/proc/heal_memories() //time fixes all wounds
	if(!vowbroken)
		vowbroken = !vowbroken
		if(mood_message in vowbroken_message)
			mood_message = null
	cheer_up()

/obj/item/toy/plush/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon_state = "map_plushie_carp"
	greyscale_config = /datum/greyscale_config/plush_carp
	greyscale_colors = "#cc99ff#000000"
	inhand_icon_state = "carp_plushie"
	attack_verb_continuous = list("bites", "eats", "fin slaps")
	attack_verb_simple = list("bite", "eat", "fin slap")
	squeak_override = list('sound/weapons/bite.ogg'=1)
	flags_1 = IS_PLAYER_COLORABLE_1 // monkestation edit

/obj/item/toy/plush/bubbleplush
	name = "\improper Bubblegum plushie"
	desc = "The friendly red demon that gives good miners gifts."
	icon_state = "bubbleplush"
	attack_verb_continuous = list("rents")
	attack_verb_simple = list("rent")
	squeak_override = list('sound/magic/demon_attack1.ogg'=1)

/obj/item/toy/plush/ratplush
	name = "\improper Ratvar plushie"
	desc = "An adorable plushie of the clockwork justiciar himself with new and improved spring arm action."
	icon_state = "plushvar"
	divine = TRUE
	var/obj/item/toy/plush/narplush/clash_target
	gender = MALE //he's a boy, right?

/obj/item/toy/plush/ratplush/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(clash_target)
		return
	var/obj/item/toy/plush/narplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clashing)
		clash_of_the_plushies(P)

/obj/item/toy/plush/ratplush/proc/clash_of_the_plushies(obj/item/toy/plush/narplush/P)
	clash_target = P
	P.clashing = TRUE
	say("YOU.")
	P.say("Ratvar?!")
	var/obj/item/toy/plush/a_winnar_is
	var/victory_chance = 10
	for(var/i in 1 to 10) //We only fight ten times max
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(!Adjacent(P))
			visible_message(span_warning("The two plushies angrily flail at each other before giving up."))
			clash_target = null
			P.clashing = FALSE
			return
		playsound(src, 'sound/magic/clockwork/ratvar_attack.ogg', 50, TRUE, frequency = 2)
		sleep(0.24 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = src
			break
		P.SpinAnimation(5, 0)
		sleep(0.5 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		playsound(P, 'sound/magic/clockwork/narsie_attack.ogg', 50, TRUE, frequency = 2)
		sleep(0.33 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = P
			break
		SpinAnimation(5, 0)
		victory_chance += 10
		sleep(0.5 SECONDS)
	if(!a_winnar_is)
		a_winnar_is = pick(src, P)
	if(a_winnar_is == src)
		say(pick("DIE.", "ROT."))
		P.say(pick("Nooooo...", "Not die. To y-", "Die. Ratv-", "Sas tyen re-"))
		playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 50, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_dies.ogg', 50, TRUE, frequency = 2)
		explosion(P, light_impact_range = 1)
		qdel(P)
		clash_target = null
	else
		say("NO! I will not be banished again...")
		P.say(pick("Ha.", "Ra'sha fonn dest.", "You fool. To come here."))
		playsound(src, 'sound/magic/clockwork/anima_fragment_death.ogg', 62, TRUE, frequency = 2)
		playsound(P, 'sound/magic/demon_attack1.ogg', 50, TRUE, frequency = 2)
		explosion(src, light_impact_range = 1)
		qdel(src)
		P.clashing = FALSE

/obj/item/toy/plush/narplush
	name = "\improper Nar'Sie plushie"
	desc = "A small stuffed doll of the elder goddess Nar'Sie. Who thought this was a good children's toy?"
	icon_state = "narplush"
	divine = TRUE
	var/clashing
	gender = FEMALE //it's canon if the toy is

/obj/item/toy/plush/narplush/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/obj/item/toy/plush/ratplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clash_target && !clashing)
		P.clash_of_the_plushies(src)

// Worn sprite taken from Space Station 14. Bee hat sprite drawn by Ubaser.
/obj/item/toy/plush/lizard_plushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "map_plushie_lizard"
	greyscale_config = /datum/greyscale_config/plush_lizard
	attack_verb_continuous = list("claws", "hisses", "tail slaps")
	attack_verb_simple = list("claw", "hiss", "tail slap")
	squeak_override = list('monkestation/sound/voice/weh.ogg' = 1) // Monkestation Edit
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	worn_icon_state = "map_plushie_lizard"
	slot_flags = ITEM_SLOT_HEAD // Monkestation Edit
	body_parts_covered = HEAD // Monkestation Edit

/obj/item/toy/plush/lizard_plushie/Initialize(mapload)
	. = ..()
	if(!greyscale_colors)
		// Generate a random valid lizard color for our plushie friend
		var/generated_lizard_color = "#" + random_color()
		var/list/lizard_hsv = rgb2hsv(generated_lizard_color)

		// If our color is too dark, use the classic green lizard plush color
		if(lizard_hsv[3] < 50)
			generated_lizard_color = "#66ff33"

		// Set our greyscale colors to the lizard color we made + black eyes
		set_greyscale(colors = list(generated_lizard_color, "#000000"))

// Preset lizard plushie that uses the original lizard plush green. (Or close to it)
/obj/item/toy/plush/lizard_plushie/green
	desc = "An adorable stuffed toy that resembles a green lizardperson. This one fills you with nostalgia and soul."
	greyscale_colors = "#66ff33#000000"

/obj/item/toy/plush/lizard_plushie/greyscale
	desc = "An adorable stuffed toy that resembles a lizardperson. This one has been custom made."
	greyscale_colors = "#d3d3d3#000000"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/toy/plush/lizard_plushie/space
	name = "space lizard plushie"
	desc = "An adorable stuffed toy that resembles a very determined spacefaring lizardperson. To infinity and beyond, little guy."
	icon_state = "map_plushie_spacelizard"
	greyscale_config = /datum/greyscale_config/plush_spacelizard
	// space lizards can't hit people with their tail, it's stuck in their suit
	attack_verb_continuous = list("claws", "hisses", "bops")
	attack_verb_simple = list("claw", "hiss", "bops")
	squeak_override = list('monkestation/sound/voice/weh.ogg' = 1) // Monkestation Edit

/obj/item/toy/plush/lizard_plushie/space/green
	desc = "An adorable stuffed toy that resembles a very determined spacefaring green lizardperson. To infinity and beyond, little guy. This one fills you with nostalgia and soul."
	greyscale_colors = "#66ff33#000000"

/obj/item/toy/plush/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "map_plushie_snake"
	greyscale_config = /datum/greyscale_config/plush_snake
	greyscale_colors = "#99ff99#000000"
	inhand_icon_state = null
	attack_verb_continuous = list("bites", "hisses", "tail slaps")
	attack_verb_simple = list("bite", "hiss", "tail slap")
	squeak_override = list('sound/weapons/bite.ogg' = 1)
	flags_1 = IS_PLAYER_COLORABLE_1 // monkestation edit

/obj/item/toy/plush/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	inhand_icon_state = null
	attack_verb_continuous = list("shoots", "nukes", "detonates")
	attack_verb_simple = list("shoot", "nuke", "detonate")
	squeak_override = list('sound/effects/hit_punch.ogg' = 1)

/obj/item/toy/plush/plasmamanplushie
	name = "plasmaman plushie"
	desc = "A stuffed toy that resembles your purple coworkers. Mmm, yeah, in true plasmaman fashion, it's not cute at all despite the designer's best efforts."
	icon_state = "plushie_pman"
	inhand_icon_state = null
	attack_verb_continuous = list("burns", "space beasts", "fwooshes")
	attack_verb_simple = list("burn", "space beast", "fwoosh")
	squeak_override = list('sound/effects/extinguish.ogg' = 1)

/obj/item/toy/plush/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "map_plushie_slime"
	greyscale_config = /datum/greyscale_config/plush_slime
	greyscale_colors = "#aaaaff#000000"
	inhand_icon_state = null
	attack_verb_continuous = list("blorbles", "slimes", "absorbs")
	attack_verb_simple = list("blorble", "slime", "absorb")
	squeak_override = list('sound/effects/blobattack.ogg' = 1)
	gender = FEMALE //given all the jokes and drawings, I'm not sure the xenobiologists would make a slimeboy
	flags_1 = IS_PLAYER_COLORABLE_1 // monkestation edit

/obj/item/toy/plush/awakenedplushie
	name = "awakened plushie"
	desc = "An ancient plushie that has grown enlightened to the true nature of reality."
	icon_state = "plushie_awake"
	inhand_icon_state = null

/obj/item/toy/plush/awakenedplushie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/edit_complainer)

/obj/item/toy/plush/whiny_plushie
	name = "whiny plushie"
	desc = "An ancient plushie that demands constant companionship, after being forgotten for too long."
	icon_state = "plushie_whiny"
	inhand_icon_state = null
	/// static list of cry messages it picks from to speak when it is insecure from no movement
	var/static/list/cry_still_messages
	/// static list of cry messages it picks from to speak when it is insecure from no holder
	var/static/list/cry_alone_messages
	/// cooldown for it sending messages, it will every 10 seconds
	COOLDOWN_DECLARE(cry_cooldown)

/obj/item/toy/plush/whiny_plushie/Initialize(mapload)
	. = ..()
	if(!cry_still_messages)
		cry_still_messages = list(
			"WHY DID WE STOP MOVING?! ARE YOU GOING TO LEAVE ME?!!",
			"WE COULD GET ATTACKED WE'RE SITTING DUCKS MOVE MOOOOOOOVE!!",
			"YOU'RE PLANNING ON DROPPING ME AREN'T YOU I KNOW YOU AAAAAAAREE!!",
			"THE SYNDICATE ARE TRIANGULATING OUR LOCAAAAAAAATIONNN!!",
			"THIS PLACE IS SCARY I WANNA LEEEEEAAAAAVVVEEEEEE!!",
			"CHELP, CHELP CCCCHHHHEEEEEEEEEEEEEEELLLLLLLPPPPPP!!",
		)
		cry_alone_messages = list(
			"NOOOOOOOOOOOOOOOOOO DON'T LEAVE MEEEEE!!",
			"WUH WHERE DID EVERYONE GOOOOOOHHHHHHH WAHHH!!",
			"SOMEONE, ANYONEEEEEEEEE PICK ME UPP!!",
			"I DIDN'T DESERVE ITTTTTTTTTT!!",
			"I WILL DIE TO JUST ONE ATTTTTTAAAAACKKKKKK!!",
			"I WILLLLLL NOT DROP GOOOD IITITTEEEEEMMMS!!",
		)
	AddComponent(/datum/component/keep_me_secure, CALLBACK(src, PROC_REF(secured_process)) , CALLBACK(src, PROC_REF(unsecured_process)))

/obj/item/toy/plush/whiny_plushie/proc/secured_process(last_move)
	icon_state = initial(icon_state)

/obj/item/toy/plush/whiny_plushie/proc/unsecured_process(last_move)
	if(!COOLDOWN_FINISHED(src, cry_cooldown))
		return
	COOLDOWN_START(src, cry_cooldown, 10 SECONDS)
	icon_state = "plushie_whiny_crying"
	if(isturf(loc))
		say(pick(cry_alone_messages))
	else
		say(pick(cry_still_messages))
	playsound(src, 'sound/items/intents/Help.ogg', 50, FALSE)

// Worn sprite taken from Space Station 14. Lizard hat sprite made by Cinder.
/obj/item/toy/plush/beeplushie
	name = "bee plushie"
	desc = "A cute toy that resembles an even cuter bee."
	icon_state = "plushie_h"
	inhand_icon_state = null
	attack_verb_continuous = list("stings")
	attack_verb_simple = list("sting")
	gender = FEMALE
	squeak_override = list('sound/voice/moth/scream_moth.ogg'=1)
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	worn_icon_state = "plushie_h"
	slot_flags = ITEM_SLOT_HEAD // Monkestation Edit
	body_parts_covered = HEAD // Monkestation Edit
	starting_traits = list(/datum/plush_trait/prickly = 25, /datum/plush_trait/ominous_levitation = 10)

/obj/item/toy/plush/goatplushie
	name = "strange goat plushie"
	icon_state = "goat"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same. Goats never change."
	squeak_override = list('sound/weapons/punch1.ogg'=1)
	/// Whether or not this goat is currently taking in a monsterous doink
	var/going_hard = FALSE
	/// Whether or not this goat has been flattened like a funny pancake
	var/splat = FALSE

/obj/item/toy/plush/goatplushie/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_TURF_INDUSTRIAL_LIFT_ENTER = PROC_REF(splat),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/plush/goatplushie/attackby(obj/item/clothing/mask/cigarette/rollie/fat_dart, mob/user, params)
	if(!istype(fat_dart))
		return ..()
	if(splat)
		to_chat(user, span_notice("[src] doesn't seem to be able to go hard right now."))
		return
	if(going_hard)
		to_chat(user, span_notice("[src] is already going too hard!"))
		return
	if(!fat_dart.lit)
		to_chat(user, span_notice("You'll have to light that first!"))
		return
	to_chat(user, span_notice("You put [fat_dart] into [src]'s mouth."))
	qdel(fat_dart)
	going_hard = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/toy/plush/goatplushie/proc/splat(datum/source)
	SIGNAL_HANDLER
	if(splat)
		return
	if(going_hard)
		going_hard = FALSE
		update_icon(UPDATE_OVERLAYS)
	icon_state = "goat_splat"
	playsound(src, SFX_DESECRATION, 50, TRUE)
	visible_message(span_danger("[src] gets absolutely flattened!"))
	splat = TRUE

/obj/item/toy/plush/goatplushie/examine()
	. = ..()
	if(splat)
		. += span_notice("[src] might need medical attention.")
	if(going_hard)
		. += span_notice("[src] is going so hard, feel free to take a picture.")

/obj/item/toy/plush/goatplushie/update_overlays()
	. = ..()
	if(going_hard)
		. += "goat_dart"

/obj/item/toy/plush/moth
	name = "moth plushie"
	desc = "A plushie depicting an adorable mothperson. It's a huggable bug!"
	icon_state = "moffplush"
	inhand_icon_state = null
	attack_verb_continuous = list("flutters", "flaps")
	attack_verb_simple = list("flutter", "flap")
	squeak_override = list('sound/voice/moth/scream_moth.ogg'=1)
///Used to track how many people killed themselves with item/toy/plush/moth
	var/suicide_count = 0
	var/suicide_text = "stares deeply into the eyes of" //for modularizing creepy toys
	var/creepy_plush_type = "mothperson" //for modularizing creepy toys
	var/has_creepy_icons = FALSE //for updating icons

	// only used for the base moth plush light
	light_system = OVERLAY_LIGHT
	light_outer_range = 4
	light_power = 1

	/// Is the light turned on or off currently
	var/on = FALSE

/obj/item/toy/plush/moth/Initialize(mapload)
	. = ..()
	if(icon_state == "[initial(icon_state)]-on")
		on = TRUE
	update_brightness()

/obj/item/toy/plush/moth/attack_self(mob/user)
	. = ..()
	toggle_light()

/obj/item/toy/plush/moth/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] stares deeply into the eyes of [src] and it begins consuming [user.p_them()]!  It looks like [user.p_theyre()] trying to commit suicide!"))
	suicide_count++
	if(suicide_count < 3)
		desc = "An unsettling [creepy_plush_type] plushy. After killing [suicide_count] [suicide_count == 1 ? "person" : "people"] it's not looking so huggable now..."
		if(has_creepy_icons)
			icon_state = "[initial(icon_state)]_1"
	else
		desc = "A creepy [creepy_plush_type] plushy. It has killed [suicide_count] people! I don't think I want to hug it any more!"
		divine = TRUE
		resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
		if(has_creepy_icons)
			icon_state = "[initial(icon_state)]_2"
	playsound(src, 'sound/hallucinations/wail.ogg', 50, TRUE, -1)
	var/list/available_spots = get_adjacent_open_turfs(loc)
	if(available_spots.len) //If the user is in a confined space the plushie will drop normally as the user dies, but in the open the plush is placed one tile away from the user to prevent squeak spam
		var/turf/open/random_open_spot = pick(available_spots)
		forceMove(random_open_spot)
	user.dust(just_ash = FALSE, drop_items = TRUE)
	return MANUAL_SUICIDE

/obj/item/toy/plush/moth/proc/update_brightness()
	if(on)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)


/obj/item/toy/plush/moth/proc/toggle_light()
	if (icon_state == "moffplush_on" || icon_state == "moffplush")
		on = !on
		update_brightness()

		set_light_on(on)
		if(light_system == COMPLEX_LIGHT)
			update_light()

		return TRUE
	return FALSE

/obj/item/toy/plush/pkplush
	name = "peacekeeper plushie"
	desc = "A plushie depicting a peacekeeper cyborg. Only you can prevent human harm!"
	icon_state = "pkplush"
	attack_verb_continuous = list("hugs", "squeezes")
	attack_verb_simple = list("hug", "squeeze")
	squeak_override = list('sound/weapons/thudswoosh.ogg'=1)

/obj/item/toy/plush/rouny
	name = "runner plushie"
	desc = "A plushie depicting a xenomorph runner, made to commemorate the centenary of the Battle of LV-426. Much cuddlier than the real thing."
	icon_state = "rouny"
	item_flags = XENOMORPH_HOLDABLE
	inhand_icon_state = null
	attack_verb_continuous = list("slashes", "bites", "charges")
	attack_verb_simple = list("slash", "bite", "charge")
	squeak_override = list('sound/items/intents/Help.ogg' = 1)

/obj/item/toy/plush/abductor
	name = "abductor plushie"
	desc = "A plushie depicting an alien abductor. The tag on it is in an indecipherable language."
	icon_state = "abductor"
	inhand_icon_state = null
	attack_verb_continuous = list("abducts", "probes")
	attack_verb_simple = list("abduct", "probe")
	squeak_override = list('sound/weather/ashstorm/inside/weak_end.ogg' = 1) //very faint sound since abductors are silent as far as "speaking" is concerned.

/obj/item/toy/plush/abductor/agent
	name = "abductor agent plushie"
	desc = "A plushie depicting an alien abductor agent. The stun baton is attached to the hand of the plushie, and appears to be inert. I wouldn't stay alone with it."
	icon_state = "abductor_agent"
	inhand_icon_state = null
	attack_verb_continuous = list("abducts", "probes", "stuns")
	attack_verb_simple = list("abduct", "probe", "stun")
	squeak_override = list(
		'sound/weapons/egloves.ogg' = 2,
		'sound/weapons/cablecuff.ogg' = 1,
	)

/obj/item/toy/plush/greek_cucumber
	name = "greek cucumber"
	desc = "A plushie depicting a large cucumber with eyes, it seems that according to the manufacturer of the toy, the human race will look like in the future."
	icon_state = "cucumber"
	inhand_icon_state = null
	attack_verb_continuous = list("squishes", "creaks", "crunches")
	attack_verb_simple = list("squish", "creak", "crunch")
	squeak_override = list(
		'sound/effects/slosh.ogg' = 1,
		'sound/effects/splat.ogg' = 2
	)

/obj/item/toy/plush/shark
	name = "shark plushie"
	desc = "A plushie depicting a somewhat cartoonish shark. The tag calls it a 'hákarl', noting that it was made by an obscure furniture manufacturer in old Scandinavia."
	lefthand_file = 'icons/mob/inhands/items/plushes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/plushes_righthand.dmi'
	icon_state = "blahaj"
	inhand_icon_state = "blahaj"
	attack_verb_continuous = list("gnaws", "gnashes", "chews")
	attack_verb_simple = list("gnaw", "gnash", "chew")

/obj/item/toy/plush/donkpocket
	name = "donk pocket plushie"
	desc = "The stuffed companion of choice for the seasoned traitor."
	icon_state = "donkpocket"
	attack_verb_continuous = list("donks")
	attack_verb_simple = list("donk")

//PLUSHTOMIZATION STUFF

/obj/item/heartstring_extractor
	name = "heart-string extractor"
	desc = "This specially treated pair of scissors has been saturated with the energy of the quintessential cotton, helping to preserve Heart-strings and Shape-strings when used to excise them."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_EDGED
	force = 1

/obj/item/heartstring
	name = "\improper Heart-strings"
	desc = "A bundle of woven cotton fibres. The vivifying crux of a plush, along with both its Soul-string and any adjoining Shape-strings. Without its Heart-string, a plushie's spirit is lost."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "heartstring"
	var/datum/weakref/our_plush
	var/list/datum/plush_trait/shape_strings = list()
	w_class = WEIGHT_CLASS_SMALL

/obj/item/heartstring/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/heartstring_extractor))
		if(!shape_strings)
			to_chat(user, span_warning("The Soul-string is bereft of Shape-strings."))
			return
		var/list/shape_string_names = list()
		for(var/datum/plush_trait/possible_string in shape_strings)
			if(possible_string.removable)
				shape_string_names[possible_string.name] = possible_string
		if(!shape_string_names.len)
			to_chat(user, span_warning("The only Shape-strings here are woven irreversably into the Soul-string."))
			return
		to_chat(user, span_notice("Select a Shape-string to cut from the Heart-string."))
		var/datum/plush_trait/shape_string_choice = shape_string_names[tgui_input_list(user, "Choose a string", "Plushtomization", shape_string_names)]
		var/obj/item/shapestring/extracted = new(get_turf(src))
		extracted.stored_trait = shape_string_choice
		if(shape_string_choice.shapestring_icon_state != "")
			extracted.icon_state = shape_string_choice.shapestring_icon_state
		extracted.name = "\improper [shape_string_choice.name] Shape-string"
		extracted.desc = "A thick cotton fibre. The sculpting energies of a plush. It moulds the quintessential Cotton into something more substantial, fueling the Cloth. This particular one [shape_string_choice.desc]"
		shape_strings.Remove(shape_string_choice)

/obj/item/shapestring
	name = "\improper Shape-string"
	desc = "A thick cotton fibre. The sculpting and binding energies of a plush. It moulds the quintessential Cotton into something more substantial, fueling the Cloth."
	icon = 'monkestation/code/modules/blueshift/icons/items.dmi'
	icon_state = "scissors"
	w_class = WEIGHT_CLASS_TINY
	var/datum/plush_trait/stored_trait

/datum/plush_trait
	var/name = "Buggy Nonsense"
	var/desc = "means that the neurodivergent frog guy did a fail. Please report this thing's presence with the report issue button. Include how you found it, please."
	var/examine_text = ""
	var/removable = TRUE
	var/processes = FALSE
	var/shapestring_icon_state = ""
	var/list/recipe = list()
	var/flags
	var/tier = 1
	var/category

/datum/plush_trait/proc/activate(obj/item/toy/plush/plush)
	if(flags)
		plush.plush_flags |= flags
	return

/datum/plush_trait/proc/deactivate(obj/item/toy/plush/plush)
	if(flags)
		plush.plush_flags &= ~(flags)
	return

/datum/plush_trait/proc/process_trigger(seconds_per_tick, obj/item/toy/plush/plush)
	return

/datum/plush_trait/proc/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	return

/datum/plush_trait/prickly
	name = "Cactaceous"
	desc = "shapes the fabric of the plush into microscopic spines, which, though mostly harmless, are extremely painful."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/prickly/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/ouched = TRUE
	if(iscarbon(squeezer))
		var/mob/living/carbon/carbsqueezer = squeezer
		if(carbsqueezer.gloves && !HAS_TRAIT(carbsqueezer.gloves, TRAIT_FINGERPRINT_PASSTHROUGH))
			ouched = FALSE
		if(HAS_TRAIT(carbsqueezer, TRAIT_PIERCEIMMUNE))
			ouched = FALSE
		if(!ouched)
			return
		to_chat(carbsqueezer, span_warning("Your hand stings horribly with a wave of needling pain!"))
		var/ouchy_arm = (carbsqueezer.get_held_index_of_item(plush) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
		carbsqueezer.apply_damage(1, BRUTE, ouchy_arm)





/datum/plush_trait/life_sponge
	name = "Viviphagous"
	desc = "allows the plush to absorb and infuse the life forces of any who hug it. Squeeze it HARMfully to give and HELPfully to take. The longer either process goes, the more potent the drain or infusion."
	var/stored_flesh = 0
	var/stored_blood = 0
	var/stored_life = 0
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	tier = 3
	recipe = list(/datum/plush_trait/prickly, /datum/plush_trait/colorful)

/datum/plush_trait/life_sponge/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(!ishuman(squeezer))
		return
	var/mob/living/carbon/human/humsqueezer = squeezer
	if((humsqueezer.istate & ISTATE_HARM) || istype(humsqueezer.client?.imode, /datum/interaction_mode/combat_mode))
		var/numcycles = 0
		humsqueezer.visible_message(span_warning("[plush] prickles painfully in your hands and begins to drain the life from your flesh!"), span_warning("A cloud of shimmering red vapor begins flowing from [humsqueezer] into [plush]!"))
		while(do_after(humsqueezer, 0.2 SECONDS, plush))
			if(((humsqueezer.getBruteLoss() + humsqueezer.getFireLoss()) < 100) && stored_flesh < 100)
				humsqueezer.adjustBruteLoss(0.5)
				humsqueezer.adjustFireLoss(0.5)
				stored_flesh = min(100, stored_flesh + 1)
			if(numcycles == 20 && stored_blood < 560)
				to_chat(span_warning("[plush] begins to drain the life from your blood!"))
			if(numcycles >= 20 && stored_blood < 560 && (humsqueezer.getToxLoss() < 100))
				humsqueezer.adjustToxLoss(1)
				stored_blood = min(500, stored_blood + 5)
			if(numcycles == 40 && stored_life < 100)
				to_chat(span_warning("[plush] begins to drain the life from your soul!"))
			if(numcycles >= 40 && stored_life < 100)
				humsqueezer.adjustCloneLoss(1)
				stored_life = min(100, stored_life + 1)
	else
		var/numcycles = 0
		humsqueezer.visible_message(span_notice("[plush] feels warm and so very soft..."), span_notice("A cloud of shimmering red vapor steams from [plush], flowing into [humsqueezer]'s flesh!"))
		while(do_after(humsqueezer, 0.2 SECONDS, plush))
			if(humsqueezer.getBruteLoss() && stored_flesh > 0)
				humsqueezer.adjustBruteLoss(-1)
				stored_flesh = max(0, stored_flesh - 1)
			if(humsqueezer.getFireLoss() && stored_flesh > 0)
				humsqueezer.adjustFireLoss(-1)
				stored_flesh = max(0, stored_flesh - 1)
			if(numcycles == 20)
				to_chat(span_notice("Your insides are all warm and fuzzy. It feels good."))
			if(numcycles >= 20)
				if(humsqueezer.getToxLoss() && stored_blood >= 5)
					humsqueezer.adjustToxLoss(-1)
					stored_blood = max(0, stored_blood - 5)
				if(humsqueezer.blood_volume < BLOOD_VOLUME_NORMAL && stored_blood >= 5)
					humsqueezer.blood_volume += 5
					stored_blood = min(0, stored_blood - 5)
			if(numcycles == 40)
				to_chat(span_notice("Your whole body is suffused with a sort of rejuvinating heat. It feels amazing."))
			if(numcycles >= 40)
				if(humsqueezer.getCloneLoss() && stored_life > 0)
					humsqueezer.adjustCloneLoss(-1)
					stored_life = max(0, stored_life - 1)
				for(var/obj/item/organ/internal/thing in humsqueezer.organs)
					if(!istype(thing))
						continue
					if(thing.damage > 0 && stored_life > 0)
						thing.apply_organ_damage(-5)
						stored_life = max(0, stored_life - 1)
				for(var/datum/wound/ouchy in humsqueezer.all_wounds)
					if((stored_life >= ouchy.severity * 5) && ouchy.severity < WOUND_SEVERITY_LOSS)
						ouchy.remove_wound()
						stored_life = max(0, stored_life - (ouchy.severity * 5))







/datum/plush_trait/ominous_levitation
	name = "Unnervingly Hovering"
	desc = "imbues the stuffing of the plush with an anti-gravitational telekinetic field, enabling it to levitate."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/ominous_levitation/activate(obj/item/toy/plush/plush)
	. = ..()
	DO_FLOATING_ANIM(plush)
	plush.visible_message(span_warning("[plush] begins to float for no conceivable reason!"))

/datum/plush_trait/ominous_levitation/deactivate(obj/item/toy/plush/plush)
	. = ..()
	STOP_FLOATING_ANIM(plush)
	plush.visible_message(span_notice("[plush] stops floating."))






/datum/plush_trait/energetic
	name = "Estiferous"
	desc = "directly imbues the cloth of the plush with a fragment of the energy of its Cotton. This manifests as a pervasive heat suffusing the plush's surface. Handle with care, and thermally insulative gloves."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/energetic/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/ouched = TRUE
	if(iscarbon(squeezer))
		var/mob/living/carbon/carbsqueezer = squeezer
		if(carbsqueezer.gloves)
			var/obj/item/clothing/gloves/electrician_gloves = carbsqueezer.gloves
			if(electrician_gloves.max_heat_protection_temperature > 360)
				ouched = FALSE
		if(HAS_TRAIT(carbsqueezer, TRAIT_RESISTHEAT) || HAS_TRAIT(carbsqueezer, TRAIT_RESISTHEATHANDS))
			ouched = FALSE
		if(!ouched)
			return
		to_chat(carbsqueezer, span_warning("[plush] burns painfully in your hand!"))
		var/ouchy_arm = (carbsqueezer.get_held_index_of_item(plush) % 2) ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM
		carbsqueezer.apply_damage(1, BURN, ouchy_arm)
		carbsqueezer.emote("gasp")
		carbsqueezer.Stun(1 SECOND)
		carbsqueezer.drop_all_held_items()






/datum/plush_trait/slippery
	name = "Lubricating"
	desc = "causes the plush to become extremely slippery."
	tier = 2
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/slippery/activate(obj/item/toy/plush/plush)
	. = ..()
	plush.AddComponentFrom(REF(src), /datum/component/slippery, 50, SLIDE)

/datum/plush_trait/slippery/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.RemoveComponentSource(REF(src), /datum/component/slippery)






/datum/plush_trait/big
	name = "Sizable"
	desc = "causes the plush to enlarge greatly."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/big/activate(obj/item/toy/plush/plush)
	. = ..()
	plush.w_class += 1
	plush.transform *= 2

/datum/plush_trait/big/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.w_class -= 1
	plush.transform *= 0.5





/datum/plush_trait/sparky
	name = "Electroreceptive"
	desc = "causes the plushie to emit small sparks."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/sparky/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	new /obj/effect/particle_effect/sparks(get_turf(plush))

/datum/plush_trait/wet
	name = "Hydrogenic"
	desc = "causes the plushie to be constantly suffused with water."
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	var/made_resistant = FALSE

/datum/plush_trait/wet/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	var/turf/open/turf = get_turf(plush)
	turf.add_liquid_list(list(/datum/reagent/water = 5), TRUE)

/datum/plush_trait/wet/activate(obj/item/toy/plush/plush)
	. = ..()
	if(!(plush.resistance_flags & FIRE_PROOF))
		plush.resistance_flags |= FIRE_PROOF
		made_resistant = TRUE

/datum/plush_trait/wet/deactivate(obj/item/toy/plush/plush)
	. = ..()
	if(made_resistant)
		plush.resistance_flags &= ~(FIRE_PROOF)
		made_resistant = FALSE




//funny admin suggested traits
/datum/plush_trait/wolfy
	name = "Autoaerolocomotive"
	desc = "The plushie moves towards the first person to hug the plushie after the Shape-string is inserted."
	var/datum/weakref/our_owner
	tier = 2
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY

/datum/plush_trait/wolfy/process_trigger(seconds_per_tick, obj/item/toy/plush/plush)
	if(our_owner.resolve())
		SSmove_manager.move_towards(plush, our_owner.resolve(), 5 SECONDS, TRUE)

/datum/plush_trait/wolfy/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(!our_owner)
		our_owner = WEAKREF(squeezer)
		to_chat(squeezer, "It feels like [plush] is staring at you...")

/datum/plush_trait/puce
	name = "Pucetrifying"
	desc = "releases a wave of... Puce? what the fuck is puce?"
	COOLDOWN_DECLARE(puceify)
	tier = 3

/datum/plush_trait/puce/squeezed(obj/item/toy/plush/plush, mob/living/squeezer)
	if(COOLDOWN_FINISHED(src, puceify))
		for(var/atom/ough in range(5, plush))
			plush.visible_message(span_danger("As [squeezer] hugs [plush], it releases a devastating wave of pucetrifacting energy!"))
			ough.add_atom_colour("#cc8899", FIXED_COLOUR_PRIORITY) // woe, for you are puce forever
			if(isliving(ough))
				to_chat(ough, span_reallybig(span_hypnophrase("P U C E")))
		COOLDOWN_START(src, puceify, 30 SECONDS)




/datum/plush_trait/colorful
	name = "Colorful"
	desc = "makes the plushie cute colors."
	var/our_color
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	tier = 1

/datum/plush_trait/colorful/activate(obj/item/toy/plush/plush)
	. = ..()
	our_color = "#[random_color()]"
	plush.add_atom_colour(our_color, FIXED_COLOUR_PRIORITY)

/datum/plush_trait/colorful/deactivate(obj/item/toy/plush/plush)
	. = ..()
	plush.remove_atom_colour(FIXED_COLOUR_PRIORITY, our_color)

/datum/plush_trait/kind
	name = "Chrysocardiac" // man i love grandeloquence
	desc = "instills love and kindness in the plushie."
	flags = PLUSH_KIND
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/charming
	name = "Argyroglossitic" // wow these are so nuancedly uninspired
	desc = "makes the plushie cuter and more charming than usual."
	flags = PLUSH_CHARMING
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY
	tier = 1

/datum/plush_trait/ugly
	name = "Dysmorphic"
	desc = "makes the plushie conventionally unattractive (by whatever obtuse standards plushies judge attractiveness by)."
	flags = PLUSH_FUGLY
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/hearts_of_iron_four
	name = "Cold-souled"
	desc = "instills stoic resolve."
	flags = PLUSH_STOIC
	tier = 1
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY

/datum/plush_trait/promiscuous
	name = "Meretricious"
	desc = "makes the affected plush scandelous and disloyal"
	flags = PLUSH_PROMISCUOUS
	category = PLUSH_TRAIT_CATEGORY_PERSONALITY
	tier = 1

/datum/plush_trait/bloody
	name = "Haemokinetic"
	desc = "imbues the plushie with the fundamental power of blood."
	category = PLUSH_TRAIT_CATEGORY_PHYSICALITY
	tier = 2



//debuggy tools for admins feeling funny


/obj/item/paper/fluff/plushmagic
	name = "An Abridged Collection Of Notes On Thaumatextilics And The Manipulation Of The Primordial Cotton - 2512"
	default_raw_text = {"
An Abridged Collection Of Notes On Thaumatextilics And The Manipulation Of The Primordial Cotton. Zachary M. Faust PhD, 2512
<br>
<br>Metaphysics:
<br>
<br>Textiles are inherently connected to and manipulative of three fundamental Forces of reality; Cotton, Cloth, and Cord.
The quintessential force of Cotton can be conceptualized to be the primal possibility and base state of the concept of 'all'. The more theorhetically inclined may wish to know that current leading models define Cotton as a subordinal expression of the hermetic <i>Prima Materia</i>, though I, personally, find such advanced theory, being far past what can be converted into practice, to be of negligable import.
The Cloth is a solidified product of the Cotton, inverse to it and formed of it. Where Cotton is motive and meaningless, Cloth is static and purposeful. It is the ordered solidity through which actuallity is derived. Cloth expresses itself directly through physical matter, rather than through immaterial energy. Cloth gives shape and property to Cotton.
The Cloth and Cotton, defined by their inequallity, could not express the universe as they do while alone. Rectifying this is the Cord. Cord is the dynamic binding force. Cotton energizes Cloth and Cloth defines Cotton. Cord holds these arangements in place. Cord is what connects the two forces, weaving together the matters of Cloth and energies of Cotton.
The interplay between Cotton, Cloth, and Cord form the universal base upon which all the cosmos is built. Typically, these forces are, if sometimes detectable, universally invisible. But in some cases, manifestations of their power can form spontaneously.
<br>
<br>
<br> Constructs:
<br>
<br>A fabric-sewn and fiber-stuffed figure, more specifically a stuffed figure containing an unusually high concentration of Cotton, holds known power. Such figures are often incorrectly refered to as 'plushies', though this designation is to be restricted to mundane stuffed objects to reduce confusion with Cotton-suffused objects, which are more correctly refered to as Constructs (some older thaumatextilic works use the term Idols).
Mundane 'plushies' are occasionally suffused with Cotton (the process of Construction ('Idolization')) through exposure to high levels of spatial and temporal disturbance. Potent, focused pulses of such disturbance exibit this property more impactfully. Many engineers' vehement insistance that their burst drive 'runs better with it like that' are products of this phenomenon, their 'lucky charm' having undergone spontaneous Construction as a result of the bluespace pulse exposure.
This effect has been noted in some cases to be so strong (specifically in areas of space with exceptionally thin spatial fabrics) as to induce Construction within minutes of a potential Construct being introduced to an area.
Many tales of cursed toys also stem from inadvertant exposure to the effects of a newly created Construct, the chaotic energies of the Construct's Cotton being broadcast to the world. This tends to create a variety of unusual effects on nearby reality, such as spontaneous energy creation or destruction, manipulation of electromagnetic fields, and alterations to the Cloth of other nearby objects.
<br>
<br>
<br>Anatomy of a Construct:
<br>
<br>A Construct's physical form—be it a toy bear, taxidermized bird, ragdoll, or any other plush-stuffed object—is comprised of three base components, formed at the moment of Construction, each of which is a manifestation of one of the Forces, and each of which is an analogue of the physical structure of the Construct. At that moment, cotton becomes Cotton, cloth becomes Cloth, and cord becomes Cord.
Within the center all Constructs there can be found a loop of something resembling-but-not-quite yarn, typically red in color and faintly luminous. This is the Heart-string, a physical incarnation of the Cord. The Cord also inhabits the literal fiber that is used to stitch the Construct together.
The Heart-string is the binding crux of a Construct, and is immutably linked to it. Stretching across the Heart-string is the Soul-string, typically this is a sort of blueish white, thin and brightly glowing. The Soul-string is Cotton made manifest, the primordial potential which powers the Construct. The stuffing material of a Construct is also suffused with a tiny fraction of the Cotton that the Soul-string is.
Woven between the Heart and Soul strings are the Shape-strings. These may be many and varied, but one is always present and immutably linked to the Soul-string, representing the Cloth that shapes the physical form of the Construct. The material from which a Construct is created is also, of course, made of Cloth. Each Shape-string woven between the Heart and Soul strings expresses some fundamental property ("Shape",  by which the Construct differs from its typical form. The original physical form of the figure Constructed seems to be partially determinative of the Shapes manifested.
These Shape-strings are typically formed at the moment of Construction. Soul-strings, being formed of purposeless energy, are extremely fragile. Attempting to manipulate a Soul-string directly is likely to damage it irreperably and, in any case, would likely yield no result beyond causing frustration and/or injury to the enterprising thaumatexilist. Severing the Soul-string will cause the instant and invariable obliteration of the Construct, as its Cloth ceases to recieve energy from its Cotton and it, thereby, ceases to exist.
Severing the Heart-string will yield similar results, as the Construct's Cloth and Cotton are unbound and thus nonexistent.
<br>
<br>
<br>A Brief Remark On Thaumatextilics As A Legitimate Field Of Study:
<br>
<br>Some less accepting academics condemn my work, and that of my colleagues in the Thaumatextilic sciences. (To whom, incidentally, I credit with a significant portion of the knowledge involved in most of my previous discoveries and those catalogued in this text. I wish particularly to name one Dr. Jay Michaels who's work, both theorhetical and practical, with Cord preservation was intrumental to my later advances in direct Heart-string manipulation instruments.)
Before our research was formalized we had no recognition whatsoever, or often ridicule. They laughed at us, called us mad, so on. Most dismissed our burgeoning practice as nothing more than an immensely elaborate practical joke at the expense of the bursar, a symbol of the inexhaustable catataxia found within every academic institution. Scientific minds can prove to be unbelievably mutable when shown definitive practical proof of the violation of basic thermodynamic models.
Since then we've typically recieved a begrudging acceptance from offical types. The real point I wish to extol here is that just because something is nonsense, does not mean it contains no sense, even if you <i>feel</i> that it cannot be possible. Feelings are not the way of research. (With the possible exception of social psychologists, but Social Psychology is a silly science for silly scientists. Rich, perhaps, coming from the 'teddy-bear guy', but nonetheless true.)
<br>
<br>
<br>Intentional Construct Creation:
<br>
<br>To apply thaumatextilics in any meaningful context would clearly require large amounts of unique Constructs to manipulate and experiment upon. Additionally, when a useful effect of Construction is discovered, one might wish to replicate it.
Fortunately, there are effective procedures to do so. Construction can, as aforementioned, be induced by exposure to powerful high-duration temporal or spatial distortions. But to replicate the existing Shapes of a construct, or even to create combinations of related Shapes, an enterprising thaumatextilist would need to somehow create a copy of an existing Construct. This is, fortunately, achievable.
In some cases, when the Cloth and Cord of two Constructs come into contact, an iota of each Construct's Cotton and Cloth is ripped from the Constructs by the combined binding forces of their Cords, resulting in the coelessence of a Heart-string and subsequently the formation of an entirely new Construct with the Shapes of both source Constructs, and occasionally new Shapes resulting from a combination of those of the original two Constructs.
This is process is typically known as Conglomeration (Some earlier works use 'Genesis', under the disproven notion that the process is spontaneous), and the resulting Construct a Conglomerate ('Child').
Unfortunately, the most effective method my colleagues have so far found for inducing Conglomeration — <i>Cloth bear witness to my truth</i> — is to, and I quote <b>verbatim</b>: 'squeeze the two Constructs against eachother and rub them together suggestively.' ...Weep for us poor sinners, for we shall all be damned at the day of Judgement for what we have wrought.
Excepting the concerning implications of the previous discovery, it is a vital component of practical Thaumatextilics. Just, look away, perhaps. It feels somehow polite.
<br>
<br>
<br>Tugging At The Heart-Strings:
<br>
<br>The manipulation of a Construct's Heart-strings and Shape-strings has been, until very recently, an inexact and largely fruitless endeavor until the release of influential modern research within the prior two decades.
(Research which, if I may be so painfully shallow as to brag, I contributed a not-insignificant fraction of). Others have expounded on these discoveries in more detail in aforementioned works (See 'Methods of preservation of metaphysical binding energies after physical seperation.', written by Jay E. Michaels, PhD and published 2507 if you feel so inclined).
The gist of such is that through the implementation of these modern methodologies, a reliable, practical method of Construct manipulation can be devised. The fundamental instrument in this process is a Heart-string extractor, a tool first divised in a 2507 paper as a theorhetical solution to the problem of Cord dispersal, and then actually invented over the following 5 years.
An extractor is, in effect, a specially prepared set of sewing shears designed to 'seal the leak', as it were, in the linkage between Heart-string and Construct and subsequently between Heart-string and Shape-string. Attempting to simply cut a Construct's Heart-string free of it nigh-invariably results in the disconnection between Heart-string bundle and Construct. This effect is theorhetically interesting in that it is able to create Constructs that continue to exist while devoid of a Heart-string or Soul-string.
These Constructs' Cloth appears to hold a remnant of its physical form though losing its Shapes. Research is currently being conducted into the possibilty of artificial Heart-string and/or Soul-string synthesis using such Constructs.
With the use of a Heart-string extractor, the Heart-string can be excised from the Construct. The Shape-strings can then be carefully seperated from the Heart-string and woven into the Heart-strings of other Constructs. Attempting to perform a Shape transplant in this manner without a heart-string extractor or other Cord-stabilizing implement would most likely lead to the destruction of the Heart-string.

"}

/obj/item/paper/fluff/plushwarning
	name = "A Warning - 17-12-2512"
	desc = "A creased piece of ruled notebook paper, it seems to have been manually ironed out some time after it was written."
	default_raw_text = {"
Stop. We have to stop. None of you understand what we've done NONE OF YOU
<br>They can think. <i>IT</i> can think. Nobody in this fucking department except me seems to be aware of the shit WE'VE ALREADY FOUND
<br>THe Constructs they think they have MINDS    none of you fucks understand what we've been doing all this bullshit with the plush toys and the archaic terminology
\[the handwriting gets noticably sloppier\] DID ANYONE EVER FUCKING CONSIDER WHAT ALL THE ARCHAIC TERMINOLOGY AND PLUSHIE BULLSHIT WAS COMING FROM? EVEN THAT STUPID THING WHERE YOU MAKE CONSTRUCTS BY LIKE, MAKING IT LOOK LIKE THEY'RE FUCKING
<br> We are CURRENTLY CREATING ARTIFICIAL SOULS and we are PUTTING THEM IN FUCKING PLUSH TOYS. WE ARE ACTUALLY FUCKING MAGICIANS. WE HAVE PULLED A METAPHORICAL RABBIT OUT OF OUR ASS.
RABBITS DONT JUST GROW INSIDE OF PEOPLES ASSES YOU KNOW
<br> WE'VE INVENTED NEW LIFE, AND WE'VE TURNED IT INTO FUCKING TEDDY BEARS. THERE ARE ACTUAL REAL SOULS IN THERE THAT WE HAVE FOREVER DAMNED. STOP THIS SHIT NOW, DON'T TELL ANYONE WHAT WE DID. PLEASE.
<br> we are so fucked were SO FUCKED we are making goddamn HOMOUNCULI WE HAVE UNIRONICALLY DISCOVERED THE PHILOSOPHER'S STONE THROUGH MANIPULATION OF THE PRIMA MATERIA AND INSTEAD OF ANYTHING PRODUCTIVE WE ARE USING IT TO MAKE PEOPLE OUT OF PLUSH TOYS
DOES MY FUCKING ID READ "ALCHEMIST" side note the alchemy division is fucking WEIRD who the hell runs that place i have seen people in there drinking weird liquids and then somehow VOMITING PRECIOUS METALS how the hell does that even work what are they DOING down there
<br> I SWEAR ON A MULTITUDE OF GODS THAT THE FUCKINGPLUSHIES ARE HAUNTING ME I CAN <b> HEAR THEM IN MY EYES</b>
<br> What the fuck have we done. NO really seriously    what the fuck have we done WHA T HAVE WE DONE    we are fucked    we are all going to go to hell i'm telling you.
<br>
Jay, if you're reading this, you're a great friend, i really genuinely do respect you, but also FUCK YOU for getting me into this bullshit I AM GOING TO LOSE MY MIND OVER HERE
and THE FUNNIEST PART? THEYRE GIVING ME ANTIPSYCHOTICS     ILL TELL YOU WHATS HAPPENING   NOTHING THEYRE NOT HELPING GOOD FUCKING RIDDANCE TO ME
i feel even SHITTIER THAN I ALREADY DO and like i suck at public speaking i am going to be cringing at my last words as a ghost EXCEPT I WONT BECAUSE WE ARE ALL DEFININELY GOING TO HELL FOR THIS SHIT
<br>
<br>
<br>
<br>
<br>
<br>\[the following, in stark contrast to the rest of the page, is written in beautifully precise cursive\]
<br>To each and every one of my dear colleagues in the Thaumatextilics division, fuck you.
<br>
<br>Sincerely, Zach
"}


