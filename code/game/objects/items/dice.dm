// don't produce a comment if the dice has less than this many sides
// so you don't have d1's and d4's constantly producing comments
#define MIN_SIDES_ALERT 5

///holding bag for dice
/obj/item/storage/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/toys/dice.dmi'
	icon_state = "dicebag"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/dice/Initialize(mapload)
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/dice))

/obj/item/storage/dice/PopulateContents()
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	var/picked = pick(list(
		/obj/item/dice/d1,
		/obj/item/dice/d2,
		/obj/item/dice/fudge,
		/obj/item/dice/d6/space,
		/obj/item/dice/d00,
		/obj/item/dice/eightbd20,
		/obj/item/dice/fourdd6,
		/obj/item/dice/d100,
	))
	new picked(src)

/obj/item/storage/dice/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/dice/hazard

/obj/item/storage/dice/hazard/PopulateContents()
	new /obj/item/dice/d6(src)
	new /obj/item/dice/d6(src)
	new /obj/item/dice/d6(src)
	for(var/i in 1 to 2)
		if(prob(7))
			new /obj/item/dice/d6/ebony(src)
		else
			new /obj/item/dice/d6(src)

///this is a prototype for dice, for a real d6 use "/obj/item/dice/d6"
/obj/item/dice
	name = "die"
	desc = "A die with six sides. Basic and serviceable."
	icon = 'icons/obj/toys/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY
	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used
	var/microwave_riggable = TRUE

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

	var/roll_on_all_impacts

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_appearance()

/obj/item/dice/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is gambling with death! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/dice/d1
	name = "d1"
	desc = "A die with only one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	// 1d4 damage
	AddComponent(/datum/component/caltrop, min_damage = 1, max_damage = 4)

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/d6/ebony
	name = "ebony die"
	desc = "A die with six sides made of dense black wood. It feels cold and heavy in your hand."
	icon_state = "de6"
	microwave_riggable = FALSE // You can't melt wood in the microwave

/obj/item/dice/d6/space
	name = "space cube"
	desc = "A die with six sides. 6 TIMES 255 TIMES 255 TILE TOTAL EXISTENCE, SQUARE YOUR MIND OF EDUCATED STUPID: 2 DOES NOT EXIST."
	icon_state = "spaced6"

/obj/item/dice/d6/space/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "spess cube"

/obj/item/paper/guides/knucklebone
	name = "knucklebones rules"
	default_raw_text = "How to play knucklebones<br>\
	<ul>\
	<li>Make two 3x3 grids right next to eachother using anything you can find to mark the ground. I like using the bartenders hologram projector.</li>\
	<li>Take turns rolling the dice and moving the dice into one of the three rows on your 3x3 grid.</li>\
	<li>Your goal is to get the most points by putting die of the same number in the same row.</li>\
	<li>If you have two of the same die in the same row, you will add them together and then times the sum by two. Then add that to the rest of the die.</li>\
	<li>If you have three of the same die in the same row, you will do the same thing but times it by three.</li>\
	<li>But if your opponent places a die across from one of your rows, you must remove all die that are the same number.</li>\
	<li>For example, if you have two 5's and a 2 in a row and your opponent places a 5 in the same row you must remove the two 5's from that row.</li>\
	<li>Note that you do not multiply the die if they are in the same collum. Only if they are in the same row.</li>\
	<li>If you find it hard to tell whether it multiplies up and down or left and right, base it off the position of your opponents 3x3.</li>\
	<li>If their rows line up with your rows, those rows are the rows that will multiply your die</li>\
	<li>The game ends when one person fills up their 3x3. The other person does not get to roll the rest of their die.</li>\
	<li>The winner is decided by who gets the most points</li>\
	<li>Have fun!</li>\
	</ul>"
/obj/item/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank" = "You aren't sure how to feel.","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golf ball."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d00/manipulate_result(original)
	return (original - 1)*10  // 10, 20, 30, etc

/obj/item/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	w_class = WEIGHT_CLASS_SMALL
	sides = 100

