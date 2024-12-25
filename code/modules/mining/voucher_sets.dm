/**
 * # Voucher Set
 *
 * A set consisting of a various equipment that can be then used as a reward for redeeming a mining voucher.
 *
 */
/datum/voucher_set
	/// Name of the set
	var/name
	/// Description of the set
	var/description
	/// Icon of the set
	var/icon
	/// Icon state of the set
	var/icon_state
	/// List of items contained in the set
	var/list/set_items = list()

/datum/voucher_set/mining/crusher_kit //monkestation edit
	name = "Crusher Kit"
	description = "Contains a kinetic crusher and a pocket fire extinguisher. Kinetic crusher is a versatile melee mining tool capable both of mining and fighting local fauna, however it is difficult to use effectively for anyone but most skilled and/or suicidal miners."
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	set_items = list(
		/obj/item/extinguisher/mini,
		/obj/item/kinetic_crusher,
		)

/datum/voucher_set/mining/extraction_kit //monkestation edit
	name = "Extraction and Rescue Kit"
	description = "Contains a fulton extraction pack and a beacon signaller, which allows you to send back home minerals, items and dead bodies without having to use the mining shuttle. And as a bonus, you get 30 marker beacons to help you better mark your path."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	set_items = list(
		/obj/item/extraction_pack,
		/obj/item/fulton_core,
		/obj/item/stack/marker_beacon/thirty,
		)

/datum/voucher_set/mining/resonator_kit //monkestation edit
	name = "Resonator Kit"
	description = "Contains a resonator and a pocket fire extinguisher. Resonator is a handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It does increased damage in low pressure."
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	set_items = list(
		/obj/item/extinguisher/mini,
		/obj/item/resonator,
		)

/datum/voucher_set/mining/survival_capsule //monkestation edit
	name = "Survival Capsule and Explorer's Webbing"
	description = "Contains an explorer's webbing, which allows you to carry even more mining equipment and already has a spare shelter capsule in it."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "explorer1"
	set_items = list(
		/obj/item/storage/belt/mining/vendor,
		)

/datum/voucher_set/mining/minebot_kit //monkestation edit
	name = "Minebot Kit"
	description = "Contains a little minebot companion that helps you in storing ore and hunting wildlife. Also comes with an upgraded industrial welding tool (80u), a welding mask and a KA modkit that allows shots to pass through the minebot."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "mining_drone"
	set_items = list(
		/mob/living/basic/mining_drone,
		/obj/item/weldingtool/hugetank,
		/obj/item/clothing/head/utility/welding,
		/obj/item/borg/upgrade/modkit/minebot_passthrough,
		)

/datum/voucher_set/mining/conscription_kit //monkestation edit
	name = "Mining Conscription Kit"
	description = "Contains a whole new mining starter kit for one crewmember, consisting of a proto-kinetic accelerator, a survival knife, a seclite, an explorer's suit, a mesons, an automatic mining scanner, a mining satchel, a gas mask, a mining radio key and a special ID card with a basic mining access."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "duffel-explorer"
	set_items = list(
		/obj/item/storage/backpack/duffelbag/mining_conscript,
	)

//MONKESTATION EDIT START
//categories
/datum/voucher_set/security

/datum/voucher_set/security/primary

/datum/voucher_set/security/utility

/datum/voucher_set/security/assistant //don't know a better name

/datum/voucher_set/security/primary/disabler
	name = "Disabler"
	description = "The standard issue energy gun of Nanotrasen security forces. Comes with it's own holster."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "disabler"
	set_items = list(
		/obj/item/storage/belt/holster/energy/disabler,
		/obj/item/gun/energy/disabler,
		)

/datum/voucher_set/security/primary/advanced_taser
	name = "Advanced Taser"
	description = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "advtaser"
	set_items = list(
		/obj/item/gun/energy/e_gun/advtaser,
		)

/datum/voucher_set/security/primary/disabler_smg
	name = "Disabler SMG"
	description = "An automatic disabler variant, as opposed to the conventional model, boasts a higher ammunition capacity at the cost of slightly reduced beam effectiveness."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "disabler_smg"
	set_items = list(
		/obj/item/gun/energy/disabler/smg,
		)

