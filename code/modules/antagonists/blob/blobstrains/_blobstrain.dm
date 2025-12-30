GLOBAL_LIST_INIT(valid_blobstrains, subtypesof(/datum/blobstrain) - /datum/blobstrain/reagent)

/datum/blobstrain
	/// The name of this strain
	var/name
	/// The description for this strain
	var/description //where is this used
	/// The color applied to our tiles
	var/color = COLOR_BLACK
	/// Used for blobs on invalid turfs
	var/cached_faded_color
	/// The color that stuff like healing effects and the overmind camera gets
	var/complementary_color = COLOR_BLACK
	/// A short description of the power and its effects
	var/shortdesc = null
	/// Any long, blob-tile specific effects
	var/effectdesc = null
	/// Short descriptor of what the strain does damage-wise, generally seen in the reroll menu
	var/analyzerdescdamage = "Unknown. Report this bug to a coder, or just adminhelp."
	/// Short descriptor of what the strain does in general, generally seen in the reroll menu
	var/analyzerdesceffect
	/// Blobbernaut attack verb
	var/blobbernaut_message = "slams"
	/// Message sent to any mob hit by the blob
	var/message = "The blob strikes you"
	/// Gets added onto 'message' if the mob stuck is of type living
	var/message_living = null

	///Ref to the team that owns us
	var/datum/team/blob/blob_team

	// Various vars that strains can buff the blob with
	/// HP regen bonus added by strain
	var/core_regen_bonus = 0
	/// resource point bonus added by strain
	var/point_rate_bonus = 0

	/// Adds to claim, pulse, and expand range
	var/core_range_bonus = 0
	/// Extra range up to which the core reinforces blobs
	var/core_strong_reinforcement_range_bonus = 0
	/// Extra range up to which the core reinforces blobs into reflectors
	var/core_reflector_reinforcement_range_bonus = 0

	/// Adds to claim, pulse, and expand range
	var/node_range_bonus = 0
	/// Nodes can sustain this many extra spores with this strain
	var/node_spore_bonus = 0
	/// Extra range up to which the node reinforces blobs
	var/node_strong_reinforcement_range_bonus = 0
	/// Extra range up to which the node reinforces blobs into reflectors
	var/node_reflector_reinforcement_range_bonus = 0

	/// Extra spores produced by factories with this strain
	var/factory_spore_bonus = 0

	/// Multiplies the max and current health of every blob with this value upon selecting this strain.
	var/max_structure_health_multiplier = 1
	/// Multiplies the max and current health of every mob with this value upon selecting this strain.
	var/max_mob_health_multiplier = 1

/datum/blobstrain/New(datum/team/blob/new_team)
	if(!istype(new_team))
		stack_trace("blobstrain created without team")
	blob_team = new_team
	cached_faded_color = BlendRGB(color, COLOR_WHITE, 0.5)

/datum/blobstrain/Destroy()
	blob_team = null
	return ..()

/datum/blobstrain/proc/on_gain()
	if(blob_team.main_overmind?.blob_core) //only apply core buffs to the main core
		var/obj/structure/blob/special/node/core/main_core = blob_team.main_overmind.blob_core
		main_core.claim_range += core_range_bonus
		main_core.pulse_range += core_range_bonus
		main_core.expand_range += core_range_bonus
		main_core.strong_reinforce_range += core_strong_reinforcement_range_bonus
		main_core.reflector_reinforce_range += core_reflector_reinforcement_range_bonus

	var/list/looked_through = blob_team.all_blobs_by_type[/obj/structure/blob/special/node]
	if(looked_through)
		for(var/obj/structure/blob/special/node/blob_node in looked_through)
			blob_node.claim_range += node_range_bonus
			blob_node.pulse_range += node_range_bonus
			blob_node.expand_range += node_range_bonus
			blob_node.strong_reinforce_range += node_strong_reinforcement_range_bonus
			blob_node.reflector_reinforce_range += node_reflector_reinforcement_range_bonus

	looked_through = blob_team.all_blobs_by_type[/obj/structure/blob/special/factory]
	if(looked_through)
		for(var/obj/structure/blob/special/factory/blob_factory in looked_through)
			blob_factory.max_spores += factory_spore_bonus

	for(var/obj/structure/blob/struc as anything in blob_team.all_blob_tiles)
		struc.modify_max_integrity(struc.max_integrity * max_structure_health_multiplier)
		struc.update_appearance()

	for(var/mob/living/blob_mob as anything in blob_team.blob_mobs)
		blob_mob.maxHealth *= max_mob_health_multiplier
		blob_mob.health *= max_mob_health_multiplier
		blob_mob.update_icons() //If it's getting a new strain, tell it what it does!
		to_chat(blob_mob, "Your overmind's blob strain is now: <b><font color=\"[color]\">[name]</b></font>!")
		to_chat(blob_mob, "The <b><font color=\"[color]\">[name]</b></font> strain [shortdesc ? "[shortdesc]" : "[description]"]")

	for(var/mob/eye/blob/overmind in blob_team.overminds)
		apply_gain_effects(overmind)

