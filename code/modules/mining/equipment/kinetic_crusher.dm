/*********************Mining Hammer****************/
/obj/item/kinetic_crusher
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	inhand_icon_state = "crusher0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "proto-kinetic crusher"
	desc = "An early design of the proto-kinetic accelerator, it is little more than a combination of various mining tools cobbled together, forming a high-tech club. \
	While it is an effective mining tool, it did little to aid any but the most skilled and/or suicidal miners against local fauna."
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.15, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT*2.075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("smashes", "crushes", "cleaves", "chops", "pulps")
	attack_verb_simple = list("smash", "crush", "cleave", "chop", "pulp")
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	actions_types = list(/datum/action/item_action/toggle_light)
	action_slots = ALL
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 5
	light_on = FALSE
	var/list/trophies = list()
	var/charged = TRUE
	var/charge_time = 15
	var/detonation_damage = 50
	var/backstab_bonus = 30
	var/overrides_main = FALSE //monkestation edit //do we override the main init?
	var/overrides_twohandrequired = FALSE //Do we have the fumble on one handed attack attempt?
	var/override_twohandedsprite = FALSE //ENABLE THIS FOR ALL NEW CRUSHER VARIENTS OR ELSE IT WILL BREAK
	var/force_wielded = 20 // MONKESTATION ADDITION used by one handed crushers with wendigo claw
	var/override_examine = FALSE //If set to true, removes the default examine text. For special crushers like sickle.
	var/override_light_overlay_sprite = FALSE //because we do a lil shit coding, going to use this to remove light overlay from anything that doesnt have it so it doesnt use nosprite

/obj/item/kinetic_crusher/Initialize(mapload)
	. = ..()
	if(!overrides_main)
		AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded) //MONKESTATION EDIT force_wielded
		AddComponent(/datum/component/butchering, \
			speed = 6 SECONDS, \
			effectiveness = 110, \
	)

/obj/item/kinetic_crusher/Destroy()
	QDEL_LIST(trophies)
	return ..()

/obj/item/kinetic_crusher/examine(mob/living/user)
	. = ..()
	if(!override_examine)
		. += span_notice("Mark a large creature with a destabilizing force with right-click, then hit them in melee to do <b>[force + detonation_damage]</b> damage.")
		. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			. += span_notice("It has \a [T] attached, which causes [T.effect_desc()].")

/obj/item/kinetic_crusher/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(LAZYLEN(trophies))
			to_chat(user, span_notice("You remove [src]'s trophies."))
			I.play_tool_sound(src)
			for(var/t in trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(src, user)
		else
			to_chat(user, span_warning("There are no trophies on [src]."))
	else if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = I
		T.add_to(src, user)
	else
		return ..()

/obj/item/kinetic_crusher/attack(mob/living/target, mob/living/carbon/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return
	var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
	if(!C)
		C = target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	..()
	for(var/t in trophies)
		if(!QDELETED(target))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(target, user)
	if(!QDELETED(C) && !QDELETED(target))
		C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did

/obj/item/kinetic_crusher/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, TRUE) //Seriously who spelled it wrong

			if(!QDELETED(C))
				C.total_damage += combined_damage


			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/attack_secondary(atom/target, mob/living/user, clickparams)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/kinetic_crusher/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		balloon_alert(user, "wield it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_kinetic_blast(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/proc/fire_kinetic_blast(atom/target, mob/living/user, clickparams)
	if(!charged)
		return
	var/modifiers = params2list(clickparams)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/destabilizer/destabilizer = new(proj_turf)
	for(var/obj/item/crusher_trophy/attached_trophy as anything in trophies)
		attached_trophy.on_projectile_fire(destabilizer, user)
	destabilizer.preparePixelProjectile(target, user, modifiers)
	destabilizer.firer = user
	destabilizer.hammer_synced = src
	playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, TRUE)
	destabilizer.fire()
	if(charge_time > 0)
		charged = FALSE
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time)

/obj/item/kinetic_crusher/proc/Recharge()
	if(!charged)
		charged = TRUE
		update_appearance()
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, TRUE)

/obj/item/kinetic_crusher/ui_action_click(mob/user, actiontype)
	set_light_on(!light_on)
	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_appearance()

/obj/item/kinetic_crusher/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	set_light_on(FALSE)
	playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	return TRUE

/obj/item/kinetic_crusher/update_icon_state()
	if(!override_twohandedsprite)
		inhand_icon_state = "crusher[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent
		return ..()

