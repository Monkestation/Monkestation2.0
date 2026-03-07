/obj/item/autosurgeon/holy
	name = "holy autosurgeon"
	desc = "A device that automatically inserts an implant into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items. \
		This one can only manipulate the organs of mechanical beings such as androids and IPCs."
	organ_whitelist = list(
	/obj/item/organ/internal/cyberimp,
	/obj/item/organ/internal/brain/cybernetic,
	/obj/item/organ/internal/eyes/robotic,
	/obj/item/organ/internal/ears/cybernetic,
	/obj/item/organ/internal/tongue/robot,
	/obj/item/organ/internal/vocal_cords/colossus, // It's divine
	/obj/item/organ/internal/heart/cybernetic,
	/obj/item/organ/internal/lungs/cybernetic,
	/obj/item/organ/internal/stomach/cybernetic,
	/obj/item/organ/internal/liver/cybernetic,
	/obj/item/organ/external/wings/functional/robotic,
	
	/obj/item/organ/internal/brain/clockwork,
	/obj/item/organ/internal/eyes/robotic/clockwork,
	/obj/item/organ/internal/ears/robot/clockwork,
	/obj/item/organ/internal/heart/clockwork,
	/obj/item/organ/internal/lungs/clockwork,
	/obj/item/organ/internal/stomach/clockwork,
	/obj/item/organ/internal/liver/clockwork,

	/obj/item/organ/internal/butt/cyber,
	/obj/item/organ/internal/butt/atomic,
	/obj/item/organ/internal/butt/bluespace,
	/obj/item/organ/internal/butt/iron,
	/obj/item/organ/internal/brain/synth,
	/obj/item/organ/internal/eyes/synth,
	/obj/item/organ/internal/ears/synth,
	/obj/item/organ/internal/heart/synth,
	/obj/item/organ/internal/stomach/synth,
	/obj/item/organ/internal/liver/synth,
	/obj/item/organ/internal/lungs/synth,
	/obj/item/organ/internal/tongue/synth
	)

/obj/item/autosurgeon/holy/use_autosurgeon(mob/living/target, mob/living/user, implant_time)
	if(!(MOB_ROBOTIC & target.mob_biotypes))
		to_chat(user, span_alert("[target] is not a machine and cannot be implanted with this."))
		playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
		return
	
	..()
