#define WRIST_WRENCH_COMBO "HG"
#define LAUNCH_KICK_COMBO "HD"
#define DROP_KICK_COMBO "DD"
#define KNEE_STOMACH_COMBO "GH"

#define CARP_STYLE_BONUS 20
#define CARP_PRONE_PENALTY 30
#define CARP_MAX_MELEE_DODGE 75
#define CARP_HELD_ITEM_WEIGHT_MALUS 10
#define CARP_MELEE_DODGE_CHANCE(style) clamp(style, 0, CARP_MAX_MELEE_DODGE)
#define CARP_DEFLECT_CHANCE(style) clamp(100 + (style), 0, 100)

/datum/martial_art/the_sleeping_carp
	name = "The Sleeping Carp"
	id = MARTIALART_SLEEPINGCARP
	help_verb = /mob/living/proc/sleeping_carp_help
	display_combos = TRUE
	grab_state_modifier = 1
	var/list/scarp_traits = list(TRAIT_NOGUNS, TRAIT_HARDLY_WOUNDED, TRAIT_NODISMEMBER, TRAIT_HEAVY_SLEEPER, TRAIT_THROW_GUNS, TRAIT_PERFECT_ATTACKER)
	/// List of objects exempt from reducing dodge probabilities
	var/static/list/exempt_objects = list(
		/obj/item/staff/bostaff,
		/obj/item/cane,
		/obj/item/nullrod/claymore/bostaff,
		/obj/item/knife,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/storage/toolbox,
		/obj/item/spear,
		/obj/item/extendohand,
		/obj/item/mop,
		/obj/item/pushbroom,
		/obj/item/melee/baseball_bat,
		/obj/item/toy/plush/carpplushie,
	)
	/// List of worn clothing whose armor doesn't reduce dodge probabilities
	var/static/list/exempt_armor = list(
		/obj/item/clothing/suit/chameleon/syndie_armor,
	)
	var/log_name = "Sleeping Carp" //monke edit start
	var/damage = 30
	var/kick_speed = 0 //how fast you get punted into the stratosphere on launchkick
	var/wounding = 0 //whether or not you get wounded by the attack
	var/zone_message = "" //string for where the attack is targetting
	var/zone = null //where the attack is targetting
	var/stamina_damage = 0
	var/counter = FALSE //monke edit end
	var/instant_grab = FALSE

/datum/martial_art/the_sleeping_carp/activate_style(mob/living/new_holder)
	. = ..()
	new_holder.add_traits(scarp_traits, SLEEPING_CARP_TRAIT)
	RegisterSignal(new_holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_holder, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	new_holder.faction |= FACTION_CARP //:D
	new_holder.grant_language(/datum/language/carptongue, ALL, type)

/datum/martial_art/the_sleeping_carp/deactivate_style(mob/living/remove_from)
	REMOVE_TRAITS_IN(remove_from, SLEEPING_CARP_TRAIT)
	UnregisterSignal(remove_from, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_PRE_BULLET_ACT))
	remove_from.faction -= FACTION_CARP //:(
	if (!QDELING(remove_from))
		remove_from.remove_language(/datum/language/carptongue, ALL, type)
	return ..()

/datum/martial_art/the_sleeping_carp/proc/check_streak(mob/living/attacker, mob/living/defender)
	if(findtext(streak, WRIST_WRENCH_COMBO))
		reset_streak()
		return wrist_wrench(attacker, defender)
	if(findtext(streak, LAUNCH_KICK_COMBO))
		reset_streak()
		launch_kick(attacker, defender)
		return TRUE
	if(findtext(streak, DROP_KICK_COMBO))
		reset_streak()
		drop_kick(attacker, defender)
		return TRUE
	if(findtext(streak, KNEE_STOMACH_COMBO))
		reset_streak()
		return knee_stomach(attacker, defender)
	return FALSE

