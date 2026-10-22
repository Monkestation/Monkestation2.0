/obj/item/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bandaid"
	resistance_flags = FLAMMABLE
	inhand_icon_state = null
	possible_transfer_amounts = list()
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 30 // three seconds
	dissolvable = FALSE

	skips_attack = TRUE

	/// the intial volume of the patch, this is for more uniform application chemicals overtime
	var/initial_volume

	///rate at which chemicals are injected per process in a percentage
	var/reagent_consumption_rate = 0.1

	///The thing we are attached to
	var/mob/living/attached
	///The overlay we apply to things we stick to
	var/mutable_appearance/patch_overlay

/obj/item/reagent_containers/pill/patch/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isliving(target))
		return ..()

	if(resistance_flags & ON_FIRE)
		balloon_alert(user, "on fire!")
		forceMove(drop_location())
		return

	if(target != user && !do_after(user, CHEM_INTERACT_DELAY(3 SECONDS, user), target))
		return ITEM_INTERACT_BLOCKING

	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	var/divided_size = world.icon_size / 2
	var/px = text2num(LAZYACCESS(modifiers, ICON_X)) - divided_size
	var/py = text2num(LAZYACCESS(modifiers, ICON_Y)) - divided_size
	user.do_attack_animation(target)
	stick(target,user,px,py)
	return .

/obj/item/reagent_containers/pill/patch/proc/stick(atom/target, mob/living/user, px,py)
	if(!initial_volume)
		initial_volume = reagents.total_volume

	patch_overlay = mutable_appearance(icon, icon_state , layer = target.layer + 1, appearance_flags = RESET_COLOR)
	var/matrix/new_matrix = matrix()
	new_matrix.Scale(0.5, 0.5)
	patch_overlay.transform = new_matrix
	patch_overlay.pixel_x = px
	patch_overlay.pixel_y = py
	target.add_overlay(patch_overlay)
	attached = target
	if(isliving(target) && user)
		var/mob/living/victim = target
		if(victim.client)
			user.log_message("stuck [src] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [src] stuck to them by [key_name(user)]", LOG_ATTACK)
	register_signals(user)
	moveToNullspace()
	START_PROCESSING(SSobj, src)

