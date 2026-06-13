
/obj/item/bodypart/arm/left/robot/buster
	name = "buster left arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	limb_id = "buster"
	inhand_icon_state = "left_buster_arm"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_static = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "buster_l_arm"
	var/datum/martial_art/buster_style/style = new

/obj/item/bodypart/arm/left/robot/buster/try_attach_limb(mob/living/carbon/new_arm_owner, special)
	. = ..()
	if(!.)
		return
	style.teach(new_arm_owner, TRUE, arm_index = 1)

/obj/item/bodypart/arm/left/robot/buster/drop_limb(special, dismembered, violent)
	style.remove(owner)
	return ..()

/obj/item/bodypart/arm/left/robot/buster/attack_self(mob/user, modifiers)
	. = ..()
	if(!ishuman(user) || !user.mind)
		return
	if((user.mind.martial_art != user.mind.default_martial_art) && !user.mind.has_martialart(MARTIALART_CQC)) //prevents people from learning several martial arts or swapping between them
		to_chat(user, span_warning("You are already dedicated to using [user.mind.martial_art.name]!"))
		return
	playsound(user,'sound/effects/phasein.ogg', 20, 1)
	to_chat(user, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(user)

/obj/item/bodypart/arm/left/robot/buster/attack_self_secondary(mob/user, modifiers)
	. = ..()
	var/obj/item/bodypart/arm/right/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = brute_dam
	opphand.burn_dam = burn_dam
	var/was_holding = user.is_holding(src)
	qdel(src)
	if(was_holding)
		user.put_in_hands(opphand)
	to_chat(user, span_notice("You modify [src] to be installed on the right arm."))

/obj/item/bodypart/arm/right/robot/buster
	name = "buster right arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	limb_id = "buster"
	inhand_icon_state = "right_buster_arm"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_static = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "buster_r_arm"
	var/datum/martial_art/buster_style/style = new

/obj/item/bodypart/arm/right/robot/buster/try_attach_limb(mob/living/carbon/new_arm_owner, special)
	. = ..()
	if(!.)
		return
	style.teach(new_arm_owner, TRUE, arm_index = 2)

/obj/item/bodypart/arm/right/robot/buster/drop_limb(special, dismembered, violent)
	style.remove(owner)
	return ..()

/obj/item/bodypart/arm/right/robot/buster/attack_self(mob/user, modifiers)
	. = ..()
	if(!ishuman(user) || !user.mind)
		return
	if((user.mind.martial_art != user.mind.default_martial_art) && !user.mind.has_martialart(MARTIALART_CQC)) //prevents people from learning several martial arts or swapping between them
		to_chat(user, span_warning("You are already dedicated to using [user.mind.martial_art.name]!"))
		return
	playsound(user,'sound/effects/phasein.ogg', 20, 1)
	to_chat(user, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(user)

/obj/item/bodypart/arm/right/robot/buster/attack_self_secondary(mob/user, modifiers)
	. = ..()
	var/obj/item/bodypart/arm/left/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = brute_dam
	opphand.burn_dam = burn_dam
	var/was_holding = user.is_holding(src)
	qdel(src)
	if(was_holding)
		user.put_in_hands(opphand)
	to_chat(user, span_notice("You modify [src] to be installed on the left arm."))
