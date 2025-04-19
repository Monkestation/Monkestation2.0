/datum/control/soulblade
	var/obj/item/melee/soulblade/blade = null
	var/move_delay = 0

/datum/control/soulblade/New(mob/new_controller, atom/new_controlled)
	..()
	blade = new_controlled

/datum/control/soulblade/is_valid(direction)
	if (blade.blood <= 0 || move_delay || blade.throwing)
		return 0
	if (!isturf(blade.loc))
		if (istype(blade.loc, /obj/structure/cult/altar))
			var/obj/structure/cult/altar/A = blade.loc
			blade.forceMove(A.loc)
			A.blade = null
			playsound(A.loc, 'sound/weapons/blade1.ogg', 50, 1)
			if (A.buckled_mobs)
				var/mob/M = A.buckled_mobs[1]
				A.unbuckle_mob(M)
			A.update_icon()
		else
			return 0
	return ..()

/datum/control/soulblade/Move_object(direction)
	if(!controlled)
		return
	var/atom/start = blade.loc
	if(!is_valid())
		return
	step(controlled, direction)
	controlled.dir = direction
	if (blade.loc != start)
		if (!blade.linked_cultist || (get_dist(get_turf(blade.linked_cultist), get_turf(controller)) > 5))
			blade.blood = max(blade.blood-1, 0)
		move_delay = 1
		spawn(blade.movespeed)
			move_delay = 0

	controller.DisplayUI("Soulblade")
