/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "toolkit_generic"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	encode_info = AUGMENT_NT_LOWLEVEL
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	/// Organ slot that the implant occupies for the right arm
	var/right_arm_organ_slot = ORGAN_SLOT_RIGHT_ARM_AUG
	/// Organ slot that the implant occupies for the left arm
	var/left_arm_organ_slot = ORGAN_SLOT_LEFT_ARM_AUG

/obj/item/organ/internal/cyberimp/arm/Initialize(mapload)
	. = ..()
	update_appearance()
	SetSlotFromZone()

/obj/item/organ/internal/cyberimp/arm/Destroy()
	hand = null
	return ..()

/obj/item/organ/internal/cyberimp/arm/on_insert(mob/living/carbon/arm_owner)
	. = ..()
	RegisterSignal(arm_owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_limb_attached))
	RegisterSignal(arm_owner, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.
	on_limb_attached(arm_owner, arm_owner.hand_bodyparts[zone == BODY_ZONE_R_ARM ? RIGHT_HANDS : LEFT_HANDS])

/obj/item/organ/internal/cyberimp/arm/on_remove(mob/living/carbon/arm_owner)
	. = ..()
	UnregisterSignal(arm_owner, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_KB_MOB_DROPITEM_DOWN))
	on_limb_detached(hand)

/obj/item/organ/internal/cyberimp/arm/proc/on_limb_attached(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(!limb || QDELETED(limb) || limb.body_zone != zone)
		return
	if(hand)
		on_limb_detached(hand)
	RegisterSignal(limb, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self))
	RegisterSignal(limb, COMSIG_BODYPART_REMOVED, PROC_REF(on_limb_detached))
	hand = limb

/obj/item/organ/internal/cyberimp/arm/proc/on_limb_detached(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(source != hand || QDELETED(hand))
		return
	UnregisterSignal(hand, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_BODYPART_REMOVED))
	hand = null

/obj/item/organ/internal/cyberimp/arm/proc/on_item_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

/obj/item/organ/internal/cyberimp/arm/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER

/datum/action/item_action/organ_action/toggle/toolkit
	desc = "You can also activate your empty hand or the tool in your hand to open the tools radial menu."

/obj/item/organ/internal/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = left_arm_organ_slot
		if(BODY_ZONE_R_ARM)
			slot = right_arm_organ_slot
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/internal/cyberimp/arm/update_icon()
	. = ..()
	transform = (zone == BODY_ZONE_R_ARM) ? null : matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC)
		. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.")

/obj/item/organ/internal/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/screwtool)
	. = ..()
	if(.)
		return TRUE
	screwtool.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	update_appearance()
