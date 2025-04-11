
/datum/rune_spell/pulse
	name = "Dark Pulse"
	desc = "Scramble the circuits of nearby devices."
	desc_talisman = "Use to scramble the circuits of nearby devices."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/technology
	page = "This rune triggers a strong EMP that messes with electronic machinery, devices, and robots up to 3 tiles away.\
		<br><br>Cultists and the objects they carry will be unaffected.\
		<br><br>You may also slap  someone directly with the talisman to have its effects only affect them, but with double intensity."
	touch_cast = 1

/datum/rune_spell/pulse/cast_touch(var/mob/M)
	var/turf/T = get_turf(M)
	invoke(activator, invocation, 1)
	playsound(T, 'sound/items/Welder2.ogg', 25, 0, -5)
	playsound(T, 'monkestation/code/modules/bloody_cult/sound/bloodboil.ogg', 25, 0, -5)
	var/obj/effect/abstract/animation = anim(target = T, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', flick_anim = "rune_pulse", sleeptime = 15, plane = GAME_PLANE_UPPER, lay = MOB_UPPER_LAYER)
	animation.add_particles(PS_CULT_SMOKE_BOX)
	spawn(6)
		animation.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE_BOX)
	M.emp_act(1)
	M.emp_act(1)
	qdel(src)

/datum/rune_spell/pulse/cast()
	var/turf/T = get_turf(spell_holder)
	playsound(T, 'sound/items/Welder2.ogg', 25, 1)
	//T.hotspot_expose(700, 125, surfaces = 1)
	spawn(0)
		darkpulse(T, 3, 3, cultist = activator)
	qdel(spell_holder)

/proc/darkpulse(turf/epicenter, heavy_range, light_range, log = 0, var/mob/living/cultist = null)
	if(!epicenter)
		return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/max_range = max(heavy_range, light_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	if(log)
		message_admins("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name] ([x0], [y0], [z0]) (<A HREF = '?_src_ = holder;adminplayerobservecoodjump = 1;X = [x0];Y = [y0];Z = [z0]'>JMP</A>).")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name].")

	spawn()
		for (var/mob/M in GLOB.player_list)
			//Double check for client
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && (M_turf.z == epicenter.z))
					var/dist = cheap_pythag(M_turf.x - x0, M_turf.y - y0)
					if((dist <= round(heavy_range + world.view - 2, 1)) && (M_turf.z - epicenter.z <= max_range) && (epicenter.z - M_turf.z <= max_range))
						M.playsound_local(epicenter, 'monkestation/code/modules/bloody_cult/sound/bloodboil.ogg', 25, 0)

		for(var/turf/T in spiral_range(max_range, epicenter))
			CHECK_TICK
			spawn(get_dist(T, epicenter))
				var/obj/effect/abstract/animation = anim(target = T, a_icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi', flick_anim = "rune_pulse", sleeptime = 15, plane = GAME_PLANE_UPPER, lay = MOB_UPPER_LAYER)
				animation.add_particles(PS_CULT_SMOKE_BOX)
				sleep(6)
				animation.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE_BOX)
			var/dist = cheap_pythag(T.x - x0, T.y - y0)
			if(dist > max_range)
				continue
			var/act = 2
			if(dist <= heavy_range)
				act = 1
			for(var/atom/movable/A in T.contents)
				if (cultist && isliving(A))
					var/mob/living/L = A
					if (IS_CULTIST(L))
						continue
					else if (L.client && L.stat != DEAD)
						var/datum/antagonist/cult/cult_datum = cultist.mind.has_antag_datum(/datum/antagonist/cult)
						cult_datum.gain_devotion(50, DEVOTION_TIER_2, "EMP", L)
				A.emp_act(act)
	return