/obj/item/kinetic_crusher/update_overlays()
	. = ..()
	if(!charged)
		. += "[icon_state]_uncharged"
	if(light_on && !override_light_overlay_sprite)
		. += "[icon_state]_lit"

/obj/item/kinetic_crusher/compact //for admins
	name = "compact kinetic crusher"
	w_class = WEIGHT_CLASS_NORMAL

//destablizing force
/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	armor_flag = BOMB
	range = 6
	log_override = TRUE
	var/obj/item/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/L = target
		var/had_effect = (L.has_status_effect(/datum/status_effect/crusher_mark)) //used as a boolean
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(/datum/status_effect/crusher_mark, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(firer)
	..()

//trophies
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "A strange spike with no usage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	var/bonus_value = 10 //if it has a bonus effect, this is how much that effect is
	var/denied_type = /obj/item/crusher_trophy

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Causes [effect_desc()] when attached to a kinetic crusher.")

/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"

/obj/item/crusher_trophy/attackby(obj/item/A, mob/living/user)
	if(istype(A, /obj/item/kinetic_crusher))
		add_to(A, user)
	else
		..()

/obj/item/crusher_trophy/proc/add_to(obj/item/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/trophy as anything in crusher.trophies)
		if(istype(trophy, denied_type) || istype(src, trophy.denied_type))
			to_chat(user, span_warning("You can't seem to attach [src] to [crusher]. Maybe remove a few trophies?"))
			return FALSE
	if(!user.transferItemToLoc(src, crusher))
		return
	crusher.trophies += src
	to_chat(user, span_notice("You attach [src] to [crusher]."))
	return TRUE

/obj/item/crusher_trophy/proc/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)
	forceMove(get_turf(crusher))
	crusher.trophies -= src
	return TRUE

/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user
/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user
/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark) //the target, the mark applied, and if the target had a mark before
/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user

//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "A wing ripped from a watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "mark detonation to prevent certain creatures from using certain attacks for <b>[bonus_value*0.1]</b> second\s"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(H.ranged) //briefly delay ranged attacks
			if(H.ranged_cooldown >= world.time)
				H.ranged_cooldown += bonus_value
			else
				H.ranged_cooldown = bonus_value + world.time

//magmawing watcher
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "A still-searing wing from a magmawing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		deadly_shot = FALSE

//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "A carefully preserved frozen wing from an icewing watcher. Suitable as a trophy for a kinetic crusher."
	icon_state = "ice_wing"
	bonus_value = 8

//legion
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "A dead and lifeless legion skull. Suitable as a trophy for a kinetic crusher."
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "a kinetic crusher to recharge <b>[bonus_value*0.1]</b> second\s faster"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time += bonus_value

//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Its pupil is collapsed and turned to mush. Suitable as a trophy for a kinetic crusher."
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "mark detonation to grant stun immunity and <b>90%</b> damage reduction for <b>1</b> second"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/blooddrunk)

//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "A spike taken from an ash drake's tail. Suitable as a trophy for a kinetic crusher."
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> damage to nearby creatures and push them back"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/L in oview(2, user))
		if(L.stat == DEAD)
			continue
		playsound(L, 'sound/magic/fireball.ogg', 20, TRUE)
		new /obj/effect/temp_visual/fire(L.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), L, user), 1) //no free backstabs, we push AFTER module stuff is done
		L.adjustFireLoss(bonus_value, forced = TRUE)

/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "A set of blood-drenched claws from a massive demon's hand. Suitable as a trophy for a kinetic crusher."
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "melee hits to do <b>[bonus_value * 0.2]</b> more damage and heal you for <b>[bonus_value * 0.1]</b>, with <b>5X</b> effect on mark detonation"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/kinetic_crusher/crusher, mob/living/user) //MONKESTATION EDIT /crusher, screw one letter vars
	. = ..()
	if(.)
		crusher.force += bonus_value * 0.2
		crusher.detonation_damage += bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=(crusher.force_wielded + bonus_value * 0.2)) //MONKESTATION EDIT force_wielded

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/kinetic_crusher/crusher, mob/living/user)  //MONKESTATION EDIT /crusher, screw one letter vars
	. = ..()
	if(.)
		crusher.force -= bonus_value * 0.2
		crusher.detonation_damage -= bonus_value * 0.8
		AddComponent(/datum/component/two_handed, force_wielded=crusher.force_wielded) //MONKESTATION EDIT force_wielded

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "The blaster tubes from a colossus's arm. Suitable as a trophy for a kinetic crusher."
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	var/deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "mark detonation to make the next destabilizer shot deal <b>[bonus_value]</b> damage but move slower"

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.speed = 2
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "A glowing trinket that was originally the Hierophant's beacon. Suitable as a trophy for a kinetic crusher."
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "mark detonation to create a homing hierophant chaser"

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/chaser = new(get_turf(user), user, target, 3, TRUE)
		chaser.monster_damage_boost = FALSE // Weaker cuz no cooldown
		chaser.damage = 20
		log_combat(user, target, "fired a chaser at", src)