/obj/item/dice/d100/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/dice/eightbd20
	name = "strange d20"
	desc = "A weird die with raised text printed on the faces. Everything's white on white so reading it is a struggle. What poor design!"
	icon_state = "8bd20"
	sides = 20
	special_faces = list("It is certain","It is decidedly so","Without a doubt","Yes, definitely","You may rely on it","As I see it, yes","Most likely","Outlook good","Yes","Signs point to yes","Reply hazy try again","Ask again later","Better not tell you now","Cannot predict now","Concentrate and ask again","Don't count on it","My reply is no","My sources say no","Outlook not so good","Very doubtful")

/obj/item/dice/eightbd20/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/dice/fourdd6
	name = "4d d6"
	desc = "A die that exists in four dimensional space. Properly interpreting them can only be done with the help of a mathematician, a physicist, and a priest."
	icon_state = "4dd6"
	sides = 48
	special_faces = list("Cube-Side: 1-1","Cube-Side: 1-2","Cube-Side: 1-3","Cube-Side: 1-4","Cube-Side: 1-5","Cube-Side: 1-6","Cube-Side: 2-1","Cube-Side: 2-2","Cube-Side: 2-3","Cube-Side: 2-4","Cube-Side: 2-5","Cube-Side: 2-6","Cube-Side: 3-1","Cube-Side: 3-2","Cube-Side: 3-3","Cube-Side: 3-4","Cube-Side: 3-5","Cube-Side: 3-6","Cube-Side: 4-1","Cube-Side: 4-2","Cube-Side: 4-3","Cube-Side: 4-4","Cube-Side: 4-5","Cube-Side: 4-6","Cube-Side: 5-1","Cube-Side: 5-2","Cube-Side: 5-3","Cube-Side: 5-4","Cube-Side: 5-5","Cube-Side: 5-6","Cube-Side: 6-1","Cube-Side: 6-2","Cube-Side: 6-3","Cube-Side: 6-4","Cube-Side: 6-5","Cube-Side: 6-6","Cube-Side: 7-1","Cube-Side: 7-2","Cube-Side: 7-3","Cube-Side: 7-4","Cube-Side: 7-5","Cube-Side: 7-6","Cube-Side: 8-1","Cube-Side: 8-2","Cube-Side: 8-3","Cube-Side: 8-4","Cube-Side: 8-5","Cube-Side: 8-6")

/obj/item/dice/fourdd6/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(thrown_by || roll_on_all_impacts)
		diceroll(thrown_by)
	return ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(clamp(1/(sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides > MIN_SIDES_ALERT && result == 1)  // less comment spam
		comment = "Ouch, bad luck."
	if(sides == 20 && result == 20)
		comment = "NAT 20!"  // maint wanted this hardcoded to nat20 don't blame me
	update_appearance()
	result = manipulate_result(result)
	if(special_faces.len == sides)
		comment = ""  // its not a number
		result = special_faces[result]
		if(!ISINTEGER(result))
			comment = special_faces[result]  // should be a str now

	if(user != null) //Dice was rolled in someone's hand
		user.visible_message(span_notice("[user] throws [src]. It lands on [result]. [comment]"), \
			span_notice("You throw [src]. It lands on [result]. [comment]"), \
			span_hear("You hear [src] rolling, it sounds like a [fake_result]."))
	else if(!src.throwing) //Dice was thrown and is coming to rest
		visible_message(span_notice("[src] rolls to a stop, landing on [result]. [comment]"))

/obj/item/dice/update_overlays()
	. = ..()
	. += "[icon_state]-[result]"

/obj/item/dice/microwave_act(obj/machinery/microwave/microwave_source, mob/microwaver, randomize_pixel_offset)
	if(microwave_riggable)
		rigged = DICE_BASICALLY_RIGGED
		rigged_value = result

	return ..() | COMPONENT_MICROWAVE_SUCCESS

/// A proc to modify the displayed result. (Does not affect what the icon_state is passed.)
/obj/item/dice/proc/manipulate_result(original)
	return original

// Die of fate stuff
/obj/item/dice/d20/fate
	name = "\improper Die of Fate"
	desc = "A die with twenty sides. You can feel unearthly energies radiating from it. Using this might be VERY risky."
	icon_state = "d20"
	sides = 20
	microwave_riggable = FALSE
	var/reusable = TRUE
	var/used = FALSE
	/// So you can't roll the die 20 times in a second and stack a bunch of effects that might conflict
	COOLDOWN_DECLARE(roll_cd)

/obj/item/dice/d20/fate/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/cursed
	name = "cursed Die of Fate"
	desc = "A die with twenty sides. You feel that rolling this is a REALLY bad idea."
	color = "#00BB00"

	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/cursed/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/stealth
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."

/obj/item/dice/d20/fate/stealth/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/stealth/cursed
	rigged = DICE_TOTALLY_RIGGED
	rigged_value = 1

/obj/item/dice/d20/fate/stealth/cursed/one_use
	reusable = FALSE

/obj/item/dice/d20/fate/diceroll(mob/user)
	if(!COOLDOWN_FINISHED(src, roll_cd))
		to_chat(user, span_warning("Hold on, [src] isn't caught up with your last roll!"))
		return

	. = ..()
	if(used)
		return

	if(!ishuman(user) || !user.mind || IS_WIZARD(user))
		to_chat(user, span_warning("You feel the magic of the dice is restricted to ordinary humans!"))
		return

	if(!reusable)
		used = TRUE

	var/turf/selected_turf = get_turf(src)
	selected_turf.visible_message(span_userdanger("[src] flares briefly."))

	addtimer(CALLBACK(src, PROC_REF(effect), user, .), 1 SECONDS)
	COOLDOWN_START(src, roll_cd, 2.5 SECONDS)

/obj/item/dice/d20/fate/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user) || !user.mind || IS_WIZARD(user))
		to_chat(user, span_warning("You feel the magic of the dice is restricted to ordinary humans! You should leave it alone."))
		user.dropItemToGround(src)