/datum/blobstrain/proc/apply_gain_effects(mob/eye/blob/overmind)
	overmind.color = complementary_color

/datum/blobstrain/proc/on_lose()
	if(blob_team.main_overmind.blob_core)
		var/obj/structure/blob/special/node/core/main_core = blob_team.main_overmind.blob_core
		main_core.claim_range -= core_range_bonus
		main_core.pulse_range -= core_range_bonus
		main_core.expand_range -= core_range_bonus
		main_core.strong_reinforce_range -= core_strong_reinforcement_range_bonus
		main_core.reflector_reinforce_range -= core_reflector_reinforcement_range_bonus

	var/list/looked_through = blob_team.all_blobs_by_type[/obj/structure/blob/special/node]
	if(looked_through)
		for(var/obj/structure/blob/special/node/blob_node in looked_through)
			blob_node.claim_range -= node_range_bonus
			blob_node.pulse_range -= node_range_bonus
			blob_node.expand_range -= node_range_bonus
			blob_node.strong_reinforce_range -= node_strong_reinforcement_range_bonus
			blob_node.reflector_reinforce_range -= node_reflector_reinforcement_range_bonus

	looked_through = blob_team.all_blobs_by_type[/obj/structure/blob/special/factory]
	if(looked_through)
		for(var/obj/structure/blob/special/factory/blob_factory in looked_through)
			blob_factory.max_spores -= factory_spore_bonus

	for(var/obj/structure/blob/struc in blob_team.all_blob_tiles)
		struc.modify_max_integrity(struc.max_integrity / max_structure_health_multiplier)

	for(var/mob/living/blob_mob in blob_team.blob_mobs)
		blob_mob.maxHealth /= max_mob_health_multiplier
		blob_mob.health /= max_mob_health_multiplier

	for(var/mob/eye/blob/overmind in blob_team.overminds)
		apply_loss_effects(overmind)

/datum/blobstrain/proc/apply_loss_effects(mob/eye/blob/overmind)
	return

///Called every process() tick of our team, returns how many points to give our main_overmind, lesser overminds will be given half of that(rounded up)
/datum/blobstrain/proc/core_process()
	return blob_team.point_rate + point_rate_bonus

///Called whenever a special tile is pulsed
/datum/blobstrain/proc/on_special_pulsed(obj/structure/blob/special/pulsed)
	return

/datum/blobstrain/proc/on_sporedeath(mob/living/spore)
	return

/datum/blobstrain/proc/send_message(mob/living/sent_to)
	var/totalmessage = message
	if(message_living && !issilicon(sent_to))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(sent_to, span_userdanger("[totalmessage]"))

/datum/blobstrain/proc/attack_living(mob/living/attacked, list/nearby_blobs, mob/eye/blob/attacker) // When the blob attacks people
	send_message(attacked)

/datum/blobstrain/proc/blobbernaut_attack(mob/living/attacked, blobbernaut) // When this blob's blobbernaut attacks people
	return

/datum/blobstrain/proc/damage_reaction(obj/structure/blob/damaged, damage, damage_type, damage_flag, coefficient = 1) //when the blob takes damage, do this
	return coefficient*damage

///Called in a tiles atom_destruction()
/datum/blobstrain/proc/death_reaction(obj/structure/blob/dying, damage_flag)
	return

///Called near the start of /obj/structure/blob/expand(), before most logic runs
/datum/blobstrain/proc/before_expansion(obj/structure/blob/expanding, turf/target_turf)
	return

/datum/blobstrain/proc/expand_reaction(obj/structure/blob/expanding, obj/structure/blob/new_blob, turf/target_turf, mob/eye/blob/controller) //when the blob expands, do this
	return

/datum/blobstrain/proc/tesla_reaction(obj/structure/blob/zapped, power, coefficient = 1) //when the blob is hit by a tesla bolt, do this
	return TRUE //return FALSE to ignore damage

//should refactor this to use signals
/datum/blobstrain/proc/extinguish_reaction(obj/structure/blob/extinguished, coefficient = 1) //when the blob is hit with water, do this
	return

/datum/blobstrain/proc/emp_reaction(obj/structure/blob/emped, severity, coefficient = 1) //when the blob is hit with an emp, do this
	return

/datum/blobstrain/proc/examine(mob/user)
	return list("<b>Progress to Critical Mass:</b> [span_notice("[blob_team.blobs_legit]/[blob_team.blobwincount].")]")
