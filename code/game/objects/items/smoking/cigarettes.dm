//cleansed 9/15/2012 17:48

/*
CONTAINS:
CIGARETTES
CIGARS
SMOKING PIPES

CIGARETTE PACKETS ARE IN FANCY.DM
*/

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	inhand_icon_state = "cigon" //gets overriden during intialize(), just have it for unit test sanity.
	throw_speed = 0.5
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	heat = 1000
	light_outer_range = 1
	light_color = LIGHT_COLOR_FIRE
	light_system = OVERLAY_LIGHT
	light_on = FALSE
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	throw_verb = "flick"
	/// Whether this cigarette has been lit.
	VAR_FINAL/lit = FALSE
	/// Whether this cigarette should start lit.
	var/starts_lit = FALSE
	// Note - these are in masks.dmi not in cigarette.dmi
	/// The icon state used when this is lit.
	var/icon_on = "cigon"
	/// The icon state used when this is extinguished.
	var/icon_off = "cigoff"
	/// The inhand icon state used when this is lit.
	var/inhand_icon_on = "cigon"
	/// The inhand icon state used when this is extinguished.
	var/inhand_icon_off = "cigoff"
	/// How long the cigarette lasts in seconds
	var/smoketime = 6 MINUTES
	/// How much time between drags of the cigarette.
	var/dragtime = 10 SECONDS
	/// The cooldown that prevents just huffing the entire cigarette at once.
	COOLDOWN_DECLARE(drag_cooldown)
	/// The type of cigarette butt spawned when this burns out.
	var/type_butt = /obj/item/cigbutt
	/// The capacity for chems this cigarette has.
	var/chem_volume = 30
	/// The reagents that this cigarette starts with.
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)
	/// Should we smoke all of the chems in the cig before it runs out. Splits each puff to take a portion of the overall chems so by the end you'll always have consumed all of the chems inside.
	var/smoke_all = TRUE
	/// How much damage this deals to the lungs per drag.
	var/lung_harm = 1
	/// If, when glorf'd, we will choke on this cig forever
	var/choke_forever = FALSE
	/// When choking, what is the maximum amount of time we COULD choke for
	var/choke_time_max = 30 SECONDS // I am mean
	/// What type of pollution does this produce on smoking, changed to weed pollution sometimes, monkestation edit
	var/pollution_type = /datum/pollutant/smoke
	/// The particle effect of the smoke rising out of the cigarette when lit
	VAR_PRIVATE/obj/effect/abstract/particle_holder/cig_smoke
	/// The particle effect of the smoke rising out of the mob when...smoked
	VAR_PRIVATE/obj/effect/abstract/particle_holder/mob_smoke
	/// How long the current mob has been smoking this cigarette
	VAR_FINAL/how_long_have_we_been_smokin = 0 SECONDS

/obj/item/clothing/mask/cigarette/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff, 90, list(BODY_ZONE_PRECISE_MOUTH), slot_flags) //90% to knock off when wearing a mask
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_MASK|ITEM_SLOT_HANDS)
	icon_state = icon_off
	inhand_icon_state = inhand_icon_off

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(mob_smoke)
	QDEL_NULL(cig_smoke)
	return ..()

/obj/item/clothing/mask/cigarette/equipped(mob/equipee, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		UnregisterSignal(equipee, list(COMSIG_HUMAN_FORCESAY, COMSIG_ATOM_DIR_CHANGE))
		return
	RegisterSignal(equipee, COMSIG_HUMAN_FORCESAY, PROC_REF(on_forcesay))
	RegisterSignal(equipee, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_mob_dir_change))

	if(lit && iscarbon(loc))
		make_mob_smoke(loc)