/// Gnashing Teeth: Harm Grab, twists and possibly breaks the target's arm, disarming them.
/datum/martial_art/the_sleeping_carp/proc/wrist_wrench(mob/living/attacker, mob/living/defender)
	// Determine if our defender is a carbon. If not, we don't wrist wrench
	if(!iscarbon(defender))
		return FALSE

	// Determine if our target has a functioning active arm. If not, return.
	var/obj/item/bodypart/affecting = defender.get_active_hand()

	if(!affecting)
		return FALSE

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	defender.visible_message(
		span_danger("[attacker] violently twists [defender]'s [affecting]!"),
		span_userdanger("[attacker] violently twists your [affecting]!"),
		span_hear("You hear a sickening sound of bone snapping!"),
		null,
		attacker,
	)
	to_chat(attacker, span_danger("You violently twist [defender]'s [affecting]!"))
	playsound(defender, 'sound/items/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "wrist wrenched (Sleeping Carp)")
	defender.apply_damage(20, BRUTE, affecting, wound_bonus = 30)
	defender.drop_all_held_items()
	return TRUE

/// Crashing Wave Kick: Harm Disarm combo, throws people seven tiles backwards
/datum/martial_art/the_sleeping_carp/proc/launch_kick(mob/living/attacker, mob/living/defender, set_damage = TRUE)
	//monke edit start
	if(set_damage)
		damage = 20
		kick_speed = 4
		wounding = CANT_WOUND
		zone_message = "chest"
		zone = BODY_ZONE_CHEST
	var/def_check = defender.getarmor(BODY_ZONE_CHEST, MELEE)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	defender.visible_message(
		span_warning("[attacker] kicks [defender] square in the [zone_message], sending [defender.p_them()] flying!"),
		span_userdanger("You are kicked square in the [zone_message] by [attacker], sending you flying!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', vol = 50, vary = TRUE, extrarange = -1)
	var/atom/throw_target = get_edge_target_turf(defender, attacker.dir)
	defender.throw_at(throw_target, 7, kick_speed, attacker)
	defender.apply_damage(damage, attacker.get_attack_type(), zone, wound_bonus = wounding, blocked = def_check)
	log_combat(attacker, defender, "launchkicked ([log_name])") //monke edit end
	return

/// Keelhaul: Disarm Disarm combo, knocks people down and deals substantial stamina damage, and also discombobulates them. Knocks objects out of their hands if they're already on the ground.
/datum/martial_art/the_sleeping_carp/proc/drop_kick(mob/living/attacker, mob/living/defender, set_damage = TRUE)
	//monke edit start
	if(set_damage)
		stamina_damage = -50
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', vol = 50, vary = TRUE, extrarange = -1)
	if(defender.body_position == STANDING_UP)
		defender.Knockdown(2 SECONDS)
		defender.visible_message(
			span_warning("[attacker] kicks [defender] in the head, sending [defender.p_them()] face first into the floor!"),
			span_userdanger("You are kicked in the head by [attacker], sending you crashing to the floor!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
	else
		defender.drop_all_held_items()
		defender.visible_message(
			span_warning("[attacker] kicks [defender] in the head!"),
			span_userdanger("You are kicked in the head by [attacker]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
	defender.stamina.adjust(stamina_damage)
	defender.adjust_dizzy_up_to(10 SECONDS, 10 SECONDS)
	defender.adjust_temp_blindness_up_to(2 SECONDS, 10 SECONDS)
	log_combat(attacker, defender, "dropkicked ([log_name])") //monke edit end
	return

/// Kraken Wrack: Grab Harm combo, causes them to be silenced and briefly stunned, as well as doing a moderate amount of stamina damage.
/datum/martial_art/the_sleeping_carp/proc/knee_stomach(mob/living/attacker, mob/living/defender)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_KICK)
	playsound(attacker, 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	defender.visible_message(
		span_warning("[attacker] violently slams [attacker.p_their()] knee into [defender]!"),
		span_userdanger("[attacker] violently slams [attacker.p_their()] knee into your stomach!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		attacker,
	)
	to_chat(attacker, span_danger("You slam your knee straight into [defender]!"))
	defender.apply_damage(20, STAMINA)
	defender.Paralyze(1 SECONDS)
	defender.adjust_silence_up_to(5 SECONDS, 5 SECONDS)
	if(defender.losebreath <= 10)
		defender.losebreath = clamp(defender.losebreath + 5, 0, 10)
	log_combat(attacker, defender, "kneed in the stomach (Sleeping Carp)")
	return TRUE

/datum/martial_art/the_sleeping_carp/grab_act(mob/living/attacker, mob/living/defender)
	var/old_grab_state = attacker.grab_state
	if(!can_deflect(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID

	if(defender.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return TRUE
	var/grab_log_description = "grabbed"
	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/punch1.ogg', vol = 25, vary = TRUE, extrarange = -1)
	if(defender.stat != DEAD && !defender.IsUnconscious() && defender.getStaminaLoss() >= 80) //We put our target to sleep.
		defender.visible_message(
			span_danger("[attacker] carefully pinch a nerve in [defender]'s neck, knocking [defender.p_them()] out cold"),
			span_userdanger("[attacker] pinches something in your neck, and you fall unconscious!"),
		)
		grab_log_description = "grabbed and nerve pinched"
		defender.Unconscious(10 SECONDS)
		if(old_grab_state == GRAB_PASSIVE || old_grab_state == GRAB_AGGRESSIVE && instant_grab == TRUE)
			attacker.setGrabState(GRAB_NECK)
			INVOKE_ASYNC(defender, TYPE_PROC_REF(/mob/living, grabbedby), attacker, 1)
			log_combat(attacker, defender, "grabbed", addition="by the neck")
			defender.visible_message(span_warning("[attacker] violently grabs [defender]!"), \
			span_userdanger("You're grabbed violently by [attacker]!"), span_hear("You hear sounds of aggressive fondling!"), COMBAT_MESSAGE_RANGE, attacker)
			to_chat(attacker, span_danger("You violently grab [defender]!"))
	defender.adjustStaminaLoss(25)
	log_combat(attacker, defender, "[grab_log_description] (Sleeping Carp)")
	return MARTIAL_ATTACK_INVALID // normal grab

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/attacker, mob/living/defender)
	if(attacker.grab_state == GRAB_KILL \
		&& attacker.zone_selected == BODY_ZONE_HEAD \
		&& attacker.pulling == defender \
		&& defender.stat != DEAD \
	)
		var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)
		if(!isnull(head))
			playsound(defender, 'sound/effects/wounds/crack1.ogg', vol = 100)
			defender.visible_message(
				span_danger("[attacker] snaps the neck of [defender]!"),
				span_userdanger("Your neck is snapped by [attacker]!"),
				span_hear("You hear a sickening snap!"),
				ignored_mobs = attacker,
			)
			to_chat(attacker, span_danger("In a swift motion, you snap the neck of [defender]!"), type = MESSAGE_TYPE_COMBAT)
			log_combat(attacker, defender, "snapped neck")
			defender.apply_damage(100, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND)
			if(!HAS_TRAIT(defender, TRAIT_NODEATH))
				defender.death()
				defender.investigate_log("has had [defender.p_their()] neck snapped by [attacker].", INVESTIGATE_DEATHS)
			return MARTIAL_ATTACK_SUCCESS

	if(defender.check_block(attacker, 10, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_INVALID // normal punch

/datum/martial_art/the_sleeping_carp/disarm_act(mob/living/attacker, mob/living/defender)
	if(!can_deflect(attacker)) //allows for deniability
		return MARTIAL_ATTACK_INVALID
	if(defender.check_block(attacker, 0, attacker.name, UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return TRUE

	attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
	playsound(defender, 'sound/items/weapons/punch1.ogg', vol = 25, vary = TRUE, extrarange = -1)
	defender.adjustStaminaLoss(25)
	log_combat(attacker, defender, "disarmed ([log_name])") //monke edit
	return MARTIAL_ATTACK_INVALID // normal disarm

/datum/martial_art/the_sleeping_carp/proc/can_deflect(mob/living/carp_user, check_intent = TRUE)
	if(!can_use(carp_user))
		return FALSE
	if(check_intent && !(carp_user.istate & ISTATE_HARM)) // monke edit: istates/intents
		return FALSE
	if(carp_user.incapacitated(IGNORE_GRAB)) //NO STUN
		return FALSE
	if(!(carp_user.mobility_flags & MOBILITY_USE)) //NO UNABLE TO USE
		return FALSE
	var/datum/dna/dna = carp_user.has_dna()
	if(dna?.check_mutation(/datum/mutation/hulk)) //NO HULK
		return FALSE
	if(!isturf(carp_user.loc)) //NO MOTHERFLIPPIN MECHS!
		return FALSE
	return TRUE

/datum/martial_art/the_sleeping_carp/proc/hit_by_projectile(mob/living/carp_user, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(istype(hitting_projectile, /obj/projectile/bullet/harpoon)) // WHITE WHALE HOLY GRAIL
		return NONE

	if(!can_deflect(carp_user))
		return NONE

	var/determine_avoidance = CARP_DEFLECT_CHANCE(carp_style_check(carp_user))
	if(!prob(determine_avoidance))
		return NONE

	carp_user.visible_message(
		span_danger("[carp_user] effortlessly swats [hitting_projectile] aside! [carp_user.p_They()] can block bullets with [carp_user.p_their()] bare hands!"),
		span_userdanger("You deflect [hitting_projectile]!"),
	)
	playsound(carp_user, pick('sound/items/weapons/bulletflyby.ogg', 'sound/items/weapons/bulletflyby2.ogg', 'sound/items/weapons/bulletflyby3.ogg'), vol = 75, vary = TRUE) // monke edit
	hitting_projectile.firer = carp_user
	hitting_projectile.set_angle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED

/// Signal from getting attacked with an item, for a special interaction with touch spells
/datum/martial_art/the_sleeping_carp/proc/on_attackby(mob/living/carbon/human/carp_user, obj/item/melee/touch_attack/touch_weapon, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(touch_weapon) || !can_deflect(carp_user, check_intent = !touch_weapon.dangerous))
		return
	var/datum/action/cooldown/spell/touch/touch_spell = touch_weapon.spell_which_made_us?.resolve()
	// monkestation edit: flavor tweaks
	if(!counter)
		carp_user.visible_message(
			span_danger("[carp_user] carefully dodges [attacker]'s [touch_weapon]!"),
			span_userdanger("You take great care to remain untouched by [attacker]'s [touch_weapon]!"),
			ignored_mobs = list(attacker),
		)
		to_chat(attacker, span_userdanger("[carp_user] carefully dodges your [touch_weapon], remaining completely untouched!"), type = MESSAGE_TYPE_COMBAT)
		carp_user.balloon_alert(attacker, "miss!")
		playsound(carp_user, 'sound/effects/miss.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	else
		carp_user.visible_message(
			span_danger("[carp_user] twists [attacker]'s arm, sending [attacker.p_their()] [touch_weapon] back towards [attacker.p_them()]!"),
			span_userdanger("Making sure to avoid [attacker]'s [touch_weapon], you twist [attacker.p_their()] arm to send it right back at [attacker.p_them()]!"),
			ignored_mobs = list(attacker),
		)
		to_chat(attacker, span_userdanger("[carp_user] swiftly grabs and twists your arm, hitting you with your own [touch_weapon]!"), type = MESSAGE_TYPE_COMBAT)
		INVOKE_ASYNC(carp_user, TYPE_PROC_REF(/atom/movable, say), message = "PATHETIC!", language = /datum/language/common, ignore_spam = TRUE, forced = src)
		if(touch_spell)
			INVOKE_ASYNC(touch_spell, TYPE_PROC_REF(/datum/action/cooldown/spell/touch, do_hand_hit), touch_weapon, attacker, attacker)
	attacker.changeNext_move(CLICK_CD_MELEE)
	// monkestation end
	return COMPONENT_NO_AFTERATTACK

/// If our user has committed to being as nautically radical as they can be, they may be able to avoid incoming attacks.
/datum/martial_art/the_sleeping_carp/check_block(mob/living/carp_user, atom/movable/hitby, damage, attack_text, attack_type, ...)
	if(!can_deflect(carp_user))
		return NONE

	if(attack_type == PROJECTILE_ATTACK || attack_type == THROWN_PROJECTILE_ATTACK)
		return NONE

	var/determine_avoidance = CARP_MELEE_DODGE_CHANCE(carp_style_check(carp_user))
	if(!prob(determine_avoidance))
		return NONE

	carp_user.visible_message(
		span_danger("[carp_user] cleanly avoids [attack_text] with incredible speed!"),
		span_userdanger("You dodge [attack_text]!"),
	)
	playsound(carp_user.loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
	return SUCCESSFUL_BLOCK

/**
 * Determines how 'carp-y' or how 'martial arts-y' we are, granting us the ability to avoid attacks.
 * At a baseline, we will always avoid projectile attacks, but we may not necessarily avoid other attacks.
 * If we wear carp based clothing, or martial arts based clothing, we improve our style factor.
 * If we are a carp mutant, we improve our style factor.
 * If we literally are a carp, we just assume we're very carpy and return our max value.
 * If we wear a lot of armor, we reduce our style factor. Some martial arts or carp items may result in a net neutral bonus.
 * If there is anything in our hands, we're also less likely to avoid attacks.
 */
/datum/martial_art/the_sleeping_carp/proc/carp_style_check(mob/living/carp_user)
	// An evaluation of how 'carp' we are.
	var/style_factor_points = 0

	if(istype(carp_user, /mob/living/basic/space_dragon) || istype(carp_user, /mob/living/basic/carp))
		return 100

	if(!ishuman(carp_user)) // We're not concerned about nonhumans here, we can assume we've covered any relevant mobs by checking for carp.
		return 0

	var/mob/living/carbon/human/human_carp_user = carp_user

	var/obj/item/bodypart/potential_head = human_carp_user.get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/bodypart/potential_chest = human_carp_user.get_bodypart(BODY_ZONE_CHEST)
	var/obj/item/clothing/is_it_the_shoes = human_carp_user.get_item_by_slot(ITEM_SLOT_FEET)

	// The presence of armor and heavy objects is a style malus
	var/style_factor_malus = 0

	// Lets look to see if any relevant headwear is armored or on theme
	if(potential_head)
		for(var/obj/item/clothing/possible_headbands in human_carp_user.get_clothing_on_part(potential_head))
			if(possible_headbands.clothing_flags & CARP_STYLE_FACTOR)
				style_factor_points += CARP_STYLE_BONUS // Basically, you only need one chest level item to contribute
			if(!is_type_in_list(possible_headbands, exempt_armor))
				style_factor_malus += possible_headbands.get_armor_rating(MELEE)

	// Then let's look for any chest clothing that is either armored or on theme
	if(potential_chest)
		for(var/obj/item/clothing/possible_gi in human_carp_user.get_clothing_on_part(potential_chest))
			if(possible_gi.clothing_flags & CARP_STYLE_FACTOR)
				style_factor_points += CARP_STYLE_BONUS // Only need one head level item to contribute
			if(!is_type_in_list(possible_gi, exempt_armor))
				style_factor_malus += possible_gi.get_armor_rating(MELEE)

	// We also consider whether our footwear is appropriate
	if(istype(is_it_the_shoes) && is_it_the_shoes.clothing_flags & CARP_STYLE_FACTOR)
		style_factor_points += CARP_STYLE_BONUS

	// Achieved a carp state of mind.
	if(human_carp_user.has_status_effect(/datum/status_effect/organ_set_bonus/carp))
		style_factor_points += CARP_STYLE_BONUS

	// We check for wielded objects. If they're not abstract items or exempt items, we add their weight as a penalty. And their block chance.
	for(var/obj/item/possibly_a_held_object as anything in human_carp_user.get_held_items())
		if(possibly_a_held_object.item_flags & (ABSTRACT|HAND_ITEM) && !possibly_a_held_object.block_chance)
			continue

		if(is_type_in_list(possibly_a_held_object, exempt_objects))
			continue

		if(possibly_a_held_object.w_class <= WEIGHT_CLASS_SMALL && !possibly_a_held_object.block_chance)
			continue

		style_factor_malus += possibly_a_held_object.block_chance
		style_factor_malus += possibly_a_held_object.w_class * CARP_HELD_ITEM_WEIGHT_MALUS * (HAS_TRAIT(possibly_a_held_object, TRAIT_WIELDED) ? 2 : 1)

	if(human_carp_user.body_position != STANDING_UP) // this ain't monkey style
		style_factor_points -= CARP_PRONE_PENALTY

	style_factor_points -= style_factor_malus

	return style_factor_points

/// Verb added to humans who learn the art of the sleeping carp.
GAME_VERB_PROC_DESC(/mob/living, sleeping_carp_help, "Recall Teachings", "Remember the martial techniques of the Sleeping Carp clan.", "Sleeping Carp")

	to_chat(src, "<b><i>You retreat inward and recall the teachings of the Sleeping Carp...</i></b>\n\
	[span_notice("Gnashing Teeth")]: Punch Grab. Violently twists your opponent's arm, dislocating or even shattering bone and forcing them to drop their held items.\n\
	[span_notice("Crashing Wave Kick")]: Punch Shove. Launch your opponent away from you with incredible force!\n\
	[span_notice("Keelhaul")]: Shove Shove. Nonlethally kick an opponent to the floor, knocking them down, discombobulating them and dealing substantial stamina damage. If they're already prone, disarm them as well.\n\
	[span_notice("Kraken Wrack")]: Grab Punch. Deliver a knee jab into the opponent, dealing high stamina damage, as well as briefly stunning them, winding them and making it difficult for them to speak.\n\
	[span_notice("Grabs and Shoves")]: While in combat mode, your typical grab and shove do decent stamina damage, and your grabs are harder to break. If you grab someone who has substantial amounts of stamina damage, you knock them out!\n\
	<span class='notice'>While in combat mode (and not stunned, not a hulk, and not in a mech), you can reflect all projectiles that come your way, sending them flying in random directions! \n\
	However, your ability to avoid projectiles is negatively affected when you are burdened by armor, or whenever you are carrying normal-sized or heavier objects in your hands. \n\
	But if you commit fully to the martial arts lifestyle by wearing martial arts or carp-related regalia, you will feel empowered enough to potentially avoid attacks even from melee weapons or other unarmed combatants. \n\
	Some melee weapons, such as bo staves, spears, short blades, knives, toolboxes, baseball bats and non-blocking small objects are safe to carry without affecting your ability to defend yourself. Exploit this for a tactical advantage. \n\
	Also, you are more resilient against suffering wounds in combat, and your limbs cannot be dismembered. This grants you extra staying power during extended combat, especially against slashing and other bleeding weapons. \n\
	You are not invincible, however- while you may not suffer debilitating wounds often, you must still watch your health and should have appropriate medical supplies for use during downtime. \n\
	In addition, your training has imbued you with a loathing of guns, and you can no longer use them.</span>")

	var/datum/martial_art/the_sleeping_carp/carp_art = GET_ACTIVE_MARTIAL_ART(src)
	if(!istype(carp_art))
		return
	var/style = carp_art.carp_style_check(src)
	to_chat(src, span_notice("Your current style lets you dodge [CARP_MELEE_DODGE_CHANCE(style)]% of melee attacks and deflect [CARP_DEFLECT_CHANCE(style)]% of projectiles."))

/obj/item/staff/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 2
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "bostaff0"
	icon_angle = -135
	base_icon_state = "bostaff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	block_chance = 50

/obj/item/staff/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 10, \
		force_wielded = 24, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/staff/bostaff/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/staff/bostaff/attack(mob/target, mob/living/user, params)
	add_fingerprint(user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) && prob(50))
		to_chat(user, span_warning("You club yourself over the head with [src]."))
		user.Paralyze(6 SECONDS)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, BODY_ZONE_HEAD)
		else
			user.take_bodypart_damage(2 * force)
		return
	if(iscyborg(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, span_warning("It would be dishonorable to attack a foe while they cannot retaliate."))
		return
	if((user.istate & ISTATE_SECONDARY))
		if(!HAS_TRAIT(src, TRAIT_WIELDED))
			return ..()
		if(!ishuman(target))
			return ..()
		var/mob/living/carbon/human/H = target
		var/list/fluffmessages = list("club", "smack", "broadside", "beat", "slam")
		H.visible_message(span_warning("[user] [pick(fluffmessages)]s [H] with [src]!"), \
						span_userdanger("[user] [pick(fluffmessages)]s you with [src]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
		to_chat(user, span_danger("You [pick(fluffmessages)] [H] with [src]!"))
		playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, TRUE, -1)
		H.stamina.adjust(-10)
		if(prob(10))
			H.visible_message(span_warning("[H] collapses!"), \
							span_userdanger("Your legs give out!"))
			H.Paralyze(8 SECONDS)
		if(H.stamina.loss && !H.IsSleeping())
			var/total_health = (H.health - H.stamina.loss)
			if(total_health <= H.crit_threshold && !H.stat)
				H.visible_message(span_warning("[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"), \
								span_userdanger("You're knocked unconscious by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
				to_chat(user, span_danger("You deliver a heavy hit to [H]'s head, knocking [H.p_them()] out cold!"))
				H.SetSleeping(60 SECONDS)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 15, 150)
	else
		return ..()

/obj/item/staff/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return FALSE

/obj/item/clothing/gloves/the_sleeping_carp
	name = "carp gloves"
	desc = "These gloves are capable of making people use The Sleeping Carp."
	icon_state = "black"
	greyscale_colors = "#000000"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/the_sleeping_carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/the_sleeping_carp)

#undef WRIST_WRENCH_COMBO
#undef LAUNCH_KICK_COMBO
#undef DROP_KICK_COMBO
#undef KNEE_STOMACH_COMBO

#undef CARP_STYLE_BONUS
#undef CARP_PRONE_PENALTY
#undef CARP_MAX_MELEE_DODGE
#undef CARP_HELD_ITEM_WEIGHT_MALUS
#undef CARP_MELEE_DODGE_CHANCE
#undef CARP_DEFLECT_CHANCE
