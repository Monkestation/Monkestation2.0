#define DOAFTER_SOURCE_STRONGARM_INTERACTION "strongarm interaction"

// Strong-Arm Implant //

/obj/item/organ/internal/cyberimp/arm/strongarm
	name = "\proper Strong-Arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action. Install one in each arm \
		to pry open doors with your bare hands!"
	icon_state = "muscle_implant"

	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_MUSCLE
	right_arm_organ_slot = ORGAN_SLOT_RIGHT_ARM_MUSCLE
	left_arm_organ_slot = ORGAN_SLOT_LEFT_ARM_MUSCLE

	actions_types = list()

	///The amount of damage dealt by the empowered attack.
	var/punch_damage = 5
	///Biotypes we apply an additional amount of damage too
	var/biotype_bonus_targets = MOB_BEAST | MOB_EPIC
	///Extra damage dealt to our targeted mobs
	var/biotype_bonus_damage = 20
	///IF true, the throw attack will not smash people into walls
	var/non_harmful_throw = TRUE
	///How far away your attack will throw your oponent
	var/attack_throw_range = 1
	///Minimum throw power of the attack
	var/throw_power_min = 1
	///Maximum throw power of the attack
	var/throw_power_max = 4
	///How long will the implant malfunction if it is EMP'd
	var/emp_base_duration = 9 SECONDS
	///How long before we get another slam punch; consider that these usually come in pairs of two
	var/slam_cooldown_duration = 5 SECONDS
	///Tracks how soon we can perform another slam attack
	COOLDOWN_DECLARE(slam_cooldown)

/obj/item/organ/internal/cyberimp/arm/strongarm/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/strongarm/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/strongarm)

