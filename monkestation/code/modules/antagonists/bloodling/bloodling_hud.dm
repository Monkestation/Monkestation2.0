
/datum/hud/bloodling/New(mob/living/owner)
	. = ..()
	var/atom/movable/screen/using

	action_intent = new /atom/movable/screen/combattoggle/flashy()
	action_intent.hud = src
	action_intent.icon = ui_style
	action_intent.screen_loc = ui_combat_toggle
	static_inventory += action_intent

	using = new /atom/movable/screen/language_menu()
	using.icon = ui_style
	using.hud = src
	using.update_appearance()
	static_inventory += using

	using = new /atom/movable/screen/navigate
	using.screen_loc = ui_alien_navigate_menu
	using.hud = src
	static_inventory += using

	healthdoll = new /atom/movable/screen/healthdoll/living()
	healthdoll.hud = src
	infodisplay += healthdoll
