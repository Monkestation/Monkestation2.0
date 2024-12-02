/obj/item/weapon/melee/cultblade
	name = "cult blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie. It features a nice round socket at the base of its obsidian blade."
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "cultblade"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharpness = SHARP_EDGED
	block_chance = 50 // now it's officially a cult esword
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")

	var/checkcult = 1


/obj/item/weapon/melee/cultblade/salt_act()
	new /obj/item/weapon/melee/cultblade/nocult(loc)
	qdel(src)

/obj/item/weapon/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS, \
	effectiveness = 100, \
	)

/obj/item/weapon/melee/cultblade/narsie_act()
	return

/obj/item/weapon/melee/cultblade/attack(var/mob/living/target, var/mob/living/carbon/human/user)
	if(!checkcult)
		return ..()
	if (IS_CULTIST(user))
		if (!IS_CULTIST(target) && target.stat != DEAD)
			var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
			if (target.mind)
				cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_cultblade", target)
			else
				cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_cultblade_nomind", target)
		if (ishuman(target) && target.resting)
			var/obj/structure/cult/altar/altar = locate() in target.loc
			if (altar)
				altar.attackby(src, user)
				return
			else
				return ..()
		else
			return ..()
	else
		user.Paralyze(0.5 SECONDS)
		user.dropItemToGround(src, TRUE)
		to_chat(user, span_warning("An unexplicable force powerfully repels \the [src] from [target]!") )

/obj/item/weapon/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(checkcult && !IS_CULTIST(user))
		to_chat(user, span_warning("An overwhelming feeling of dread comes over you as you pick up \the [src]. It would be wise to rid yourself of this, quickly.") )
		user.set_dizzy(12 SECONDS)


/obj/item/weapon/melee/cultblade/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/soulstone/gem))
		var/turf/T = get_turf(user)
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		user.dropItemToGround(src)
		var/obj/item/weapon/melee/soulblade/SB = new (T)
		spawn(1)
			user.put_in_active_hand(SB)
			if (IS_CULTIST(user))
				SB.linked_cultist = user
				to_chat(SB.shade, "<spawn class = 'notice'>You have made contact with [user]. As long as you remain within 5 tiles of them, you can move by yourself without losing blood, and regenerate blood passively at a faster rate.</span>")
		var/obj/item/soulstone/gem/sgem = I
		var/mob/living/basic/shade/shadeMob = locate(/mob/living/basic/shade) in sgem.contents
		if (shadeMob)
			shadeMob.forceMove(SB)
			SB.shade = shadeMob
			sgem.contents -= shadeMob
			if (shadeMob.mind)
				shadeMob.give_blade_powers()
			else
				to_chat(user, span_warning("Although the game appears to hold a shade, it somehow doesn't appear to have a mind capable of manipulating the blade.") )
				to_chat(user, span_danger("(that's a bug, call Deity, and tell him exactly how you obtained that shade).") )
				message_admins("[key_name(usr)] somehow placed a soul gem containing a shade with no mind inside a soul blade.")
		SB.update_icon()
		qdel(sgem)
		qdel(src)
		return 1
	if(istype(I, /obj/item/soulstone))
		to_chat(user, span_warning("\The [I] doesn't fit in \the [src]'s socket.") )
		return 1
	..()


/obj/item/weapon/melee/cultblade/nocult
	name = "broken cult blade"
	desc = "What remains of an arcane weapon wielded by the followers of Nar-Sie. In this state, it can be held mostly without risks."
	icon_state = "cultblade-broken"
	checkcult = 0
	force = 15

/obj/item/weapon/melee/cultblade/nocult/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/talisman) || istype(I, /obj/item/paper))
		return 1
	..()