/obj/item/crusher_trophy/ice_demon_cube
	name = "demonic cube"
	desc = "A stone cold cube dropped from an ice demon."
	icon_state = "ice_demon_cube"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	denied_type = /obj/item/crusher_trophy/ice_demon_cube
	///how many will we summon?
	var/summon_amount = 2
	///cooldown to summon demons upon the target
	COOLDOWN_DECLARE(summon_cooldown)

/obj/item/crusher_trophy/ice_demon_cube/effect_desc()
	return "mark detonation to unleash demonic ice clones upon the target"

/obj/item/crusher_trophy/ice_demon_cube/on_mark_detonation(mob/living/target, mob/living/user)
	if(isnull(target) || !COOLDOWN_FINISHED(src, summon_cooldown))
		return
	for(var/i in 1 to summon_amount)
		var/turf/drop_off = find_dropoff_turf(target, user)
		var/mob/living/basic/mining/demon_afterimage/crusher/friend = new(drop_off)
		friend.faction = list(FACTION_NEUTRAL)
		friend.befriend(user)
		friend.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
	COOLDOWN_START(src, summon_cooldown, 30 SECONDS)

///try to make them spawn all around the target to surround him
/obj/item/crusher_trophy/ice_demon_cube/proc/find_dropoff_turf(mob/living/target, mob/living/user)
	var/list/turfs_list = get_adjacent_open_turfs(target)
	for(var/turf/possible_turf in turfs_list)
		if(possible_turf.is_blocked_turf())
			continue
		return possible_turf
	return get_turf(user)

// CRUSHER VARIENTS

//Proto-Kinetic Crushers
/obj/item/kinetic_crusher/machete
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKMachete"
	inhand_icon_state = "PKMachete0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon = 'icons/mob/clothing/belt.dmi'
	worn_icon_state = "PKMachete0"
	name = "proto-kinetic machete"
	desc = "Recent breakthroughs with proto-kinetic technology have led to improved designs for the early proto-kinetic crusher, namely the ability to pack all \
	the same technology into a smaller more portable package. The machete design was chosen as to make a much easier to handle and less cumbersome frame. Of course \
	the smaller package means that the power is not as high as the original crusher design, but the different shell makes it capable of blocking basic attacks."
	force = 15
	block_chance = 25
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	armour_ignorance = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "cuts", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "chop", "cut", "swipe", "slash")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = NONE
	light_system = OVERLAY_LIGHT
	light_outer_range = 5
	light_on = FALSE
	charged = TRUE
	charge_time = 10
	detonation_damage = 35
	backstab_bonus = 20
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 15
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/machete/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 4 SECONDS, \
		effectiveness = 130, \
	)

/obj/item/kinetic_crusher/spear
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKSpear"
	inhand_icon_state = "PKSpear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "PKSpear0"
	name = "proto-kinetic spear"
	desc = "Having finally invested in better Proto-kinetic tech, research and development was able to cobble together this new proto-kinetic weapon. By compacting all the tecnology \
	we were able to fit it all into a spear styled case. No longer will proto-kinetic crushers be for the most skilled and suicidal, but now they will be available to the most cautious \
	paranoid miners, now able to enjoy the (slightly lower) power of a crusher, while maintaining a (barely) minimum safe distance."
	force = 0
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 20
	armour_ignorance = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("pierces", "stabs", "impales", "pokes", "jabs")
	attack_verb_simple = list("imaple", "stab", "pierce", "jab", "poke")
	sharpness = SHARP_EDGED
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 8
	light_on = FALSE
	charged = TRUE
	charge_time = 15
	detonation_damage = 45
	backstab_bonus = 20
	reach = 2
	overrides_main = TRUE
	overrides_twohandrequired = FALSE
	override_twohandedsprite = TRUE
	force_wielded = 15
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)
	AddComponent(/datum/component/butchering, \
		speed = 6 SECONDS, \
		effectiveness = 90, \
	)

