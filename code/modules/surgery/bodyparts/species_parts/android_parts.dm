/**
 * This is ultra stupid, but essentially androids use robotic limb subtypes that are NOT
 * immune to being replaced on species change.
 * Yes, that is the entire reason these exist.
 */

/obj/item/bodypart/head/robot/android
	change_exempt_flags = NONE
	head_flags = HEAD_HAIR | HEAD_EYESPRITES

/obj/item/bodypart/chest/robot/android
	change_exempt_flags = NONE
	bodypart_traits = list(TRAIT_LIMBATTACHMENT)
	wing_types = list(/obj/item/organ/external/wings/functional/robotic)

/obj/item/bodypart/arm/left/robot/android
	change_exempt_flags = NONE

/obj/item/bodypart/arm/right/robot/android
	change_exempt_flags = NONE

/obj/item/bodypart/leg/left/robot/android
	change_exempt_flags = NONE
	step_sounds = list('sound/effects/servostep.ogg')

/obj/item/bodypart/leg/right/robot/android
	change_exempt_flags = NONE
	step_sounds = list('sound/effects/servostep.ogg')
