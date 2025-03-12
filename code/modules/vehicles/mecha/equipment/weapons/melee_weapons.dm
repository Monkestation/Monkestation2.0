
/obj/item/mecha_parts/mecha_equipment/melee_weapon
	name = "mecha melee weapon"
	icon_state = "mecha_generic_melee"
	range = MECHA_MELEE|MECHA_RANGED	//so we can do stuff at range and in melee
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	mech_flags = EXOSUIT_MODULE_MELEE
	equipment_flags = MELEE_OVERRIDE
	obj_flags = UNIQUE_RENAME // because it's COOL
	var/restricted = TRUE //for our special hugbox exofabs
	///	If we have a longer range weapon, such as a spear or whatever capable of hitting people further away, this is how much extra range it has
	var/extended_range = 0
	///	Attack speed modifier for a weapon. Big weapons will have a longer delay between attacks, while smaller ones will be faster
	var/attack_speed_modifier = 1
	///	Attack sound for the weapon
	var/attack_sound = 'monkestation/sound/weapons/mechasword.ogg'
	//Attack types - Note that at least one of these must be true otherwise it'll only have passive effects (if any)
	//By default we assume we're using a small weapon with only a special single-target attack
    ///	If the weapon has an AOE attack
	var/cleave = FALSE
	///	If the weapon has a single-target strike
	var/precise_attacks = TRUE

	///	Damage type for the weapon
	var/dam_type = BRUTE
	///	If it's sharp or not
	var/attack_sharpness = SHARP_EDGED
	///	Damage the weapon will do. Note this is ADDED to the base mecha attack damage (usually)
	var/weapon_damage = 0
	///	If we have both cleave and precise attacks, the precise may have more damage
	var/precise_weapon_damage = 0
	///	Minimum damage dealt with a weapon. Applies to non-combat mechs with the secret compartment module to make them suck a little less
	var/minimum_damage = 0
	///	Bonus deflection chance for using a melee weapon capable of blocking attacks
	var/deflect_bonus = 0
	///	Base armor piercing value of the weapon. This value is doubled for precise attacks
	var/base_armor_piercing = 0
	///	Fauna bonus damage, if any
	var/fauna_damage_bonus = 0
	///	Structure damage multiplier, for stuff like big ol' smashy hammers. Base structure damage multiplier for mech melee attacks is 3.
	var/structure_damage_mult = 3
	///	Mech damage multiplier, modifies the structure damage multiplier for damage specifically against mechs. Default to 0.75 for extended mech combat gaming
	var/mech_damage_multiplier = 0.5
	///	Weapons that can hit turfs, default to false because it'll be special effects maybe some time
	var/can_stab_turfs = FALSE

	///	Effect on hitting something
	var/hit_effect = ATTACK_EFFECT_SLASH
	///	Effect of the cleave attack
	var/cleave_effect = /obj/effect/temp_visual/dir_setting/firing_effect/sweep_attack