/obj/item/kinetic_crusher/spear/update_icon_state()
	inhand_icon_state = "PKSpear[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent
	return ..()

/obj/item/kinetic_crusher/hammer
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKHammer"
	inhand_icon_state = "PKHammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "PKHammer0"
	name = "proto-kinetic hammer"
	desc = "Somehow research and development managed to make the proto-kinetic crusher even bigger, allowing more parts to be fit inside and increase the power output. \
	This increased power output allows it to surpass the power generated by the standard crusher, while also pushing back the target. Unfortunetly the flat head \
	results in backstabs being impossible."
	force = 0
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("slams", "crushes", "smashes", "flattens", "pounds")
	attack_verb_simple = list("slam", "crush", "smash", "flatten", "pound")
	sharpness = NONE
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 5
	light_on = FALSE
	charged = TRUE
	detonation_damage = 70
	backstab_bonus = 0
	overrides_main = TRUE
	overrides_twohandrequired = FALSE
	override_twohandedsprite = TRUE
	force_wielded = 20
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/hammer/Initialize(mapload)
		. = ..()
		AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/hammer/attack(mob/living/target, mob/living/user)
	var/relative_direction = get_cardinal_dir(src, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return
	else if(!QDELETED(target) && !target.anchored)
		var/whack_speed = (2)
		target.throw_at(throw_target, 2, whack_speed, user, gentle = TRUE)

/obj/item/kinetic_crusher/hammer/update_icon_state()
	inhand_icon_state = "PKHammer[HAS_TRAIT(src, TRAIT_WIELDED)]" // this is not icon_state and not supported by 2hcomponent
	return ..()

/obj/item/kinetic_crusher/claw
	icon = 'icons/obj/mining.dmi'
	icon_state = "PKClaw"
	inhand_icon_state = "PKClaw0"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = NONE
	name = "proto-kinetic claws"
	desc = "Truely the most compact version of the crusher ever made, its small enough to fit in your backpack and still function as a crusher. \
	Best used when attacking from behind, rewarding those capable of landing what we call a 'critical hit' \
	(DISCLAIMER) The shell is made to fit over gloves, so dont try to wear it like a glove."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 4
	armour_penetration = 0
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/pierce.ogg'
	attack_verb_continuous = list("swipes", "slashes", "cuts", "slaps")
	attack_verb_simple = list("swipe", "slash", "cut", "slap")
	sharpness = SHARP_POINTY
	actions_types = list(/datum/action/item_action/toggle_light)
	obj_flags = UNIQUE_RENAME
	light_system = OVERLAY_LIGHT
	light_outer_range = 4
	light_on = FALSE
	charged = TRUE
	charge_time = 2
	detonation_damage = 40
	backstab_bonus = 120
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 5
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/claw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 5 SECONDS, \
		effectiveness = 100, \
	)


/obj/item/kinetic_crusher/pilebunker
	icon_state = "pb_spike"
	inhand_icon_state = "pb_spike"
	icon = 'icons/obj/mining 64x.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "proto-kinetic pile bunker"
	desc = "An absolute beast of a crusher, designed to inflict as much damage as possible in a single strike, \
	with little regard for the user's own safety or physical ability to handle the weapon. Takes a short \
	moment to wind up a blow, and the spike has to be retracted after each use."
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = NONE
	base_pixel_x = -5
	pixel_x = -5
	throwforce = 0
	throw_speed = 0
	armour_penetration = 100 //yknow what fuck you, its a pile bunker
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("impales", "stabs", "destroys", "strikes")
	attack_verb_simple = list("impale", "stab", "destroy", "strike")
	sharpness = SHARP_POINTY
	charge_time = 75 //be patient, its alot of damage :)
	detonation_damage = 295 //add the five for a perfect 300 damage, enough to kill all basic enemies
	backstab_bonus = 200 //if you land a backstab it does 500 instead
	overrides_main = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 5 //hit the crusher mark or suffer no damage
	var/armed = FALSE //is the weapon armed?
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/pilebunker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/pilebunker/Recharge()
	if(!charged)
		charged = TRUE
		update_appearance()
		playsound(src.loc, 'sound/weapons/autoguninsert.ogg', 60, TRUE)

