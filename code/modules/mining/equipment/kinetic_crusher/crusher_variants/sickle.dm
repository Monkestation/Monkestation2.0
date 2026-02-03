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
		if(!CM || !L.remove_status_effect(/datum/status_effect/crusher_mark))
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
