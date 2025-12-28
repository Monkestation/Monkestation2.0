/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE

	var/atom/contains_type
	var/notify_admins = FALSE

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftdeliverypackage[rand(1,5)]"

	contains_type = get_gift_type()

/obj/item/a_gift/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list..."))
	return BRUTELOSS

/obj/item/a_gift/examine(mob/M)
	. = ..()
	if((M.mind && HAS_TRAIT(M.mind, TRAIT_PRESENT_VISION)) || isobserver(M))
		. += span_notice("It contains \a [initial(contains_type.name)].")

/obj/item/a_gift/attack_self(mob/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_CANNOT_OPEN_PRESENTS))
		to_chat(M, span_warning("You're supposed to be spreading gifts, not opening them yourself!"))
		return

	qdel(src)

	var/gift_name = contains_type::name
	if(ispath(contains_type, /obj/item))
		var/atom/I = new contains_type(get_turf(M))
		if (!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
			M.put_in_hands(I)
			I.add_fingerprint(M)
			I.AddComponent(/datum/component/gift_item, M) // monkestation edit: gift item info component
			gift_name = I
		else
			M.visible_message(span_danger("Oh no! The present that [M] opened had nothing inside it!"))
			return
	else
		new contains_type(M.drop_location(), M)
	M.visible_message(span_notice("[M] unwraps \the [src], finding \a [gift_name] inside!"))
	M.investigate_log("has unwrapped a present containing [gift_name] ([contains_type]).", INVESTIGATE_PRESENTS)
	if(notify_admins)
		message_admins("[ADMIN_LOOKUPFLW(M)] unwrapped a present containing <b>[gift_name]</b> <small>([contains_type])</small>")

/obj/item/a_gift/proc/get_gift_type()
	var/gift_type_list = list(/obj/item/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/diamond,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_official,
		/obj/item/book/manual/wiki/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/basketball,
		/obj/item/banhammer,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/pai_card,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/biker,
		/obj/item/clothing/suit/costume/poncho,
		/obj/item/clothing/suit/costume/poncho/green,
		/obj/item/clothing/suit/costume/poncho/red,
		/obj/item/clothing/suit/costume/snowman,
		/obj/item/clothing/head/costume/snowman,
		/obj/item/stack/sheet/mineral/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo)) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"
	notify_admins = TRUE

/obj/item/a_gift/anything/get_gift_type()
	if(!length(GLOB.possible_gifts))
		GLOB.possible_gifts = initialize_possible_gifts()
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type

/obj/item/a_gift/spooky
	name = "spooky gift"
	desc = "Could contain tricks or treats!"

/obj/item/a_gift/spooky/Initialize(mapload)
	. = ..()
	icon_state = "spooky_gift"
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)

	contains_type = get_gift_type()

/obj/item/a_gift/spooky/get_gift_type()
	var/gift_type_list = list(/obj/item/food/burger/ghost,
		/obj/item/paper/selfdestruct/job_application,
		/obj/item/stack/sheet/hauntium,
		/obj/item/tome,
		/obj/item/clothing/suit/costume/ghost_sheet,
		/obj/item/food/cookie/sugar/spookycoffin,
		/obj/item/food/cookie/sugar/spookyskull,
		/mob/living/basic/skeleton,
		/obj/effect/mine/sound/bwoink,
		/obj/effect/mine/shrapnel/sting,
		/obj/item/clothing/mask/cigarette/syndicate,
		/obj/item/clothing/mask/cigarette/candy,
		/obj/effect/mine/sound/spooky,
		/obj/item/knife,
		/obj/item/restraints/legcuffs/beartrap/prearmed,
		/obj/item/skeleton_potion,
		/obj/item/bad_luck
		)
	var/gift_type = pick(gift_type_list)
	return gift_type