/obj/item/kinetic_crusher/pilebunker/attack(mob/living/target, mob/living/carbon/user)
	if(!armed)
		to_chat(user, span_warning("The pilebunker is not armed, re-arm it! (Right click while unarmed!)"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	user.visible_message(
		span_boldwarning("[user] plants their feet firmly to the ground and  winds up an attack!"),
		span_boldwarning("You plant your feet firmly to the ground and wind up an attack!"),
	)
	if(do_after(user, 1 SECOND, src) && (get_dist(user, target) <= 1))
		armed = FALSE
		update_appearance()
		var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = target.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = target.health
		..()
		for(var/t in trophies)
			if(!QDELETED(target))
				var/obj/item/crusher_trophy/T = t
				T.on_melee_hit(target, user)
		if(!QDELETED(C) && !QDELETED(target))
			C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did
	else
		user.visible_message(
			span_boldwarning("[user] stumbles as their stance is broken!"),
			span_boldwarning("You stumble as your stance is broken!"),
		)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/pilebunker/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health
				playsound(user, 'sound/weapons/blastcannon.ogg', 100, TRUE)
				shake_camera(user, 10, 3)
				var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
				user.throw_at(throw_target, 3, 5, gentle = FALSE)
			new /obj/effect/temp_visual/explosion/fast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
			if(!QDELETED(C))
				C.total_damage += combined_damage
			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/pilebunker/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(!armed)
		playsound(user, 'sound/mecha/hydraulic.ogg', 100, TRUE)
		if(do_after(user, 3 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_SLOWDOWNS))
			armed = TRUE
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		balloon_alert(user, "wield it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_kinetic_blast(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/pilebunker/update_icon_state()
	if(!armed)
		icon_state = "pb_spike"
		inhand_icon_state = "pb_spike"
	else
		icon_state = "pb"
		inhand_icon_state = "pb"
	return ..()

/obj/item/gun/magic/crusherknives //WHILE THIS ISNT EXACTLY CRUSHER, IT HAS A TON OF RE-USED CRUSHER CODE AND FUNCTIONS EXACTLY LIKE ONE, SO ITS GOING  HERE.
	name = "set of proto kinetic knives"
	desc = "With a touch of bluespace, the crusher has been made into a more practical form for throwing. \
	This set of throwing knives allows you to utilize the features of a crusher while maintaining more than a safe \
	distance from whatever fauna stands between you and your ore. Unfortunetly, while they are the perfect shape for throwing, the awkward grip \
	and blade make it pretty much impossible to stab with... at least it can still utilize trophies."
	fire_sound = 'sound/weapons/fwoosh.ogg'
	pinless = TRUE
	force = 10
	throwforce = 10
	throw_speed = 5
	wound_bonus = 2
	bare_wound_bonus = 10
	armour_penetration = 0
	block_chance = 0
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY //as to not trample on the crusher varients who use portability as their gimmick. if this seems too dumb we can change it to normal.
	antimagic_flags = NONE
	hitsound = 'sound/weapons/bladeslice.ogg'
	icon = 'icons/obj/mining.dmi'
	attack_verb_continuous = list("slashes", "stabs", "cuts")
	attack_verb_simple = list("slash", "stab", )
	icon_state = "crusherknife"
	inhand_icon_state = "switchblade_on"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	can_charge = TRUE //MAGICALLY ENHANCED THROWING KNIVES WOOOOO
	max_charges = 5
	recharge_rate = 5
	ammo_type = /obj/item/ammo_casing/magic/knives
	var/list/trophies = list() //yes these are new variables because this isnt a crusher subtype
	var/charged = TRUE
	var/charge_time = 5
	var/detonation_damage = 60 //these are the same as the thrown projectile so the description is correct on the damage.
	var/backstab_bonus = 10
	//so a quick note, you can technically land crusher melee stabs... however thats if point blanking it removed, from this... which i admittedly cant get removed from here so... im just redacting any mention of stabbing... sorry :(


/obj/item/gun/magic/crusherknives/Initialize(mapload)
	. = ..()
	var/obj/item/ammo_casing/magic/knives/pain = chambered
	pain.hammer_synced = src

/obj/item/gun/magic/crusherknives/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("You dont want to throw your very last knife! Wait for some spares to regenerate!"))

/obj/item/gun/magic/crusherknives/update_overlays()
	. = ..()
	if(!charged)
		. += "[icon_state]_uncharged"

/obj/item/gun/magic/crusherknives/process(seconds_per_tick) //This is here because I want it to play a sound when it regens a knife
	if (charges >= max_charges)
		charge_timer = 0
		return
	charge_timer += seconds_per_tick
	if(charge_timer < recharge_rate)
		return 0
	charge_timer = 0
	playsound(src, 'sound/items/unsheath.ogg', 100, TRUE) //aforementioned sound when a knife regenerates
	if(charges == 0) //make sure if the weapon gets emptied, a new round gets chambered
		charges++
		recharge_newshot()
	while(charges < max_charges) //regenerate the entire magazine
		charges++
	return 1

/obj/item/gun/magic/crusherknives/examine(mob/living/user)
	. = ..()
	. += span_notice("Mark a large creature with a destabilizing force with right-click, then hit them with a thrown knife to do <b>[force + detonation_damage]</b> damage.")
	. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += span_notice("It has \a [T] attached, which causes [T.effect_desc()].")

/obj/item/gun/magic/crusherknives/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(LAZYLEN(trophies))
			to_chat(user, span_notice("You remove [src]'s trophies."))
			I.play_tool_sound(src)
			for(var/t in trophies)
				var/obj/item/crusher_trophy/T = t
				T.remove_from(src, user)
		else
			to_chat(user, span_warning("There are no trophies on [src]."))
	else if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/T = I
		T.add_to(src, user)
	else
		return ..()

/obj/item/gun/magic/crusherknives/attack(mob/living/target, mob/living/carbon/user)
	var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
	if(!C)
		C = target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	..()
	for(var/t in trophies)
		if(!QDELETED(target))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(target, user)
	if(!QDELETED(C) && !QDELETED(target))
		C.total_damage += target_health - target.health

/obj/item/gun/magic/crusherknives/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 50, TRUE) //halved the volume because its a small knife

			if(!QDELETED(C))
				C.total_damage += combined_damage


			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/gun/magic/crusherknives/attack_secondary(atom/target, mob/living/user, clickparams)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/gun/magic/crusherknives/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_kinetic_blast(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/magic/crusherknives/proc/fire_kinetic_blast(atom/target, mob/living/user, clickparams)
	if(!charged)
		return
	var/modifiers = params2list(clickparams)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/destabilizer/longrange/destabilizer = new(proj_turf)
	for(var/obj/item/crusher_trophy/attached_trophy as anything in trophies)
		attached_trophy.on_projectile_fire(destabilizer, user)
	destabilizer.preparePixelProjectile(target, user, modifiers)
	destabilizer.firer = user
	destabilizer.hammer_synced = src
	playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, TRUE)
	destabilizer.fire()
	if(charge_time > 0)
		charged = FALSE
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time)

