//I will need to recode parts of this but I am way too tired atm //I don't know who left this comment but they never did come back
/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	light_outer_range = 2
	desc = "A thick wall of writhing tendrils."
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	pass_flags_self = PASSBLOB
	can_atmos_pass = ATMOS_PASS_PROC
	obj_flags = CAN_BE_HIT|BLOCK_Z_OUT_DOWN // stops blob mobs from falling on multiz.
	max_integrity = BLOB_REGULAR_MAX_HP
	armor_type = /datum/armor/structure_blob
	/// How many points does it cost to create a blob of this type
	var/point_cost = 0
	/// How many points the blob gets back when it removes a blob of that type. If less than 0, blob cannot be removed.
	var/point_return = 0
	/// how much health this blob regens when pulsed
	var/health_regen = BLOB_REGULAR_HP_REGEN
	/// Multiplies brute damage by this
	var/brute_resist = BLOB_BRUTE_RESIST
	/// Multiplies burn damage by this
	var/fire_resist = BLOB_FIRE_RESIST
	/// If the blob blocks atmos and heat spread
	var/atmosblock = FALSE
	/// is this tile valid for winning
	var/legit = FALSE
	/// ref to the team that we belong to, should only be updated by set_owner()
	VAR_FINAL/datum/team/blob/blob_team

	/// We got pulsed when?
	COOLDOWN_DECLARE(pulse_timestamp)
	/// we got healed when?
	COOLDOWN_DECLARE(heal_timestamp)

/datum/armor/structure_blob
	fire = 80
	acid = 70
	laser = 50

/obj/structure/blob/Initialize(mapload, datum/team/blob/owning_team)
	. = ..()
	if(owning_team)
		set_owner(owning_team)
	register_context()
	GLOB.blobs += src //Keep track of the blob in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_appearance()
	if(atmosblock)
		air_update_turf(TRUE, TRUE)
	consume_tile()
	if(!QDELETED(src)) //Consuming our tile can in rare cases cause us to del
		AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOB, CELL_VIRUS_TABLE_GENERIC, 2, 2)

/obj/structure/blob/Destroy(force)
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(TRUE, FALSE)
	set_owner(null, FALSE)
	GLOB.blobs -= src //it's no longer in the all blobs list either
	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, TRUE) //Expand() is no longer broken, no check necessary.
	return ..()

/obj/structure/blob/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(!isovermind(user))
		return .

	if(istype(src, /obj/structure/blob/normal))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Create strong blob"
	if(istype(src, /obj/structure/blob/shield) && !istype(src, /obj/structure/blob/shield/reflective))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Create reflective blob"

	if(point_return >= 0)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove blob"

	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/Adjacent(atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/blob) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/blob/block_superconductivity()
	return atmosblock

/obj/structure/blob/can_atmos_pass(turf/T, vertical = FALSE)
	return !atmosblock

/obj/structure/blob/update_icon() //Updates color based on overmind color if we have an overmind.
	. = ..()
	if(blob_team)
		add_atom_colour(blob_team.blobstrain.color, FIXED_COLOUR_PRIORITY)
		if(!legit)
			add_atom_colour(blob_team.blobstrain.cached_faded_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/blob/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity > 0)
		blob_team?.blobstrain.emp_reaction(src, severity)
		if(prob(100 - severity * 30))
			new /obj/effect/temp_visual/emp(get_turf(src))

/obj/structure/blob/zap_act(power, zap_flags)
	if(blob_team?.blobstrain.tesla_reaction(src, power))
		take_damage(power * 0.0025, BURN, ENERGY)
	else
		take_damage(power * 0.0025, BURN, ENERGY)
	power -= power * 0.0025 //You don't get to do it for free
	return ..() //You don't get to do it for free

/obj/structure/blob/extinguish()
	. = ..()
	blob_team.blobstrain.extinguish_reaction(src)

/obj/structure/blob/hulk_damage()
	return 15

/obj/structure/blob/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(attacking_item.tool_behaviour == TOOL_ANALYZER)
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<b>The analyzer beeps once, then reports:</b><br>")
		playsound(attacking_item, 'sound/machines/ping.ogg', 70)
		if(blob_team)
			to_chat(user, "<b>Progress to Critical Mass:</b> [span_notice("[blob_team.blobs_legit]/[blob_team.blobwincount].")]")
			to_chat(user, chemeffectreport(user).Join("\n"))
		else
			to_chat(user, "<b>Blob core neutralized. Critical mass no longer attainable.</b>")
		to_chat(user, typereport(user).Join("\n"))
	else
		return ..()

/obj/structure/blob/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(ROLE_BLOB in user.faction) //sorry, but you can't kill the blob as a blobbernaut
		return
	..()

/obj/structure/blob/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/blob/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
			EMPTY_BLOCK_GUARD // Pass
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = get_armor_rating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	if(blob_team && damage_flag)
		damage_amount = blob_team.blobstrain.damage_reaction(src, damage_amount, damage_type, damage_flag)
	return damage_amount

/obj/structure/blob/take_damage(damage_amount, damage_type = BRUTE, damage_flag = FALSE, sound_effect = TRUE, attack_dir)
	. = ..()
	if(. && atom_integrity > 0)
		update_appearance()