/proc/initialize_possible_gifts()
	. = subtypesof(/obj/item)
	for(var/obj/item/item_type as anything in .)
		if(!item_type::icon_state || !item_type::inhand_icon_state || (item_type::item_flags & (ABSTRACT | DROPDEL)))
			. -= item_type

	// List of items we want to block the anything-gift from spawning. Reasons for blocking
	// these vary, but usually come down to keeping the server (and game clients) stable.
	//
	// Subtypes of these items will also be blocked.
	var/list/blocked_items = list(
		// Just leaves the coordinates everywhere
		/obj/item/gps/visible_debug,
		// Can lag the hell out of the server
		/obj/item/gun/energy/recharge/kinetic_accelerator/meme,
		// Per Biddi's suggestion; plus doesn't seem to do much anyways?
		/obj/item/research,
		//only upsets people consistantly
		/obj/item/gun/magic/wand/death,
		/obj/item/gun/magic/wand/resurrection/debug,
		//holy fuck why was this enabled
		/obj/item/debug,
		/obj/item/storage/box/debugbox,
		/obj/item/gun/energy/beam_rifle/debug,
		/obj/item/multitool/field_debug,
		/obj/item/bounty_cube/debug_cube,
		/obj/item/organ/internal/cyberimp/brain/nif/debug,
		/obj/item/spellbook_charge/debug,
		/obj/item/uplink/nuclear/debug,
		//kills only the debug uplink from the gifts.
		/obj/item/mod/control/pre_equipped/chrono,

		// causes too many issues
		/obj/item/wallframe/painting/eldritch,

		// abstract items that shouldn't be gotten anyways
		/obj/item/clothing/head/chameleon/drone,
		/obj/item/clothing/mask/chameleon/drone,
		/obj/item/clothing/neck/necklace/ashwalker/cursed,

		//A list of every debug item I could find. I compiled a list of every item in the possible gifts list
		//and ran a keyword search through the list. Hopefully, this grabbed most, if not all, of the items.
		//There are PROBABLY repeats from the list above but it shouldn't matter.
		//Shaved down to exclude the non-game-breaking ones


		/obj/item/mod/control/pre_equipped/debug,
		/obj/item/reagent_containers/hypospray/medipen/tuberculosiscure/debug,
		/obj/item/reagent_containers/cup/bottle/disease_debug,
		/obj/item/pinpointer/area_pinpointer/debug,
		/obj/item/flashlight/emp/debug,
		/obj/item/airlock_painter/decal/debug,
		/obj/item/autosurgeon/organ/nif/debug,

		/obj/item/melee/skateboard/hoverboard/admin,
		/obj/item/mod/control/pre_equipped/administrative,
		/obj/item/bombcore/badmin/summon,
		/obj/item/bombcore/badmin/summon/clown,
		/obj/item/ai_module/core/full/admin,
		/obj/item/rwd/admin,
		/obj/item/mining_scanner/admin,
		/obj/item/kinetic_crusher/adminpilebunker,
		/obj/item/camera/spooky/badmin,
		/obj/item/storage/box/fish_debug,
	)

	for(var/blocked_item in blocked_items)
		// Block the item listed, and any subtypes too.
		. -= typesof(blocked_item)

	// Boring items that will get blocked during the week of christmas.
	var/list/boring_items = list(
		/obj/item/ammo_casing,
		/obj/item/circuit_component,
		/obj/item/electronics,
		/obj/item/mcobject,
		/obj/item/paper,
		/obj/item/pipe,
		/obj/item/reagent_containers,
		/obj/item/stack/cable_coil,
		/obj/item/stack/medical,
		/obj/item/stack/pipe_cleaner_coil,
		/obj/item/stack/rods,
		/obj/item/stack/tile,
		/obj/item/storage/pill_bottle,
		/obj/item/trash,
	)
	var/time_info = time2text(world.realtime, "MM DD")
	var/month = text2num(copytext(time_info, 1, 3))
	var/day = text2num(copytext(time_info, 4))
	// first day of winter / sunday before christmas -> day after christmas
	if(month == 12 && ISINRANGE(day, 21, 26))
		for(var/blocked_item in boring_items)
			// Block the item listed, and any subtypes too.
			. -= typesof(blocked_item)
		// remove anything that's just available in loadout
		. -= assoc_to_keys(GLOB.all_loadout_datums)

	// List of items with a reduced chance to spawn
	var/list/reduced_chance_items = list(
		// Security reasons
		/obj/item/card/id/advanced/centcom,
		/obj/item/construction/rcd/combat/admin,
	)
	for(var/reduced_chance_item in reduced_chance_items)
		if(prob(50))
			. -= typesof(reduced_chance_item)

