/*
/datum/hud/dextrous/cyber_husky/New(mob/owner)
	..()

	var/atom/movable/screen/inventory/inv_box
	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "Glasses"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_drone_storage
	inv_box.slot_id = ITEM_SLOT_EYES
	static_inventory += inv_box

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()


/datum/hud/dextrous/cyber_husky/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/basic/pet/cyber_husky/husky = mymob

	if(hud_shown)
		if(!isnull(husky.glasses))
			husky.glasses.screen_loc = ui_drone_storage
			husky.client.screen += husky.glasses
	else
		husky.glasses?.screen_loc = null

	..()
*/
