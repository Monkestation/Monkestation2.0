/*************************************************************
 * RBMK Reactor Defines (Simplified Balance Revision)
 * - Focused on core reactor logic and icon states only
 * - All lighting and color logic removed
 *************************************************************/

/*************************************************************
 * Visual Thresholds (Icon States Only)
 *************************************************************/

// Temperature thresholds (Kelvin-equivalent)
#define RBMK_TEMP_OFF              293
#define RBMK_TEMP_RUNNING          900
#define RBMK_TEMP_HOT              2500
#define RBMK_TEMP_VERYHOT          4500
#define RBMK_TEMP_OVERHEAT         8500

/*************************************************************
 * Instability & Integrity Overlays
 *************************************************************/

#define RBMK_INSTABILITY_WARNING    120
#define RBMK_INSTABILITY_CRITICAL   275
#define RBMK_DAMAGE_OVERLAY_1       90
#define RBMK_DAMAGE_OVERLAY_2       70
#define RBMK_DAMAGE_OVERLAY_3       50
#define RBMK_DAMAGE_OVERLAY_4       25

/*************************************************************
 * Reactor Safety Baselines
 *************************************************************/

#define RBMK_SAFE_FLUX              150
#define RBMK_SAFE_RADIATION         80

// Weighting for instability formula
#define RBMK_FLUX_WEIGHT            0.55
#define RBMK_TEMP_WEIGHT            0.30
#define RBMK_RAD_WEIGHT             0.15

// Synergy / runaway interactions
#define RBMK_SYNERGY_FLUX_THRESHOLD 200
#define RBMK_SYNERGY_TEMP_RATIO     0.7
#define RBMK_SYNERGY_MULT           1.5

// Radiation hazard “kicker”
#define RBMK_RADIATION_KICKER_THRESHOLD 100
#define RBMK_RADIATION_KICKER_BONUS     10

#define RBMK_INSTABILITY_MAX        500

/*************************************************************
 * Control Rods / Cooling / Decay
 *************************************************************/

#define RBMK_CONTROL_ROD_MAX        100
#define RBMK_REPAIRABLE_TEMP_RATIO  0.7
#define RBMK_AMBIENT_TEMP           293
#define RBMK_IDLE_COOL_RATE         0.6
#define RBMK_HEAT_SCALING           0.0022
#define RBMK_FLUX_DECAY             0.2
#define RBMK_RADIATION_DECAY        0.2

/*************************************************************
 * Integrity Stress Thresholds
 *************************************************************/

// Temperature stress (now ramps slower)
#define RBMK_TEMP_STRESS_THRESHOLD       5000
#define RBMK_TEMP_STRESS_DIVISOR         5000
#define RBMK_TEMP_NEAR_MAX_RATIO         0.9
#define RBMK_TEMP_NEAR_MAX_DIVISOR       1000

// Flux stress (more forgiving)
#define RBMK_FLUX_STRESS_THRESHOLD       200
#define RBMK_FLUX_STRESS_DIVISOR         1600
#define RBMK_FLUX_HIGH_THRESHOLD         400
#define RBMK_FLUX_HIGH_DIVISOR           800

// Instability tolerance
#define RBMK_INSTABILITY_THRESHOLD       100
#define RBMK_INSTABILITY_DIVISOR         60

// Pressure stress thresholds (coolant-driven realism)
#define RBMK_PRESSURE_WARNING            1000
#define RBMK_PRESSURE_WARNING_DIVISOR    1200
#define RBMK_PRESSURE_CRITICAL           1800
#define RBMK_PRESSURE_CRITICAL_DIVISOR   900
#define RBMK_PRESSURE_EXTREME            2400
#define RBMK_PRESSURE_EXTREME_DIVISOR    600

// Repairable conditions
#define RBMK_REPAIRABLE_FLUX_LIMIT       90
#define RBMK_REPAIRABLE_PRESSURE_LIMIT   600

/*************************************************************
 * Meltdown Behavior & Effects
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
#define RBMK_MELTDOWN_HEAVY_RANGE   12
#define RBMK_MELTDOWN_LIGHT_RANGE   20
#define RBMK_MELTDOWN_FLASH_RANGE   25

/*************************************************************
 * Core Reactor Limits & Constants
 *************************************************************/

#define RBMK_MAX_TEMP             10000
#define RBMK_MAX_RADIATION        600
#define RBMK_MAX_INSTABILITY      500
#define RBMK_MAX_FLUX             600
#define RBMK_MAX_MODERATOR        100
#define RBMK_MAX_INTEGRITY        100

// Physics multipliers — balance heat vs. control rod depth
#define RBMK_TEMP_GAIN_PER_TICK   24
#define RBMK_TEMP_LOSS_PER_DEPTH  0.25
#define RBMK_RADIATION_TEMP_MULT  0.012
#define RBMK_RADIATION_FLUX_MULT  1.8
#define RBMK_FLUX_GAIN            2.2
#define RBMK_FLUX_MODERATOR_MULT  0.04
#define RBMK_INSTABILITY_GAIN     1.1
#define RBMK_INSTABILITY_FLUX_MULT 0.12
#define RBMK_MODERATOR_DECAY      0.25
#define RBMK_MODERATOR_RECOVERY   0.05

/*************************************************************
 * Coolant System
 *************************************************************/

// Bigger coolant volume = longer stability before overpressure
#define RBMK_COOLANT_VOLUME_MAX   1500
#define RBMK_INLET_RATE_MIN       1
#define RBMK_INLET_RATE_MAX       250
#define RBMK_OUTLET_PRESSURE_BASE 101.3
#define RBMK_OUTLET_PRESSURE_MAX  2500
