/*************************************************************
 * RBMK Reactor Defines (2025 Final Linear-Core Revision)
 * ---------------------------------------------------------
 * FIXED BASELINE:
 * - Reactivity is mathematically viable
 * - Flux can accumulate
 * - Heat can overcome coolant
 * - Void coefficient engages before meltdown
 * - No instability, no poisoning
 *************************************************************/


/*************************************************************
 * Temperature Thresholds (Kelvin)
 *************************************************************/

#define RBMK_AMBIENT_TEMP               293      // 20°C environment
#define RBMK_TEMP_STRESS_THRESHOLD      2500
#define RBMK_TEMP_CRITICAL              6500
#define RBMK_MAX_TEMP                   10000

// Visual bands
#define RBMK_TEMP_OFF                   RBMK_AMBIENT_TEMP
#define RBMK_TEMP_RUNNING               900
#define RBMK_TEMP_HOT                   2500
#define RBMK_TEMP_VERYHOT               4500
#define RBMK_TEMP_OVERHEAT              6500
#define RBMK_TEMP_MELTDOWN              8000


/*************************************************************
 * Void Coefficient (Linear, ACTIVE)
 *************************************************************/

#define RBMK_VC_TEMP_COEFF              0.00008   // was 0.00002 (too weak)
#define RBMK_VC_MAX                     3.0


/*************************************************************
 * Flux / Radiation / Heat (CRITICAL FIXES)
 *************************************************************/

#define RBMK_FLUX_GAIN                  0.25      // was 0.02 (non-viable)
#define RBMK_TEMP_GAIN_PER_TICK         0.24      // aggressive temp gain
#define RBMK_HEAT_SCALING               0.05      // was 0.0025 (killed heat)

#define RBMK_FLUX_DECAY                 0.05      // was 0.18 (dominant sink)
#define RBMK_RADIATION_DECAY            0.12

#define RBMK_RADIATION_FLUX_MULT        0.10
#define RBMK_RADIATION_TEMP_MULT        0.00035

#define RBMK_FLUX_STRESS_THRESHOLD      250
#define RBMK_FLUX_HIGH_THRESHOLD        600


/*************************************************************
 * Integrity / Damage Overlays
 *************************************************************/

#define RBMK_MAX_INTEGRITY              100

#define RBMK_DAMAGE_OVERLAY_1           90
#define RBMK_DAMAGE_OVERLAY_2           70
#define RBMK_DAMAGE_OVERLAY_3           50
#define RBMK_DAMAGE_OVERLAY_4           25


/*************************************************************
 * Control Rods / Repair
 *************************************************************/

#define RBMK_CONTROL_ROD_MAX            100

#define RBMK_REPAIRABLE_TEMP_RATIO      0.65
#define RBMK_REPAIRABLE_FLUX_LIMIT      200
#define RBMK_REPAIRABLE_PRESSURE_LIMIT  1800


/*************************************************************
 * Coolant / Pressure System
 *************************************************************/

#define RBMK_COOLANT_VOLUME_MAX         1500

#define RBMK_INLET_RATE_MIN             1
#define RBMK_INLET_RATE_MAX             250

#define RBMK_OUTLET_PRESSURE_BASE       101.3
#define RBMK_OUTLET_PRESSURE_MAX        4200

#define RBMK_PRESSURE_WARNING           2400
#define RBMK_PRESSURE_CRITICAL          3800
#define RBMK_PRESSURE_EXTREME           5200


/*************************************************************
 * Tritium (Optional Byproduct)
 *************************************************************/

#define RBMK_TRITIUM_RATE               0.00045


/*************************************************************
 * Meltdown Behavior
 *************************************************************/

#define RBMK_MELTDOWN_PREFIX            "⚠ RBMK MELTDOWN"
#define RBMK_MELTDOWN_BROADCAST         "⚠ RBMK Reactor critical failure!"

#define RBMK_MELTDOWN_RADIATION         TRUE
#define RBMK_MELTDOWN_ATMOS_DUMP        TRUE
#define RBMK_MELTDOWN_EXPLOSIONS        TRUE
#define RBMK_MELTDOWN_ALARMS            TRUE

#define RBMK_MELTDOWN_RAD_RANGE         20
#define RBMK_MELTDOWN_RAD_THRESHOLD     0.05

#define RBMK_MELTDOWN_DEV_RANGE         6
#define RBMK_MELTDOWN_HEAVY_RANGE       10
#define RBMK_MELTDOWN_LIGHT_RANGE       15
#define RBMK_MELTDOWN_FLASH_RANGE       18


/*************************************************************
 * Global Caps
 *************************************************************/

#define RBMK_MAX_RADIATION              700
#define RBMK_MAX_FLUX                   900