//Melee weapon attacks are a little different in that they'll override the standard melee attack
/obj/item/mecha_parts/mecha_equipment/melee_weapon/action(mob/source, atom/target, list/modifiers)
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if (!targloc || !istype(targloc) || !curloc)
		return 0
	if (targloc == curloc)
		return 0
	if(!action_checks(target))
		return 0
	if(target == targloc  && cleave)	//If we are targetting a location and not an object or mob
		var/attack_dir = NONE
		if(chassis.mecha_flags & OMNIDIRECTIONAL_ATTACKS)
			if(source.client) //try to get the precise angle to the source's mouse rather than just the tile clicked on
				attack_dir = angle2dir(mouse_angle_from_client(source.client))
			if(!attack_dir) //if no fancy targeting has happened, default to something alright
				attack_dir = angle2dir(get_angle(chassis, target))
		else
			attack_dir = chassis.dir
		cleave_attack(attack_dir)
	else if(precise_attacks && (get_dist(src,target) <= (1 + extended_range)) && can_stab_at(chassis, target) && !istype(target, /obj/item) && !istype(target, /obj/effect))	//If we are targetting something stabbable and they're within reach
		if(istype(target, /turf/open) && !can_stab_turfs)
			return 0	//Don't stab turf if we can't
		else
			precise_attack(target)
	else if(cleave)
		cleave_attack((chassis.mecha_flags & OMNIDIRECTIONAL_ATTACKS) ? get_dir(chassis, target) : chassis.dir) //Or swing wildly
	else	//Failure to sword
		return 0
	chassis.log_message("Attacked with [src.name], targeting [target].", LOG_MECHA)
	to_chat(world, span_warning("Timer set from [world.time] with duration [chassis.melee_cooldown * attack_speed_modifier]"))
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MELEE_ATTACK, chassis.melee_cooldown * attack_speed_modifier)//Cooldown is on the MECH so people dont bypass it by switching equipment
	TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), chassis.melee_cooldown * attack_speed_modifier)
	SEND_SIGNAL(source, COMSIG_MOB_USED_MECH_EQUIPMENT, chassis)
	chassis.use_power(energy_drain)
	return 1

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/can_stab_at(atom/attacker, atom/target)	//Checks for line of stab (like line of sight but harder) from attacker to defender
	//Note that we don't check for valid turfs or if starter and target are the same because that's already done in action()
	var/turf/current = null
	var/turf/next = null
	var/turf/starter = get_turf(attacker)
	var/turf/targloc = get_turf(target)

	if(attacker.Adjacent(target))	//Check if we're in normal melee range. If we aren't the rest of this will run to check if we have line of stab.
		return 1
	if(abs(starter.x - targloc.x) == abs(starter.y - targloc.y))	//If we're exactly diagonal
		current = get_step_towards(starter, targloc)	//We check directly diagonal for reasons
	else
		current = get_step_towards_lenient(starter, targloc)	//Otherwise we use a more lenient check
	if(!starter.Adjacent(current))	//Not next to our first turf, immediately fail
		return 0
	if(current != targloc)	//If our target isn't our first turf, find the next turf
		next = get_step_towards(current, targloc)
	while(current != targloc)	//as long as we haven't reached our target turf
		if(!current.Adjacent(next))	//check if we can stab from our current turf to the next one
			return 0
		if(current.density)	//If it's a wall and we're not at our target, we can't stab through it
			return 0
		for(var/obj/O in current)
			if(O.density && !(O.pass_flags & LETPASSTHROW))	//If there's a solid object we can't reach over on the turf
				return 0
		current = next
		if(next != targloc)	//Move to the next tile if we're not already there
			next = get_step_towards(next, targloc)
	return 1




/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/precise_attack(atom/target)	//No special attack by default. These will be set in the weapons themselves
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/cleave_attack()
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/proc/special_hit(atom/target)	//For special effects, slightly simplifies cleave/precise attack procs
	return 1

/obj/item/mecha_parts/mecha_equipment/melee_weapon/on_attach()
	if(deflect_bonus)
		chassis.deflect_chance += deflect_bonus

/obj/item/mecha_parts/mecha_equipment/melee_weapon/on_detach()
	if(deflect_bonus)
		chassis.deflect_chance -= deflect_bonus

	//		//=========================================================\\
	//======||				SWORDS AND SWORD-ADJACENTS			 	   ||
	//		\\=========================================================//

