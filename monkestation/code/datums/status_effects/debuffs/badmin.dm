/datum/status_effect/badmin_stone
	id = "badmin_stone"
	status_type = STATUS_EFFECT_MULTIPLE
	duration = -1
	tick_interval = 10
	alert_type = null
	var/obj/item/badmin_stone/stone
	var/next_msg = 0

/datum/status_effect/badmin_stone/on_creation(mob/living/new_owner, obj/item/badmin_stone/new_stone)
	. = ..()
	if(.)
		stone = new_stone

/datum/status_effect/badmin_stone/Destroy()
	stone = null
	return ..()

/datum/status_effect/badmin_stone/tick()
	var/has_other_stone = FALSE
	if(istype(stone.loc, /obj/item/badmin_gauntlet))
		return
	for(var/obj/item/badmin_stone/badminstone in owner.get_contents())
		if(badminstone != stone && !istype(badminstone.loc, /obj/item/badmin_gauntlet))
			has_other_stone = TRUE
	if(!has_other_stone)
		return
	if(world.time >= next_msg)
		owner.visible_message("<span class='danger'>[owner]'s [pick("face", "hands", "arms", "legs")] bruises a bit...</span>", "<span class='userdanger'>Your body can't handle holding two badmin stones at once!</span>")
		next_msg = world.time + rand(10 SECONDS, 25 SECONDS)
	owner.adjustBruteLoss(4.5) //Starting at 7 damage for 2 stones, plus 4.5 damage per extra stone.
