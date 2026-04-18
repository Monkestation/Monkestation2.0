//This file contains all Lavaland megafauna loot. Does not include crusher trophies.


//Hierophant: Hierophant Club

#define HIEROPHANT_BLINK_RANGE 5
#define HIEROPHANT_BLINK_COOLDOWN (15 SECONDS)

/datum/action/innate/dash/hierophant
	current_charges = 1
	max_charges = 1
	charge_rate = HIEROPHANT_BLINK_COOLDOWN
	recharge_sound = null
	phasein = /obj/effect/temp_visual/hierophant/blast/visual
	phaseout = /obj/effect/temp_visual/hierophant/blast/visual
	// It's a simple purple beam, works well enough for the purple hiero effects.
	beam_effect = "plasmabeam"
	teleport_channel = TELEPORT_CHANNEL_MAGIC

/datum/action/innate/dash/hierophant/teleport(mob/user, atom/target)
	var/dist = get_dist(user, target)
	if(dist > HIEROPHANT_BLINK_RANGE)
		user.balloon_alert(user, "destination out of range!")
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf_ignore_climbable())
		user.balloon_alert(user, "destination blocked!")
		return FALSE

	. = ..()
	var/obj/item/hierophant_club/club = target
	if(!istype(club))
		return

	club.update_appearance(UPDATE_ICON_STATE)

/datum/action/innate/dash/hierophant/charge()
	. = ..()
	var/obj/item/hierophant_club/club = target
	if(!istype(club))
		return

	club.update_appearance(UPDATE_ICON_STATE)

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical teleportation feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	inhand_icon_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	attack_verb_continuous = list("clubs", "beats", "pummels")
	attack_verb_simple = list("club", "beat", "pummel")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	actions_types = list(/datum/action/item_action/vortex_recall)
	action_slots = ALL
	/// Linked teleport beacon for the group teleport functionality.
	var/obj/effect/hierophant/beacon
	/// TRUE if currently doing a teleport to the beacon, FALSE otherwise.
	var/teleporting = FALSE //if we ARE teleporting
	/// Action enabling the blink-dash functionality.
	var/datum/action/innate/dash/hierophant/blink
	/// Whether the blink ability is activated. IF TRUE, left clicking a location will blink to it. If FALSE, this is disabled.
	var/blink_activated = TRUE

/obj/item/hierophant_club/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	blink = new(src)