//Standard melee weapon, easily modifiable to suit your needs
/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword
	name = "generic mech sword"
	desc = "Generic mech sword! It's a bit too big to use yourself."
	cleave = TRUE
	precise_attacks = TRUE
	attack_sharpness = SHARP_EDGED
	attack_sound = 'monkestation/sound/weapons/mechasword.ogg'			//Recorded from Respawn/EA's Titanfall 2 (Ronin broadsword swing). Apparently they don't care so we're probably good
	///The sound it makes when the cleave hits a mob, different from the attack
	var/mob_strike_sound = 'sound/weapons/bladeslice.ogg'
	harmful = TRUE											//DO NOT give to children. Or do, I'm not the police.
	minimum_damage = 0
	///Wound bonus if it's supposed to be ouchy beyond just doing damag
	var/sword_wound_bonus = 0
	///If our precise attacks have a light touch for mob
	var/precise_no_mobdamage = FALSE
	///Same as precies_no_mobdamage but for everything else
	var/precise_no_objdamage = FALSE

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 3 SECONDS, 120)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/special_hit(atom/target)
	return 0

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/shortsword	//Our bread-and-butter mech shortsword for both slicing and stabbing baddies
	name = "\improper GD6 \"Jaeger\" Shortsword"
	desc = "An extendable arm-mounted blade with a nasty edge. It is small and fast enough to deflect some incoming attacks."
	energy_drain = 2
	weapon_damage = 10
	precise_weapon_damage = 15
	fauna_damage_bonus = 30		//because why not
	deflect_bonus = 15
	base_armor_piercing = 15
	structure_damage_mult = 2.5	//Sword is not as smashy
	minimum_damage = 25

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/cleave_attack(attack_dir)	//use this for basic cleaving attacks, tweak as needed
	playsound(chassis, attack_sound, 50, 1)
	var/turf/M = get_turf(chassis)
	for(var/i = 0 to 2)
		var/it_turn = 45*(1-i)
		var/turf/T = get_step(M,turn(attack_dir, it_turn))	//+45, +0, and -45 will get the three front tiles
		special_hit(T)	//So we can hit turfs too
		for(var/atom/A in T.contents)
			special_hit(A)
			if(isliving(A) && can_stab_at(chassis, A))	//If there's a stabbable mob
				var/mob/living/L = A

				if(iscarbon(L))	//If we're a carbon we can get armor and jazz
					var/mob/living/carbon/C = L
					var/obj/item/bodypart/body_part = pick(C.bodyparts)	//Cleave attack isn't very precise
					var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing)
					C.apply_damage(max(chassis.force + weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness, wound_bonus = sword_wound_bonus)
				else							//Regular mobs just take damage
					L.apply_damage(max(chassis.force + weapon_damage, minimum_damage), dam_type)
					if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid) && fauna_damage_bonus)	//If we're hitting fauna, because heck those guys
						L.apply_damage(fauna_damage_bonus, dam_type)

				L.visible_message(span_danger("[chassis.name] strikes [L] with a wide swing of [src]!"), \
				  span_userdanger("[chassis.name] strikes you with [src]!"))
				chassis.log_message("Hit [L] with [src.name] (cleave attack).", LOG_MECHA)
				playsound(L, mob_strike_sound, 50)

			if((isstructure(A) || ismachinery(A) || istype(A, /obj/vehicle/sealed/mecha)) && can_stab_at(chassis, A))	//if it's a big thing we hit anyways. Structures ALWAYS are hit, machines and mechs can be protected
				var/obj/O = A
				if(!O.density && !istype(O, /obj/structure/spacevine))	//Make sure it's not an open door or something
					continue
				var/object_damage = max(chassis.force + weapon_damage, minimum_damage) * structure_damage_mult * (istype(A, /obj/vehicle/sealed/mecha) ? mech_damage_multiplier : 1)	//Half damage on mechs
				O.take_damage(object_damage, dam_type, MELEE, 0, get_dir(chassis, O), base_armor_piercing)
				if(istype(O, /obj/structure/window))
					playsound(O,'sound/effects/Glasshit.ogg', 50)	//glass bonk noise
				else
					if(istype(A, /obj/vehicle/sealed/mecha))
						O.visible_message(span_danger("[chassis.name] strikes [O] with a wide swing of [src]!"))	//Don't really need to make a message for EVERY object, just important ones
					playsound(O,'sound/weapons/smash.ogg', 50)	//metallic bonk noise

	new cleave_effect(get_turf(src), attack_dir)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/precise_attack(atom/target)
	special_hit(target)

	if(isliving(target))
		var/mob/living/living_target = target
		var/mob/living/weapondude = chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)[1]

		if(living_target.stat == DEAD && !precise_no_mobdamage && (LAZYLEN(living_target.butcher_results) || LAZYLEN(living_target.guaranteed_butcher_results)))
			var/datum/component/butchering/butchering = src.GetComponent(/datum/component/butchering)
			if(!do_after(weapondude, butchering.speed, living_target))
				return
			butchering.startButcher(src, living_target, chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)[1])
			return

		if(iscarbon(living_target) && !precise_no_mobdamage)
			var/mob/living/carbon/C = living_target
			var/obj/item/bodypart/body_part = living_target.get_bodypart(weapondude? weapondude.zone_selected : BODY_ZONE_CHEST)
			var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing * 2)	//more AP for precision attacks
			C.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness, wound_bonus = sword_wound_bonus)
		else if(!precise_no_mobdamage)
			living_target.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type)
			if(ismegafauna(living_target) || istype(living_target, /mob/living/simple_animal/hostile/asteroid))	//Stab them harder
				living_target.apply_damage(fauna_damage_bonus, dam_type)

		living_target.visible_message(span_danger("[chassis.name] strikes [living_target] with [src]!"), \
				  span_userdanger("[chassis.name] strikes you with [src]!"))
		chassis.log_message("Hit [living_target] with [src.name] (precise attack).", LOG_MECHA)

	else if(target.uses_integrity && !precise_no_objdamage)	//If the initial target is a big object, hit it even if it's not dense.
		var/object_damage = max(chassis.force + precise_weapon_damage, minimum_damage) * structure_damage_mult * (ismecha(target) ? mech_damage_multiplier : 1)	//Half damage on mechs to prolong COOL MECH FIGHTS
		target.take_damage(object_damage, dam_type, MELEE, 0, get_dir(chassis, target), base_armor_piercing * 2)
	else
		return
	chassis.do_attack_animation(target, hit_effect)
	playsound(chassis, attack_sound, 50, 1)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/energy_axe
	name = "\improper SH-NT \"Killerhurtz\" Energy Axe"
	desc = "An oversized, destructive-looking axe with a powered edge. While far too big for use by an individual, an exosuit might be able to wield it."
	icon_state = "mecha_energy_axe"
	precise_attacks = FALSE		//This is not a weapon of precision, it is a weapon of destruction
	energy_drain = 4
	weapon_damage = 30
	fauna_damage_bonus = 30		//If you're fighting fauna with this thing, why? I mean it works, I guess.
	base_armor_piercing = 40
	structure_damage_mult = 4	//Think obi-wan cutting through a bulkhead with his lightsaber but he's a giant mech with a huge terrifying axe
	mech_damage_multiplier = 0.75	//Your puny exosuit will not save you
	minimum_damage = 40
	attack_speed_modifier = 1.5 //Kinda chunky
	mob_strike_sound = 'sound/weapons/blade1.ogg'
	light_outer_range = 5
	light_color = "#FF0000"

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/energy_axe/special_hit(A)
	if(istype(A, /turf/closed/wall))		//IT BREAKS WALLS TOO
		var/turf/closed/wall/W = A
		playsound(W, 'sound/weapons/blade1.ogg', 50)
		W.dismantle_wall()

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/energy_axe/on_attach()
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/energy_axe/on_detach()
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/katana	//Anime mech sword
	name = "\improper HR-2 \"Ronin\" Katana"
	desc = "An oversized, light-weight replica of an ancient style of blade. Still woefully underpowered in D&D."
	icon_state = "mecha_katana"
	energy_drain = 2
	cleave = FALSE				//small fast blade
	precise_weapon_damage = 10
	attack_speed_modifier = 0.7	//live out your anime dreams in a mech
	fauna_damage_bonus = 20		//because why not
	deflect_bonus = 20			//ANIME REASONS
	base_armor_piercing = 20	//40 on the precise attacks, something about being folded 10 gorillion times or whatever
	structure_damage_mult = 2	//katana is less smashy than other swords
	minimum_damage = 20
	sword_wound_bonus = 15		//More bleeding

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/batong
	name = "\improper AV-98 \"Ingram\" Heavy Stun Baton"
	desc = "A stun baton, but bigger. The tide of toolbox-armed assistants don't stand a chance."
	icon_state = "mecha_batong"
	energy_drain = 30
	attack_speed_modifier = 2	//needs to recharge
	structure_damage_mult = 1
	precise_weapon_damage = -25	//Mostly nonlethal
	weapon_damage = -25
	minimum_damage = 10			//Mostly.
	hit_effect = ATTACK_EFFECT_BOOP	//Boop :^)
	attack_sharpness = FALSE
	precise_no_mobdamage = TRUE	//Light touch for targetted stuns
	mob_strike_sound = 'sound/weapons/egloves.ogg'
	attack_sound = 'sound/weapons/egloves.ogg'
	var/stunforce = 12 SECONDS	//Stuns a little harder
	var/stamina_damage = 100

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/batong/special_hit(atom/target)	//It's a stun baton. It stuns.
	if(ismob(target))
		var/mob/living/mobtarget = target
		var/trait_check = HAS_TRAIT(target, TRAIT_BATON_RESISTANCE)

		if(iscyborg(mobtarget))
			mobtarget.flash_act(affect_silicon = TRUE)
			mobtarget.Paralyze(stunforce * 0.5 * (trait_check ? 0.1 : 1))
		else
			if(!trait_check)
				mobtarget.stamina.adjust(-stamina_damage)
			else
				var/stamina_to_min = (mobtarget.stamina.maximum * 0.29)
				mobtarget.stamina.adjust_to(-stamina_damage, stamina_to_min)
			if(!trait_check)
				mobtarget.Knockdown(stunforce)
		step_away(mobtarget, src)	//We push all mobs back a tad
	return TRUE



