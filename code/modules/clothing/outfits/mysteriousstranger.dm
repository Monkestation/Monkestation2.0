/datum/outfit/myststranger
	name = "A Mysterious Stranger"

	id = /obj/item/card/id/advanced/debug
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit_store = /obj/item/tank/internals/oxygen/yellow
	back = /obj/item/mod/control/pre_equipped/myststranger
	box = /obj/item/storage/box/material
	backpack_contents = list(
		/obj/item/melee/energy/axe/lone_wanderer = 1,
		/obj/item/debug/omnitool = 1,
		/obj/item/storage/medkit/lone_wanderer_medkit = 1,
		/obj/item/gun/ballistic/revolver/lone_wanderer = 1,
		/obj/item/gps/advanced/lone_wanderer = 1,
		/obj/item/holochip/tenthousand = 1,
	)
	belt = /obj/item/defibrillator/compact/combat/loaded/nanotrasen
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/debug
	gloves = /obj/item/clothing/gloves/combat
	shoes = /obj/item/clothing/shoes/magboots/advance
	mask = /obj/item/clothing/mask/chameleon

	r_pocket = /obj/item/reagent_containers/medipen/lone_wanderer/single
	l_pocket = /obj/item/reagent_containers/medipen/lone_wanderer/single

	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/myststranger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	W.registered_name = "Mysterious Stranger"
	W.assignment = "???"
	W.update_label()
	W.update_icon()
	var/obj/item/implant/vanish/impl = new /obj/item/implant/vanish(H)//poof
	impl.implant(H, null, silent = TRUE)
	///Mysterious Stranger has been everywhere, they are everywhere; they might as well be god.
	///Im gonna put this note here, please dont fucking use this to interfere with antags unless they ask for it.
	H.add_traits(list(TRAIT_ALL_SURGERIES,TRAIT_ASHSTORM_IMMUNE,TRAIT_BATON_RESISTANCE, \
	TRAIT_SHOCKIMMUNE,TRAIT_IMPACTIMMUNE,TRAIT_LAVA_IMMUNE,TRAIT_XENO_IMMUNE,TRAIT_MADNESS_IMMUNE,TRAIT_WEATHER_IMMUNE,TRAIT_RADSTORM_IMMUNE, \
	TRAIT_TENTACLE_IMMUNE,TRAIT_OVERWATCH_IMMUNE,TRAIT_PUSHIMMUNE,TRAIT_RUSTIMMUNE,TRAIT_RADIMMUNE,TRAIT_TOXIMMUNE,TRAIT_BOMBIMMUNE,TRAIT_NUKEIMMUNE, \
	TRAIT_SNOWSTORM_IMMUNE,TRAIT_TIME_STOP_IMMUNE,TRAIT_STUNIMMUNE,TRAIT_PIERCEIMMUNE,TRAIT_TESLA_SHOCKIMMUNE,TRAIT_KNOW_ENGI_WIRES,TRAIT_KNOW_ROBO_WIRES,\
	TRAIT_BRAIN_TRAUMA_IMMUNITY,TRAIT_VIRUSIMMUNE,TRAIT_NO_MINDSWAP,TRAIT_NEVER_WOUNDED,TRAIT_TOWER_OF_BABEL,TRAIT_IGNORESLOWDOWN,\
	TRAIT_FEARLESS,TRAIT_NO_SLIP_ALL,TRAIT_FAST_CLIMBER,TRAIT_FAST_CUFFING,TRAIT_FASTMED))

	H.apply_status_effect(/datum/status_effect/ancient_caretaker,-1,TRUE)

///If you'ld like to know why all this kit's gear is in here for the most part, its because its PART of the kit, and should probably
///NOT appear anywhere else! If it does.... FUCK
///SOME ITEMS are actually properly sorted. Deal with it.

///Funny teleport axe.
/obj/item/melee/energy/axe/lone_wanderer
	name = "experimental protonic inversal axe"
	///Fallout NV OWB refrence FTW.
	desc = "Yes, because the intellectually challenged see an M and a T next to each other and take Occam's razor to it!"
	desc_controls = "Right-Click to dash."
	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/lone_wanderer/jaunt

/obj/item/melee/energy/axe/lone_wanderer/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/energy/axe/lone_wanderer/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!interacting_with.density)
		jaunt?.teleport(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/melee/energy/axe/lone_wanderer/equipped(mob/user, slot, initial)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Grant(user, src)

/obj/item/melee/energy/axe/lone_wanderer/dropped(mob/user)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Remove(user)

/obj/item/melee/energy/axe/lone_wanderer/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/datum/action/innate/dash/lone_wanderer
	current_charges = 5
	max_charges = 5
	charge_rate = 20
	beam_length = 0.1 SECONDS
	recharge_sound = null

/datum/action/innate/dash/lone_wanderer/GiveAction(mob/viewer)
	return

/datum/action/innate/dash/lone_wanderer/HideFrom(mob/viewer)
	return
///Medkit
/obj/item/storage/medkit/lone_wanderer_medkit
	name = "ancient medical storage"
	icon_state = "medkit_tactical_premium"
	desc = "Give me your tired, your poor, your battered or bruised, all are welcome in my loving arms."

/obj/item/storage/medkit/lone_wanderer_medkit/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_GIGANTIC
	atom_storage.max_slots = 28

/obj/item/storage/medkit/lone_wanderer_medkit/PopulateContents()
	var/list/items_inside = list(
		/obj/item/scalpel/advanced = 1,
		/obj/item/hemostat = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/circular_saw = 1,
		/obj/item/bonesetter = 1,
		/obj/item/cautery/advanced = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/blood_filter/advanced = 1,
		/obj/item/emergency_bed = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/bodybag/bluespace = 1,
		/obj/item/reagent_containers/medipen/lone_wanderer = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/gauze/sterilized = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/medical/bone_gel = 1,
	)
	generate_items_inside(items_inside, src)
///Stims [for medkit]
/obj/item/reagent_containers/medipen/lone_wanderer
	name = "ancient stim-pac"
	desc = "Quit squirming, im trying to help you!"
	icon_state = "syndipen"
	base_icon_state = "syndipen"
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/lonehope = 10)
	label_text = "Never seems to run dry, and always seems clean."
	infinite = TRUE

