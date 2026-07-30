/obj/item/robot_model/security
	name = "Security"
	hud_icon_state = "security"
	default_skin = /datum/robot_skin/security/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/security/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/extinguisher/mini,
	)
	emagged_modules = list(
		/obj/item/gun/energy/laser/cyborg,
	)
	clockwork_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clockwork/weapon/brass_spear,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/vanguard,
	)
	radio_channels = list(RADIO_CHANNEL_SECURITY)
	traits = list(TRAIT_PUSHIMMUNE)

/obj/item/robot_model/security/Initialize(mapload)
	. = ..()
	if(!cyborg_owner)
		return
	to_chat(cyborg_owner, span_userdanger("While you have picked the security model, you still have to follow your laws, NOT Space Law. \
		For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to."))