/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/trogdor	//TROGDOR!!!!! (But he's not a robot so I can't make the visible name that)
	name = "\improper TO-4 \"Tahu\" Flaming Chainsword"	//ITS ALSO A CHAINSWORD FUCK YEAH
	desc = "It's as ridiculous as it is badass. You feel like use of this this might be considered a war crime somewhere."
	icon_state = "mecha_trogdor"
	energy_drain = 3
	precise_weapon_damage = 5	//Gotta make space for the burninating
	attack_speed_modifier = 1.2	//Little unwieldy
	fauna_damage_bonus = 20
	base_armor_piercing = 15
	structure_damage_mult = 3.5	//It melts AND cuts!
	sword_wound_bonus = -30		//We're here for the fire damage thank you
	var/burninating = 10		//BURNINATING THE COUNTRYSIDE
	mob_strike_sound = 'sound/weapons/chainsawhit.ogg'

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/trogdor/special_hit(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/armor_block = L.run_armor_check(BODY_ZONE_CHEST, MELEE)	//it's a sword so we check melee armor
		var/burn_damage = (100-armor_block)/100 * burninating
		if(iscarbon(A))
			var/mob/living/carbon/C = L
			C.adjustFireLoss(burn_damage)
		else
			L.apply_damage(burn_damage, BURN)
		L.adjust_fire_stacks(2)
		L.ignite_mob()
		playsound(L, 'sound/items/welder.ogg', 50, 1)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/maul
	name = "\improper ASW-8 \"Barbatos\" Heavy Maul"
	desc = "A massive, unwieldy, mace-like weapon, this thing really looks like something you don't want to be hit by if you're not a fan of being concave."
	icon_state = "mecha_maul"
	energy_drain = 4
	weapon_damage = 25			//Very smashy
	precise_weapon_damage = 30
	attack_speed_modifier = 2.5	//Very slow
	fauna_damage_bonus = 40
	structure_damage_mult = 4	//Good for stationary objects
	attack_sharpness = 0
	sword_wound_bonus = 20		//Makes bones sad :(
	mob_strike_sound = 'sound/effects/meteorimpact.ogg'	//WHAM
	hit_effect = ATTACK_EFFECT_SMASH					//POW

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/maul/special_hit(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/throwtarget = get_edge_target_turf(src.chassis, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 8, 2, src)	//Get outta here!
		do_item_attack_animation(L, hit_effect)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier
	name = "\improper MS-15 \"Gyan\" Rapier"
	desc = "A remarkably thin blade for a weapon wielded by an exosuit, this rapier is the favorite of syndicate pilots that perfer finesse over brute force."
	icon_state = "mecha_rapier"
	energy_drain = 4
	cleave = FALSE
	base_armor_piercing = 25	//50 on precise attack
	deflect_bonus = 15			//Mech fencing but it parries bullets too because robot reaction time or something
	structure_damage_mult = 2	//Ever try to shank an engine block?
	mech_damage_multiplier = 0.75	//Notably better against mechs
	attack_sharpness = SHARP_POINTY
	attack_speed_modifier = 0.8	//Counteracts the 0.2 second time between attacks
	extended_range = 1			//So we can jump at people
	attack_sound = 'sound/weapons/rapierhit.ogg'
	sword_wound_bonus = 10		//Stabby
	var/stab_number = 2			//Stabby stabby
	var/next_lunge = 0
	var/base_lunge_cd = 1		//Cooldown for lunge (in seconds because math)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier/precise_attack(atom/target)
	//Lunge stuff
	if(get_dist(chassis, target) > 1)	//First we hop forward
		do_lunge_at(target)
	if(get_dist(get_turf(src.chassis), get_turf(target)) > 1)	//If we weren't able to get within range we don't attack
		TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MELEE_ATTACK, chassis.melee_cooldown * attack_speed_modifier * 0.5)	//half cooldown on a failed lunge attack
		TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), chassis.melee_cooldown * attack_speed_modifier * 0.5)
		return

	for(var/i in 1 to stab_number)
		if(!target)	//oops we broked it
			break
		special_hit(target)
		if(isliving(target))
			var/mob/living/L = target
			var/mob/living/weapondude = chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)[1]

			if(iscarbon(L) && !precise_no_mobdamage)
				var/mob/living/carbon/C = L
				var/obj/item/bodypart/body_part = C.get_bodypart(weapondude ? weapondude.zone_selected : BODY_ZONE_CHEST)
				if(i > 1)
					body_part = pick(C.bodyparts)	//If it's not the first strike we pick a random one, mostly to reduce the chances of instant dismembering
				var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing * 2)	//more AP for precision attacks
				C.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness, wound_bonus = sword_wound_bonus)
			else if(!precise_no_mobdamage)
				L.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type)
				if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))	//Stab them harder
					L.apply_damage(fauna_damage_bonus, dam_type)

			L.visible_message(span_danger("[chassis.name] strikes [L] with [src]!"), \
					span_userdanger("[chassis.name] strikes you with [src]!"))
			chassis.log_message("Hit [L] with [src.name] (precise attack).", LOG_MECHA)

		else if(target.uses_integrity && !precise_no_objdamage)	//If the initial target is a big object, hit it even if it's not dense.
			var/object_damage = max(chassis.force + precise_weapon_damage, minimum_damage) * structure_damage_mult * (ismecha(target) ? mech_damage_multiplier : 1)	//Nukie mech, slightly less bad at killing mechs
			target.take_damage(object_damage, dam_type, MELEE, 0, null, base_armor_piercing)	//Fine, no direction for you
		else
			return
		chassis.do_attack_animation(target, hit_effect)
		playsound(chassis, attack_sound, 50, 1)
		TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_MELEE_ATTACK, chassis.melee_cooldown * attack_speed_modifier + 2 * (stab_number - i))	//Cheeky cooldown math, should be standard cooldown + total delay between attacks
		TIMER_COOLDOWN_START(chassis, COOLDOWN_MECHA_EQUIPMENT(type), chassis.melee_cooldown * attack_speed_modifier + 2 * (stab_number - i))
		if(i != stab_number)	//Only sleep between attacks
			sleep(0.2 SECONDS)	//Slight delay
	return TRUE

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier/proc/do_lunge_at(atom/target)
	if(world.time < next_lunge)	//On cooldown
		return
	if(get_dist(get_turf(src.chassis), get_turf(target)) <= 1)	//Already in melee range
		return
	if(isturf(target))	//No free moving, you gotta stab something
		return
	step_towards(src.chassis, target)
	next_lunge = world.time + base_lunge_cd * (chassis.melee_cooldown)	//If we can attack faster we can lunge faster too

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier/razerfang
	name = "\improper GAT-98 \"Razerfang\" Dual Daggers"
	desc = "A pair of short, hollow blades forged of exceptionally hard metal, these weapons are capable of injecting venom into a target on a successful hit."
	icon_state = "mecha_razer"
	gender = PLURAL
	energy_drain = 4
	cleave = FALSE
	base_armor_piercing = 40	//80 on precise attack
	deflect_bonus = 5			//Helps, but is a bit to small to be particularly good at it
	attack_sharpness = SHARP_POINTY
	attack_speed_modifier = 2	//Strike and fall back, let the venom do the work
	precise_weapon_damage = -25	//Tiny dagger
	minimum_damage = 10			//So we don't do negative damage
	extended_range = 1			//So we can jump at people
	attack_sound = 'monkestation/sound/weapons/sword2.ogg'
	sword_wound_bonus = 10		//Stabby
	stab_number = 2				//Stabby stabby
	base_lunge_cd = 5			//Cooldown for lunge (in seconds because math)
	var/venom_cd = 5 SECONDS	//No infinite stacking of venom in people super easily please
	var/next_venom = 0
	var/venom_type = /datum/reagent/toxin/venom
	var/inject_volume = 6		//12 units per hit by default

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier/razerfang/special_hit(atom/target)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	if(world.time > next_venom)
		C.reagents.add_reagent(venom_type, inject_volume)	//Should ruin your day without charcoal

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/rapier/razerfang/precise_attack(atom/target)
	if(..() && iscarbon(target))
		next_venom = world.time + venom_cd	//do this here so that we only reset the cooldown after a full attack on a carbon

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/scythe
	name = "hydraulic scythe"
	desc = "A large cutting tool for removing infestations of expansionist plants."
	icon_state = "mecha_scythe"
	equip_cooldown = 5
	minimum_damage = 5

