
/datum/rune_spell/tearreality
	secret=TRUE
	name="Tear Reality"
	desc="Bring 8 cultists or prisoners to kickstart the ritual to bring forth Nar-Sie."
	desc_talisman="Use to kickstart the ritual to bring forth Nar-Sie where you stand."
	invocation="Tok-lyr rqa'nap g'lt-ulotf!"
	word1=/datum/rune_word/hell
	word2=/datum/rune_word/join
	word3=/datum/rune_word/self
	page=""
	var/atom/blocker
	var/list/dance_platforms=list()
	var/dance_count=0
	var/dance_target=240
	var/obj/effect/cult_ritual/dance/dance_manager
	var/image/crystals
	var/image/top_crystal
	var/image/narsie_glint

	var/spawners_sent=FALSE
	var/list/pillar_spawners=list()
	var/list/gateway_spawners=list()

/datum/rune_spell/tearreality/cast()
	var/obj/effect/new_rune/R=spell_holder
	R.one_pulse()
	var/turf/T=get_turf(R)

	//The most fickle rune there ever was
	var/datum/team/cult/cult=locate_team(/datum/team/cult)
	if (!istype(cult))
		to_chat(activator, span_warning("Couldn't find the cult faction. Something's broken, please report the issue to an admin or using the BugReport button at the top."))
		return

	switch(cult.stage)
		if (BLOODCULT_STAGE_NORMAL)
			to_chat(activator, span_cult("The rune pulses but no energies respond to its signal."))
			to_chat(activator, span_cult("The Eclipse is coming, but until then this rune serves no purpose."))
			if (!is_station_level(R.z))
				to_chat(activator, span_cult("When it does, you should try again <font color='red'>aboard the station</font>."))
			var/obj/structure/dance_check/checker=new(T, src)
			var/list/moves_to_do=list(SOUTH, WEST, NORTH, NORTH, EAST, EAST, SOUTH, SOUTH, WEST)
			for (var/direction in moves_to_do)
				if (!checker.Move(get_step(checker, direction)))//The checker passes through mobs and non-dense objects, but bumps against dense objects and turfs
					to_chat(activator, span_cult("and <font color='red'>in a more open area</font>."))
			abort()
			return

		if (BLOODCULT_STAGE_MISSED)
			to_chat(activator, span_cult("The rune pulses but no energies respond to its signal."))
			to_chat(activator, span_cult("The window of opportunity has passed along with the Eclipse. Make your way off this space station so you may attempt another day."))
			abort()
			return

		if (BLOODCULT_STAGE_ECLIPSE)
			to_chat(activator, span_cult("The Bloodstone has been raised! Now is not the time to use that rune."))
			abort()
			return

		if (BLOODCULT_STAGE_DEFEATED)
			to_chat(activator, span_cult("The rune pulses but no energies respond to its signal."))
			to_chat(activator, span_cult("With the Bloodstone's collapse, the veil in this region of space has fully mended itself. Another cult will make an attempt in another space station someday."))
			abort()
			return

		if (BLOODCULT_STAGE_NARSIE)
			to_chat(activator, span_cult("The tear has already be opened. Praise the Geometer in this most unholy day!"))
			abort()
			return

	if (cult.stage != BLOODCULT_STAGE_READY)
		to_chat(activator, span_warning("Cult faction appears to be in an unset stage. Something's broken, please report the issue to an admin or using the BugReport button at the top."))
		abort()
		return

	if (!is_station_level(R.z))
		to_chat(activator, span_cult("The rune pulses but no energies respond to its signal."))
		to_chat(activator, span_cult("You should try again <font color='red'>aboard the station</font>."))
		abort()
		return

	if (cult.tear_ritual)
		var/obj/effect/new_rune/U=cult.tear_ritual.spell_holder
		to_chat(activator, span_cult("The rune pulses but no energies respond to its signal."))
		to_chat(activator, span_cult("It appears that another tear is currently being opened. Somewhere...<font color='red'>to the [dir2text(get_dir(R, U))]</font>."))
		abort()
		return

	var/obj/structure/dance_check/checker=new(T, src)
	var/list/moves_to_do=list(SOUTH, WEST, NORTH, NORTH, EAST, EAST, SOUTH, SOUTH, WEST)
	for (var/direction in moves_to_do)
		if (!checker.Move(get_step(checker, direction)))//The checker passes through mobs and non-dense objects, but bumps against dense objects and turfs
			if (blocker)
				to_chat(activator, span_cult("The nearby [blocker] will impede the ritual."))
			to_chat(activator, span_cult("You should try again <font color='red'>in a more open area</font>."))
			abort()
			return

	//Alright now we can get down to business
	cult.tear_ritual=src
	R.overlays.len=0
	R.icon='monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi'
	R.pixel_x=-32
	R.pixel_y=-32
	R.layer=SIGIL_LAYER
	R.plane=GAME_PLANE
	R.set_light(1, 2, COLOR_RED)

	var/datum/holomap_marker/marker=new(R)
	marker.id=HOLOMAP_MARKER_TEARREALITY
	marker.filter=HOLOMAP_FILTER_CULT
	marker.x=R.x
	marker.y=R.y
	marker.z=R.z
	marker.icon='monkestation/code/modules/bloody_cult/icons/holomap_markers.dmi'
	marker.icon_state="tearreality"

	anim(target=R.loc, a_icon='monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi', flick_anim="rune_tearreality_activate", lay=SIGIL_LAYER, offX=-32, offY=-32, plane=GAME_PLANE)

	var/list/platforms_to_spawn=list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)
	for (var/direction in platforms_to_spawn)
		if (!destroying_self)
			var/turf/U=get_step(R, direction)
			shadow(U, R.loc)
			var/obj/effect/cult_ritual/dance_platform/platform=new(U, src)
			dance_platforms += platform
			sleep(1)

	if (!destroying_self)
		message_admins("[key_name(activator)] is preparing the Tear Reality ritual at [T.loc] ([T.x], [T.y], [T.z]).")
		for (var/datum/mind/mind in cult.members)
			var/mob/living/M=mind.current
			to_chat(M, span_cult("The ritual to tear reality apart and pull the station into the realm of Nar-Sie is now taking place in <font color='red'>[T.loc]</font>."))
			to_chat(M, span_cult("A total of 8 persons, either cultists or prisoners, is required for the ritual to start. Go there to help start and then protect the ritual."))

		var/image/I_circle=image('monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi', "rune_tearreality")
		SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, spell_holder)
		I_circle.layer=SIGIL_LAYER
		I_circle.appearance_flags |= RESET_COLOR
		var/image/I_crystals=image('monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi', "tear_stones")
		SET_PLANE_EXPLICIT(I_crystals, GAME_PLANE, spell_holder)
		I_crystals.layer=SIGIL_LAYER
		I_crystals.appearance_flags |= RESET_COLOR
		R.overlays += I_circle
		R.overlays += I_crystals
		custom_rune=TRUE

		crystals=image('monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi', "tear_stones_[min(8, 1+(dance_count/30))]")
		SET_PLANE_EXPLICIT(crystals, GAME_PLANE, spell_holder)

		top_crystal=image('monkestation/code/modules/bloody_cult/icons/cult_96x96.dmi', "tear_stones_top")
		SET_PLANE_EXPLICIT(top_crystal, GAME_PLANE, spell_holder)
		top_crystal.layer=SIGIL_LAYER + 0.1
		top_crystal.appearance_flags |= RESET_COLOR
		R.overlays += top_crystal

		narsie_glint=image('monkestation/code/modules/bloody_cult/icons/cult.dmi', "narsie_glint")
		SET_PLANE_EXPLICIT(narsie_glint, ABOVE_LIGHTING_PLANE, spell_holder)
		narsie_glint.alpha=0
		narsie_glint.pixel_x=32
		narsie_glint.pixel_y=32
		R.overlays += narsie_glint


