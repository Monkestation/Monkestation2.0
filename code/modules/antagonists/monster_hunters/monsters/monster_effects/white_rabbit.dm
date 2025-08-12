/obj/effect/bnnuy
	name = "wonderland rift"
	desc = span_big(span_hypnophrase("FEED YOUR HEAD."))
	icon = 'monkestation/icons/mob/rabbit.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	/// The icon state applied to the image created for this rift.
	var/real_icon_state = "bnnuy-rift"
	/// The antag datum of the monster hunter that can see us.
	var/datum/antagonist/monsterhunter/hunter_antag
	/// Has the rabbit already whispered?
	var/being_used = FALSE
	/// Is this rabbit selected to drop the gun?
	var/drop_gun = FALSE

/obj/effect/bnnuy/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	if(!istype(hunter) || QDELING(hunter) || QDELETED(hunter.owner) || !isopenturf(loc))
		return INITIALIZE_HINT_QDEL
	hunter_antag = hunter
	var/image/hunter_image = image(icon, src, real_icon_state, OBJ_LAYER)
	SET_PLANE_EXPLICIT(hunter_image, ABOVE_LIGHTING_PLANE, src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/bnnuy_rift, "bnnuy_rift", hunter_image, hunter_antag.owner)
	AddElement(/datum/element/block_turf_fingerprints)
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))

/obj/effect/bnnuy/Destroy(force)
	hunter_antag?.rabbits -= src
	hunter_antag = null
	return ..()

/obj/effect/bnnuy/examine(mob/user)
	. = ..()
	if(hunter_antag)
		. += span_info("You have found [hunter_antag.rabbits_spotted] out of 5 rabbits.")

/obj/effect/bnnuy/attack_hand(mob/living/user, list/modifiers)
	if(user?.mind != hunter_antag.owner)
		return SECONDARY_ATTACK_CALL_NORMAL
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(being_used)
		return
	being_used = TRUE
	open_rift(user)
	SEND_SIGNAL(hunter_antag, COMSIG_GAIN_INSIGHT)
	qdel(src)

/obj/effect/bnnuy/proc/verify_user_can_see(mob/user)
	return (user?.mind == hunter_antag.owner)

/obj/effect/bnnuy/proc/open_rift(mob/living/user)
	var/list/extra_logs = list()
	if(hunter_antag?.rabbits_spotted == 0) //our first bunny
		user.put_in_hands(new /obj/item/clothing/mask/cursed_rabbit(drop_location()))
		extra_logs += "the cursed rabbit mask"
	user.put_in_hands(new /obj/item/rabbit_eye(drop_location()))
	if(drop_gun)
		give_gun(user)
		extra_logs += "the hunter's revolver"
	hunter_antag?.rabbits -= src
	var/msg = "opened a wonderland rift at [AREACOORD(src)]"
	if(length(extra_logs) > 0)
		msg += ", which dropped [english_list(extra_logs)]"
	user.log_message(msg, LOG_GAME)
	// spawn a wonderland rift right here in 20-60 seconds
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_new), /obj/effect/anomaly/dimensional/wonderland/rift, get_turf(src), null, FALSE), rand(20 SECONDS, 1 MINUTES))
	var/rabbit_amount = max(rand(hunter_antag.rabbits_spotted, hunter_antag.rabbits_spotted + 2), 2)
	// spawn (benign) rabbits randomly around the station
	for(var/i = 1 to rabbit_amount)
		var/turf/target_turf = get_safe_random_station_turf_equal_weight()
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_new), /obj/effect/wonderland_rabbit_enter, target_turf), rand(5 SECONDS, 30 SECONDS))

/obj/effect/bnnuy/proc/give_gun(mob/living/user)
	user.put_in_hands(new /obj/item/gun/ballistic/revolver/hunter_revolver(drop_location()))
	var/datum/action/cooldown/spell/conjure_item/blood_silver/silverblood = new(user)
	silverblood.StartCooldown()
	silverblood.Grant(user)

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift
	add_ghost_version = TRUE
	/// The mind of the hunter that should see this rift.
	var/datum/mind/hunter_mind

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/New(key, image/I, datum/mind/hunter_mind)
	src.hunter_mind = hunter_mind
	return ..(key, I, NONE)

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/Destroy()
	. = ..()
	hunter_mind = null

/datum/atom_hud/alternate_appearance/basic/bnnuy_rift/mobShouldSee(mob/target)
	return !isobserver(target) && target.mind == hunter_mind