/obj/item/gun/magic/crusherknives/proc/Recharge()
	if(!charged)
		charged = TRUE
		update_appearance()
		playsound(src.loc, 'sound/weapons/etherealmiss.ogg' , 60, TRUE)

/obj/projectile/destabilizer/longrange //This does not get all its procs copy pasted because its actually a subtype of destabilizer
	name = "destabilizing shot"
	range = 15 //its an actual knife you throw
	log_override = TRUE
	hammer_synced = /obj/item/gun/magic/crusherknives

/obj/item/ammo_casing/magic/knives
	name = "MAGICAL KNIFE!!!"
	desc = "OH GOD OH FUCK ITS A MAGIC KNIFE!! (PLEASE REPORT ME)"
	slot_flags = null
	projectile_type = /obj/projectile/magic/knives
	firing_effect_type = null
	var/obj/item/gun/magic/crusherknives/hammer_synced

/obj/item/ammo_casing/magic/knives/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	var/obj/projectile/magic/knives/misery = loaded_projectile
	misery.hammer_synced = hammer_synced
	. = ..()

/obj/projectile/magic/knives
	name = "thrown proto-kinetic knife"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusherknife_thrown"
	damage = 10 //if people start abusing the FUCK out of this for station combat, drop it to five, thatll fucking teach them
	damage_type = BRUTE
	armour_penetration = 0
	armor_flag = MELEE
	wound_bonus = 5
	bare_wound_bonus = 10
	hitsound = 'sound/weapons/guillotine.ogg'
	hitsound_wall = 'sound/weapons/guillotine.ogg'
	antimagic_flags = NONE
	antimagic_charge_cost = 0
	var/obj/item/gun/magic/crusherknives/hammer_synced
	var/detonation_damage = 60
	var/backstab_bonus = 10

