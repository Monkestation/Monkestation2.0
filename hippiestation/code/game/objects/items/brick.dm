/obj/item/combat_brick
	name = "brick"
	desc = "A brick, prefered break-in tool in many planets."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "brick"
	force = 10
	throwforce = 15
	attack_verb_continuous = "bricks"
	attack_verb_simple = "brick"
	hitsound = 'hippiestation/sound/weapons/brick.ogg'
	var/durability = 2

/obj/item/combat_brick/Initialize(mapload)
	. = ..()
	if(prob(1))
		name = "brown brick"
		desc = "<font color = #835C3B>I understand why all the kids are playing this game these days. It's because they like to build brown bricks with Minecrap. I also like to build brown bricks with Minecrap. It's the most fun you can possibly have.</font>"
		icon_state = "brownbrick"
		force = 15
		throwforce = 20
		durability = INFINITY

/obj/item/combat_brick/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(!ishuman(target_mob))
		return
	var/mob/living/carbon/human/M = target_mob
	if(prob(5) && M.stat != DEAD && !istype(M.head, /obj/item/clothing/head/helmet))
		brick_ko(M)

/obj/item/combat_brick/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(.)
		return
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(prob(10))
			brick_ko(H)
			playsound(src, 'hippiestation/sound/effects/ZUBALAWA.ogg', 50, 0)
	if(!durability)
		return
	if(istype(hit_atom, /obj/structure/window))
		var/obj/structure/window/W = hit_atom
		W.atom_destruction("brick")
		durability -= 1
	if(istype(hit_atom, /obj/machinery/door/window))
		var/obj/machinery/door/window/W = hit_atom
		W.atom_destruction("brick")
		durability -= 1

/obj/item/combat_brick/proc/brick_ko(mob/living/carbon/human/H)
	if(H.stat == DEAD || istype(H.head, /obj/item/clothing/head/helmet))
		return FALSE
	H.emote("scream")
	H.visible_message(span_danger("[H] is knocked out with [src]!"))
	H.AdjustUnconscious(60)

