/obj/item/gun/ballistic/shotgun/china_lake
	name = "\improper China Lake 40mm"
	desc = "Oh, they're goin' ta have to glue you back together...IN HELL!"
	slot_flags = ITEM_SLOT_BACK
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/china_lake

	icon = 'monkestation/icons/misc/china_lake/china_lake_obj.dmi'
	icon_state = "china_lake"

	worn_icon = 'monkestation/icons/misc/china_lake/china_lake_worn.dmi'
	worn_icon_state = "china_lake"

	lefthand_file = 'monkestation/icons/misc/china_lake/china_lake_lefthand.dmi'
	righthand_file = 'monkestation/icons/misc/china_lake/china_lake_righthand.dmi'
	inhand_icon_state = "china_lake"

	fire_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_fire.ogg'
	fire_sound_volume = 90
	rack_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_rack.ogg'

/obj/item/ammo_box/magazine/internal/china_lake
	name = "china lake internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 3
	multiload = FALSE

/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher. This one seems rather light."
	projectile_type = /obj/projectile/bullet/a40mm/weak
	color = "#d3bd8c"

/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	desc = "use a weel gun"
	damage = 30

/obj/projectile/bullet/a40mm/weak/explosive_power(atom/target)
	explosion(target, devastation_range = -5, light_impact_range = 2, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)