/obj/item/reagent_containers/medipen/lone_wanderer/single
	name = "super stim-pac"
	desc = "Looks ancient; where did this come from?"
	icon_state = "gorillapen"
	inhand_icon_state = "gorillapen"
	base_icon_state = "gorillapen"
	label_text = "Something something not liable for.... wait how many sieverts did that just say this contains!?"
	infinite = FALSE

/datum/reagent/medicine/lonehope
	name = "Lone Hope"
	description = "Who knows what this is...Heals great though."
	reagent_state = LIQUID
	color = "#DCDCDC"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	var/healing = 2.5
	ph = 1
	chemical_flags = REAGENT_NO_RANDOM_RECIPE | REAGENT_DEAD_PROCESS | REAGENT_UNAFFECTED_BY_METABOLISM | REAGENT_IGNORE_STASIS | REAGENT_DONOTSPLIT

/datum/reagent/medicine/lonehope/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	var/healed = healing * REM * seconds_per_tick
	affected_mob.adjustToxLoss(-healed, FALSE, TRUE, affected_biotype)
	affected_mob.adjustOxyLoss(-healed, FALSE, TRUE, affected_biotype, required_respiration_type = affected_respiration_type)
	affected_mob.adjustBruteLoss(-healed, FALSE, TRUE, affected_bodytype)
	affected_mob.adjustFireLoss(-healed, FALSE, TRUE, affected_bodytype)
	if(affected_mob.blood_volume < BLOOD_VOLUME_NORMAL - healed)
		affected_mob.blood_volume += healed
	..()
	. = TRUE

/datum/reagent/medicine/lonehope/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick)
	var/healed = healing * REM * seconds_per_tick
	affected_mob.adjustToxLoss(-healed, FALSE, TRUE, affected_biotype)
	affected_mob.adjustOxyLoss(-healed, FALSE, TRUE, affected_biotype, required_respiration_type = affected_respiration_type)
	affected_mob.adjustBruteLoss(-healed, FALSE, TRUE, affected_bodytype)
	affected_mob.adjustFireLoss(-healed, FALSE, TRUE, affected_bodytype)
	if(affected_mob.blood_volume < BLOOD_VOLUME_NORMAL - healed)
		affected_mob.blood_volume += healed
	..()
	. = TRUE
///Status effect for us
/datum/status_effect/ancient_caretaker
	id = "ancientcaretaker"
	alert_type = null
	remove_on_fullheal = FALSE

/datum/status_effect/ancient_caretaker/on_creation(mob/living/new_owner)
	src.duration = -1
	return ..()

/datum/status_effect/ancient_caretaker/tick(seconds_between_ticks)
	var/healed = 1 * REM * seconds_between_ticks
	owner.adjustToxLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	owner.adjustOxyLoss(-healed, FALSE, TRUE, MOB_ORGANIC, required_respiration_type = ALL)
	owner.adjustBruteLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	owner.adjustFireLoss(-healed, FALSE, TRUE, MOB_ORGANIC)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL - healed)
		owner.blood_volume += healed
	..()

///Gps, for finding things
/obj/item/gps/advanced/lone_wanderer
	name = "ancient gps"
	desc = "Far too many seek this signal, only to find their graves. Far too few carry their own to be saved by this ones carrier."
	gpstag = "???"

///Dayum he loaded.
/obj/item/holochip/tenthousand
	credits = 10000


///Fuck you dusting implant I DONT WANT REMAINS.
/obj/item/implant/vanish
	name = "V.A.N.I.S.H. implant"
	desc = "To go without leaving a corpse. That is the way of the Gerudo."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "plutonium_core_pulse"
	actions_types = list(/datum/action/item_action/vansish_implant)
	var/popup = FALSE // is the window open?
	var/active = FALSE

/datum/action/item_action/vansish_implant
	check_flags = NONE
	name = "Activate V.A.N.I.S.H. Insurance Implant"

/obj/item/implant/vanish/proc/on_death(datum/source)
	SIGNAL_HANDLER
	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish.
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/item/implant/vanish,activate), "death")

/obj/item/implant/vanish/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> V.A.N.I.S.H. Insurance Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Highly unstable.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> To go without leaving a corpse. That is the way of the Gerudo.<BR>
				<b>Special Features:</b> Self Immolation<BR>
				"}
	return dat

/obj/item/implant/vanish/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to well, VANISH!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	to_chat(imp_in, "<span class='notice'>Your V.A.N.I.S.H. implant activates!</span>")

	if(imp_in)
		imp_in.investigate_log("has been QDEL'D by a V.A.N.I.S.H. Implant.", INVESTIGATE_DEATHS)
		QDEL_IN(imp_in,0.1 SECONDS)
		qdel(src)
		return

/obj/item/implant/vanish/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/vanish/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implanter/vanish
	name = "implanter (V.A.N.I.S.H.)"
	imp_type = /obj/item/implant/vanish

/obj/item/implantcase/vanish
	name = "implant case - 'V.A.N.I.S.H.'"
	desc = "A glass case containing a V.A.N.I.S.H. implant."
	imp_type = /obj/item/implant/vanish

/datum/action/item_action/vanish_implant
	check_flags = NONE
	name = "Activate V.A.N.I.S.H. Implant"