/obj/item/organ/internal/cyberimp/arm/strongarm/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(ishuman(reciever)) //Sorry, only humans
		RegisterSignal(reciever, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/internal/cyberimp/arm/strongarm/Remove(mob/living/carbon/implant_owner, special = 0)
	. = ..()
	UnregisterSignal(implant_owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/organ/internal/cyberimp/arm/strongarm/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	owner.balloon_alert(owner, "your arm spasms wildly!")
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/arm/strongarm/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	owner.balloon_alert(owner, "your arm stops spasming!")

/obj/item/organ/internal/cyberimp/arm/strongarm/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.get_active_hand() != source.get_bodypart(check_zone(zone)) || !proximity)
		return NONE
	if(!(source.istate & ISTATE_HARM) || (source.istate & ISTATE_SECONDARY))
		return NONE
	if(!isliving(target))
		return NONE
	var/datum/dna/dna = source.has_dna()
	if(dna?.check_mutation(/datum/mutation/human/hulk)) //NO HULK
		return NONE
	if(!COOLDOWN_FINISHED(src, slam_cooldown))
		return NONE

	var/mob/living/living_target = target

	source.changeNext_move(CLICK_CD_MELEE)
	var/picked_hit_type = pick("punch", "smash", "pummel", "bash", "slam")

	if(organ_flags & ORGAN_FAILING)
		if(source.body_position != LYING_DOWN && living_target != source && prob(50))
			to_chat(source, span_danger("You try to [picked_hit_type] [living_target], but lose your balance and fall!"))
			source.Knockdown(3 SECONDS)
			source.forceMove(get_turf(living_target))
		else
			to_chat(source, span_danger("Your muscles spasm!"))
			source.Paralyze(1 SECONDS)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(source, punch_damage, "[source]'s' [picked_hit_type]"))
			source.do_attack_animation(target)
			playsound(living_target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			log_combat(source, target, "attempted to [picked_hit_type]", "muscle implant")
			return COMPONENT_CANCEL_ATTACK_CHAIN

	var/potential_damage = punch_damage
	var/obj/item/bodypart/attacking_bodypart = hand
	potential_damage += rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high)

	var/is_correct_biotype = living_target.mob_biotypes & biotype_bonus_targets
	if(biotype_bonus_targets && is_correct_biotype) //If we are punching one of our special biotype targets, increase the damage floor by a factor of two.
		potential_damage += biotype_bonus_damage

	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(living_target.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

	var/target_zone = living_target.get_random_valid_zone(source.zone_selected)
	var/armor_block = living_target.run_armor_check(target_zone, MELEE/*, armour_penetration = attacking_bodypart.unarmed_effectiveness*/)
	living_target.apply_damage(potential_damage, attacking_bodypart.attack_type, target_zone, armor_block)
	living_target.apply_damage(potential_damage * 2, STAMINA, target_zone, armor_block)

	if(source.body_position != LYING_DOWN) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
		living_target.throw_at(throw_target, attack_throw_range, rand(throw_power_min,throw_power_max), source, gentle = non_harmful_throw)

	living_target.visible_message(
		span_danger("[source] [picked_hit_type]ed [living_target]!"),
		span_userdanger("You're [picked_hit_type]ed by [source]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		source,
	)

	to_chat(source, span_danger("You [picked_hit_type] [target]!"))

	log_combat(source, target, "[picked_hit_type]ed", "muscle implant")

	COOLDOWN_START(src, slam_cooldown, slam_cooldown_duration)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/organ_set_bonus/strongarm
	id = "organ_set_bonus_strongarm"
	organs_needed = 2
	bonus_activate_text = span_notice("Your improved arms allow you to open airlocks by force with your bare hands!")
	bonus_deactivate_text = span_notice("You can no longer force open airlocks with your bare hands.")
	required_biotype = NONE

/datum/status_effect/organ_set_bonus/strongarm/enable_bonus()
	. = ..()
	if(.)
		owner.AddElement(/datum/element/door_pryer, pry_time = 6 SECONDS, interaction_key = DOAFTER_SOURCE_STRONGARM_INTERACTION)

/datum/status_effect/organ_set_bonus/strongarm/disable_bonus()
	. = ..()
	owner.RemoveElement(/datum/element/door_pryer, pry_time = 6 SECONDS, interaction_key = DOAFTER_SOURCE_STRONGARM_INTERACTION)

/obj/item/organ/internal/cyberimp/arm/ammo_counter
	name = "S.M.A.R.T. ammo logistics system"
	desc = "Special inhand implant that allows transmits the current ammo and energy data straight to the user's visual cortex."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#750137"
	encode_info = AUGMENT_NT_HIGHLEVEL

	var/atom/movable/screen/cybernetics/ammo_counter/counter_ref
	var/obj/item/gun/our_gun

/obj/item/organ/internal/cyberimp/arm/ammo_counter/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	RegisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP, PROC_REF(add_to_hand))
	RegisterSignal(M,COMSIG_CARBON_ITEM_DROPPED, PROC_REF(remove_from_hand))

/obj/item/organ/internal/cyberimp/arm/ammo_counter/Remove(mob/living/carbon/M, special)
	. = ..()
	UnregisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP)
	UnregisterSignal(M,COMSIG_CARBON_ITEM_DROPPED)
	our_gun = null
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/update_implants()
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/update_hud_elements()
	SIGNAL_HANDLER
	if(!owner || !owner?.hud_used)
		return

	if(!check_compatibility())
		return

	var/datum/hud/H = owner.hud_used

	if(!our_gun)
		if(!H.cybernetics_ammo[zone])
			return
		H.cybernetics_ammo[zone] = null

		H.infodisplay -= counter_ref
		H.mymob.client.screen -= counter_ref
		QDEL_NULL(counter_ref)
		return

	if(!H.cybernetics_ammo[zone])
		counter_ref = new(null, H)
		counter_ref.screen_loc =  zone == BODY_ZONE_L_ARM ? ui_hand_position(1,1,9) : ui_hand_position(2,1,9)
		H.cybernetics_ammo[zone] = counter_ref
		H.infodisplay += counter_ref
		H.mymob.client.screen += counter_ref

	var/display
	if(istype(our_gun,/obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/balgun = our_gun
		display = balgun.magazine.ammo_count(FALSE)
	else
		var/obj/item/gun/energy/egun = our_gun
		var/obj/item/ammo_casing/energy/shot = egun.ammo_type[egun.select]
		display = FLOOR(egun.cell.charge / shot.e_cost,1)
	counter_ref.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='white'>[display]</font></div>")

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/add_to_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	var/obj/item/bodypart/bp = owner.get_active_hand()

	if(bp.body_zone != zone)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		our_gun = maybegun
		RegisterSignal(owner,COMSIG_MOB_FIRED_GUN, PROC_REF(update_hud_elements))

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		our_gun = egun
		RegisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER, PROC_REF(update_hud_elements))

	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/remove_from_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	if(our_gun != maybegun)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		UnregisterSignal(owner,COMSIG_MOB_FIRED_GUN)

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		UnregisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER)


	our_gun = null
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/syndicate
	organ_flags = parent_type::organ_flags | ORGAN_HIDDEN
	encode_info = AUGMENT_SYNDICATE_LEVEL

/obj/item/organ/internal/cyberimp/arm/cooler
	name = "sub-dermal cooling implant"
	desc = "Special inhand implant that cools you down if overheated."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#00e1ff"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/cooler/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.standard_body_temperature
	if(amt == 0)
		return
	owner.add_homeostasis_level(type, amt, 0.25 KELVIN)

/obj/item/organ/internal/cyberimp/arm/cooler/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_homeostasis_level(type)

/obj/item/organ/internal/cyberimp/arm/heater
	name = "sub-dermal heater implant"
	desc = "Special inhand implant that heats you up if overcooled."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#ff9100"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/heater/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.standard_body_temperature
	if(amt == 0)
		return
	owner.add_homeostasis_level(type, amt, 0.25 KELVIN)

/obj/item/organ/internal/cyberimp/arm/heater/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_homeostasis_level(type)

#undef DOAFTER_SOURCE_STRONGARM_INTERACTION