/datum/voucher_set/security/primary/paco
	name = "Paco"
	description = "A modern and reliable sidearm for the soldier in the field. Commonly issued as a sidearm to Security Officers. Uses standard and rubber .35 Auto and high capacity magazines."
	icon = 'monkestation/code/modules/security/icons/paco_ammo.dmi'
	icon_state = "35r-16"
	set_items = list(
		/obj/item/gun/ballistic/automatic/pistol/paco/no_mag,
		/obj/item/ammo_box/magazine/m35/rubber,
		/obj/item/ammo_box/magazine/m35/rubber,
		)

/datum/voucher_set/security/primary/strobe_shield
	name = "Strobe Shield"
	description = "A shield with a built in, high intensity light capable of blinding and disorienting suspects. Takes regular handheld flashes as bulbs."
	icon = 'icons/obj/weapons/shields.dmi'
	icon_state = "flashshield"
	set_items = list(
		/obj/item/shield/riot/flash,
		)

/datum/voucher_set/security/utility/nv_hud
	name = "Night Vision Security HUD"
	description = "An advanced heads-up display that provides ID data and vision in complete darkness."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "securityhudnight"
	set_items = list(
		/obj/item/clothing/glasses/hud/security/night,
		)

/datum/voucher_set/security/utility/sec_projector
	name = "Security Holobarrier Projector"
	description = "A holographic projector that creates holographic security barriers along with holographic handcuffs."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_sec"
	set_items = list(
		/obj/item/holosign_creator/security,
		)

/datum/voucher_set/security/utility/citationinator
	name = "Citationinator"
	description = "A cheaply made plastic handheld doohickey, capable of issuing fines to ner-do-wells, and printing out a slip of paper with the details of the fine."
	icon = 'monkestation/icons/obj/items/secass.dmi'
	icon_state = "doohickey_closed"
	set_items = list(
		/obj/item/citationinator,
		)

/datum/voucher_set/security/utility/donut_box
	name = "Donut Box"
	description = "Tantalizing..."
	icon = 'icons/obj/food/donuts.dmi'
	icon_state = "donutbox"
	set_items = list(
		/obj/item/storage/fancy/donut_box,
		/obj/item/reagent_containers/cup/glass/coffee,
		)

/datum/voucher_set/security/utility/flashbangs
	name = "Box of Flashbangs"
	description = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "flashbang"
	set_items = list(
		/obj/item/storage/box/flashbangs,
		)

/datum/voucher_set/security/utility/webbing
	name = "Security Webbing"
	description = "Unique and versatile chest rig, can hold security gear."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "securitywebbing"
	set_items = list(
		/obj/item/storage/belt/security/webbing,
		)

/datum/voucher_set/security/utility/justice_helmet
	name = "Helmet of Justice"
	description = "Crime fears the helmet of justice."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	icon_state = "justice"
	set_items = list(
		/obj/item/clothing/head/helmet/toggleable/justice,
		/obj/item/clothing/mask/gas/sechailer/swat,
		)

/datum/voucher_set/security/utility/pinpointer_pairs
	name = "Pinpointer Pair"
	description = "A pair of handheld tracking devices that lock onto the other half of the matching pair."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer"
	set_items = list(
		/obj/item/storage/box/pinpointer_pairs,
		)

/datum/voucher_set/security/utility/tackling_gloves
	name = "Gripper Gloves"
	description = "Special gloves that manipulate the blood vessels in the wearer's hands, granting them the ability to launch headfirst into walls."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "tackle"
	set_items = list(
		/obj/item/clothing/gloves/tackler,
		)

/datum/voucher_set/security/utility/swat
	name = "SWAT Helmet"
	description = "An extremely robust helmet with the Nanotrasen logo emblazoned on the top."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	icon_state = "swat"
	set_items = list(
		/obj/item/clothing/head/helmet/swat/nanotrasen,
		/obj/item/clothing/mask/gas/sechailer/swat,
		)

/datum/voucher_set/security/assistant/medical
	name = "Medical Kit"
	description = "A basic set of emergency triage tools to help injured officers."
	icon = 'icons/obj/storage/medkit.dmi'
	icon_state = "medbriefcase"
	set_items = list(
		/obj/item/emergency_bed,
		/obj/item/storage/medkit/emergency,
		)

/datum/voucher_set/security/assistant/nightwatch

/datum/voucher_set/security/assistant/brig_aid

/datum/voucher_set/security/assistant/detective

/datum/voucher_set/security/assistant/buddy_cop