/obj/item/hierophant_club/Destroy()
	QDEL_NULL(blink)
	return ..()

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += span_hierophant_warning("The[beacon ? " beacon is not currently":"re is a beacon"] attached.")

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message(span_suicide("[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlockopen.ogg', 75, TRUE)
	user.visible_message(span_hierophant_warning("[user] fades out, leaving [user.p_their()] belongings behind!"))
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		new /obj/effect/temp_visual/hierophant/blast/visual(T, user, TRUE)
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/attack_self(mob/user)
	blink_activated = !blink_activated
	to_chat(user, span_notice("You [blink_activated ? "enable" : "disable"] the blink function on [src]."))

/obj/item/hierophant_club/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// If our target is the beacon and the hierostaff is next to the beacon, we're trying to pick it up.
	if(interacting_with == beacon)
		return NONE
	if(blink_activated)
		blink.teleport(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/hierophant_club/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(blink_activated)
		blink.teleport(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/hierophant_club/update_icon_state()
	icon_state = inhand_icon_state = "hierophant_club[blink?.current_charges > 0 ? "_ready":""][(!QDELETED(beacon)) ? "":"_beacon"]"
	return ..()

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		to_chat(user, span_warning("You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!"))
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message(span_hierophant_warning("[user] starts fiddling with [src]'s pommel..."), \
			span_notice("You start detaching the hierophant beacon..."))
			if(do_after(user, 5 SECONDS, target = user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, TRUE, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_mob_action_buttons()
				user.visible_message(span_hierophant_warning("[user] places a strange machine beneath [user.p_their()] feet!"), \
				"[span_hierophant("You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!")]\n\
				[span_notice("You can remove the beacon to place it again by striking it with the club.")]")
		else
			to_chat(user, span_warning("You need to be on solid ground to detach the beacon!"))
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, span_warning("You are too close to the beacon to teleport to it!"))
		return
	var/turf/beacon_turf = get_turf(beacon)
	if(beacon_turf?.is_blocked_turf(TRUE))
		to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You don't have enough space to teleport from here!"))
		return
	teleporting = TRUE //start channel
	user.update_mob_action_buttons()
	user.visible_message(span_hierophant_warning("[user] starts to glow faintly..."))
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 4 SECONDS, target = user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_mob_action_buttons()
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, TRUE)
		playsound(source,'sound/machines/airlockopen.ogg', 200, TRUE)
		if(!do_after(user, 0.3 SECONDS, target = user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_mob_action_buttons()
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_mob_action_buttons()
			beacon.icon_state = "hierophant_tele_off"
			return
		user.log_message("teleported self from [AREACOORD(source)] to [beacon].", LOG_GAME)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/t in RANGE_TURFS(1, source))
			new /obj/effect/temp_visual/hierophant/blast/visual(t, user, TRUE)
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, PROC_REF(teleport_mob), source, L, T, user)
		sleep(0.6 SECONDS) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_mob_action_buttons()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/teleporting, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, teleporting)) //get position relative to caster
	if(!turf_to_teleport_to || turf_to_teleport_to.is_blocked_turf(TRUE))
		return
	animate(teleporting, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(0.1 SECONDS)
	if(!teleporting)
		return
	teleporting.visible_message(span_hierophant_warning("[teleporting] fades out!"))
	sleep(0.2 SECONDS)
	if(!teleporting)
		return
	var/success = do_teleport(teleporting, turf_to_teleport_to, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	sleep(0.1 SECONDS)
	if(!teleporting)
		return
	animate(teleporting, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(0.1 SECONDS)
	if(!teleporting)
		return
	teleporting.visible_message(span_hierophant_warning("[teleporting] fades in!"))
	if(user != teleporting && success)
		log_combat(user, teleporting, "teleported", null, "from [AREACOORD(source)]")

/obj/item/hierophant_club/pickup(mob/living/user)
	. = ..()
	blink.Grant(user, src)
	user.update_icons()

/obj/item/hierophant_club/dropped(mob/user)
	. = ..()
	blink.Remove(user)
	user.update_icons()

#undef HIEROPHANT_BLINK_RANGE
#undef HIEROPHANT_BLINK_COOLDOWN

//Bubblegum: Mayhem in a Bottle, H.E.C.K. Suit, Soulscythe

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/target in range(7,user))
		target.apply_status_effect(/datum/status_effect/mayhem)
	to_chat(user, span_notice("You shatter the bottle!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!"))
	user.log_message("activated a bottle of mayhem", LOG_ATTACK)
	qdel(src)

/obj/item/clothing/suit/hooded/hostile_environment
	name = "H.E.C.K. suit"
	desc = "Hostile Environment Cross-Kinetic Suit: A suit designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon_state = "hostile_env"
	hoodtype = /obj/item/clothing/head/hooded/hostile_environment
	armor_type = /datum/armor/hooded_hostile_environment

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	clothing_flags = THICKMATERIAL|HEADINTERNALS
	resistance_flags = FIRE_PROOF|LAVA_PROOF|ACID_PROOF
	transparent_protection = HIDESUITSTORAGE|HIDEJUMPSUIT
	allowed = null
	greyscale_colors = "#4d4d4d#808080"
	greyscale_config = /datum/greyscale_config/heck_suit
	greyscale_config_worn = /datum/greyscale_config/heck_suit/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/datum/armor/hooded_hostile_environment
	melee = 70
	bullet = 40
	laser = 10
	energy = 20
	bomb = 50
	fire = 100
	acid = 100

/obj/item/clothing/suit/hooded/hostile_environment/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)
	AddComponent(/datum/component/gags_recolorable)
	allowed = GLOB.mining_suit_allowed

/obj/item/clothing/suit/hooded/hostile_environment/process(seconds_per_tick)
	. = ..()
	var/mob/living/carbon/wearer = loc
	if(istype(wearer) && SPT_PROB(1, seconds_per_tick)) //cursed by bubblegum
		if(prob(7.5))
			wearer.cause_hallucination(/datum/hallucination/oh_yeah, "H.E.C.K suit", haunt_them = TRUE)
		else
			to_chat(wearer, span_warning("[pick("You hear faint whispers.","You smell ash.","You feel hot.","You hear a roar in the distance.")]"))

/obj/item/clothing/head/hooded/hostile_environment
	name = "H.E.C.K. helmet"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	desc = "Hostile Environiment Cross-Kinetic Helmet: A helmet designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon_state = "hostile_env"
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/hooded_hostile_environment

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_flags = SNUG_FIT|THICKMATERIAL
	resistance_flags = FIRE_PROOF|LAVA_PROOF|ACID_PROOF
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH
	actions_types = list()
	greyscale_colors = "#4d4d4d#808080#ff3300"
	greyscale_config = /datum/greyscale_config/heck_helmet
	greyscale_config_worn = /datum/greyscale_config/heck_helmet/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/hooded/hostile_environment/Initialize(mapload)
	. = ..()
	update_appearance()
	AddComponent(/datum/component/butchering/wearable, \
	speed = 0.5 SECONDS, \
	effectiveness = 150, \
	bonus_modifier = 0, \
	butcher_sound = null, \
	disabled = null, \
	can_be_blunt = TRUE, \
	butcher_callback = CALLBACK(src, PROC_REF(consume)), \
	)
	AddElement(/datum/element/radiation_protected_clothing)
	AddComponent(/datum/component/gags_recolorable)

/obj/item/clothing/head/hooded/hostile_environment/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	to_chat(user, span_notice("You feel a bloodlust. You can now butcher corpses with your bare arms."))

/obj/item/clothing/head/hooded/hostile_environment/dropped(mob/user, silent = FALSE)
	. = ..()
	to_chat(user, span_notice("You lose your bloodlust."))

/obj/item/clothing/head/hooded/hostile_environment/proc/consume(mob/living/user, mob/living/butchered)
	if(butchered.mob_biotypes & (MOB_ROBOTIC | MOB_SPIRIT))
		return
	var/health_consumed = butchered.maxHealth * 0.1
	user.heal_ordered_damage(health_consumed, list(BRUTE, BURN, TOX))
	to_chat(user, span_notice("You heal from the corpse of [butchered]."))
	var/datum/client_colour/color = user.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(color, 1 SECONDS)

//Ash Drake: Spectral Blade, Lava Staff, Dragon's Blood

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "spectral"
	inhand_icon_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	SSpoints_of_interest.make_point_of_interest(src)
	AddComponent(/datum/component/butchering, \
	speed = 15 SECONDS, \
	effectiveness = 90, \
	)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.RemoveInvisibility(type)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, span_warning("You just recently called out for aid. You don't want to annoy the spirits!"))
		return
	to_chat(user, span_notice("You call out for aid, attempting to summon spirits to your side."))

	notify_ghosts(
		"[user] is raising [user.p_their()] [name], calling for your help!",
		action = NOTIFY_ORBIT,
		source = user,
		ignore_key = POLL_IGNORE_SPECTRAL_BLADE,
		header = "Spectral blade",
	)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.get_all_contents()
	var/mob/dead/observer/current_spirits = list()
	for(var/thing in contents)
		var/atom/A = thing
		A.transfer_observers_to(src)
	for(var/i in orbiters?.orbiter_list)
		if(!isobserver(i))
			continue
		var/mob/dead/observer/G = i
		ghost_counter++
		G.SetInvisibility(INVISIBILITY_NONE, id = type, priority = INVISIBILITY_PRIORITY_BASIC_ANTI_INVISIBILITY)
		current_spirits |= G
	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.RemoveInvisibility(type)
	spirits = current_spirits
	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()
	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/consumer = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			to_chat(user, span_danger("Your appearance morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities."))
			var/datum/color_palette/generic_colors/located = consumer.dna.color_palettes[/datum/color_palette/generic_colors]
			located.mutant_color = "#A02720"
			consumer.dna.features = list(
				"tail_lizard" = "Dark Tiger",
				"tail_human" = "None",
				"snout" = "Sharp",
				"horns" = "Curled",
				"ears" = "None",
				"wings" = "None",
				"frills" = "None",
				"spines" = "Long",
				"body_markings" = "Dark Tiger Body",
				"legs" = DIGITIGRADE_LEGS,
			)
			consumer.eye_color_left = "#FEE5A3"
			consumer.eye_color_right = "#FEE5A3"
			consumer.set_species(/datum/species/lizard)
		if(2)
			to_chat(user, span_danger("Your flesh begins to melt! Miraculously, you seem fine otherwise."))
			consumer.set_species(/datum/species/skeleton/draconic) //monke edit
		if(3)
			to_chat(user, span_danger("Power courses through you! You can now shift your form at will."))
			var/datum/action/cooldown/spell/shapeshift/dragon/dragon_shapeshift = new(user.mind || user)
			dragon_shapeshift.Grant(user)
		if(4)
			to_chat(user, span_danger("You feel like you could walk straight through lava now."))
			ADD_TRAIT(user, TRAIT_LAVA_IMMUNE, type)

	playsound(user,'sound/items/drink.ogg', 30, TRUE)
	qdel(src)

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "lavastaff"
	inhand_icon_state = "lavastaff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/weapons/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 18
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	attack_verb_continuous = list("sears", "clubs", "burn")
	attack_verb_simple = list("sear", "club", "burn")
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/open/lava/smooth/weak
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/misc/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 10 SECONDS
	var/create_delay = 3 SECONDS
	var/reset_cooldown = 5 SECONDS
	/// Cooldown for when this can be used again.
	COOLDOWN_DECLARE(next_use)
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space/transit, /turf/closed))