/obj/item/mecha_parts/mecha_equipment/melee_weapon/sword/scythe/special_hit(atom/target)
	if(istype(target, /mob/living/basic/venus_human_trap))
		var/mob/living/dead_plant = target
		dead_plant.take_bodypart_damage(chassis.force + weapon_damage)
	else if(istype(target, /obj/structure/spacevine))
		target.atom_destruction(BRUTE) // BEGONE!!


	//		//=========================================================\\
	//======||			SNOWFLAKE WEAPONS THAT ARENT SWORDS		 	   ||
	//		\\=========================================================//


/obj/item/mecha_parts/mecha_equipment/melee_weapon/rocket_fist	//Passive upgrade weapon when selected, makes your mech punch harder AND faster
	name = "\improper RS-77 \"Atom Smasher\" Rocket Fist"
	desc = "A large metal fist fitted to the arm of an exosuit, it uses repurposed maneuvering thrusters from a Raven battlecruiser to give a little more oomph to every punch. Also helps increase the speed at which the mech is able to return to a ready stance after each swing."
	icon_state = "mecha_rocket_fist"
	weapon_damage = 20 // PUNCH HARDER

/obj/item/mecha_parts/mecha_equipment/melee_weapon/rocket_fist/precise_attack(atom/target)
	target.mech_melee_attack(chassis, chassis.force + weapon_damage, FALSE)	//DONT SET THIS TO TRUE