/obj/item/clothing/mask/cigarette/dropped(mob/dropee, silent)
	. = ..()
	// Moving the cigarette from mask to hands (or pocket I guess) will emit a larger puff of smoke
	if(!QDELETED(src) && !QDELETED(dropee) && how_long_have_we_been_smokin >= 4 SECONDS && iscarbon(dropee) && iscarbon(loc))
		var/mob/living/carbon/smoker = dropee
		// This relies on the fact that dropped is called before slot is nulled
		if(src == smoker.wear_mask && !smoker.incapacitated())
			long_exhale(smoker)

	UnregisterSignal(dropee, list(COMSIG_HUMAN_FORCESAY, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(mob_smoke)
	how_long_have_we_been_smokin = 0 SECONDS

/obj/item/clothing/mask/cigarette/proc/on_forcesay(mob/living/source)
	SIGNAL_HANDLER
	source.apply_status_effect(/datum/status_effect/choke, src, lit, choke_forever ? -1 : rand(25 SECONDS, choke_time_max))

/obj/item/clothing/mask/cigarette/proc/on_mob_dir_change(mob/living/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(isnull(mob_smoke))
		return
	update_particle_position(mob_smoke, new_dir)

/obj/item/clothing/mask/cigarette/proc/update_particle_position(obj/effect/abstract/particle_holder/to_edit, new_dir = loc.dir)
	var/new_x = 0
	var/human_height_offset
	var/new_layer = initial(to_edit.layer)
	if(new_dir & NORTH)
		new_x = 4
		new_layer = BELOW_MOB_LAYER
	else if(new_dir & SOUTH)
		new_x = -4
	else if(new_dir & EAST)
		new_x = 8
	else if(new_dir & WEST)
		new_x = -8
	if(ishuman(loc))
		var/mob/living/carbon/human/our_smoker = loc
		human_height_offset = HUMAN_HEIGHT_MEDIUM - our_smoker.mob_height
	to_edit.set_particle_position(new_x, 8 - human_height_offset, 0)
	to_edit.layer = new_layer

/obj/item/clothing/mask/cigarette/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is huffing [src] as quickly as [user.p_they()] can! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer."))
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(lit)
		return ..()

	var/lighting_text = attacking_item.ignition_effect(src, user)
	if(!lighting_text)
		return ..()

	if(!check_oxygen(user)) //cigarettes need oxygen
		balloon_alert(user, "no air!")
		return ..()

	if(smoketime > 0)
		light(lighting_text)
	else
		to_chat(user, span_warning("There is nothing to smoke!"))

/// Checks that we have enough air to smoke
/obj/item/clothing/mask/cigarette/proc/check_oxygen(mob/user)
	if(reagents.has_reagent(/datum/reagent/oxygen))
		return TRUE
	var/datum/gas_mixture/air = return_air()
	if(!isnull(air) && air.has_gas(/datum/gas/oxygen, 1))
		return TRUE
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/the_smoker = user
	return the_smoker.can_breathe_helmet()

/obj/item/clothing/mask/cigarette/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
		return NONE
	var/obj/item/reagent_containers/cup/glass = interacting_with
	if(!istype(glass)) //you can dip cigarettes into beakers
		return NONE

	if(glass.reagents.trans_to(src, chem_volume, transfered_by = user)) //if reagents were transfered, show the message
		to_chat(user, span_notice("You dip \the [src] into \the [glass]."))
	//if not, either the beaker was empty, or the cigarette was full
	else if(!glass.reagents.total_volume)
		to_chat(user, span_warning("[glass] is empty!"))
	else
		to_chat(user, span_warning("[src] is full!"))
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/mask/cigarette/update_icon_state()
	. = ..()
	if(lit)
		icon_state = icon_on
		inhand_icon_state = inhand_icon_on
	else
		icon_state = icon_off
		inhand_icon_state = inhand_icon_off

/// Lights the cigarette with given flavor text.
/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return

	lit = TRUE
	playsound(src.loc, 'sound/items/lighter/cig_light.ogg', 100, 1)
	make_cig_smoke()
	set_light_on(TRUE)
	if(!(flags_1 & INITIALIZED_1))
		update_appearance(UPDATE_ICON)
		return

	attack_verb_continuous = string_list(list("burns", "singes"))
	attack_verb_simple = string_list(list("burn", "singe"))
	hitsound = 'sound/items/welder.ogg'
	damtype = BURN
	force = 4
	if(reagents?.get_reagent_amount(/datum/reagent/toxin/plasma) >= 2.5) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents?.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)
		return

	if(reagents?.has_reagent(/datum/reagent/flash_powder))
		if(!isliving(loc))
			loc.visible_message(span_hear("\The [src] burns up!"))
			qdel(src)
			return
		var/mob/living/user = loc
		loc.visible_message(span_hear("[user]'s [name] burns up as [p_they(user)] fall to the ground!"), span_danger("The solution violently explodes!"))
		user.flash_act(INFINITY, visual = TRUE, length = 5 SECONDS)
		user.playsound_local(get_turf(user), SFX_EXPLOSION, 50, TRUE)
		user.cause_hallucination(/datum/hallucination/death, "trick trick [name]")
		qdel(src)
		return

	if(reagents?.get_reagent_amount(/datum/reagent/fuel) >= 5) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents?.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)
		return


	// Setting the puffed pollutant to cannabis if we're smoking the space drugs reagent(obtained from cannabis)
	if(reagents.has_reagent(/datum/reagent/drug/space_drugs))
		pollution_type = /datum/pollutant/smoke/cannabis

	// allowing reagents to react after being lit
	reagents.flags &= ~(NO_REACT)
	reagents.handle_reactions()
	update_appearance(UPDATE_ICON)
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	if(iscarbon(loc))
		var/mob/living/carbon/smoker = loc
		if(src == smoker.wear_mask)
			make_mob_smoke(smoker)

/obj/item/clothing/mask/cigarette/extinguish()
	. = ..()
	if(!lit)
		return
	attack_verb_continuous = null
	attack_verb_simple = null
	hitsound = null
	damtype = BRUTE
	force = 0
	STOP_PROCESSING(SSobj, src)
	reagents.flags |= NO_REACT
	lit = FALSE
	playsound(src.loc, 'sound/items/lighter/cig_snuff.ogg', 100, 1)
	update_appearance(UPDATE_ICON)
	set_light_on(FALSE)
	if(ismob(loc))
		to_chat(loc, span_notice("Your [name] goes out."))
	QDEL_NULL(cig_smoke)
	QDEL_NULL(mob_smoke)

/obj/item/clothing/mask/cigarette/proc/long_exhale(mob/living/carbon/smoker)
	// Find a mob to blow smoke at
	var/mob/living/guy_infront
	for(var/mob/living/guy in get_step(smoker, smoker.dir))
		// one of you has to get on the other's level
		if(guy.body_position != smoker.body_position)
			continue
		// ensures we're face to face
		if(!(REVERSE_DIR(guy.dir) & smoker.dir))
			continue
		guy_infront = guy
		// in case we get a living first, we wanna prioritize humans
		if(ishuman(guy_infront))
			break

	if(isnull(guy_infront))
		smoker.visible_message(
			span_notice("[smoker] exhales a large cloud of smoke from [src]."),
			span_notice("You exhale a large cloud of smoke from [src]."),
		)

	else if(ishuman(guy_infront) && guy_infront.get_bodypart(BODY_ZONE_HEAD) && !guy_infront.is_pepper_proof())
		guy_infront.visible_message(
			span_notice("[smoker] exhales a large cloud of smoke from [src] directly at [guy_infront]'s face!"),
			span_notice("You exhale a large cloud of smoke from [src] directly at [guy_infront]'s face."),
			ignored_mobs = guy_infront,
		)
		to_chat(guy_infront, span_warning("You get a face full of smoke from [smoker]'s [name]!"))
		smoke_in_face(guy_infront)

	else
		guy_infront.visible_message(
			span_notice("[smoker] exhales a large cloud of smoke from [src] at [guy_infront]."),
			span_notice("You exhale a large cloud of smoke from [src] at [guy_infront]."),
		)

	if(!isturf(smoker.loc))
		return

	var/obj/effect/abstract/particle_holder/big_smoke = new(smoker.loc, /particles/smoke/cig/big)
	update_particle_position(big_smoke, smoker.dir)
	QDEL_IN(big_smoke, big_smoke.particles.lifespan)

/// Called when a mob gets smoke blown in their face.
/obj/item/clothing/mask/cigarette/proc/smoke_in_face(mob/living/getting_smoked)
	getting_smoked.add_mood_event("smoke_bm", /datum/mood_event/smoke_in_face)
	if(iscarbon(getting_smoked))
		var/mob/living/carbon/carbon_smoked = getting_smoked
		if(carbon_smoked.internal != null || carbon_smoked.has_smoke_protection()) //doesnt get upset if they have smoke protection
			return

	if(prob(20) && !HAS_TRAIT(getting_smoked, TRAIT_SMOKER))
		getting_smoked.emote("cough")

/// Handles processing the reagents in the cigarette.
/obj/item/clothing/mask/cigarette/proc/handle_reagents(seconds_per_tick)
	if(!reagents.total_volume)
		return
	reagents.expose_temperature(heat, 0.05)
	if(!reagents.total_volume) //may have reacted and gone to 0 after expose_temperature
		return
	var/to_smoke = smoke_all ? (reagents.total_volume * (dragtime / smoketime)) : REAGENTS_METABOLISM
	var/mob/living/carbon/smoker = loc
	// These checks are a bit messy but at least they're fairly readable
	// Check if the smoker is a carbon mob, since it needs to have wear_mask
	if(!istype(smoker))
		// If not, check if it's a gas mask
		if(!istype(smoker, /obj/item/clothing/mask/gas))
			reagents.remove_all(to_smoke)
			return

		smoker = smoker.loc

		// If it is, check if that mask is on a carbon mob
		if(!istype(smoker) || smoker.get_item_by_slot(ITEM_SLOT_MASK) != loc)
			reagents.remove_all(to_smoke)
			return
	else
		if(src != smoker.wear_mask)
			reagents.remove_all(to_smoke)
			return

	how_long_have_we_been_smokin += seconds_per_tick * (1 SECONDS)
	reagents.expose(smoker, INGEST, min(to_smoke / reagents.total_volume, 1))
	var/obj/item/organ/internal/lungs/lungs = smoker.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(lungs && IS_ORGANIC_ORGAN(lungs))
		var/smoker_resistance = HAS_TRAIT(smoker, TRAIT_SMOKER) ? 0.5 : 1
		smoker.adjustOrganLoss(ORGAN_SLOT_LUNGS, lung_harm * smoker_resistance)
	if(!reagents.trans_to(smoker, to_smoke, methods = INGEST, ignore_stomach = TRUE))
		reagents.remove_all(to_smoke)

/obj/item/clothing/mask/cigarette/process(seconds_per_tick)
	var/mob/living/user = isliving(loc) ? loc : null
	var/turf/location = get_turf(src)
	user?.ignite_mob()

	if(!check_oxygen(user))
		extinguish()
		return

	location.pollute_turf(pollution_type, 5, POLLUTION_PASSIVE_EMITTER_CAP)

	smoketime -= seconds_per_tick * (1 SECONDS)
	if(smoketime <= 0)
		put_out(user)
		return

	open_flame(heat)
	if((reagents?.total_volume) && COOLDOWN_FINISHED(src, drag_cooldown))
		COOLDOWN_START(src, drag_cooldown, dragtime)
		handle_reagents(seconds_per_tick)

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		put_out(user, TRUE)
	return ..()

/obj/item/clothing/mask/cigarette/proc/put_out(mob/user, done_early = FALSE)
	var/atom/location = drop_location()
	if(!isnull(user))
		if(done_early)
			if(isfloorturf(location) && location.has_gravity())
				user.visible_message(span_notice("[user] calmly drops and treads on [src], putting it out instantly."))
				new /obj/effect/decal/cleanable/ash(location)
				long_exhale(user)
			else
				user.visible_message(span_notice("[user] pinches out [src]."))
			how_long_have_we_been_smokin = 0 SECONDS
		else
			to_chat(user, span_notice("Your [name] goes out."))
	new type_butt(location)
	qdel(src)

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()
	if(M.on_fire && !lit)
		light(span_notice("[user] lights [src] with [M]'s burning body. What a cold-blooded badass."))
		return
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(!lit || !cig || (user.istate & ISTATE_HARM))
		return ..()

	if(cig.lit)
		to_chat(user, span_warning("The [cig.name] is already lit!"))
	if(M == user)
		cig.attackby(src, user)
	else
		cig.light(span_notice("[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name]."))

/obj/item/clothing/mask/cigarette/fire_act(exposed_temperature, exposed_volume)
	light()

/obj/item/clothing/mask/cigarette/get_temperature()
	return lit * heat

/obj/item/clothing/mask/cigarette/proc/make_mob_smoke(mob/living/smoker)
	mob_smoke = new(smoker, /particles/smoke/cig)
	update_particle_position(mob_smoke, smoker.dir)
	return mob_smoke

/obj/item/clothing/mask/cigarette/proc/make_cig_smoke()
	cig_smoke = new(src, /particles/smoke/cig)
	cig_smoke.particles.scale *= 1.5
	return cig_smoke

// Cigarette brands.
/obj/item/clothing/mask/cigarette/space_cigarette
	desc = "A Space brand cigarette that can be smoked anywhere."
	list_reagents = list(/datum/reagent/drug/nicotine = 9, /datum/reagent/oxygen = 9)
	smoketime = 4 MINUTES // space cigs have a shorter burn time than normal cigs
	//smoke_all = TRUE // so that it doesn't runout of oxygen while being smoked in space

/obj/item/clothing/mask/cigarette/dromedary
	desc = "A DromedaryCo brand cigarette. Contrary to popular belief, does not contain Calomel, but is reported to have a watery taste."
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/water = 5) //camel has water