/obj/item/lava_staff/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) && (user.istate & ISTATE_HARM))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/lava_staff/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, next_use))
		to_chat(user, span_warning("Wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, next_use))] before using \the [src] again!"))
		return ITEM_INTERACT_BLOCKING
	if(DOING_INTERACTION(user, DOAFTER_SOURCE_LAVA_STAFF))
		to_chat(user, span_warning("You're already using \the [src]!"))
		return ITEM_INTERACT_BLOCKING
	var/turf/target_turf = get_turf(interacting_with)
	if(!isopenturf(target_turf) || is_type_in_typecache(target_turf, banned_turfs))
		return ITEM_INTERACT_BLOCKING
	if(!(target_turf in view(user.client.view, get_turf(user))))
		return ITEM_INTERACT_BLOCKING
	if(islava(target_turf))
		remove_lava(user, target_turf)
	else
		create_lava(user, target_turf)
	return ITEM_INTERACT_SUCCESS

/obj/item/lava_staff/proc/create_lava(mob/living/user, turf/open/target)
	var/obj/effect/temp_visual/lavastaff/lava_visual = new(target)
	animate(lava_visual, alpha = 255, time = create_delay)
	user.visible_message(span_danger("[user] points [src] at [target]!"))
	if(do_after(user, create_delay, target, interaction_key = DOAFTER_SOURCE_LAVA_STAFF))
		var/old_name = target.name
		if(target.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
			// 2x faster on lavaland
			var/cooldown = create_cooldown
			if(is_mining_level(target.z))
				cooldown *= 0.5
			COOLDOWN_START(src, next_use, cooldown)
			user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
			message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(target)]")
			user.log_message("fired the lava staff at [AREACOORD(target)].", LOG_ATTACK)
			playsound(target, 'sound/magic/fireball.ogg', vol = 200, vary = TRUE)
	qdel(lava_visual)