/obj/item/mecha_parts/mecha_equipment/melee_weapon/rocket_fist/on_attach()
	chassis.melee_cooldown *= 0.8	//PUNCH FASTER

/obj/item/mecha_parts/mecha_equipment/melee_weapon/rocket_fist/on_attach()
	chassis.melee_cooldown /= 0.8

/obj/item/mecha_parts/mecha_equipment/melee_weapon/spear
	name = "\improper S5-C \"White Witch\" Shortspear"
	desc = "A hardened, telescoping metal rod with a wicked-sharp tip. Perfect for punching holes in things normally out of reach."
	icon_state = "mecha_spear"
	energy_drain = 3
	force = 10						//I want someone to stab someone else with this by hand
	extended_range = 1				//Hits from a tile away
	precise_weapon_damage = 10
	minimum_damage = 20
	attack_speed_modifier = 1.6		//Range comes with a cost
	attack_sharpness = SHARP_POINTY
	sharpness = SHARP_POINTY		//You can't use it well but it IS still a giant sharp metal stick
	base_armor_piercing = 40
	structure_damage_mult = 1.5		//Not great at destroying stuff
	mech_damage_multiplier = 1		//Anti-mech weapon
	hit_effect = ATTACK_EFFECT_KICK	//Don't question it


/obj/item/mecha_parts/mecha_equipment/melee_weapon/spear/precise_attack(atom/target, penetrated = FALSE)
	//if(!penetrated)
		//Find some way to get all the stuff in a line between attacker and target and hit them all, but this can wait

	if(isliving(target))
		var/mob/living/L = target
		var/mob/living/weapondude = chassis.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)[1]

		if(iscarbon(L))
			var/mob/living/carbon/C = L
			var/obj/item/bodypart/body_part = L.get_bodypart(penetrated ? BODY_ZONE_CHEST : weapondude ? weapondude.zone_selected : BODY_ZONE_CHEST)
			var/armor_block = C.run_armor_check(body_part, MELEE, armour_penetration = base_armor_piercing)
			C.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type, body_part, armor_block, sharpness = attack_sharpness)
		else
			L.apply_damage(max(chassis.force + precise_weapon_damage, minimum_damage), dam_type)
			if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid) && fauna_damage_bonus)	//Stab them harder
				L.apply_damage(fauna_damage_bonus, dam_type)

		L.visible_message(span_danger("[chassis.name] stabs [L] with [src]!"), \
				  span_userdanger("[chassis.name] stabs you with [src]!"))
		chassis.log_message("Hit [L] with [src.name] (precise attack).", LOG_MECHA)

	else if(target.uses_integrity)	//If the initial target is a big object, hit it even if it's not dense.
		var/object_damage = max(chassis.force + precise_weapon_damage, minimum_damage) * structure_damage_mult * (ismecha(target) ? mech_damage_multiplier : 1)
		target.take_damage(object_damage, dam_type, MELEE, 0, get_dir(chassis, target), base_armor_piercing)
		if(ismecha(target))
			special_hit(target)
	else
		return
	chassis.do_attack_animation(target, hit_effect)
	playsound(chassis, attack_sound, 50, 1)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/spear/special_hit(atom/target)	//Pierces mechs and hits the pilot
	if(ismecha(target))
		var/obj/vehicle/sealed/mecha/M = target
		for(var/mob/living/carbon/human/kebabbed in M.occupants)
			if(ishuman(kebabbed))
				precise_attack(kebabbed, TRUE)
				kebabbed.visible_message(span_danger("[chassis.name] stabs [kebabbed] with [src]!"), \
					span_userdanger("[chassis.name] penetrates your suits armor with [src]!"))
				chassis.log_message("Hit [kebabbed] with [src.name] (precise attack).", LOG_MECHA)


