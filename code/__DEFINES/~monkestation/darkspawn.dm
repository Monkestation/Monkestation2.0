//Defines specifically for the darkspawn game mode
#define DARKSPAWN_MUNDANE 0
#define DARKSPAWN_DIVULGED 1
#define DARKSPAWN_PROGENITOR 2

#define DARKSPAWN_SCOUT (1<<0)
#define DARKSPAWN_FIGHTER (1<<1)
#define DARKSPAWN_WARLOCK (1<<2)
#define ALL_DARKSPAWN_CLASSES (DARKSPAWN_SCOUT | DARKSPAWN_FIGHTER | DARKSPAWN_WARLOCK)

/// things that you use and it fucks someone up
#define STORE_OFFENSE "offense"
///things that you use and it does something less straightforward
#define STORE_UTILITY "utility"
///things that always happen all the time
#define STORE_PASSIVE "passives"

///used by the antag datum and class component to handle power purchasing
#define COMSIG_DARKSPAWN_PURCHASE_POWER "purchase_power"
///used by the psi_web to handle upgrading existing abilities
#define COMSIG_DARKSPAWN_UPGRADE_ABILITY "upgrade_ability"
///used by the psi_web to handle refunding ability upgrades
#define COMSIG_DARKSPAWN_DOWNGRADE_ABILITY "downgrade_ability"

//Staff upgrade bitflags
#define STAFF_UPGRADE_CONFUSION (1<<0)
#define STAFF_UPGRADE_HEAL (1<<1)
#define STAFF_UPGRADE_LIGHTEATER (1<<2)
#define STAFF_UPGRADE_EXTINGUISH (1<<3)
#define TENDRIL_UPGRADE_TWIN (1<<4)
#define TENDRIL_UPGRADE_CLEAVE (1<<5)
#define STAFF_UPGRADE_EFFICIENCY (1<<6)

///lets darkspawns walk through weak light
#define TRAIT_DARKSPAWN_LIGHTRES "darkspawn_lightres"
///lets darkspawns walk through any light
#define TRAIT_DARKSPAWN_CREEP "darkspawn_creep"
///permanently reduces the lucidity gained from future succs
#define TRAIT_DARKSPAWN_DEVOURED "darkspawn_devoured"
///disable psi regeneration (make sure to remove it after some time)
#define TRAIT_DARKSPAWN_PSIBLOCK "darkspawn_psiblock"
///make aoe ally buff abilities also affect allied darkspawns
#define TRAIT_DARKSPAWN_BUFFALLIES "darkspawn_allybuff"
///revives the darkspawn if they're dead and in the dark
#define TRAIT_DARKSPAWN_UNDYING "darkspawn_undying"

///reduces the cooldown of all used /datum/action/cooldown by 25%
#define TRAIT_FAST_COOLDOWNS "short_spell_cooldowns"
