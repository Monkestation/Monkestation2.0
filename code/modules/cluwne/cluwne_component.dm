/datum/component/cluwne
	/// our current deconversion method
	var/deconversion_method
	var/mob/living/carbon/human/our_cluwne
	var/datum/mind/our_mind
	var/old_brain_type

/datum/component/cluwne/Initialize(deconversion = CLUWNE_DECONVERT_ON_DEATH)
	if(!istype(parent, /mob/living/carbon/human))
		return COMPONENT_INCOMPATIBLE
	our_cluwne = parent
	deconversion_method = deconversion
	makeCluwne(our_cluwne)
	if(our_cluwne?.mind)
		our_mind = our_cluwne.mind
	START_PROCESSING(SSprocessing, src)

/datum/component/cluwne/RegisterWithParent()
	if(our_mind)
		RegisterSignal(our_mind, COMSIG_MIND_TRANSFERRED, PROC_REF(on_transfer))

/datum/component/cluwne/UnregisterFromParent()
	if(our_mind)
		UnregisterSignal(our_mind, COMSIG_MIND_TRANSFERRED)

/datum/component/cluwne/proc/on_transfer(datum/mind/source, mob/living/old_current)
	SIGNAL_HANDLER
	if(ishuman(old_current))
		removeCluwne(old_current)
	if(ishuman(our_mind.current))
		our_mind.current.AddComponent(/datum/component/cluwne, deconversion = deconversion_method) //no escape
		qdel(src)