/obj/item/clothing/mask/cigarette/uplift
	desc = "An Uplift Smooth brand cigarette. Smells refreshing."
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/consumable/menthol = 5)

/obj/item/clothing/mask/cigarette/robust
	desc = "A Robust brand cigarette."

/obj/item/clothing/mask/cigarette/robustgold
	desc = "A Robust Gold brand cigarette."
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/gold = 3) // Just enough to taste a hint of expensive metal.

/obj/item/clothing/mask/cigarette/carp
	desc = "A Carp Classic brand cigarette. A small label on its side indicates that it does NOT contain carpotoxin."

/obj/item/clothing/mask/cigarette/carp/Initialize(mapload)
	. = ..()
	if(!prob(5))
		return
	reagents?.add_reagent(/datum/reagent/toxin/carpotoxin , 3) // They lied

/obj/item/clothing/mask/cigarette/syndicate
	desc = "An unknown brand cigarette. The filter looks robust."
	chem_volume = 60
	lung_harm = 0.75
	smoketime = 2 MINUTES
	list_reagents = list(/datum/reagent/drug/nicotine = 10, /datum/reagent/medicine/omnizine = 15)

/obj/item/clothing/mask/cigarette/syndicate/smoke_in_face(mob/living/getting_smoked)
	. = ..()
	getting_smoked.adjust_eye_blur(6 SECONDS)
	getting_smoked.adjust_temp_blindness(2 SECONDS)

