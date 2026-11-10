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
		/obj/item/storage/backpack/deforest_surgical/stocked = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/bodybag/bluespace = 1,
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

	r_pocket = /obj/item/reagent_containers/medipen/advanced/blood_loss
	l_pocket = /obj/item/reagent_containers/medipen/ekit

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

/obj/item/gps/advanced/lone_wanderer
	name = "ancient gps"
	desc = "Far too many seek this signal, only to find their graves. Far too few carry their own to be saved by this ones carrier."
	gpstag = "???"

/obj/item/holochip/tenthousand
	credits = 10000

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