/obj/item/lava_staff/proc/remove_lava(mob/living/user, turf/open/lava/target)
	var/old_name = target.name
	if(target.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
		// reset cooldown is 10x faster on lavaland!
		var/cooldown = reset_cooldown
		if(is_mining_level(target.z))
			cooldown *= 0.1
		COOLDOWN_START(src, next_use, cooldown)
		user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
		playsound(target, 'sound/magic/fireball.ogg', vol = 200, vary = TRUE)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 5 SECONDS
	alpha = 0 // animated upon creation

/turf/open/lava/smooth/weak
	lava_damage = 10
	lava_firestacks = 10
	temperature_damage = 2500

//Blood-Drunk Miner: Cleaving Saw


/obj/item/melee/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon_state = "cleaving_saw"
	inhand_icon_state = "cleaving_saw"
	worn_icon_state = "cleaving_saw"
	attack_verb_continuous = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "saw", "slice", "tear", "lacerate", "rip", "dice", "cut")
	force = 12
	throwforce = 20
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	/// List of factions we deal bonus damage to
	var/list/nemesis_factions = list(FACTION_MINING, FACTION_BOSS)
	/// Amount of damage we deal to the above factions
	var/faction_bonus_force = 30
	/// Whether the cleaver is actively AoE swiping something.
	var/swiping = FALSE
	/// Amount of bleed stacks gained per hit
	var/bleed_stacks_per_hit = 3
	/// Force when the saw is opened.
	var/open_force = 20
	/// Throwforce when the saw is opened.
	var/open_throwforce = 20
	/// how much stamina does it cost to roll?
	var/roll_stamcost = 20
	/// how far are we rolling?
	var/roll_range = 5
	/// do you spin when dodgerolling
	var/roll_orientation = TRUE