/obj/item/clothing/mask/cigarette/shadyjims
	desc = "A Shady Jim's Super Slims cigarette."
	lung_harm = 1.5
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/lipolicide = 4, /datum/reagent/ammonia = 2, /datum/reagent/toxin/plantbgone = 1, /datum/reagent/toxin = 1.5)

/obj/item/clothing/mask/cigarette/xeno
	desc = "A slimey cigarette. It smells faintly of the medical bay."
	lung_harm = 0
	list_reagents = list (/datum/reagent/drug/nicotine = 10, /datum/reagent/medicine/regen_jelly = 15, /datum/reagent/drug/krokodil = 5)

/obj/item/clothing/mask/cigarette/flash_powder
	desc = /obj/item/clothing/mask/cigarette/space_cigarette::desc
	list_reagents = list(/datum/reagent/drug/nicotine = 9, /datum/reagent/flash_powder = 5)

// Rollies.

/obj/item/clothing/mask/cigarette/rollie
	name = "rollie"
	desc = "A roll of dried plant matter wrapped in thin paper."
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	smoketime = 4 MINUTES
	chem_volume = 50
	list_reagents = null
	choke_time_max = 40 SECONDS
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/mask/cigarette/rollie/Initialize(mapload)
	name = pick(list(
		"bifta",
		"bifter",
		"bird",
		"blunt",
		"bloint",
		"boof",
		"boofer",
		"bomber",
		"bone",
		"bun",
		"doink",
		"doob",
		"doober",
		"doobie",
		"dutch",
		"fatty",
		"hogger",
		"hooter",
		"hootie",
		"\improper J",
		"jay",
		"jimmy",
		"joint",
		"juju",
		"jeebie weebie",
		"number",
		"owl",
		"phattie",
		"puffer",
		"reef",
		"reefer",
		"rollie",
		"scoobie",
		"shorty",
		"spiff",
		"spliff",
		"toke",
		"torpedo",
		"zoot",
		"zooter"))
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/cannabis = 15)