/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop
	name = "heavy mop"
	desc = "A very big mop, designed to be attached to mechanical exosuits."
	icon_state = "mecha_mop"
	energy_drain = 5
	attack_sound = 'sound/effects/slosh.ogg'

	cleave = TRUE
	precise_attacks = FALSE // cleave only
	attack_sharpness = FALSE
	harmful = FALSE
	weapon_damage = 0 // no damage
	structure_damage_mult = 0 // don't break stuff while trying to clean
	var/auto_sweep = TRUE
	var/mop_action = /datum/action/innate/mecha/equipment/sweeping

/datum/action/innate/mecha/equipment/sweeping
	name = "Toggle Auto-Mop"
	button_icon_state = "sweep_on"

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/Initialize(mapload)
	. = ..()
	var/action_type = mop_action	//Take the schematics
	mop_action = null				//Clean out the box
	var/datum/action/new_action = new action_type	//Make the thingy based on the schematics
	mop_action = new_action		//Put the thingy back in the box


/datum/action/innate/mecha/equipment/sweeping/Activate()
	var/obj/vehicle/sealed/mecha/chassis = owner.loc	//This will definitely work
	for(var/equipment in chassis.flat_equipment)
		if(istype(equipment, /obj/item/mecha_parts/mecha_equipment/melee_weapon/mop))
			var/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/mop = equipment
			mop.auto_sweep = !mop.auto_sweep
			button_icon_state = "sweep_[mop.auto_sweep ? "on" : "off"]"
			build_all_button_icons()

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	chassis.initialize_controller_action_type(mop_action, VEHICLE_CONTROL_EQUIPMENT)
	RegisterSignal(M, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_MOVABLE_PRE_MOVE)
	chassis.destroy_controller_action_type(mop_action, VEHICLE_CONTROL_EQUIPMENT)
	return ..()

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/proc/on_pre_move(obj/vehicle/sealed/mecha/mech, atom/newloc)
	if(mech.equipment_disabled)
		return
	if(!auto_sweep)
		return
	var/mop_dir = get_dir(mech, newloc)
	if(mop_dir != mech.dir) // only sweep things in front of the mech
		return
	do_mop(mech, newloc)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/proc/do_mop(obj/vehicle/sealed/mecha/mech, atom/newloc, throw_power=1)
	var/turf/mop_turf = newloc
	var/turf/thrown_at = get_edge_target_turf(mop_turf, chassis.dir)
	var/cleaned = FALSE

	if(mop_turf.wash(CLEAN_SCRUB))
		cleaned = TRUE
	for(var/atom/movable/moved_atom in newloc)
		if(istype(moved_atom, /obj/effect/decal/nuclear_waste)) // sweep that nuclear waste under the rug
			cleaned = TRUE
			playsound(moved_atom, 'sound/effects/footstep/gib_step.ogg', 50, 1)
			qdel(moved_atom)
			continue
		if(isobserver(moved_atom))
			continue // what the fuck?
		if(moved_atom.wash(CLEAN_SCRUB))
			cleaned = TRUE
		if(moved_atom.anchored)
			continue
		if(moved_atom == chassis) // it can clean itself, but not move itself
			continue
		moved_atom.throw_at(thrown_at, throw_power, 1, mech.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)[1], (throw_power > 1))
		if(isliving(moved_atom) && throw_power > 1)
			moved_atom.visible_message(span_danger("[mech] mops the floor with [moved_atom]!"), span_userdanger("[mech] mops the floor with you!"))

	if(cleaned)
		playsound(newloc, 'sound/effects/slosh.ogg', 25, 1)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/mop/cleave_attack(attack_dir)
	playsound(chassis, attack_sound, 50, 1)
	for(var/turf/T in list(get_turf(chassis), get_step(chassis, attack_dir), get_step(chassis, turn(attack_dir, -45)), get_step(chassis, turn(attack_dir, 45))))
		do_mop(chassis, T, 3) // mop the floor with them!
	new cleave_effect(get_turf(src), attack_dir)

