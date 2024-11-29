/datum/action/cooldown/spell/pointed/wraith/decay
	name = "Decay"
	desc = "Cause instant exhaustion on living targets, and manipulate the electronics of devices."
	button_icon_state = "decay"

	essence_cost = 30
	cooldown_time = 1 MINUTE

/datum/action/cooldown/spell/pointed/wraith/decay/cast(mob/living/carbon/cast_on)
	. = ..()
	new /obj/effect/temp_visual/revenant(get_turf(cast_on))
	if(istype(cast_on)) // hooman
		to_chat(cast_on, span_revenwarning("You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")]."))
		cast_on.stamina.adjust(-rand(100, 120), FALSE)
		return

	if(iscyborg(cast_on))
		var/mob/living/silicon/robot/filthy_silicon_scum = cast_on
		playsound(filthy_silicon_scum, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		filthy_silicon_scum.spark_system.start()
		filthy_silicon_scum.emp_act(EMP_HEAVY)
		return

	if(isbot(cast_on))
		var/mob/living/simple_animal/bot/blessed_silicon_bot = cast_on
		blessed_silicon_bot.bot_cover_flags &= ~BOT_COVER_LOCKED
		blessed_silicon_bot.bot_cover_flags |= BOT_COVER_OPEN

	cast_on.emag_act(owner)
