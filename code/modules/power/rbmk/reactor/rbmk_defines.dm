/*************************************************************
 * RBMK Defines
 *************************************************************/

// --- Temperature thresholds for visuals ---
#define RBMK_TEMP_OFF             293
#define RBMK_TEMP_RUNNING         500
#define RBMK_TEMP_HOT             1500
#define RBMK_TEMP_VERYHOT         2500
#define RBMK_TEMP_OVERHEAT        RBMK_MAX_TEMP

// --- Light radii / brightness per stage ---
#define RBMK_LIGHT_RUNNING_RADIUS 1
#define RBMK_LIGHT_RUNNING_POWER  1
#define RBMK_LIGHT_RUNNING_COLOR  "#33f"

#define RBMK_LIGHT_HOT_RADIUS     2
#define RBMK_LIGHT_HOT_POWER      2
#define RBMK_LIGHT_HOT_COLOR      "#06f"

#define RBMK_LIGHT_VERYHOT_RADIUS 2
#define RBMK_LIGHT_VERYHOT_POWER  2.5
#define RBMK_LIGHT_VERYHOT_COLOR  "#f60"

#define RBMK_LIGHT_OVERHEAT_RADIUS 3
#define RBMK_LIGHT_OVERHEAT_POWER  3
#define RBMK_LIGHT_OVERHEAT_COLOR  "#f00"

#define RBMK_LIGHT_MELTDOWN_RADIUS 4
#define RBMK_LIGHT_MELTDOWN_POWER  4
#define RBMK_LIGHT_MELTDOWN_COLOR  "#ff0"

// --- Instability thresholds ---
#define RBMK_INSTABILITY_WARNING 100
#define RBMK_INSTABILITY_CRITICAL 200

// --- Integrity overlay thresholds ---
#define RBMK_DAMAGE_OVERLAY_1 90
#define RBMK_DAMAGE_OVERLAY_2 75
#define RBMK_DAMAGE_OVERLAY_3 50
#define RBMK_DAMAGE_OVERLAY_4 25

// Safe baselines
#define RBMK_SAFE_FLUX                100
#define RBMK_SAFE_RADIATION           50

// Weighting factors
#define RBMK_FLUX_WEIGHT              0.5
#define RBMK_TEMP_WEIGHT              0.35
#define RBMK_RAD_WEIGHT               0.15

// Synergy runaway
#define RBMK_SYNERGY_FLUX_THRESHOLD   100
#define RBMK_SYNERGY_TEMP_RATIO       0.7
#define RBMK_SYNERGY_MULT             1.5

// Radiation danger kicker
#define RBMK_RADIATION_KICKER_THRESHOLD 50
#define RBMK_RADIATION_KICKER_BONUS     10

// Max clamp
#define RBMK_INSTABILITY_MAX          500

// Control rod system
#define RBMK_CONTROL_ROD_MAX         100
#define RBMK_REPAIRABLE_TEMP_RATIO   0.7

// Temperature & cooling
#define RBMK_AMBIENT_TEMP            293
#define RBMK_IDLE_COOL_RATE          5

// Heat scaling
#define RBMK_HEAT_SCALING            0.1

// Natural decay per tick
#define RBMK_FLUX_DECAY              1
#define RBMK_RADIATION_DECAY         0.5

// --- Integrity thresholds ---
#define RBMK_TEMP_STRESS_THRESHOLD       1500
#define RBMK_TEMP_STRESS_DIVISOR         2000

#define RBMK_TEMP_NEAR_MAX_RATIO         0.9
#define RBMK_TEMP_NEAR_MAX_DIVISOR       200

#define RBMK_FLUX_STRESS_THRESHOLD       100
#define RBMK_FLUX_STRESS_DIVISOR         1000

#define RBMK_FLUX_HIGH_THRESHOLD         300
#define RBMK_FLUX_HIGH_DIVISOR           300

#define RBMK_INSTABILITY_THRESHOLD       100
#define RBMK_INSTABILITY_DIVISOR         50

// --- Pressure stress ---
#define RBMK_PRESSURE_WARNING            17000
#define RBMK_PRESSURE_WARNING_DIVISOR    2000

#define RBMK_PRESSURE_CRITICAL           20000
#define RBMK_PRESSURE_CRITICAL_DIVISOR   500

#define RBMK_PRESSURE_EXTREME            23000
#define RBMK_PRESSURE_EXTREME_DIVISOR    100

// --- Repairable conditions ---
#define RBMK_REPAIRABLE_FLUX_LIMIT       80
#define RBMK_REPAIRABLE_PRESSURE_LIMIT   17000

// --- Meltdown messaging ---
#define RBMK_MELTDOWN_PREFIX        "⚠ RBMK MELTDOWN"
#define RBMK_MELTDOWN_BROADCAST     "⚠ RBMK Reactor critical failure!"

// --- Meltdown visuals ---
#define RBMK_MELTDOWN_LIGHT_COLOR   "#663300"

// --- Meltdown feature toggles ---
#define RBMK_MELTDOWN_RADIATION     TRUE
#define RBMK_MELTDOWN_ATMOS_DUMP    TRUE
#define RBMK_MELTDOWN_EXPLOSIONS    TRUE
#define RBMK_MELTDOWN_ALARMS        TRUE

// --- Meltdown effect tuning ---
#define RBMK_MELTDOWN_RAD_RANGE     20
#define RBMK_MELTDOWN_RAD_THRESHOLD 0.05

#define RBMK_MELTDOWN_DEV_RANGE     6
#define RBMK_MELTDOWN_HEAVY_RANGE   12
#define RBMK_MELTDOWN_LIGHT_RANGE   20
#define RBMK_MELTDOWN_FLASH_RANGE   25

// --- Core reactor limits ---
#define RBMK_MAX_TEMP             20000
#define RBMK_MAX_RADIATION        500
#define RBMK_MAX_INSTABILITY      500
#define RBMK_MAX_FLUX             500
#define RBMK_MAX_MODERATOR        100

// --- Reactor physics multipliers ---
#define RBMK_TEMP_GAIN_PER_TICK   10
#define RBMK_TEMP_LOSS_PER_DEPTH  0.05
#define RBMK_RADIATION_TEMP_MULT  0.01
#define RBMK_RADIATION_FLUX_MULT  2
#define RBMK_FLUX_GAIN            2
#define RBMK_FLUX_MODERATOR_MULT  0.05
#define RBMK_INSTABILITY_GAIN     0.5
#define RBMK_INSTABILITY_FLUX_MULT 0.1
#define RBMK_MODERATOR_DECAY      0.2
#define RBMK_MODERATOR_RECOVERY   0.05

// --- Coolant ---
#define RBMK_COOLANT_VOLUME_MAX   14000
#define RBMK_INLET_RATE_MIN       1
#define RBMK_INLET_RATE_MAX       200
#define RBMK_OUTLET_PRESSURE_BASE 101.3
#define RBMK_OUTLET_PRESSURE_MAX  10000

// --- Integrity ---
#define RBMK_MAX_INTEGRITY        100