/obj/item/mecha_parts/mecha_equipment/melee_weapon/flyswatter
	name = "comically large flyswatter"
	desc = "A comically large flyswatter, presumably for killing comically large bugs."
	attack_sound = 'sound/effects/snap.ogg'
	icon_state = "mecha_flyswatter"
	cleave = FALSE
	precise_attacks = TRUE
	hit_effect = ATTACK_EFFECT_SMASH
	///Things in this list will be instantly splatted.
	var/list/strong_against
	///Damage to mobs with the MOB_BUG biotype, quadrupled for simple mobs
	var/bug_damage = 30

/obj/item/mecha_parts/mecha_equipment/melee_weapon/flyswatter/Initialize(mapload)
	. = ..()
	strong_against = typecacheof(list(
		/mob/living/basic/bee,
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
		/obj/item/queen_bee
	))

/obj/item/mecha_parts/mecha_equipment/melee_weapon/flyswatter/precise_attack(atom/target)
	var/mob/living/mob_target = target
	if(is_type_in_typecache(target, strong_against))
		new /obj/effect/decal/cleanable/insectguts(target.drop_location())
		to_chat(chassis.occupants, span_warning("You easily splat the [target]."))
		if(isliving(target))
			var/mob/living/bug = target
			bug.death(TRUE)
		else
			qdel(target)
	else if(isliving(target) && (mob_target.mob_biotypes & MOB_BUG))
		mob_target.apply_damage(bug_damage * (ishuman(mob_target) ? 1 : 4), BRUTE, wound_bonus=CANT_WOUND) // bonus damage to simple mobs
		target.visible_message(span_warning("[chassis] splats [target] with [src]!"), span_userdanger("[chassis] splats you with [src]!"))
	chassis.do_attack_animation(target, hit_effect)
	playsound(chassis, attack_sound, 50, 1)

