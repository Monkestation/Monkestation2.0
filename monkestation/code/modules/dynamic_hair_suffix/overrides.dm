#define OVERRIDE_DYNAMIC_HAIR_SUFFIX(typepath, suffix, facial_suffix) \
	##typepath { dynamic_hair_suffix = suffix; dynamic_fhair_suffix = facial_suffix; }
#define NO_DYNAMIC_HAIR_SUFFIX(typepath) OVERRIDE_DYNAMIC_HAIR_SUFFIX(typepath, "", "")

OVERRIDE_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head, "+generic", "")
OVERRIDE_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/helmet/space/beret, "+generic", "+generic")
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/beret)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/bomb_hood)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/bowler)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/chefhat)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/collectable/chef)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/collectable/hos)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/collectable/police)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/collectable/slime)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/cone)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/costume/kitty)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/costume/rabbitears)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/crown)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/frenchberet)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/hardhat/reindeer)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/helmet/chaplain/cage)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/helmet/police)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/helmet/space)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/hooded)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/hos)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/jester)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/mod)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/nursehat)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/peaceflower)
NO_DYNAMIC_HAIR_SUFFIX(/obj/item/clothing/head/shrine_wig)

#undef NO_DYNAMIC_HAIR_SUFFIX
#undef OVERRIDE_DYNAMIC_HAIR_SUFFIX
