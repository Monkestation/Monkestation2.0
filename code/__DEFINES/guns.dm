//Gun weapon weight
#define WEAPON_LIGHT 1
#define WEAPON_MEDIUM 2
#define WEAPON_HEAVY 3
//Gun trigger guards
#define TRIGGER_GUARD_ALLOW_ALL -1
#define TRIGGER_GUARD_NONE 0
#define TRIGGER_GUARD_NORMAL 1
//Gun bolt types
///Gun has a bolt, it stays closed while not cycling. The gun must be racked to have a bullet chambered when a mag is inserted.
///  Example: c20, shotguns, m90
#define BOLT_TYPE_STANDARD 1
///Gun has a bolt, it is open when ready to fire. The gun can never have a chambered bullet with no magazine, but the bolt stays ready when a mag is removed.
///  Example: Tomson, Uzi, the L6 SAW
#define BOLT_TYPE_OPEN 2
///Gun has no moving bolt mechanism, it cannot be racked. Also dumps the entire contents when emptied instead of a magazine.
///  Example: Break action shotguns, revolvers
#define BOLT_TYPE_NO_BOLT 3
///Gun has a bolt, it locks back when empty. It can be released to chamber a round if a magazine is in.
///  Example: Pistols with a slide lock, some SMGs
#define BOLT_TYPE_LOCKING 4
//Sawn off nerfs
///accuracy penalty of sawn off guns
#define SAWN_OFF_ACC_PENALTY 25
///added recoil of sawn off guns
#define SAWN_OFF_RECOIL 1

//ammo box sprite defines
///ammo box will always use provided icon state
#define AMMO_BOX_ONE_SPRITE 0
///ammo box will have a different state for each bullet; <icon_state>-<bullets left>
#define AMMO_BOX_PER_BULLET 1
/// Ammo box will have a different sprite for any ammo at all, and no ammo, <icon_state>-full <icon_state>-empty
#define AMMO_BOX_FULL_EMPTY 2

#define SUPPRESSED_NONE 0
#define SUPPRESSED_QUIET 1 ///standard suppressed
#define SUPPRESSED_VERY 2 /// no message

//bullet_act() return values
#define BULLET_ACT_HIT "HIT" //It's a successful hit, whatever that means in the context of the thing it's hitting.
#define BULLET_ACT_BLOCK "BLOCK" //It's a blocked hit, whatever that means in the context of the thing it's hitting.
#define BULLET_ACT_FORCE_PIERCE "PIERCE" //It pierces through the object regardless of the bullet being piercing by default.

#define NICE_SHOT_RICOCHET_BONUS 10 //if the shooter has the NICE_SHOT trait and they fire a ricocheting projectile, add this to the ricochet chance and auto aim angle

//paint gun accepted canister flags
///standard sized paint gun canisters use this
#define STANDARD_PAINT_GUN_CANISTER (1<<0)
///large paint gun canisters used this
#define LARGE_PAINT_GUN_CANISTER (1<<1)