/obj/item/dice/d20/fate/proc/effect(mob/living/carbon/human/user,roll)
	var/turf/selected_turf = get_turf(src)
	switch(roll)
		if(1)
			//Dust
			selected_turf.visible_message(span_userdanger("[user] turns to dust!"))
			user.investigate_log("has been dusted by a die of fate.", INVESTIGATE_DEATHS)
			user.dust()
		if(2)
			//Death
			selected_turf.visible_message(span_userdanger("[user] suddenly dies!"))
			user.investigate_log("has been killed by a die of fate.", INVESTIGATE_DEATHS)
			user.death()
		if(3)
			//Swarm of creatures
			selected_turf.visible_message(span_userdanger("A swarm of creatures surrounds [user]!"))
			for(var/direction in GLOB.alldirs)
				var/turf/stepped_turf = get_step(get_turf(user), direction)
				do_sparks(3, FALSE, stepped_turf)
				new /mob/living/basic/creature(stepped_turf)
		if(4)
			//Destroy Equipment
			selected_turf.visible_message(span_userdanger("Everything [user] is holding and wearing disappears!"))
			for(var/obj/item/non_implant in user)
				if(istype(non_implant, /obj/item/implant))
					continue
				qdel(non_implant)
		if(5)
			//Monkeying
			selected_turf.visible_message(span_userdanger("[user] transforms into a monkey!"))
			user.monkeyize()
		if(6)
			//Cut speed
			selected_turf.visible_message(span_userdanger("[user] starts moving slower!"))
			user.add_movespeed_modifier(/datum/movespeed_modifier/die_of_fate)
		if(7)
			//Throw
			selected_turf.visible_message(span_userdanger("Unseen forces throw [user]!"))
			user.Stun(60)
			user.adjustBruteLoss(50)
			var/throw_dir = pick(GLOB.cardinals)
			var/atom/throw_target = get_edge_target_turf(user, throw_dir)
			user.throw_at(throw_target, 200, 4)
		if(8)
			//Fuel tank Explosion
			selected_turf.visible_message(span_userdanger("An explosion bursts into existence around [user]!"))
			explosion(get_turf(user), devastation_range = -1, light_impact_range = 2, flame_range = 2, explosion_cause = src)
		if(9)
			//Cold
			selected_turf.visible_message(span_userdanger("[user] looks a little under the weather!"))
			var/virus_choice = pick(WILD_ACUTE_DISEASES)
			var/list/anti = list(
				ANTIGEN_BLOOD	= 1,
				ANTIGEN_COMMON	= 1,
				ANTIGEN_RARE	= 2,
				ANTIGEN_ALIEN	= 0,
				)
			var/list/bad = list(
				EFFECT_DANGER_HELPFUL	= 0,
				EFFECT_DANGER_FLAVOR	= 1,
				EFFECT_DANGER_ANNOYING	= 2,
				EFFECT_DANGER_HINDRANCE	= 3,
				EFFECT_DANGER_HARMFUL	= 1,
				EFFECT_DANGER_DEADLY	= 0,
				)
			var/datum/disease/acute/new_disease = new virus_choice
			new_disease.makerandom(list(50,90),list(50,100),anti,bad,src)
			user.infect_disease(new_disease, TRUE, "(Die of Fate 7)")

		if(10)
			//Nothing
			selected_turf.visible_message(span_userdanger("Nothing seems to happen."))
		if(11)
			//Cookie
			selected_turf.visible_message(span_userdanger("A cookie appears out of thin air!"))
			var/obj/item/food/cookie/C = new(drop_location())
			do_smoke(0, holder = src, location = drop_location())
			C.name = "Cookie of Fate"
		if(12)
			//Healing
			selected_turf.visible_message(span_userdanger("[user] looks very healthy!"))
			user.revive(ADMIN_HEAL_ALL, revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
		if(13)
			//Mad Dosh
			selected_turf.visible_message(span_userdanger("Mad dosh shoots out of [src]!"))
			var/turf/Start = get_turf(src)
			for(var/direction in GLOB.alldirs)
				var/turf/dirturf = get_step(Start,direction)
				if(prob(50))
					new /obj/item/stack/spacecash/c1000(dirturf)
					continue
				var/obj/item/storage/bag/money/bag_money = new(dirturf)
				for(var/i in 1 to rand(5,50))
					new /obj/item/coin/gold(bag_money)
		if(14)
			//Free Gun
			selected_turf.visible_message(span_userdanger("An impressive gun appears!"))
			do_smoke(0, holder = src, location = drop_location())
			new /obj/item/gun/ballistic/revolver/mateba(drop_location())
		if(15)
			//Random One-use spellbook
			selected_turf.visible_message(span_userdanger("A magical looking book drops to the floor!"))
			do_smoke(0, holder = src, location = drop_location())
			new /obj/item/book/granter/action/spell/random(drop_location())
		if(16)
			//Servant & Servant Summon
			selected_turf.visible_message(span_userdanger("A Dice Servant appears in a cloud of smoke!"))
			var/mob/living/carbon/human/human_servant = new(drop_location())
			do_smoke(0, holder = src, location = drop_location())

			var/mob/chosen_one = SSpolling.poll_ghosts_for_target("Do you want to play as [span_danger("[user.real_name]'s")] [span_notice("Servant")]?", check_jobban = ROLE_WIZARD, role = ROLE_WIZARD, poll_time = 5 SECONDS, checked_target = human_servant, alert_pic = user, role_name_text = "dice servant")
			if(chosen_one)
				message_admins("[ADMIN_LOOKUPFLW(chosen_one)] was spawned as Dice Servant")
				human_servant.PossessByPlayer(chosen_one.key)

			human_servant.equipOutfit(/datum/outfit/butler)
			var/datum/mind/servant_mind = new /datum/mind()
			var/datum/antagonist/magic_servant/servant_antagonist = new
			servant_mind.transfer_to(human_servant)
			servant_antagonist.setup_master(user)
			servant_mind.add_antag_datum(servant_antagonist)

			var/datum/action/cooldown/spell/summon_mob/summon_servant = new(user.mind || user, human_servant)
			summon_servant.Grant(user)

		if(17)
			//Tator Kit
			selected_turf.visible_message(span_userdanger("A suspicious box appears!"))
			new /obj/item/storage/box/syndicate/bundle_a(drop_location())
			do_smoke(0, holder = src, location = drop_location())
		if(18)
			//Captain ID
			selected_turf.visible_message(span_userdanger("A golden identification card appears!"))
			new /obj/item/card/id/advanced/gold/captains_spare(drop_location())
			do_smoke(0, holder = src, location = drop_location())
		if(19)
			//Instrinct Resistance
			selected_turf.visible_message(span_userdanger("[user] looks very robust!"))
			user.physiology.brute_mod *= 0.5
			user.physiology.burn_mod *= 0.5

		if(20)
			//Free wizard!
			selected_turf.visible_message(span_userdanger("Magic flows out of [src] and into [user]!"))
			user.mind.make_wizard()

/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit/black_really
	neck = /obj/item/clothing/neck/tie/red/tied
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white

/datum/action/cooldown/spell/summon_mob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	button_icon_state = "summons"

	school = SCHOOL_CONJURATION
	cooldown_time = 10 SECONDS

	invocation = "JE VES"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	spell_max_level = 0 //cannot be improved

	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 2

	var/datum/weakref/summon_weakref

/datum/action/cooldown/spell/summon_mob/New(Target, mob/living/summoned_mob)
	. = ..()
	if(summoned_mob)
		summon_weakref = WEAKREF(summoned_mob)

/datum/action/cooldown/spell/summon_mob/cast(atom/cast_on)
	. = ..()
	var/mob/living/to_summon = summon_weakref?.resolve()
	if(QDELETED(to_summon))
		to_chat(cast_on, span_warning("You can't seem to summon your servant - it seems they've vanished from reality, or never existed in the first place..."))
		return

	do_teleport(
		to_summon,
		get_turf(cast_on),
		precision = 1,
		asoundin = 'sound/magic/wand_teleport.ogg',
		asoundout = 'sound/magic/wand_teleport.ogg',
		channel = TELEPORT_CHANNEL_MAGIC,
	)
/proc/dicesplosion(atom/A, num_dice, multiplier=1, additive=0, obj/item/dice/die_type=/obj/item/dice/d6, throwing_distance=3, do_balloon_alert=TRUE, delay=1, delete_delay=1)
	var/max_per_die = die_type::sides
	var/final_result = 0
	var/our_list_of_dice = list()
	for(var/i in 1 to num_dice)
		var/ourdir = pick(GLOB.alldirs)
		var/obj/item/dice/our_current_die = new(get_step(A, ourdir), die_type)
		var/our_number = rand(1, max_per_die)
		final_result += our_number
		our_current_die.resistance_flags |= INDESTRUCTIBLE
		our_current_die.rigged = DICE_TOTALLY_RIGGED
		our_current_die.rigged_value = our_number
		our_current_die.roll_on_all_impacts = TRUE
		var/ourrange = rand(1, throwing_distance)
		our_current_die.throw_at(get_edge_target_turf(A, get_dir(A, our_current_die)), ourrange, 3, spin=TRUE)
		our_list_of_dice += our_current_die
	final_result *= multiplier
	final_result += additive
	sleep(delay SECONDS)
	if(do_balloon_alert)
		var/the_message = "[num_dice]d[max_per_die]"
		if(multiplier != 1)
			the_message += " [(multiplier >= 1) ? "*" : "/"] [multiplier]"
		if(additive)
			the_message += " [(additive >= 0) ? "+" : "-"] [additive]"
		the_message += " = [final_result]"
		A.balloon_alert_to_viewers(the_message)
	for(var/this_die in our_list_of_dice)
		QDEL_IN(this_die, delete_delay SECONDS)
	return final_result

/obj/item/toy/toy_dagger/dnd
	name = "\improper Dungeoneer's Dagger"
	desc = "A strange relic, recovered from an ancient warehouse belonging to \"Piezo Inc.\", whoever they were." //and you thought it was a DND joke... but it was I... PATHFINDER
	inhand_icon_state = ""
	w_class = WEIGHT_CLASS_SMALL
	override_notes = TRUE
	sharpness = SHARP_POINTY
	tool_behaviour = TOOL_KNIFE
	force_string = "Extremely robust... when backstabbing"

	///our power
	var/sneak_attack_dice = 12
	var/damage_mult = 1.5
	var/flat_bonus = 5 //they have really good dex iunno
	var/funny_alert_message = "SNEAK ATTACK!"
	var/backstab_time = 1 SECOND
	var/list/modes = list("lethal", "nonlethal", "lucky")
	var/mode_number = 1
	var/mode = "lethal"

/obj/item/toy/toy_dagger/dnd/Initialize(mapload)
	. = ..()
	offensive_notes = "Deals [sneak_attack_dice]d6[(damage_mult != 1) ? " * [damage_mult]" : "" ][(flat_bonus != 0) ? " + [flat_bonus]" : ""] brute damage when stabbing from behind. This takes a few seconds."
	ADD_TRAIT(src, TRAIT_EXAMINE_SKIP, TRAIT_GENERIC)

/obj/item/toy/toy_dagger/dnd/attack_self(mob/user)
	if(mode_number < modes.len)
		mode_number++
	else
		mode_number = 1
	switch(modes[mode_number])
		if("lethal")
			mode = "lethal"
			to_chat(user, "[src] is now in lethal mode.")
		if("nonlethal")
			mode = "nonlethal"
			to_chat(user, "[src] is now in stunning mode.")
		if("lucky")
			mode = "lucky"
			to_chat(user, "[src] is now in test-your-luck mode.")

/obj/item/toy/toy_dagger/dnd/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(!ishuman(interacting_with) || HAS_TRAIT(interacting_with, TRAIT_GODMODE))
		user.balloon_alert(user, "cant backstab that")
		return ITEM_INTERACT_BLOCKING
	var/mob/living/carbon/human/stabbystabbed = interacting_with
	var/backstab_dir = get_dir(user, stabbystabbed)
	// Backstab bonus
	if(!((user.dir & backstab_dir) && (stabbystabbed.dir & backstab_dir)))
		user.balloon_alert(user, "must backstab")
		return ITEM_INTERACT_BLOCKING
	if(do_after(user, backstab_time, stabbystabbed))
		if(!((user.dir & backstab_dir) && (stabbystabbed.dir & backstab_dir)))
			user.balloon_alert(user, "must backstab")
			return ITEM_INTERACT_BLOCKING
		else
			stabbystabbed.balloon_alert_to_viewers(funny_alert_message)
			do_the_stab(stabbystabbed, user, mode)
			return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/toy/toy_dagger/dnd/proc/do_the_stab(mob/living/carbon/human/stabbed, mob/living/user, mode)
	if(mode == "lethal")
		var/datum/callback/sneakycallback = CALLBACK(src, GLOBAL_PROC_REF(dicesplosion), stabbed, sneak_attack_dice, damage_mult, flat_bonus, /obj/item/dice/d6, 2, TRUE, 2, 2)
		var/sneak_attack_damage = sneakycallback.Invoke()
		var/obj/item/bodypart/back_that_we_stab = stabbed.get_bodypart(BODY_ZONE_CHEST)
		back_that_we_stab.receive_damage(brute=sneak_attack_damage, sharpness=src.sharpness, bare_wound_bonus=40)

	if(mode == "nonlethal")
		stabbed.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_GODMODE, TRAIT_MUTE, TRAIT_EMOTEMUTE, TRAIT_NOBREATH, TRAIT_STASIS), DND_DAGGER_FX_TRAIT)
		DO_FLOATING_ANIM(stabbed)
		var/datum/callback/saving_throw_roller = CALLBACK(src, GLOBAL_PROC_REF(dicesplosion), stabbed, 1, 1, 0, /obj/item/dice/d20, 1, TRUE, 1.5, 0.5)
		stabbed.balloon_alert_to_viewers("mute 3 rounds: Will DC 16 reduces") //round is 6 seconds *nod
		var/will_saving_throw = saving_throw_roller.Invoke()
		stabbed.balloon_alert_to_viewers("Paralyze 2 rounds: Fortitude DC 14 negates") //round is 6 seconds *nod
		var/fort_saving_throw = saving_throw_roller.Invoke()
		stabbed.balloon_alert_to_viewers("Sleep 1 round: Reflex DC 12 negates") //round is 6 seconds *nod
		var/reflex_saving_throw = saving_throw_roller.Invoke()
		STOP_FLOATING_ANIM(stabbed)
		stabbed.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_GODMODE, TRAIT_MUTE, TRAIT_EMOTEMUTE, TRAIT_NOBREATH, TRAIT_STASIS), DND_DAGGER_FX_TRAIT)
		if(will_saving_throw >= 16 - (HAS_TRAIT(stabbed, TRAIT_MINDSHIELD) ? 6 : 0)) // mindshields are a Will bonus now iunno
			ADD_TRAIT(stabbed, TRAIT_SOFTSPOKEN, type)
			addtimer(TRAIT_CALLBACK_REMOVE(stabbed, TRAIT_SOFTSPOKEN, type), 18 SECONDS)
		else
			ADD_TRAIT(stabbed, TRAIT_MUTE, type)
			addtimer(TRAIT_CALLBACK_REMOVE(stabbed, TRAIT_MUTE, type), 18 SECONDS)
		if(fort_saving_throw < 14 - (HAS_TRAIT(stabbed, TRAIT_BATON_RESISTANCE) ? 4 : 0))
			stabbed.Paralyze(12 SECONDS)
		if(reflex_saving_throw < 14 - (HAS_TRAIT(stabbed, TRAIT_LIGHT_SLEEPER) ? 4 : 0))
			stabbed.Unconscious(6 SECONDS)

	if(mode == "lucky")
		stabbed.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_GODMODE, TRAIT_NOBREATH, TRAIT_STASIS), DND_DAGGER_FX_TRAIT)
		DO_FLOATING_ANIM(stabbed)
		var/datum/callback/kerplodydice = CALLBACK(src, GLOBAL_PROC_REF(dicesplosion), stabbed, 1, 1, 0, /obj/item/dice/d20, 1, TRUE, 5, 5)
		stabbed.balloon_alert_to_viewers("Damage: d1, Crit Damage Mult: 7e500") //shit kills you so hard your soul dies too
		var/explosion_roll = kerplodydice.Invoke()
		if(explosion_roll == 20) //UTTERLY HILLARIOUS I TELL YOU
			stabbed.balloon_alert_to_viewers("...Uh oh.")
			to_chat(stabbed, span_userdanger("Uh oh."))
			new /obj/effect/temp_visual/circle_wave/dndagger(get_turf(stabbed))
			sleep(5 SECONDS)
			var/obj/item/dice/d20/our_souviner = new(stabbed.loc)
			var/initials = ""
			var/list/our_name_list = splittext(stabbed.real_name, " ")
			if(our_name_list.len == 1)
				initials += uppertext(our_name_list[1][1])
				initials += uppertext(our_name_list[1][2])
				initials += "."
			else
				initials += uppertext(our_name_list[1][1])
				initials += "."
				initials += uppertext(our_name_list[2][1])
				initials += "."
			our_souviner.name = "\improper Isocahedral Memento"
			our_souviner.desc = "A die with twenty sides. It feels sad, somehow. The letters [span_hypnophrase(initials)] are carved where the twenty should be."
			our_souviner.resistance_flags |= INDESTRUCTIBLE
			our_souviner.special_faces = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", span_hypnophrase(initials))
			if(stabbed.mind)
				var/obj/item/soulstone/anybody/stone = new(our_souviner)
				stone.resistance_flags |= INDESTRUCTIBLE
				stone.capture_soul(stabbed, forced=TRUE)
				for(var/mob/living/basic/shade/die_prisoner in stone.contents)
					ADD_TRAIT(die_prisoner, TRAIT_SOFTSPOKEN, REF(our_souviner))
					die_prisoner.name = stabbed.real_name
					die_prisoner.real_name = stabbed.real_name
					die_prisoner.mind.add_antag_datum(/datum/antagonist/shade_imprisoned)
					to_chat(die_prisoner, span_hypnophrase("Your soul writhes and buckles as a surge of metaphysical probability evaporates your body!"))
					to_chat(die_prisoner, span_hypnophrase("And yet, you persist. Trapped, forever and <i>ad infinitum</i>, within the very thing that doomed you."))
					to_chat(die_prisoner, span_hypnophrase(span_reallybig("You cannot kill a spirit, but you can certainly make it bleed.")))
			else
				stabbed.dust(TRUE, FALSE, TRUE) //you ded big time
		else
			STOP_FLOATING_ANIM(stabbed)
			stabbed.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_GODMODE, TRAIT_NOBREATH, TRAIT_STASIS), DND_DAGGER_FX_TRAIT)
			var/obj/item/bodypart/back_that_we_stab = stabbed.get_bodypart(BODY_ZONE_CHEST)
			back_that_we_stab.receive_damage(brute=1)
#undef MIN_SIDES_ALERT