/obj/item/clothing/mask/cigarette/rollie/mindbreaker
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 35, /datum/reagent/toxin/lipolicide = 15)

/obj/item/clothing/mask/cigarette/candy
	name = "\improper Little Timmy's candy cigarette"
	desc = "For all ages*! Doesn't contain any amount of nicotine. Health and safety risks can be read on the tip of the cigarette."
	smoketime = 2 MINUTES
	icon_state = "candyoff"
	icon_on = "candyon"
	icon_off = "candyoff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	inhand_icon_off = "candyoff"
	type_butt = /obj/item/food/candy_trash
	heat = 473.15 // Lowered so that the sugar can be carmalized, but not burnt.
	lung_harm = 0.5
	list_reagents = list(/datum/reagent/consumable/sugar = 20)
	choke_time_max = 70 SECONDS // This shit really is deadly

/obj/item/clothing/mask/cigarette/candy/nicotine
	desc = "For all ages*! Doesn't contain any* amount of nicotine. Health and safety risks can be read on the tip of the cigarette."
	type_butt = /obj/item/food/candy_trash/nicotine
	list_reagents = list(/datum/reagent/consumable/sugar = 20, /datum/reagent/drug/nicotine = 20) //oh no!
	//smoke_all = TRUE //timmy's not getting out of this one

