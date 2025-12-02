/*************************************************************
 * RBMK Reactor Defines (Balanced 2025 Revision)
 * Fully aligned with NEW PROCESS LOOP
 *************************************************************/

/*************************************************************
 * Temperature Thresholds (Kelvin)
 *************************************************************/

#define RBMK_TEMP_OFF              293
#define RBMK_TEMP_RUNNING          700     // Lower: core begins work here
#define RBMK_TEMP_HOT              1500    // Visible glow begins
#define RBMK_TEMP_VERYHOT          3000
#define RBMK_TEMP_OVERHEAT         6000    // Dangerous but not instant melt

/*************************************************************
 * Instability / Integrity Overlays
 *************************************************************/

#define RBMK_INSTABILITY_WARNING    140
#define RBMK_INSTABILITY_CRITICAL   260

#define RBMK_DAMAGE_OVERLAY_1       90
#define RBMK_DAMAGE_OVERLAY_2       70
#define RBMK_DAMAGE_OVERLAY_3       50
#define RBMK_DAMAGE_OVERLAY_4       25

/*************************************************************
 * Reactor Safety Baselines
 *************************************************************/

#define RBMK_SAFE_FLUX              250
#define RBMK_SAFE_RADIATION         90

#define RBMK_FLUX_WEIGHT            0.55
#define RBMK_TEMP_WEIGHT            0.30
#define RBMK_RAD_WEIGHT             0.15

#define RBMK_SYNERGY_FLUX_THRESHOLD 400
#define RBMK_SYNERGY_TEMP_RATIO     0.65
#define RBMK_SYNERGY_MULT           1.4

#define RBMK_RADIATION_KICKER_THRESHOLD 110
#define RBMK_RADIATION_KICKER_BONUS     12

#define RBMK_INSTABILITY_MAX        500

/*************************************************************
 * Rod & Cooling Parameters
 *************************************************************/

#define RBMK_CONTROL_ROD_MAX        100
#define RBMK_REPAIRABLE_TEMP_RATIO  0.65
#define RBMK_AMBIENT_TEMP           293
#define RBMK_IDLE_COOL_RATE         0.7

#define RBMK_HEAT_SCALING           0.0025
#define RBMK_FLUX_DECAY             0.18
#define RBMK_RADIATION_DECAY        0.18

/*************************************************************
 * Updated Stress Thresholds (Balanced to new process)
 *************************************************************/

#define RBMK_TEMP_STRESS_THRESHOLD       1800
#define RBMK_TEMP_STRESS_DIVISOR         7000
#define RBMK_TEMP_NEAR_MAX_RATIO         0.88
#define RBMK_TEMP_NEAR_MAX_DIVISOR       1500

#define RBMK_FLUX_STRESS_THRESHOLD       350
#define RBMK_FLUX_STRESS_DIVISOR         1800
#define RBMK_FLUX_HIGH_THRESHOLD         550
#define RBMK_FLUX_HIGH_DIVISOR           1100

#define RBMK_INSTABILITY_THRESHOLD       130
#define RBMK_INSTABILITY_DIVISOR         75

#define RBMK_PRESSURE_WARNING            950
#define RBMK_PRESSURE_WARNING_DIVISOR    1400
#define RBMK_PRESSURE_CRITICAL           1500
#define RBMK_PRESSURE_CRITICAL_DIVISOR   900
#define RBMK_PRESSURE_EXTREME            2000
#define RBMK_PRESSURE_EXTREME_DIVISOR    700

#define RBMK_REPAIRABLE_FLUX_LIMIT       200
#define RBMK_REPAIRABLE_PRESSURE_LIMIT   650

/*************************************************************
 * Meltdown Constants (unchanged)
 *************************************************************/

#define RBMK_MELTDOWN_PREFIX        "⚠ RBMK MELTDOWN"
#define RBMK_MELTDOWN_BROADCAST     "⚠ RBMK Reactor critical failure!"
#define RBMK_MELTDOWN_RADIATION     TRUE
#define RBMK_MELTDOWN_ATMOS_DUMP    TRUE
#define RBMK_MELTDOWN_EXPLOSIONS    TRUE
#define RBMK_MELTDOWN_ALARMS        TRUE

#define RBMK_MELTDOWN_RAD_RANGE     20
#define RBMK_MELTDOWN_RAD_THRESHOLD 0.05
#define RBMK_MELTDOWN_DEV_RANGE     6
#define RBMK_MELTDOWN_HEAVY_RANGE   10
#define RBMK_MELTDOWN_LIGHT_RANGE   15
#define RBMK_MELTDOWN_FLASH_RANGE   18

/*************************************************************
 * Maxima
 *************************************************************/

#define RBMK_MAX_TEMP             12000
#define RBMK_MAX_RADIATION        700
#define RBMK_MAX_INSTABILITY      500
#define RBMK_MAX_FLUX             900      // was 400, now correct for 4–6 rods
#define RBMK_MAX_MODERATOR        100
#define RBMK_MAX_INTEGRITY        100

/*************************************************************
 * Coolant System
 *************************************************************/

#define RBMK_COOLANT_VOLUME_MAX   1500
#define RBMK_INLET_RATE_MIN       1
#define RBMK_INLET_RATE_MAX       250

#define RBMK_OUTLET_PRESSURE_BASE 101.3
#define RBMK_OUTLET_PRESSURE_MAX  1200     // UI & real max now consistent

/*************************************************************
 * RBMK Core Production Gains (Required Missing Defines)
 *************************************************************/

// Temperature gained per tick from total rod reactivity
#define RBMK_TEMP_GAIN_PER_TICK     0.015   // balanced baseline

// Flux gained per tick from total rod reactivity
#define RBMK_FLUX_GAIN              0.02    // smooth progression

// Radiation from temperature component
#define RBMK_RADIATION_TEMP_MULT    0.0007  // temp → rads

// Radiation from flux component
#define RBMK_RADIATION_FLUX_MULT    0.12    // flux → rads
