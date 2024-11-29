/datum/action/cooldown/spell/pointed/wraith/animate_object
	name = "Animate Object"
	desc = "Animates an object to attack any nearby humans."
	button_icon_state = "animate_object"

	essence_cost = 100
	cooldown_time = 30 SECONDS

	aim_assist = FALSE

/datum/action/cooldown/spell/pointed/wraith/animate_object/before_cast(obj/item/cast_on)
	. = ..()
	if(!istype(cast_on))
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

	if(cast_on.anchored || cast_on.density) // Don't throw around anchored things or dense things
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/wraith/animate_object/cast(obj/item/cast_on)
	. = ..()
	new /obj/effect/temp_visual/revenant(get_turf(cast_on))
	if(istype(cast_on, /obj/item/weldingtool) || isgrenade(cast_on))
		cast_on.attack_self(src)
	new /mob/living/basic/wraith_spawn/animated_item(get_turf(cast_on), cast_on)