/obj/item/cigbutt/roach
	name = "roach"
	desc = "A manky old roach, or for non-stoners, a used rollup."
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/greytide
	name = "grey mainthol"
	desc = "Made by hand, has a funky smell."
	chem_volume = 60
	lung_harm = 2.5
	type_butt = /obj/item/cigbutt/greycigbutt
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/consumable/menthol = 6, /datum/reagent/medicine/oculine = 1)
	/// Weighted list of random reagents to add
	var/static/list/possible_reagents = list(
		/datum/reagent/toxin/fentanyl = 2,
		/datum/reagent/glitter = 2,
		/datum/reagent/drug/aranesp = 2,
		/datum/reagent/consumable/laughter = 2,
		/datum/reagent/medicine/insulin = 2,
		/datum/reagent/drug/maint/powder = 2,
		/datum/reagent/drug/maint/sludge = 2,
		/datum/reagent/toxin/staminatoxin = 2,
		/datum/reagent/toxin/leadacetate = 2,
		/datum/reagent/drug/space_drugs = 2,
		/datum/reagent/drug/pumpup = 2,
		/datum/reagent/drug/kronkaine = 2,
		/datum/reagent/consumable/mintextract = 2,
		/datum/reagent/pax = 1,
	)

/obj/item/clothing/mask/cigarette/greytide/Initialize(mapload)
	. = ..()
	if(prob(40))
		reagents.add_reagent(pick_weight(possible_reagents), rand(10, 15))

/obj/item/cigbutt/greycigbutt
	desc = "It's low tide, now."

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	inhand_icon_state = "cigaron" //gets overriden during intialize(), just have it for unit test sanity.
	inhand_icon_on = "cigaron"
	inhand_icon_off = "cigaroff"
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	smoketime = 10 MINUTES
	chem_volume = 45
	list_reagents = list(/datum/reagent/drug/nicotine = 15)
	choke_time_max = 40 SECONDS

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 20 MINUTES
	chem_volume = 60
	list_reagents = list(/datum/reagent/drug/nicotine = 30)
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = "A cigar fit for only the best of the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 30 MINUTES
	chem_volume = 75
	list_reagents = list(/datum/reagent/drug/nicotine = 45)
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = "A manky old cigar butt."
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meerschaum or something."
	icon_state = "pipeoff"
	icon_on = "pipeoff"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	inhand_icon_state = null
	inhand_icon_on = null
	inhand_icon_off = null
	smoketime = 0
	chem_volume = 200 // So we can fit densified chemicals plants
	list_reagents = null
	w_class = WEIGHT_CLASS_SMALL
	choke_forever = TRUE
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	///name of the stuff packed inside this pipe
	var/packeditem

/obj/item/clothing/mask/cigarette/pipe/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME)

/obj/item/clothing/mask/cigarette/pipe/update_name()
	. = ..()
	name = packeditem ? "[packeditem]-packed [initial(name)]" : "empty [initial(name)]"

/obj/item/clothing/mask/cigarette/pipe/put_out(mob/user, done_early = FALSE)
	lit = FALSE
	if(done_early)
		user.visible_message(span_notice("[user] puts out [src]."), span_notice("You put out [src]."))
	else
		if(user)
			to_chat(user, span_notice("Your [name] goes out."))
	playsound(src.loc, 'sound/items/lighter/cig_snuff.ogg', 100, 1)
	how_long_have_we_been_smokin = 0
	update_appearance(UPDATE_ICON)
	set_light_on(FALSE)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(cig_smoke)
	QDEL_NULL(mob_smoke)

/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/thing, mob/user, params)
	if(lit)
		to_chat(user, span_warning("The [src] is lit!"))
		return

	if(!istype(thing, /obj/item/food/grown))
		return ..()

	var/obj/item/food/grown/to_smoke = thing

	if((to_smoke.reagents.total_volume + reagents.total_volume) > chem_volume)
		to_chat(user, span_warning("It cannot be packed further!"))
		return

	if(!HAS_TRAIT(to_smoke, TRAIT_DRIED))
		to_chat(user, span_warning("It has to be dried first!"))
		return

	to_chat(user, span_notice("You stuff [to_smoke] into [src]."))
	packeditem = to_smoke.name
	update_name()
	if(to_smoke.reagents)
		to_smoke.reagents.trans_to(src, to_smoke.reagents.total_volume, transfered_by = user)
	smoketime = round(reagents.total_volume/1.5) MINUTES
	qdel(to_smoke)


/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/atom/location = drop_location()
	if(packeditem && !lit)
		to_chat(user, span_notice("You empty [src] onto [location]."))
		new /obj/effect/decal/cleanable/ash(location)
		packeditem = null
		smoketime = 0
		reagents.clear_reagents()
		update_name()
		return
	return ..()

