/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	var/blood_type = null
	var/labelled = FALSE
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	reagent_flags = DRAWABLE | DRAINABLE

/obj/item/reagent_containers/blood/Initialize(mapload, vol)
	. = ..()
	if(!isnull(blood_type))
		var/datum/blood_type/blood = GLOB.blood_types[blood_type]
		reagents.add_reagent(blood.reagent_type, 200, list("viruses" = null,"blood_DNA" = null,"blood_type" = blood_type, "resistances" = null, "trace_chem" = null))
		update_appearance()

/// Handles updating the container when the reagents change.
/obj/item/reagent_containers/blood/on_reagent_change(datum/reagents/holder, ...)
	blood_type = null

	var/datum/reagent/master_reagent = holder.get_master_reagent()
	if(master_reagent)
		if(istype(master_reagent, /datum/reagent/blood))
			blood_type = master_reagent.data?["blood_type"]
		else
			for(var/blood_type in GLOB.blood_types)
				var/datum/blood_type/blood = GLOB.blood_types[blood_type]
				if(blood.reagent_type == master_reagent.type)
					blood_type = blood_type
					break

	return ..()

#define BLOODBAG_GULP_SIZE 5

/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, params)
	if(!can_drink(victim, attacker))
		return

	if(victim != attacker)
		if(!do_after(attacker, 5 SECONDS, victim, hidden = TRUE))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from \the [src]."),
			span_notice("You put \the [src] up to [victim]'s mouth."))
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transfered_by = attacker, methods = INGEST)
		playsound(victim, 'sound/items/drink.ogg', vol = 30, vary = TRUE)
		return TRUE

	while(do_after(victim, 1 SECONDS, victim, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker), hidden = TRUE))
		victim.visible_message(
			span_notice("[victim] puts \the [src] up to [victim.p_their()] mouth."),
			span_notice("You take a sip from \the [src]."),
		)
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transfered_by = attacker, methods = INGEST)
		playsound(victim, 'sound/items/drink.ogg', vol = 30, vary = TRUE)
	return TRUE

#undef BLOODBAG_GULP_SIZE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents?.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	return TRUE

/obj/item/reagent_containers/blood/update_name(updates)
	. = ..()
	if(labelled)
		return
	var/datum/blood_type/blood = GLOB.blood_types[blood_type]
	name = "blood pack[blood ? " - [blood.name]" : null]"

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload, vol)
	icon_state = "bloodpack"
	blood_type = pick(subtypesof(/datum/blood_type/crew) - /datum/blood_type/crew/human)
	return ..()

/obj/item/reagent_containers/blood/a_plus
	blood_type = /datum/blood_type/crew/human/a_plus

/obj/item/reagent_containers/blood/a_minus
	blood_type = /datum/blood_type/crew/human/a_minus

/obj/item/reagent_containers/blood/b_plus
	blood_type = /datum/blood_type/crew/human/b_plus

/obj/item/reagent_containers/blood/b_minus
	blood_type = /datum/blood_type/crew/human/b_minus

/obj/item/reagent_containers/blood/o_plus
	blood_type = /datum/blood_type/crew/human/o_plus

/obj/item/reagent_containers/blood/o_minus
	blood_type = /datum/blood_type/crew/human/o_minus

/obj/item/reagent_containers/blood/lizard
	blood_type = /datum/blood_type/crew/lizard

/obj/item/reagent_containers/blood/ethereal
	blood_type = /datum/blood_type/crew/ethereal

/obj/item/reagent_containers/blood/spider
	blood_type = /datum/blood_type/crew/spider

/obj/item/reagent_containers/blood/snail
	blood_type = /datum/blood_type/snail

/obj/item/reagent_containers/blood/snail/examine()
	. = ..()
	. += span_notice("It's a bit slimy... The label indicates that this is meant for snails.")

/obj/item/reagent_containers/blood/podperson
	blood_type = /datum/blood_type/water

/obj/item/reagent_containers/blood/podperson/examine()
	. = ..()
	. += span_notice("This appears to be some very overpriced water.")

// for slimepeople
/obj/item/reagent_containers/blood/toxin
	blood_type = /datum/blood_type/slime

/obj/item/reagent_containers/blood/toxin/examine()
	. = ..()
	. += span_notice("There is a toxin warning on the label. This is for slimepeople.")

/obj/item/reagent_containers/blood/attackby(obj/item/tool, mob/user, params)
	if (IS_WRITING_UTENSIL(tool))
		if(!user.can_write(tool))
			return
		var/custom_label = tgui_input_text(user, "What would you like to label the blood pack?", "Blood Pack", name, MAX_NAME_LEN)
		if(!user.can_perform_action(src))
			return
		if(user.get_active_held_item() != tool)
			return
		if(custom_label)
			labelled = TRUE
			name = "blood pack - [custom_label]"
			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)
			balloon_alert(user, "new label set")
		else
			labelled = FALSE
			update_name()
	else
		return ..()
