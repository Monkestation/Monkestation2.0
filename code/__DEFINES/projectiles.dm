
// check_pierce() return values
/// Default behavior: hit and delete self
#define PROJECTILE_PIERCE_NONE 0
/// Hit the thing but go through without deleting. Causes on_hit to be called with pierced = TRUE
#define PROJECTILE_PIERCE_HIT 1
/// Entirely phase through the thing without ever hitting.
#define PROJECTILE_PIERCE_PHASE 2
// Delete self without hitting
#define PROJECTILE_DELETE_WITHOUT_HITTING 3

// Caliber defines: (current count stands at 27)
/// The caliber used by the [L6 SAW][/obj/item/gun/ballistic/automatic/l6_saw].
#define CALIBER_712X82MM "mm71282"
/// The caliber used by the [security auto-rifle][/obj/item/gun/ballistic/automatic/wt550].
#define CALIBER_46X30MM "4.6x30mm"
/// The caliber used by the Nanotrasen Saber SMG, PP-95 SMG and Type U3 Uzi. Also used as the default caliber for pistols but only the stechkin APS machine pistol doesn't override it.
#define CALIBER_9MM "9mm"
/// The caliber used as the default for ballistic guns. Only not overridden for the [surplus rifle][/obj/item/gun/ballistic/automatic/surplus].
#define CALIBER_10MM "10mm"
/// The caliber used by most revolver variants.
#define CALIBER_357 ".357"
/// The caliber used by the detective's revolver.
#define CALIBER_38 ".38"
/// The caliber used by the chaplain's revolver.
#define CALIBER_77 ".77"
/// The caliber used by the C-20r SMG, the tommygun, and the M1911 pistol.
#define CALIBER_45 ".45"
/// The caliber used by sniper rifles and the desert eagle.
#define CALIBER_50 ".50"
/// The caliber used by the gyrojet pistol.
#define CALIBER_75 ".75"
/// The caliber used by [one revolver variant][/obj/item/gun/ballistic/revolver/nagant].
#define CALIBER_N762 "n762"
/// The caliber used by the the M-90gl Carbine, and NT-ARG 'Boarder'.
#define CALIBER_A556 "a556"
/// The caliber used by bolt action rifles.
#define CALIBER_A762 "a762"
/// The caliber used by shotguns.
#define CALIBER_SHOTGUN "shotgun"
/// The caliber used by grenade launchers.
#define CALIBER_40MM "40mm"
/// The caliber used by rocket launchers.
#define CALIBER_84MM "84mm"
/// The caliber used by laser guns.
#define CALIBER_LASER "laser"
/// The caliber used by most energy guns.
#define CALIBER_ENERGY "energy"
/// The acliber used by foam force and donksoft toy guns.
#define CALIBER_FOAM "foam_force"
/// The caliber used by the bow and arrow.
#define CALIBER_ARROW "arrow"
/// The caliber used by the harpoon gun.
#define CALIBER_HARPOON "harpoon"
/// The caliber used by the rebar crossbow.
#define CALIBER_REBAR "sharpened rod"
/// The caliber used by the rebar crossbow when forced to hold 2 rods.
#define CALIBER_REBAR_FORCED "sharpened rod"
/// The caliber used by the syndicate rebar crossbow.
#define CALIBER_REBAR_SYNDIE "sharpened rod"
/// The caliber used by the meat hook.
#define CALIBER_HOOK "hook"
/// The caliber used by the changeling tentacle mutation.
#define CALIBER_TENTACLE "tentacle"
#define CALIBER_A223 "a223"
/// The caliber used by bolt action rifles.
#define CALIBER_STRILKA310 ".310_strilka"
/// The caliber used by the atlatl spear thrower
#define CALIBER_SPEAR "throwing spear"
//Peashooter ammo for mech and minigun
#define CALIBER_22LR ".22 LR"
//20mm ammo for mech
#define CALIBER_ATR "20x160mm Neville"
//60mm rockets for anti mech
#define CALIBER_60MM "60mm Rocket"
// The caliber used by the PACO
#define CALIBER_35 ".35"
// The caliber used by the Quarad machinegun
#define CALIBER_C65XENO "6.5x39"
// The caliber used by the mining autoshotgun
#define KINETIC_20G "20 Gauge kinetic shell"
// The caliber used by the mining LMG
#define CALIBER_A762_KINETIC "7.65 Kinetic"
// The caliber used by mining grenade launchers
#define CALIBER_40MM_KINETIC "40mm Kinetic Grenade"
// The caliber used by the mining revolver
#define CALIBER_GOV_MINING ".45-70 Gov Kinetic"
// The caliber used by the Thor kinetic mining rifle
#define CALIBER_MINER_950 ".950 JDJ Kinetic"
// The caliber used by the mining doublebarrel
#define MINER_SHOTGUN "kinetic shotgun"

/// For gunpoints, how many tiles around the target the shooter can roam without losing their shot
#define GUNPOINT_SHOOTER_STRAY_RANGE 2

/// A spark will be generated for each THIS amount of damage dealt to a robotic limb by a projectile.
#define PROJECTILE_DAMAGE_PER_ROBOTIC_SPARK 20

//Designed for things that need precision trajectories like projectiles.
//Don't use this for anything that you don't absolutely have to use this with (like projectiles!) because it isn't worth using a datum unless you need accuracy down to decimal places in pixels.

//You might see places where it does - 16 - 1. This is intentionally 17 instead of 16, because of how byond's tiles work and how not doing it will result in rounding errors like things getting put on the wrong turf.

#define RETURN_PRECISE_POSITION(A) new /datum/position(A)
#define RETURN_PRECISE_POINT(A) new /datum/point(A)

#define RETURN_POINT_VECTOR(ATOM, ANGLE, SPEED) (new /datum/point/vector(ATOM, null, null, null, null, ANGLE, SPEED))
#define RETURN_POINT_VECTOR_INCREMENT(ATOM, ANGLE, SPEED, AMT) (new /datum/point/vector(ATOM, null, null, null, null, ANGLE, SPEED, AMT))

///The self charging rate of energy guns that magically recharge themselves, in watts.
#define STANDARD_ENERGY_GUN_SELF_CHARGE_RATE (0.05 * STANDARD_CELL_CHARGE)

/// Macro to turn a number of laser shots into an energy cost, based on the above define
/// e.g. LASER_SHOTS(12, STANDARD_CELL_CHARGE) means 12 shots
#define LASER_SHOTS(X, MAX_CHARGE) (((100 * MAX_CHARGE) - ((100 * MAX_CHARGE) % X)) / (100 * X)) // I wish I could just use round, but it can't be used in datum members