/datum/rune_spell/tearreality/cast_talisman() //Tear Reality talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/new_rune/R=new(get_turf(activator))
	R.icon_state="temp"
	R.active_spell=new type(activator, R)
	qdel(src)

/datum/rune_spell/tearreality/midcast(mob/add_cultist)
	to_chat(add_cultist, span_cult("Stand in the surrounding circles with fellow cultists and captured prisoners until every spot is filled."))

/datum/rune_spell/tearreality/abort(cause)
	var/datum/team/cult/cult=locate_team(/datum/team/cult)
	if (cult && (cult.tear_ritual == src))
		cult.tear_ritual=null
	if (dance_manager)
		QDEL_NULL(dance_manager)

	var/obj/effect/new_rune/R=spell_holder
	R.set_light(0)
	R.icon='monkestation/code/modules/bloody_cult/icons/deityrunes.dmi'
	R.pixel_x=0
	R.pixel_y=0
	R.layer=CULT_OVERLAY_LAYER
	R.plane=GAME_PLANE

	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		qdel(platform)

	spawn()
		for(var/obj/effect/cult_ritual/tear_spawners/pillar_spawner/CR in pillar_spawners)
			CR.cancel()
			sleep(1)

	for(var/obj/effect/cult_ritual/CR in gateway_spawners)
		qdel(CR)

	..()