/obj/item/clothing/mask/cigarette/pipe/update_particle_position(obj/effect/abstract/particle_holder/to_edit, new_dir = loc.dir)
	var/new_x = 0
	var/new_layer = initial(to_edit.layer)
	var/human_height_offset
	if(new_dir & NORTH)
		new_x = 6
		new_layer = BELOW_MOB_LAYER
	else if(new_dir & SOUTH)
		new_x = -6
	else if(new_dir & EAST)
		new_x = 8
	else if(new_dir & WEST)
		new_x = -8
	if(ishuman(loc))
		var/mob/living/carbon/human/our_smoker = loc
		human_height_offset = HUMAN_HEIGHT_MEDIUM - our_smoker.mob_height
	to_edit.set_particle_position(new_x, 8 - human_height_offset, 0)
	to_edit.layer = new_layer

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters. Can be loaded with objects."
	icon_state = "cobpipeoff"
	icon_on = "cobpipeoff"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	inhand_icon_on = null
	inhand_icon_off = null

///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = "A thin piece of paper used to make fine smokeables."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/customizable_reagent_holder, /obj/item/clothing/mask/cigarette/rollie, CUSTOM_INGREDIENT_ICON_NOCHANGE, ingredient_type=CUSTOM_INGREDIENT_TYPE_DRYABLE, max_ingredients=2, job_xp = 1, job = JOB_BOTANIST)


///////////////
//VAPE NATION//
///////////////
/obj/item/clothing/mask/vape
	name = "\improper E-Cigarette"
	desc = "A classy and highly sophisticated electronic cigarette, for classy and dignified gentlemen. A warning label reads \"Warning: Do not fill with flammable materials.\""//<<< i'd vape to that.
	icon_state = "vape"
	worn_icon_state = "vape_worn"
	greyscale_config = /datum/greyscale_config/vape
	greyscale_config_worn = /datum/greyscale_config/vape/worn
	greyscale_colors = "#2e2e2e"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_TINY
	flags_1 = IS_PLAYER_COLORABLE_1
	light_outer_range = 1
	light_color = LIGHT_COLOR_HALOGEN
	light_system = OVERLAY_LIGHT
	light_on = FALSE

	/// The capacity of the vape.
	var/chem_volume = 100
	/// The amount of time between drags.
	var/dragtime = 8 SECONDS
	/// A cooldown to prevent huffing the vape all at once.
	COOLDOWN_DECLARE(drag_cooldown)
	/// Whether the resevoir is open and we can add reagents.
	var/screw = FALSE
	/// Whether the vape has been overloaded to spread smoke.
	var/super = FALSE

/obj/item/clothing/mask/vape/Initialize(mapload)
	. = ..()
	create_reagents(chem_volume, NO_REACT)
	reagents.add_reagent(/datum/reagent/drug/nicotine, 50)

/obj/item/clothing/mask/vape/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is puffin hard on dat vape, [user.p_they()] trying to join the vape life on a whole notha plane!"))//it doesn't give you cancer, it is cancer
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/vape/screwdriver_act(mob/living/user, obj/item/tool)
	if(!screw)
		screw = TRUE
		to_chat(user, span_notice("You open the cap on [src]."))
		reagents.flags |= OPENCONTAINER
		if(obj_flags & EMAGGED)
			icon_state = "vape_open_high"
			set_greyscale(new_config = /datum/greyscale_config/vape/open_high)
		else if(super)
			icon_state = "vape_open_med"
			set_greyscale(new_config = /datum/greyscale_config/vape/open_med)
		else
			icon_state = "vape_open_low"
			set_greyscale(new_config = /datum/greyscale_config/vape/open_low)
	else
		screw = FALSE
		to_chat(user, span_notice("You close the cap on [src]."))
		reagents.flags &= ~(OPENCONTAINER)
		icon_state = initial(icon_state)
		set_greyscale(new_config = initial(greyscale_config))

/obj/item/clothing/mask/vape/multitool_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(screw && !(obj_flags & EMAGGED))//also kinky
		if(!super)
			super = TRUE
			to_chat(user, span_notice("You increase the voltage of [src]."))
			icon_state = "vape_open_med"
			set_greyscale(new_config = /datum/greyscale_config/vape/open_med)
		else
			super = FALSE
			to_chat(user, span_notice("You decrease the voltage of [src]."))
			icon_state = "vape_open_low"
			set_greyscale(new_config = /datum/greyscale_config/vape/open_low)

	if(screw && (obj_flags & EMAGGED))
		to_chat(user, span_warning("[src] can't be modified!"))