///Registers signals to the object it is attached to
/obj/item/reagent_containers/pill/patch/proc/register_signals(mob/living/user)
	RegisterSignal(attached, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(attached, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(attached, COMSIG_QDELETING, PROC_REF(on_attached_qdel))
	RegisterSignal(attached, COMSIG_HUMAN_BURNING, PROC_REF(on_burn))

//Unregisters signals from the object it is attached to
/obj/item/reagent_containers/pill/patch/proc/unregister_signals(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(attached, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_IGNITED, COMSIG_QDELETING, COMSIG_HUMAN_BURNING))

/obj/item/reagent_containers/pill/patch/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(resistance_flags & ON_FIRE)
		return
	if(!. && prob(10) && isliving(hit_atom))
		stick(hit_atom, throwingdatum.thrower, rand(-7,7), rand(-7,7))
		to_chat(attached, span_bolddanger("[src] has stuck to you."))
		attached.balloon_alert_to_viewers("[src] lands on its sticky side!")

/obj/item/reagent_containers/pill/patch/fire_act(temperature, volume)
	if(isturf(loc))
		var/turf/our_turf = loc
		if(our_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(src, TRAIT_T_RAY_VISIBLE))
			return
	if(temperature && !(resistance_flags & FIRE_PROOF))
		take_damage(clamp(0.02 * temperature, 0, 20), BURN, FIRE, 0)
	if(QDELETED(src)) // take_damage() can send our obj to an early grave, let's stop here if that happens
		return
	if(!(resistance_flags & ON_FIRE) && (resistance_flags & FLAMMABLE) && !(resistance_flags & FIRE_PROOF))
		AddComponent(/datum/component/burning, custom_fire_overlay || GLOB.fire_overlay, burning_particles)
		START_PROCESSING(SSobj, src)
		return TRUE
	return ..()

///Signal handler for COMSIG_LIVING_IGNITED, deletes this patch, if it is flammable
/obj/item/reagent_containers/pill/patch/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	if(!(resistance_flags & FLAMMABLE))
		return
	to_chat(attached, span_warning("The [src] burns!"))
	reagents.expose_temperature(2000)

/obj/item/reagent_containers/pill/patch/proc/on_burn()
	SIGNAL_HANDLER
	if(!(resistance_flags & FLAMMABLE))
		return
	to_chat(attached, span_warning("The [src] burns!"))
	reagents.expose_temperature(2000)

/// Signal handler for COMSIG_QDELETING, deletes this patch if the attached object is deleted
/obj/item/reagent_containers/pill/patch/proc/on_attached_qdel(datum/source)
	SIGNAL_HANDLER
	peel()
	qdel(src)

///Makes this patch move from nullspace and cut the overlay from the object it is attached to, silent for no visible message.
/obj/item/reagent_containers/pill/patch/proc/peel(datum/source)
	SIGNAL_HANDLER
	if(!attached)
		return
	attached.cut_overlay(patch_overlay)
	patch_overlay = null
	forceMove(attached.drop_location())
	pixel_y = rand(-4,1)
	pixel_x = rand(-3,3)
	unregister_signals()
	attached = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/pill/patch/process(seconds_per_tick)
	if(resistance_flags & ON_FIRE)
		reagents.expose_temperature(2000)
		return

	if(!reagents.total_volume)
		peel()
		qdel(src)
		return

	reagents.trans_to(attached, initial_volume * reagent_consumption_rate, methods = PATCH)

/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	return TRUE // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/pill/patch/Destroy(force)
	. = ..()
	if(attached)
		peel()

/obj/item/reagent_containers/pill/patch/libital
	name = "libital patch (brute)"
	desc = "A pain reliever. Does minor liver damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/libital = 2, /datum/reagent/medicine/granibitaluri = 8) //10 iterations
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/pill/patch/aiuri
	name = "aiuri patch (burn)"
	desc = "Helps with burn injuries. Does minor eye damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 2, /datum/reagent/medicine/granibitaluri = 8)
	icon_state = "bandaid_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries. Slightly toxic."
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 20)
	icon_state = "bandaid_both"

/obj/item/reagent_containers/pill/patch/modafinil
	name = "modafinil patch (WARNING)"
	desc = "Helps quickly wake up patients and cures dizziness. Easy to overdose, apply one patch and wait for it to finish applying before applying another."
	list_reagents = list(/datum/reagent/medicine/modafinil = 1)
	icon_state = "bandaid_exclaimationpoint"

// Patch styles for chem master

/obj/item/reagent_containers/pill/patch/style
	icon_state = "bandaid_blank"
/obj/item/reagent_containers/pill/patch/style/brute
	icon_state = "bandaid_brute_2"
/obj/item/reagent_containers/pill/patch/style/burn
	icon_state = "bandaid_burn_2"
/obj/item/reagent_containers/pill/patch/style/bruteburn
	icon_state = "bandaid_both"
/obj/item/reagent_containers/pill/patch/style/toxin
	icon_state = "bandaid_toxin_2"
/obj/item/reagent_containers/pill/patch/style/oxygen
	icon_state = "bandaid_suffocation_2"
/obj/item/reagent_containers/pill/patch/style/omni
	icon_state = "bandaid_mix"
/obj/item/reagent_containers/pill/patch/style/bruteplus
	icon_state = "bandaid_brute"
/obj/item/reagent_containers/pill/patch/style/burnplus
	icon_state = "bandaid_burn"
/obj/item/reagent_containers/pill/patch/style/toxinplus
	icon_state = "bandaid_toxin"
/obj/item/reagent_containers/pill/patch/style/oxygenplus
	icon_state = "bandaid_suffocation"
/obj/item/reagent_containers/pill/patch/style/monkey
	icon_state = "bandaid_monke"
/obj/item/reagent_containers/pill/patch/style/clown
	icon_state = "bandaid_clown"
/obj/item/reagent_containers/pill/patch/style/one
	icon_state = "bandaid_1"
/obj/item/reagent_containers/pill/patch/style/two
	icon_state = "bandaid_2"
/obj/item/reagent_containers/pill/patch/style/three
	icon_state = "bandaid_3"
/obj/item/reagent_containers/pill/patch/style/four
	icon_state = "bandaid_4"
/obj/item/reagent_containers/pill/patch/style/exclamation
	icon_state = "bandaid_exclaimationpoint"
/obj/item/reagent_containers/pill/patch/style/question
	icon_state = "bandaid_questionmark"
/obj/item/reagent_containers/pill/patch/style/colonthree
	icon_state = "bandaid_colonthree"