//we have more copy pasted crusher code here because the damage from a projectile is different from a melee strike
/obj/projectile/magic/knives/on_hit(atom/target, Firer, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in hammer_synced.trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, firer)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(firer, L)
			var/def_check = L.getarmor(type = BOMB)
			if((firer.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
				playsound(firer, 'sound/weapons/kenetic_accel.ogg', 50, TRUE)

			if(!QDELETED(C))
				C.total_damage += combined_damage


			SEND_SIGNAL(firer, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)
	. = ..()


/obj/item/kinetic_crusher/sickle
	icon_state = "crushersickle"
	inhand_icon_state = "crushersickle"
	worn_icon_state = "crushersickle"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	name = "proto-kinetic sickle"
	desc = "A simple yet effective design change was to curve the blade far more drastically, which \
	has resulted in a crusher that is capable of digging deep through the natural armor of local fauna \
	and cutting into veins and arteries, allowing the sickle design to cause extra damage through extreme blood loss."
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "slices", "cleaves", "chops", "swipes")
	attack_verb_simple = list("cleave", "slice", "cut", "swipe", "slash")
	sharpness = SHARP_EDGED
	charged = TRUE
	charge_time = 10
	detonation_damage = 25 //40 on a detonation 60 on a backstab but you get 125 bonus if you whack do three marks
	backstab_bonus = 20
	overrides_main = TRUE
	overrides_twohandrequired = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 15
	override_examine = TRUE //turned on because of the bleed part in
	override_light_overlay_sprite = TRUE

/obj/item/kinetic_crusher/sickle/examine(mob/living/user)
	. = ..()
	. += span_notice("Mark a large creature with a destabilizing force with right-click, then hit them in melee to do <b>[force + detonation_damage]</b> damage.")
	. += span_notice("Does <b>[force + detonation_damage + backstab_bonus]</b> damage if the target is backstabbed, instead of <b>[force + detonation_damage]</b>.")
	. += span_notice("Does <b> 4 </b> stack of bleed on mark detonation, <b> 6 </b> for a backstab. upon reaching <b> 10 </b> stacks of bleed, deals <b> 125 </b> extra damage.")
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += span_notice("It has \a [T] attached, which causes [T.effect_desc()].")

/obj/item/kinetic_crusher/sickle/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(/datum/status_effect/crusher_mark)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(/datum/status_effect/crusher_mark))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		var/datum/status_effect/stacking/saw_bleed/sickle/existing_bleed = L.has_status_effect(/datum/status_effect/stacking/saw_bleed/sickle)
		if(existing_bleed)
			existing_bleed.add_stacks(4)
		else
			L.apply_status_effect(/datum/status_effect/stacking/saw_bleed/sickle, 4)
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
				existing_bleed = L.has_status_effect(/datum/status_effect/stacking/saw_bleed/sickle) //updates the var to check for existing bleed again (which should absolutely exist)
				if(existing_bleed)
					existing_bleed.add_stacks(2)
				else
					L.apply_status_effect(/datum/status_effect/stacking/saw_bleed/sickle, 2)
				playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, TRUE) //Seriously who spelled it wrong

			if(!QDELETED(C))
				C.total_damage += combined_damage


			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)


//ADMIN ONLY PILE BUNKER THAT DOES WHAT YOU WOULD EXPECT OTHER THAN SHIT CODE

/obj/item/kinetic_crusher/adminpilebunker
	icon_state = "THEpilebunker_spike"
	inhand_icon_state = "THEpilebunker_spike"
	icon = 'icons/obj/mining 256x32.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/256x32_melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/256x32_melee_righthand.dmi'
	name = "Somewhat Long Pilebunker"
	desc = "Mining RND broke the fabric of reality, and uh... made... this slightly more penetrative pilebunker... that works on people... \
	Please return this to your nearest CC officer. how do they even manage this..."
	force = 100
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = ""
	slot_flags = NONE
	base_pixel_x = -126
	pixel_x = -126
	inhand_x_dimension = -194
	armour_penetration = 1000
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_continuous = list("absolutely obliterates")
	attack_verb_simple = list("absolutely obliterates")
	sharpness = SHARP_EDGED
	charge_time = 0.01
	detonation_damage = 10000
	backstab_bonus = 10000
	reach = 10
	overrides_main = TRUE
	override_twohandedsprite = TRUE
	force_wielded = 100
	var/armed = FALSE