/obj/structure/blob/atom_destruction(damage_flag)
	blob_team?.blobstrain.death_reaction(src, damage_flag)
	return ..()

/obj/structure/blob/examine(mob/user)
	. = ..()
	var/datum/atom_hud/hud_to_check = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	if(HAS_TRAIT(user, TRAIT_RESEARCH_SCANNER) || hud_to_check.hud_users[user])
		. += "<b>Your HUD displays an extensive report...</b><br>"
		if(blob_team)
			. += blob_team.blobstrain.examine(user)
		else
			. += "<b>Core neutralized. Critical mass no longer attainable.</b>"
		. += chemeffectreport(user)
		. += typereport(user)
	else
		if(blob_team && (isovermind(user) || isobserver(user)))
			. += blob_team.blobstrain.examine(user)
		. += "It seems to be made of [get_chem_name()]."

/obj/structure/blob/proc/chemeffectreport(mob/user) as /list
	RETURN_TYPE(/list)
	. = list()
	if(blob_team)
		. += list("<b>Material: <font color=\"[blob_team.blobstrain.color]\">[blob_team.blobstrain.name]</font>[span_notice(".")]</b>",
		"<b>Material Effects:</b> [span_notice("[blob_team.blobstrain.analyzerdescdamage]")]",
		"<b>Material Properties:</b> [span_notice("[blob_team.blobstrain.analyzerdesceffect || "N/A"]")]")
	else
		. += "<b>No Material Detected!</b>"

/obj/structure/blob/proc/typereport(mob/user)
	RETURN_TYPE(/list)
	return list("<b>Blob Type:</b> [span_notice("[uppertext(initial(name))]")]",
							"<b>Health:</b> [span_notice("[atom_integrity]/[max_integrity]")]",
							"<b>Effects:</b> [span_notice("[scannerreport()]")]")

/obj/structure/blob/proc/change_to(passed_type, datum/team/blob/controller)
	if(!ispath(passed_type))
		CRASH("change_to(): invalid type for blob")
	var/obj/structure/blob/changed_to = new passed_type(src.loc, controller)
	changed_to.creation_action()
	changed_to.update_appearance()
	changed_to.setDir(dir)
	qdel(src)
	return changed_to

/obj/structure/blob/proc/be_pulsed()
	if(COOLDOWN_FINISHED(src, pulse_timestamp))
		consume_tile()
		if(COOLDOWN_FINISHED(src, heal_timestamp))
			update_integrity(min(atom_integrity + health_regen, max_integrity))
			COOLDOWN_START(src, heal_timestamp, 2 SECONDS)
		update_appearance()
		COOLDOWN_START(src, pulse_timestamp, 1 SECOND)
		return TRUE //we did it, we were pulsed!
	return FALSE //oh no we failed

/obj/structure/blob/proc/scannerreport()
	return "None."

/obj/structure/blob/proc/get_chem_name()
	return blob_team?.blobstrain.name || "some kind of organic tissue"

///Update our blob_team to the passed value, returns our old team if we had one and changed team
/obj/structure/blob/proc/set_owner(datum/team/blob/new_owner, update_visuals = TRUE)
	if(new_owner == blob_team)
		return FALSE

	. = blob_team
	if(new_owner && !istype(new_owner))
		if(istype(new_owner, /mob/eye/blob))
			new_owner = astype(new_owner, /mob/eye/blob).antag_team
		else
			stack_trace("Blob tile\[[src]\] passed an invalid new_owner\[[new_owner], [new_owner.type]\].")

	check_legit()
	blob_team = new_owner
	if(.)
		var/datum/team/blob/old_owner = .
		old_owner.all_blob_tiles -= src
		old_owner.all_blobs_by_type[src.type] -= src
		if(legit)
			old_owner.blobs_legit--

	if(blob_team)
		blob_team.all_blob_tiles += src
		var/list/typed_blobs = blob_team.all_blobs_by_type[src.type]
		if(!typed_blobs)
			blob_team.all_blobs_by_type[src.type] = list(src)
		else
			typed_blobs += src

		if(legit)
			blob_team.blobs_legit++
			if(!blob_team.victory_in_progress)
				blob_team.highest_tile_count = max(blob_team.highest_tile_count, blob_team.blobs_legit)

	if(update_visuals)
		update_appearance()

///Check if our area allows blobs and update related values
/obj/structure/blob/proc/check_legit(new_team = FALSE)
	var/old_value = legit
	legit = (astype(get_step(src, 0).loc, /area).area_flags & BLOBS_ALLOWED)
	if(legit != old_value && blob_team)
		if(legit)
			blob_team.blobs_legit++
		else
			blob_team.blobs_legit--

/obj/structure/blob/proc/handle_ctrl_click(mob/eye/blob/overmind)
	return

/obj/structure/blob/proc/attempt_removal(mob/eye/blob/overmind)
	if(QDELETED(src))
		return FALSE

	if(point_return && overmind)
		overmind.add_points(point_return)
		to_chat(overmind, span_notice("Gained [point_return] resources from removing \the [src]."))
		balloon_alert(overmind, "+[point_return] resource\s")

	qdel(src)
	return TRUE