/datum/component/cluwne/proc/makeCluwne(mob/living/carbon/human/our_human)
	if(HAS_TRAIT(our_human, TRAIT_CLUWNE))
		return
	ADD_TRAIT(our_human, TRAIT_CLUWNE, REF(src))
	our_cluwne = our_human
	var/obj/item/organ/internal/brain/cluwne/new_brain = new()
	var/obj/item/organ/internal/brain/existing_brain = our_cluwne.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!istype(existing_brain, new_brain) && !existing_brain.decoy_override)
		var/list/skillchips
		skillchips = existing_brain.clone_skillchip_list()
		our_cluwne.destroy_all_skillchips(silent = TRUE)
		old_brain_type = existing_brain.type
		new_brain.replace_into(our_cluwne)
		if(skillchips)
			for(var/chip in skillchips)
				var/chip_type = chip["type"]
				if(!ispath(chip_type, /obj/item/skillchip))
					continue
				var/obj/item/skillchip/skillchip = new chip_type(our_cluwne)
				if(our_cluwne.implant_skillchip(skillchip, force = TRUE))
					qdel(skillchip)
					continue
				skillchip.set_metadata(chip, silent = TRUE)


	if(istype(our_cluwne.back, /obj/item/mod/control))
		var/obj/item/mod/control/modsuit_control = our_cluwne.back
		if(istype(our_cluwne.wear_suit, /obj/item/clothing/suit/mod))
			modsuit_control.active = FALSE
			modsuit_control.quick_deploy(src)

	to_chat(our_cluwne, "<span class='danger'>You feel funny.</span>")

	var/datum/effect_system/fluid_spread/smoke/green/smoke = new
	smoke.set_up(0, holder = our_cluwne, location = get_turf(our_cluwne))
	smoke.start()

	our_cluwne.playsound_local(get_turf(our_cluwne), 'sound/voice/cluwne/cluwne_conversion.ogg', 50,0, use_reverb = TRUE)

	our_cluwne.Stun(3 SECONDS)
	dress_up()

	RegisterSignal(our_cluwne, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(our_cluwne, COMSIG_ATOM_ATTACKBY,PROC_REF(on_attack))

/datum/component/cluwne/proc/dress_up()
	if(our_cluwne.dropItemToGround(our_cluwne.wear_mask) && !istype(!our_cluwne.wear_mask , /obj/item/clothing/mask/gas/cluwne))
		var/obj/item/clothing/cluwne_mask = new /obj/item/clothing/mask/gas/cluwne(our_cluwne)
		our_cluwne.equip_to_slot_or_del(cluwne_mask, ITEM_SLOT_MASK)
		ADD_TRAIT(cluwne_mask, TRAIT_NODROP, REF(src))
		ADD_TRAIT(cluwne_mask, TRAIT_CLUWNE, REF(src))

	if(our_cluwne.dropItemToGround(our_cluwne.w_uniform) && !istype(our_cluwne.w_uniform, /obj/item/clothing/under/rank/civilian/clown/cluwne))
		var/obj/item/clothing/cluwne_shirt = new /obj/item/clothing/under/rank/civilian/clown/cluwne(our_cluwne)
		our_cluwne.equip_to_slot_or_del(cluwne_shirt, ITEM_SLOT_ICLOTHING)
		ADD_TRAIT(cluwne_shirt, TRAIT_NODROP, REF(src))
		ADD_TRAIT(cluwne_shirt, TRAIT_CLUWNE, REF(src))

	if(our_cluwne.dropItemToGround(our_cluwne.gloves) && !istype(our_cluwne.gloves, /obj/item/clothing/gloves/color/white/cluwne))
		var/obj/item/clothing/cluwne_gloves = new /obj/item/clothing/gloves/color/white/cluwne(our_cluwne)
		our_cluwne.equip_to_slot_or_del(cluwne_gloves, ITEM_SLOT_GLOVES)
		ADD_TRAIT(cluwne_gloves, TRAIT_NODROP, REF(src))
		ADD_TRAIT(cluwne_gloves, TRAIT_CLUWNE, REF(src))

	if(our_cluwne.dropItemToGround(our_cluwne.shoes) && !istype(our_cluwne.shoes, /obj/item/clothing/shoes/clown_shoes/cluwne/cursed))
		var/obj/item/clothing/cluwne_shoes = new /obj/item/clothing/shoes/clown_shoes/cluwne/cursed(our_cluwne)
		our_cluwne.equip_to_slot_or_del(cluwne_shoes, ITEM_SLOT_FEET)
		ADD_TRAIT(cluwne_shoes, TRAIT_NODROP, REF(src))
		ADD_TRAIT(cluwne_shoes, TRAIT_CLUWNE, REF(src))

/datum/component/cluwne/proc/removeCluwne(mob/living/carbon/human/our_human, remove_curse = FALSE)
	if(!HAS_TRAIT(our_human, TRAIT_CLUWNE))
		return
	REMOVE_TRAIT(our_cluwne, TRAIT_CLUWNE, REF(src))
	var/obj/item/organ/internal/brain/existing_brain = our_human.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(istype(existing_brain, /obj/item/organ/internal/brain/cluwne) && !existing_brain.decoy_override)
		var/list/skillchips
		skillchips = existing_brain.clone_skillchip_list()
		our_human.destroy_all_skillchips(silent = TRUE)
		var/obj/item/organ/internal/brain/new_brain = new old_brain_type()
		new_brain.replace_into(our_human)
		if(skillchips)
			for(var/chip in skillchips)
				var/chip_type = chip["type"]
				if(!ispath(chip_type, /obj/item/skillchip))
					continue
				var/obj/item/skillchip/skillchip = new chip_type(our_cluwne)
				if(our_human.implant_skillchip(skillchip, force = TRUE))
					qdel(skillchip)
					continue
				skillchip.set_metadata(chip, silent = TRUE)

	var/datum/effect_system/fluid_spread/smoke/green/smoke = new
	smoke.set_up(0, holder = our_cluwne, location = get_turf(our_human))
	smoke.start()
	our_human.playsound_local(get_turf(our_human), 'sound/voice/cluwne/cluwne_deconversion.ogg', 50,0, use_reverb = TRUE)

	var/list/belongings = our_human.get_all_gear()
	for(var/obj/item/clothing/clothing_item in belongings)
		if(HAS_TRAIT(clothing_item, TRAIT_CLUWNE))
			qdel(clothing_item)
	UnregisterSignal(our_cluwne, COMSIG_LIVING_DEATH)
	UnregisterSignal(our_cluwne, COMSIG_ATOM_ATTACKBY)

	if(remove_curse)
		qdel(src)

/datum/component/cluwne/process(seconds_per_tick)
	if(our_cluwne && HAS_TRAIT(our_cluwne, TRAIT_CLUWNE))
		dress_up()

/datum/component/cluwne/proc/on_attack(atom/movable/source, obj/item/item, mob/living/attacker)
	SIGNAL_HANDLER

	if(!our_cluwne)
		return

	if(!ishuman(attacker))
		return

	var/mob/living/carbon/human/our_attacker = attacker

	if(!istype(our_cluwne.buckled, /obj/structure/altar_of_gods))
		return
	if(!istype(item, /obj/item/book/bible))
		return
	if(!our_attacker.mind?.holy_role)
		return

	INVOKE_ASYNC(src, PROC_REF(excorcise), our_attacker, item)
	return COMPONENT_NO_AFTERATTACK

/datum/component/cluwne/proc/excorcise(mob/living/carbon/human/priest, obj/item/item)
	our_cluwne.visible_message(span_danger("[priest] smacks [our_cluwne]'s twisted form with [item]."))
	playsound(our_cluwne, SFX_PUNCH, 25, TRUE, -1)
	var/god = "Christ"
	if(GLOB.deity)
		god = "[GLOB.deity]"
	var/exorcism_phrase = "The power of [god] compels you!"
	priest.say(exorcism_phrase, forced = item.name)
	our_cluwne.emote("screech")
	our_cluwne.emote("spin")
	our_cluwne.emote("flip")
	addtimer(CALLBACK(src, PROC_REF(removeCluwne), our_cluwne, TRUE), 2 SECONDS)

/datum/component/cluwne/proc/on_death(mob/living/died, gibbed)
	SIGNAL_HANDLER
	if(!ishuman(died))
		return
	if(deconversion_method == CLUWNE_DECONVERT_ON_DEATH)
		removeCluwne(our_cluwne, remove_curse = TRUE)

/datum/component/cluwne/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSprocessing, src)
