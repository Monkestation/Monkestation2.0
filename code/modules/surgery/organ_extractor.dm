/obj/item/organ_extractor
	name = "organ extractor"
	desc = "A device that can remove organs from a target, and store them inside. Stored organs can be implanted into the user. Synthesizes chemicals to keep the organ fresh."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "organ_extractor"
	inhand_icon_state = "organ_extractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/organ/internal/storedorgan
	///Is the device currently extracting an organ?
	var/in_use = FALSE
	var/insert_time = 12 SECONDS
	var/self_insert_time = 7 SECONDS
	var/advanced = FALSE

/obj/item/organ_extractor/Destroy(force)
	. = ..()
	QDEL_NULL(storedorgan)

/obj/item/organ_extractor/examine(mob/user)
	. = ..()
	if(storedorgan)
		. += span_notice("It has [storedorgan] floating around inside the jar!")
		. += span_notice("You can <b>Screwdriver</b> [src] to try to adjust [storedorgan]'s configuration.")
		. += span_notice("You can <b>Wrench</b> [src] to eject [storedorgan]!")

/obj/item/organ_extractor/screwdriver_act(mob/living/user, obj/item/I)
	if(storedorgan)
		return storedorgan.screwdriver_act(user, I)

/obj/item/organ_extractor/wrench_act(mob/living/user, obj/item/I)
	if(storedorgan)
		to_chat(user, span_warning("You unwrench the jar, and [storedorgan] falls onto the floor!"))
		storedorgan.forceMove(get_turf(user))
		storedorgan.unfreeze()
		storedorgan = null
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
		overlays.Cut()
		return TRUE

/obj/item/organ_extractor/emag_act(mob/user)
	if(storedorgan)
		storedorgan.emag_act(user)

/obj/item/organ_extractor/emp_act(severity)
	if(storedorgan)
		storedorgan.emp_act(severity)

/obj/item/organ_extractor/attack_self(mob/user)
	insert_organ(user, user)

/obj/item/organ_extractor/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(in_use)
		to_chat(user, span_warning("[src] is already busy!"))
		return ITEM_INTERACT_BLOCKING
	if(!iscarbon(interacting_with))
		to_chat(user, span_warning("ERROR: [interacting_with] has no organs to harvest!"))
		return ITEM_INTERACT_BLOCKING

	var/mob/living/carbon/impromptu_patient = interacting_with

	if(!impromptu_patient.incapacitated())
		to_chat(user, span_warning("ERROR: [impromptu_patient] is not incapacitated, and may move during the operation! Correction required."))
		return ITEM_INTERACT_BLOCKING
	if(storedorgan)
		to_chat(user, span_warning("NOTICE: Internal organ deteced. Beginning insertion procedure!"))
		insert_organ(user, impromptu_patient)
		return ITEM_INTERACT_BLOCKING

	in_use = TRUE
	var/obj/item/organ/chosen_organ = tgui_input_list(user, "Please select an organ for removal", "Organ Selection", impromptu_patient.organs)
	if(!chosen_organ || !user.Adjacent(impromptu_patient))
		in_use = FALSE
		return ITEM_INTERACT_BLOCKING
	if(!istype(chosen_organ, /obj/item/organ/internal) || chosen_organ.organ_flags & ORGAN_UNREMOVABLE) //Saftey first
		to_chat(user, span_warning("ERROR: [chosen_organ] is not valid for removal for unknown reasons!"))
		in_use = FALSE
		return ITEM_INTERACT_BLOCKING

	var/obj/item/organ/internal/internal_organ = chosen_organ
	var/drilled_zone = parse_zone(chosen_organ.zone)
	user.visible_message(span_danger("[user] activates [src] and begins to drill into [impromptu_patient]!"), span_warning("You level the extractor at [impromptu_patient] and hold down the trigger."))
	to_chat(impromptu_patient, span_danger("You feel a lot of pain as [user] drills into your [drilled_zone]!"))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 75, TRUE)

	if(!advanced)
		impromptu_patient.apply_damage(15, BRUTE, drilled_zone)
	if(!do_after(user, insert_time, target = impromptu_patient))// Slightly longer than stamina crit, at least cuff and buckle them to a pipe or something
		to_chat(user, span_warning("ERROR: Process interrupted!"))
		in_use = FALSE
		return
	if(!internal_organ || !istype(internal_organ) || !(internal_organ.owner == impromptu_patient)) //Organ got deleted / moved somewhere else?
		to_chat(user, span_warning("ERROR: unable to find the desired organ!"))
		in_use = FALSE
		return

	user.visible_message(span_danger("[user] removes [internal_organ] from [impromptu_patient]!"), span_warning("You remove [internal_organ] from [impromptu_patient] as it gets sucked into [src]'s internal container!"))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 75, TRUE)
	impromptu_patient.apply_damage(10, BRUTE, drilled_zone)
	internal_organ.Remove(impromptu_patient, FALSE)
	in_use = FALSE
	insert_internal_organ_in_extractor(internal_organ)

/obj/item/organ_extractor/proc/insert_organ(mob/user, mob/our_target)
	if(!storedorgan)
		to_chat(user, span_warning("[src] currently has no organ stored."))
		return
	if(in_use)
		to_chat(user, span_warning("[src] is already busy!"))
		return

	var/user_is_target = FALSE
	if(user == our_target)
		user_is_target = TRUE
	if(!iscarbon(our_target))
		return

	var/mob/living/carbon/impromptu_patient = our_target
	in_use = TRUE
	var/drilled_zone = parse_zone(storedorgan.zone)
	user.visible_message(span_danger("[user] activates [src] and begins to drill into [impromptu_patient]!"), span_warning("You level the extractor at [user_is_target ? "yourself" : impromptu_patient] and hold down the trigger."))
	if(!advanced)
		impromptu_patient.apply_damage(5, BRUTE, drilled_zone)
	playsound(src, 'sound/weapons/circsawhit.ogg', 50, TRUE)

	if(!do_after(user, (user_is_target ? self_insert_time : insert_time), target = impromptu_patient))
		to_chat(user, span_warning("ERROR: Process interrupted!"))
		in_use = FALSE
		return

	if(!advanced)
		impromptu_patient.apply_damage(10, BRUTE, drilled_zone)
	storedorgan.Insert(impromptu_patient, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "o_implant_extract", 1, "[storedorgan.type]")
	playsound(src, 'sound/weapons/circsawhit.ogg', 50, TRUE)
	storedorgan.unfreeze()
	storedorgan = null
	in_use = FALSE
	overlays.Cut()

/obj/item/organ_extractor/proc/insert_internal_organ_in_extractor(obj/item/organ/organ_to_be_inserted)
	organ_to_be_inserted.forceMove(src)
	storedorgan = organ_to_be_inserted
	storedorgan.freeze()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/organ_extractor/update_overlays()
	. = ..()
	if(!storedorgan)
		return
	var/organ_x = storedorgan.pixel_x
	var/organ_y = storedorgan.pixel_y
	storedorgan.pixel_x = 2
	storedorgan.pixel_y = -2
	var/image/img = image("icon" = storedorgan, "layer" = FLOAT_LAYER)
	var/matrix/MA = matrix(transform)
	MA.Scale(0.66, 0.66)
	img.transform = MA
	img.plane = FLOAT_PLANE
	. += img
	storedorgan.pixel_x = organ_x
	storedorgan.pixel_y = organ_y
	. += "[icon_state]_2" //should look nicer for transparent stuff.