/obj/item/kinetic_crusher/adminpilebunker/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddComponent(/datum/component/two_handed, force_unwielded=0, force_wielded=force_wielded)

/obj/item/kinetic_crusher/adminpilebunker/attack(mob/living/target, mob/living/carbon/user)
	if(!armed)
		to_chat(user, span_warning("The pilebunker is not armed, re-arm it! (Right click while unarmed!)"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		to_chat(user, span_warning("[src] is too heavy to use with one hand! You fumble and drop everything."))
		user.drop_all_held_items()
		return COMPONENT_CANCEL_ATTACK_CHAIN
	user.visible_message(
		span_boldwarning("[user] plants their feet firmly to the ground and  winds up an attack!"),
		span_boldwarning("You plant your feet firmly to the ground and wind up an attack!"),
	)
	armed = FALSE
	update_appearance()
	var/datum/status_effect/crusher_damage/C = target.has_status_effect(/datum/status_effect/crusher_damage)
	if(!C)
		C = target.apply_status_effect(/datum/status_effect/crusher_damage)
	var/target_health = target.health
	..()
	for(var/t in trophies)
		if(!QDELETED(target))
			var/obj/item/crusher_trophy/T = t
			T.on_melee_hit(target, user)
	if(!QDELETED(C) && !QDELETED(target))
		C.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did

/obj/item/kinetic_crusher/adminpilebunker/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/admin/CM = L.has_status_effect(/datum/status_effect/crusher_mark/admin)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(/datum/status_effect/crusher_mark/admin))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(/datum/status_effect/crusher_damage)
		if(!C)
			C = L.apply_status_effect(/datum/status_effect/crusher_damage)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health
				playsound(user, 'sound/weapons/blastcannon.ogg', 100, TRUE)
				var/atom/throw_target = get_edge_target_turf(user, get_dir(target, user))
				user.throw_at(throw_target, 100, 1000, gentle = FALSE)
			new /obj/effect/temp_visual/explosion/fast(get_turf(L))
			var/backstabbed = FALSE
			var/combined_damage = detonation_damage
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(type = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				backstabbed = TRUE
				combined_damage += backstab_bonus
			if(!QDELETED(C))
				C.total_damage += combined_damage
			SEND_SIGNAL(user, COMSIG_LIVING_CRUSHER_DETONATE, L, src, backstabbed)
			L.apply_damage(combined_damage, BRUTE, blocked = def_check)

/obj/item/kinetic_crusher/adminpilebunker/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(!armed)
		playsound(user, 'sound/mecha/hydraulic.ogg', 100, TRUE)
		if(do_after(user, 0.1 SECONDS, src, IGNORE_USER_LOC_CHANGE | IGNORE_SLOWDOWNS))
			armed = TRUE
			update_appearance()
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!HAS_TRAIT(src, TRAIT_WIELDED) && !overrides_twohandrequired)
		balloon_alert(user, "wield it first!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_kinetic_blast(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/kinetic_crusher/adminpilebunker/fire_kinetic_blast(atom/target, mob/living/user, clickparams)
	if(!charged)
		return
	var/modifiers = params2list(clickparams)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/destabilizer/admin/destabilizer = new(proj_turf)
	for(var/obj/item/crusher_trophy/attached_trophy as anything in trophies)
		attached_trophy.on_projectile_fire(destabilizer, user)
	destabilizer.preparePixelProjectile(target, user, modifiers)
	destabilizer.firer = user
	destabilizer.hammer_synced = src
	playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, TRUE)
	destabilizer.fire()
	if(charge_time > 0)
		charged = FALSE
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time)

/obj/item/kinetic_crusher/adminpilebunker/update_icon_state()
	if(!armed)
		icon_state = "THEpilebunker_spike"
		inhand_icon_state = "THEpilebunker_spike"
	else
		icon_state = "THEpilebunker"
		inhand_icon_state = "THEpilebunker"
	return ..()

//destablizing force that can mark people
/obj/projectile/destabilizer/admin
	name = "death force"
	icon_state = "pulse1"
	range = 50

/obj/projectile/destabilizer/admin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/L = target
		var/had_effect = (L.has_status_effect(/datum/status_effect/crusher_mark/admin)) //used as a boolean
		var/datum/status_effect/crusher_mark/admin/CM = L.apply_status_effect(/datum/status_effect/crusher_mark/admin, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/M = target_turf
		new /obj/effect/temp_visual/kinetic_blast(M)
		M.gets_drilled(firer)
	..()