/obj/item/melee/cleaving_saw/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		transform_cooldown_time = (CLICK_CD_MELEE * 0.25), \
		force_on = open_force, \
		throwforce_on = open_throwforce, \
		sharpness_on = sharpness, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		attack_verb_continuous_on = list("cleaves", "swipes", "slashes", "chops"), \
		attack_verb_simple_on = list("cleave", "swipe", "slash", "chop"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/cleaving_saw/examine(mob/user)
	. = ..()
	. += span_notice("It is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].")
	. += span_notice("Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.")
	. += span_notice("Transforming it immediately after an attack causes the next attack to come out faster.")
	. += span_notice("You can also right click to perform a roll! This has NO i-frames, do not try to dodge through attacks!")

/obj/item/melee/cleaving_saw/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!"))
	attack_self(user)
	return BRUTELOSS

/obj/item/melee/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	var/is_open = HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE)
	if(!is_open || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!is_open)
			faction_bonus_force = 0
		var/is_nemesis_faction = FALSE
		for(var/found_faction in target.faction)
			if(found_faction in nemesis_factions)
				is_nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
		. = ..()
		if(is_nemesis_faction)
			force -= faction_bonus_force
		if(!is_open)
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/turf = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/living_target in turf)
				if(user.Adjacent(living_target) && living_target.body_position != LYING_DOWN)
					melee_attack_chain(user, living_target)
		swiping = FALSE

/*
 * If we're attacking [target]s in our nemesis list, apply unique effects.
 *
 * user - the mob attacking with the saw
 * target - the mob being attacked
 */
/obj/item/melee/cleaving_saw/proc/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	var/datum/status_effect/stacking/saw_bleed/existing_bleed = target.has_status_effect(/datum/status_effect/stacking/saw_bleed)
	if(existing_bleed)
		existing_bleed.add_stacks(bleed_stacks_per_hit)
	else
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed, bleed_stacks_per_hit)

/*
 * The dodge roll that is mandatory for a Fromsoft reference
 *
 */

/obj/item/melee/cleaving_saw/click_alt(mob/user) //want blood born quick steps or dark souls rolls (completely cosmetic)
	roll_orientation = !roll_orientation
	to_chat(user, span_notice("You are now [roll_orientation ? "rolling" : "quick-stepping"] when you dodge. (This only affects if you spin or not during a dodge.)"))
	return CLICK_ACTION_SUCCESS

/obj/item/melee/cleaving_saw/pre_attack_secondary(atom/A, mob/living/user, params)
	return TRUE // Let's dance.

/obj/item/melee/cleaving_saw/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.IsImmobilized()) // no free dodgerolls
		return
	var/turf/where_to = get_turf(interacting_with)
	user.stamina.adjust(-roll_stamcost)
	user.Immobilize(0.8 SECONDS) // you dont get to adjust your roll
	user.throw_at(where_to, range = roll_range, speed = 2, force = MOVE_FORCE_NORMAL, spin = roll_orientation)
	playsound(user, 'monkestation/sound/effects/body-armor-rolling.ogg', 50, FALSE)
	return ..()

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback and makes the nextmove after transforming much quicker.
 */
/obj/item/melee/cleaving_saw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	user.changeNext_move(CLICK_CD_MELEE * 0.25)
	if(user)
		balloon_alert(user, "[active ? "opened" : "closed"] [src]")
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))
	return COMPONENT_NO_DEFAULT_MESSAGE

//Legion: Staff of Storms

/obj/item/storm_staff
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	inhand_icon_state = "staffofstorms"
	icon = 'icons/obj/weapons/guns/magic.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 20
	damtype = BURN
	hitsound = 'sound/weapons/taserhit.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/max_thunder_charges = 3
	var/thunder_charges = 3
	var/thunder_charge_time = 15 SECONDS
	var/static/list/excluded_areas = list(/area/space)
	var/list/targeted_turfs = list()

/obj/item/storm_staff/examine(mob/user)
	. = ..()
	. += span_notice("It has [thunder_charges] charges remaining.")
	. += span_notice("Use it in hand to dispel storms.")
	. += span_notice("Use it on targets to summon thunderbolts from the sky.")
	. += span_notice("The thunderbolts are boosted if in an area with weather effects.")

