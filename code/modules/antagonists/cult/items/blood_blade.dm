/obj/item/melee/blood_dagger
	name = "blood dagger"
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	lefthand_file = 'monkestation/code/modules/bloody_cult/icons/in_hands/swords_axes_l.dmi'
	righthand_file = 'monkestation/code/modules/bloody_cult/icons/in_hands/swords_axes_r.dmi'
	icon_state = "blood_dagger"
	inhand_icon_state = "blood_dagger"
	desc = "A knife-shaped hunk of solidified blood. Can be thrown to pin enemies down."
	siemens_coefficient = 0.2
	sharpness = SHARP_EDGED
	force = 15.0
	w_class = WEIGHT_CLASS_GIGANTIC//don't want it stored anywhere case
	var/mob/originator = null
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger/linked_ui
	var/stacks = 0
	var/absorbed = 0

/obj/item/melee/blood_dagger/Destroy()
	if(linked_ui)
		linked_ui.dagger = null
		linked_ui.UpdateIcon()
		linked_ui = null
	var/turf/T = get_turf(src)
	playsound(T, 'monkestation/code/modules/bloody_cult/sound/forge_over.ogg', 100, 0, -2)
	if (!absorbed && !locate(/obj/effect/decal/cleanable/blood/splatter) in T)
		var/obj/effect/decal/cleanable/blood/splatter/S = new (T)//splash
		if (color)
			S.color = color
			S.update_icon()
	..()

/obj/item/melee/blood_dagger/suicide_act(mob/living/user)
	to_chat(viewers(user), span_danger("[user] is slitting \his throat with \the [src]! It looks like \he's trying to commit suicide.") )

/obj/item/melee/blood_dagger/dropped(mob/user)
	..()
	qdel(src)

/obj/item/melee/blood_dagger/attack(mob/living/target, mob/living/carbon/human/user)
	if(target == user)
		if (stacks < 5)
			user.blood_volume -= 5
			stacks++
			playsound(user, 'sound/weapons/bladeslice.ogg', 30, 0, -2)
			to_chat(user, span_warning("\The [src] takes a bit of your blood.") )
		return
	if (IS_CULTIST(user) && !IS_CULTIST(target) && !target.stat == DEAD)
		var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
		if (target.mind)
			cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_blooddagger", target)
		else
			cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_blooddagger_nomind", target)
	..()
/obj/item/melee/blood_dagger/attack_hand(mob/living/user)
	if(!ismob(loc))
		qdel(src)
		return
	..()

/obj/item/melee/blood_dagger/attack_self(mob/user)
	if (ishuman(user) && IS_CULTIST(user))
		var/mob/living/carbon/human/H = user
		if (!HAS_TRAIT(H, TRAIT_NOBLOOD))
			to_chat(user, span_notice("You sheath \the [src] back inside your body[stacks ? ", along with the stolen blood" : ""].") )
			H.blood_volume += 5 + stacks * 5
		else
			to_chat(user, span_notice("You sheath \the [src] inside your body, but the blood fails to find vessels to occupy.") )
		absorbed = 1
		playsound(H, 'monkestation/code/modules/bloody_cult/sound/bloodyslice.ogg', 30, 0, -2)
		qdel(src)


/obj/item/melee/blood_dagger/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
	var/turf/starting = get_turf(thrower)
	var/obj/projectile/blooddagger/dagger = new (starting)
	dagger.stacks = stacks
	dagger.damage = 5 + stacks * 5
	dagger.icon_state = icon_state
	dagger.color = color
	dagger.preparePixelProjectile(target, starting)
	dagger.fire(direct_target = target)
	dagger.process()
	qdel(src)

/obj/item/melee/blood_dagger/attack(mob/living/attacked, mob/living/carbon/human/user)
	. = ..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			C.blood_volume -= 5
			if (stacks < 5)
				stacks++
				to_chat(user, span_warning("\The [src] steals a bit of their blood.") )