/datum/rune_spell/tearreality/proc/dancer_check(mob/living/C)
	var/obj/effect/new_rune/R=spell_holder
	if (dance_platforms.len <= 0)
		return
	if (!isturf(R.loc))//moved inside the blood stone
		return
	if (dance_manager && C)
		dance_manager.dancers |= C
		if(IS_CULTIST(C))
			C.say("Tok-lyr rqa'nap g'lt-ulotf!", "C")
		else
			to_chat(C, span_cult("The tentacles shift and force your body to move alongside them, performing some kind of dance."))
		return
	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		if (!platform.dancer)
			return

	//full dancers!
	var/turf/T=get_turf(R)

	var/datum/team/cult/cult=locate_team(/datum/team/cult)
	cult.twister=TRUE

	if (!spawners_sent)
		spawners_sent=TRUE
		new /obj/effect/cult_ritual/tear_spawners/vertical_spawner(T, src)
		new /obj/effect/cult_ritual/tear_spawners/vertical_spawner/up(T, src)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left(T, src)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right(T, src)

	dance_manager=new(T)

	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		dance_manager.extras += platform
		platform.dance_manager=dance_manager
		if (platform.dancer)
			dance_manager.dancers += platform.dancer
			if(IS_CULTIST(platform.dancer))
				C.say("Tok-lyr rqa'nap g'lt-ulotf!", "C")
			else
				to_chat(C, span_cult("The tentacles shift and force your body to move alongside them, performing some kind of dance."))

	dance_manager.tear=src
	dance_manager.we_can_dance()

/datum/rune_spell/tearreality/proc/update_crystals()
	var/obj/effect/new_rune/R=spell_holder
	R.overlays -= crystals
	R.overlays -= top_crystal
	R.overlays -= narsie_glint
	crystals.icon_state="tear_stones_[min(8, 1+round(dance_count/30))]"
	top_crystal.icon_state="tear_stones_1"
	narsie_glint.alpha=max(0, (dance_count-105)*2)//Nar-Sie's eyes become about visible half-way through the dance
	top_crystal.appearance_flags &= ~RESET_COLOR
	R.overlays += crystals
	R.overlays += top_crystal
	if (isturf(R.loc))
		if (dance_count >= dance_target)// DANCE IS OVER!!
			var/datum/team/cult/cult=locate_team(/datum/team/cult)
			if (cult && !cult.bloodstone)
				var/obj/structure/cult/bloodstone/blood_stone=new(R.loc)
				cult.bloodstone=blood_stone
				cult.stage(BLOODCULT_STAGE_ECLIPSE)
				R.mouse_opacity=0
				R.forceMove(blood_stone)//keeping the rune safe inside the bloodstone
				QDEL_NULL(dance_manager)
				blood_stone.flashy_entrance(src)
		else
			R.overlays += narsie_glint

/datum/rune_spell/tearreality/proc/pillar_update(update_level)
	for (var/obj/effect/cult_ritual/tear_spawners/pillar_spawner/PS in pillar_spawners)
		PS.execute(update_level)

	for (var/obj/effect/cult_ritual/tear_spawners/gateway_spawner/GS in gateway_spawners)
		GS.execute(update_level)

/datum/rune_spell/tearreality/proc/lost_dancer()
	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		if (platform.dancer)
			return
	dance_count=0
	QDEL_NULL(dance_manager)
	var/obj/effect/new_rune/R=spell_holder
	R.overlays -= crystals
	R.overlays -= top_crystal
	top_crystal.icon_state="tear_stones_top"
	top_crystal.appearance_flags |= RESET_COLOR
	R.overlays += top_crystal

/datum/rune_spell/tearreality/proc/dance_increment(mob/living/L)
	if (dance_manager)
		var/increment=0.5
		if (iscarbon(L))
			var/mob/living/carbon/C=L
			if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult))
				increment += 0.5
			increment += (C.get_cult_power()) / 100

			var/obj/item/candle/blood/candle
			if (istype(C.get_active_held_item(), /obj/item/candle/blood))
				candle=C.get_active_held_item()
			else if (istype(C.get_inactive_held_item(), /obj/item/candle/blood))
				candle=C.get_inactive_held_item()
			if (candle && candle.lit)
				increment += 0.5
		dance_count += increment
