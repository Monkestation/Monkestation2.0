/obj/structure/glowshroom
	/// A cooldown to "spread out" glowshroom processing whenever tick usage is at the limit.
	COOLDOWN_DECLARE(antilag_cooldown)

/obj/structure/glowshroom/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, antilag_cooldown))
		return
	if(TICK_CHECK)
		COOLDOWN_START(src, antilag_cooldown, rand(1 SECONDS, 5 SECONDS))
		return
	return ..()
