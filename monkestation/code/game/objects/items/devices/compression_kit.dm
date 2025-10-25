/obj/item/compression_kit
	name = "bluespace compression kit"
	desc = "An illegally modified BSRPED, capable of reducing the size of most items."
	icon = 'monkestation/icons/obj/tools.dmi'
	icon_state = "compression_kit"
	inhand_icon_state = "BS_RPED"
	worn_icon_state = "RPED"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/charges = 5

/obj/item/compression_kit/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges left. Recharge with bluespace crystals.")

/obj/item/compression_kit/proc/sparks()
	var/datum/effect_system/spark_spread/spark_spread = new /datum/effect_system/spark_spread
	spark_spread.set_up(5, TRUE, get_turf(src))
	spark_spread.start()

/obj/item/compression_kit/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = NONE
	if(!isitem(interacting_with))
		return NONE
	var/obj/item/target_item = interacting_with
	if(charges <= 0)
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(user, span_warning("The bluespace compression kit is out of charges! Recharge it with bluespace crystals."))
		return ITEM_INTERACT_BLOCKING
	var/pre_compress = SEND_SIGNAL(target_item, COMSIG_ITEM_PRE_COMPRESS, user, src)
	if(pre_compress & COMPONENT_STOP_COMPRESSION)
		if(!(pre_compress & COMPONENT_HANDLED_MESSAGE))
			to_chat(user, span_warning("[src] is unable to compress [target_item]!"))
		return ITEM_INTERACT_BLOCKING
	if(target_item.w_class <= WEIGHT_CLASS_TINY)
		playsound(get_turf(src), 'sound/machines/buzz-two.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		to_chat(user, span_warning("[target_item] cannot be compressed smaller!"))
		return ITEM_INTERACT_BLOCKING

	playsound(get_turf(src), 'sound/weapons/flash.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	user.visible_message(span_warning("[user] is compressing [target_item] with [src]!"), vision_distance = COMBAT_MESSAGE_RANGE)
	if(!do_after(user, 4 SECONDS, target_item, interaction_key = "[type]", hidden = TRUE) && charges > 0 && target_item.w_class > WEIGHT_CLASS_TINY)
		return ITEM_INTERACT_BLOCKING

	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', vol = 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	sparks()
	flash_lighting_fx(range = 3, power = 3, color = LIGHT_COLOR_CYAN)
	if(!target_item.adjust_weight_class(-1))
		to_chat(user, span_bolddanger("Bluespace compression has encountered a critical error and stopped working, please report this your superiors."))
		return ITEM_INTERACT_FAILURE
	SEND_SIGNAL(target_item, COMSIG_ITEM_COMPRESSED, user, src)
	charges -= 1
	to_chat(user, span_boldnotice("You successfully compress [target_item]! [src] now has [charges] charges."))
	return ITEM_INTERACT_SUCCESS

/obj/item/compression_kit/attackby(obj/item/stack/bs, mob/user, params)
	. = ..()
	var/static/list/bs_typecache = typecacheof(list(/obj/item/stack/ore/bluespace_crystal, /obj/item/stack/sheet/bluespace_crystal))
	if(is_type_in_typecache(bs, bs_typecache) && bs.use(1))
		charges += 2
		to_chat(user, span_notice("You insert [bs] into [src]. It now has [charges] charges."))

/obj/item/compression_kit/storage_insert_on_interaction(datum/storage, atom/storage_holder, mob/user)
	return !HAS_TRAIT(storage_holder, TRAIT_BYPASS_COMPRESS_CHECK)
