/datum/action/cooldown/spell/pointed/wraith/possess_object
	name = "Possess Object"
	desc = "Animates an object with you being in control of it"
	button_icon_state = "possess_object"

	essence_cost = 300
	cooldown_time = 2.5 MINUTES

	aim_assist = FALSE

/datum/action/cooldown/spell/pointed/wraith/possess_object/before_cast(obj/item/cast_on)
	. = ..()
	if(!istype(cast_on) || cast_on.anchored || cast_on.density)
		. |= SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/possess_object/cast(obj/item/cast_on)
	. = ..()
	new /obj/effect/temp_visual/revenant(get_turf(cast_on))
	var/mob/living/basic/wraith_spawn/animated_item/mob = new(get_turf(cast_on), cast_on, owner)
	if(istype(cast_on, /obj/item/weldingtool) || isgrenade(cast_on))
		cast_on.attack_self(mob)