/obj/item/storm_staff/attack_self(mob/user)
	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf || (is_type_in_list(user_area, excluded_areas)))
		to_chat(user, span_warning("Something is preventing you from using the staff here."))
		return
	var/datum/weather/affected_weather
	for(var/datum/weather/weather as anything in SSweather.processing)
		if((user_turf.z in weather.impacted_z_levels) && ispath(user_area.type, weather.area_type))
			affected_weather = weather
			break
	if(!affected_weather)
		return
	if(affected_weather.stage == END_STAGE)
		balloon_alert(user, "already ended!")
		return
	if(affected_weather.stage == WIND_DOWN_STAGE)
		balloon_alert(user, "already ending!")
		return
	balloon_alert(user, "you hold the staff up...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	user.visible_message(span_warning("[user] holds [src] skywards as an orange beam travels into the sky!"), \
	span_notice("You hold [src] skyward, dispelling the storm!"))
	playsound(user, 'sound/magic/staff_change.ogg', 200, FALSE)
	var/old_color = user.color
	user.color = list(340/255, 240/255, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	var/old_transform = user.transform
	user.transform *= 1.2
	animate(user, color = old_color, transform = old_transform, time = 1 SECONDS)
	affected_weather.wind_down()
	user.log_message("has dispelled a storm at [AREACOORD(user_turf)].", LOG_GAME)

/obj/item/storm_staff/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) && (user.istate & ISTATE_HARM))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/storm_staff/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return thunder_blast(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/storm_staff/proc/thunder_blast(atom/target, mob/user)
	if(!thunder_charges)
		balloon_alert(user, "needs to charge!")
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/area/target_area = get_area(target)
	if(!target_turf || !target_area || (is_type_in_list(target_area, excluded_areas)))
		balloon_alert(user, "can't bolt here!")
		return FALSE
	if(target_turf in targeted_turfs)
		balloon_alert(user, "already targeted!")
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		balloon_alert(user, "you don't want to harm!")
		return FALSE
	var/power_boosted = FALSE
	for(var/datum/weather/weather as anything in SSweather.processing)
		if(weather.stage != MAIN_STAGE)
			continue
		if((target_turf.z in weather.impacted_z_levels) && ispath(target_area.type, weather.area_type))
			power_boosted = TRUE
			break
	playsound(src, 'sound/magic/lightningshock.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	targeted_turfs += target_turf
	balloon_alert(user, "you aim at [target_turf]...")
	new /obj/effect/temp_visual/telegraphing/thunderbolt(target_turf)
	addtimer(CALLBACK(src, PROC_REF(throw_thunderbolt), target_turf, power_boosted), 1.5 SECONDS)
	thunder_charges--
	addtimer(CALLBACK(src, PROC_REF(recharge)), thunder_charge_time)
	user.log_message("fired the staff of storms at [AREACOORD(target_turf)].", LOG_ATTACK)
	return TRUE

/obj/item/storm_staff/proc/recharge(mob/user)
	thunder_charges = min(thunder_charges + 1, max_thunder_charges)
	playsound(src, 'sound/magic/charge.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/storm_staff/proc/throw_thunderbolt(turf/target, boosted)
	targeted_turfs -= target
	new /obj/effect/temp_visual/thunderbolt(target)
	var/list/affected_turfs = list(target)
	if(boosted)
		for(var/direction in GLOB.alldirs)
			var/turf_to_add = get_step(target, direction)
			if(!turf_to_add)
				continue
			affected_turfs += turf_to_add
	for(var/turf/turf as anything in affected_turfs)
		new /obj/effect/temp_visual/electricity(turf)
		for(var/mob/living/hit_mob in turf)
			to_chat(hit_mob, span_userdanger("You've been struck by lightning!"))
			hit_mob.electrocute_act(15 * (isanimal_or_basicmob(hit_mob) ? 3 : 1) * (turf == target ? 2 : 1) * (boosted ? 2 : 1), src, flags = SHOCK_TESLA|SHOCK_NOSTUN)

		for(var/obj/hit_thing in turf)
			hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(target, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	target.visible_message(span_danger("A thunderbolt strikes [target]!"))
	explosion(target, light_impact_range = (boosted ? 1 : 0), flame_range = (boosted ? 2 : 1), silent = TRUE)