/obj/item/clothing/mask/vape/emag_act(mob/user, obj/item/card/emag/emag_card) // I WON'T REGRET WRITTING THIS, SURLY.

	if (!screw)
		balloon_alert(user, "open the cap first!")
		return FALSE

	if (obj_flags & EMAGGED)
		balloon_alert(user, "already emagged!")
		return FALSE

	obj_flags |= EMAGGED
	super = FALSE
	balloon_alert(user, "voltage maximized")
	icon_state = "vape_open_high"
	set_greyscale(new_config = /datum/greyscale_config/vape/open_high)
	var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread //for effect
	sp.set_up(5, 1, src)
	sp.start()
	return TRUE

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(!screw)
		balloon_alert(user, "open the cap first!")
		return
	if(reagents.total_volume > 0)
		to_chat(user, span_notice("You empty [src] of all reagents."))
		reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_MASK))
		return

	if(screw)
		to_chat(user, span_warning("You need to close the cap first!"))
		return

	to_chat(user, span_notice("You start puffing on the vape."))
	reagents.flags &= ~(NO_REACT)
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/obj/item/clothing/mask/vape/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_MASK) == src)
		reagents.flags |= NO_REACT
		STOP_PROCESSING(SSobj, src)
		set_light_on(FALSE)

/obj/item/clothing/mask/vape/proc/handle_reagents()
	if(!reagents.total_volume)
		return

	var/mob/living/carbon/vaper = loc
	if(!iscarbon(vaper) || src != vaper.wear_mask)
		reagents.remove_all(REAGENTS_METABOLISM)
		return

	if(reagents?.get_reagent_amount(/datum/reagent/fuel))
		//HOT STUFF
		vaper.adjust_fire_stacks(2)
		vaper.ignite_mob()

	if(reagents?.get_reagent_amount(/datum/reagent/toxin/plasma) >= 2.5) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents?.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start(src)
		qdel(src)

	if(!reagents.trans_to(vaper, REAGENTS_METABOLISM, methods = INGEST, ignore_stomach = TRUE))
		reagents.remove_all(REAGENTS_METABOLISM)

/obj/item/clothing/mask/vape/process(seconds_per_tick)
	var/mob/living/M = loc

	if(isliving(loc))
		M.ignite_mob()

	if(!reagents.total_volume)
		if(ismob(loc))
			to_chat(M, span_warning("[src] is empty!"))
			STOP_PROCESSING(SSobj, src)
			//it's reusable so it won't unequip when empty
		return

	if(!COOLDOWN_FINISHED(src, drag_cooldown))
		return

	//Time to start puffing those fat vapes, yo.
	COOLDOWN_START(src, drag_cooldown, dragtime)

	//open flame removed because vapes are a closed system, they won't light anything on fire
	var/turf/my_turf = get_turf(src)
	my_turf.pollute_turf(/datum/pollutant/smoke/vape, 5, POLLUTION_PASSIVE_EMITTER_CAP)

	if(obj_flags & EMAGGED)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/puff = new
		puff.set_up(4, holder = src, location = loc, carry = reagents, efficiency = 24)
		puff.start()
		if(prob(5)) //small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/effects/pop_expl.ogg', 50, FALSE)
			M.apply_damage(20, BURN, BODY_ZONE_HEAD)
			M.Paralyze(300)
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, span_userdanger("[src] suddenly explodes in your mouth!"))
			qdel(src)
			return
	else if(super)
		var/datum/effect_system/fluid_spread/smoke/chem/smoke_machine/puff = new
		puff.set_up(1, holder = src, location = loc, carry = reagents, efficiency = 24)
		puff.start()

	handle_reagents()

/obj/item/clothing/mask/vape/red
	greyscale_colors = "#A02525"
	flags_1 = NONE

/obj/item/clothing/mask/vape/blue
	greyscale_colors = "#294A98"
	flags_1 = NONE

/obj/item/clothing/mask/vape/purple
	greyscale_colors = "#9900CC"
	flags_1 = NONE

/obj/item/clothing/mask/vape/green
	greyscale_colors = "#3D9829"
	flags_1 = NONE

/obj/item/clothing/mask/vape/yellow
	greyscale_colors = "#DAC20E"
	flags_1 = NONE

/obj/item/clothing/mask/vape/orange
	greyscale_colors = "#da930e"
	flags_1 = NONE

/obj/item/clothing/mask/vape/black
	greyscale_colors = "#2e2e2e"
	flags_1 = NONE

/obj/item/clothing/mask/vape/white
	greyscale_colors = "#DCDCDC"
	flags_1 = NONE
