/obj/item/clothing/shoes/bowling
	name = "bowling shoes"
	desc = "Made for use in only the finest bowling alleys. \
	The soles are made of space carp leather which increases buoyancy, allowing you to run faster."
	icon_state = "bowling_shoes"
	worn_icon_state = "bowling_shoes"
	inhand_icon_state = "sneakers_back"
	icon = 'hippiestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'hippiestation/icons/mob/feet.dmi'
	slowdown = -0.4


/obj/item/clothing/under/bowling_jersey
	name = "bowling jersey"
	desc = "The latest in kingpin fashion. \
	Nanites sewn in the sleeve stabilize the arm muscles to increase bowling power "
	icon_state = "bowling_jersey"
	worn_icon_state = "bowling_jersey"
	inhand_icon_state = "lb_suit"
	icon = 'hippiestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'hippiestation/icons/mob/uniform.dmi'


/obj/item/bowling_ball
	name = "bowling ball"
	desc = "A heavy, round device used to knock pins (or people) down. You reckon you can place it on your head"
	icon_state = "bowling_ball"
	inhand_icon_state = "bowling_ball"
	icon = 'hippiestation/icons/obj/items.dmi'
	worn_y_offset = 4
	worn_icon = 'hippiestation/icons/mob/head.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	force = 6
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 3
	throw_range = 2
	throw_speed = 1
	var/pro_wielded = FALSE
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD


/obj/item/bowling_ball/Initialize()
	. = ..()
	color = pick("gray", "red", "magenta", "lime", "yellow", "cyan", "blue", "teal", "black")
	ADD_TRAIT(src, TRAIT_UNCATCHABLE, TRAIT_GENERIC)

/obj/item/bowling_ball/throw_at(atom/target, range, speed, mob/thrower, spin = FALSE, diagonals_first = FALSE, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	icon_state = "bowling_ball_spin"
	playsound(src,'hippiestation/sound/effects/bowl.ogg',40,0)
	target = get_target(target, get_turf(thrower))
	range = 150
	if(!ishuman(thrower))
		return ..()
	var/mob/living/carbon/human/user = thrower
	if(user.w_uniform && istype(user.w_uniform, /obj/item/clothing/under/bowling_jersey))
		pro_wielded = TRUE
	. = ..()

/obj/item/bowling_ball/proc/get_target(turf/target, turf/starting)
	var/x_o = (target.x - starting.x)
	var/y_o = (target.y - starting.y)
	var/new_x = clamp((starting.x + (x_o * 3)), 0, world.maxx)
	var/new_y = clamp((starting.y + (y_o * 3)), 0, world.maxy)
	var/turf/newtarget = locate(new_x, new_y, starting.z)
	return newtarget


/obj/item/bowling_ball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	icon_state = "bowling_ball"
	if(!iscarbon(hit_atom))
		return ..()
	var/mob/living/carbon/target_mob = hit_atom
	if(target_mob.body_position == LYING_DOWN)
		return ..()
	playsound(src, 'hippiestation/sound/effects/bowlhit.ogg', 60, 0)
	if(pro_wielded)
		target_mob.Knockdown(80)
		target_mob.setStaminaLoss(40)
		if(prob(30))
			target_mob.emote(pick("scream", "superfart", "cry"))
	else
		target_mob.Knockdown(10)
		if(prob(20))
			target_mob.emote(pick("scream", "laugh"))


