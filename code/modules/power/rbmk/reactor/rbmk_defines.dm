/*************************************************************
 * RBMK Reactor Defines (2025 Final Linear-Core Revision)
 * ---------------------------------------------------------
 * Supports:
 *   - Reactivity → Flux → Temperature feedback loop
 *   - Linear Void Coefficient (VC)
 *   - Tritium as optional byproduct
 *   - Structural integrity damage thresholds
 *   - Coolant pressure / gas behavior
 *
 * Removed:
 *   - Instability
 *   - Poisoning
 *   - Complicated synergy curves
 *************************************************************/


/*************************************************************
 * Temperature Thresholds (Kelvin)
 *************************************************************/

#define RBMK_AMBIENT_TEMP               293      // 20°C environment
#define RBMK_TEMP_STRESS_THRESHOLD      1500     // damage begins here
#define RBMK_TEMP_CRITICAL              6000     // meltdown region
#define RBMK_MAX_TEMP                   12000    // hard meltdown limit

// Visual temperature bands (used by rbmk_visuals.dm)
#define RBMK_TEMP_OFF                   RBMK_AMBIENT_TEMP
#define RBMK_TEMP_RUNNING               700
#define RBMK_TEMP_HOT                   1500
#define RBMK_TEMP_VERYHOT               3000
#define RBMK_TEMP_OVERHEAT              RBMK_TEMP_CRITICAL


/*************************************************************
 * Void Coefficient (Linear VC System)
 *************************************************************/

#define RBMK_VC_TEMP_COEFF              0.00002  // VC grows with temp
#define RBMK_VC_MAX                     3.0      // hard cap


/*************************************************************
 * Flux / Radiation / Heat Constants
 *************************************************************/

#define RBMK_FLUX_GAIN                  0.02     // reactivity → flux
#define RBMK_TEMP_GAIN_PER_TICK         0.015    // reactivity → temp
#define RBMK_HEAT_SCALING               0.0025   // coolant absorption scaling

#define RBMK_FLUX_DECAY                 0.18     // natural flux loss
#define RBMK_RADIATION_DECAY            0.18     // natural radiation loss

#define RBMK_RADIATION_FLUX_MULT        0.10     // flux → radiation
#define RBMK_RADIATION_TEMP_MULT        0.00035  // temp → radiation

#define RBMK_FLUX_STRESS_THRESHOLD      250      // integrity starts taking flux damage
#define RBMK_FLUX_HIGH_THRESHOLD        600      // high-flux zone


/*************************************************************
 * Integrity / Damage Overlay Thresholds
 *************************************************************/

#define RBMK_MAX_INTEGRITY              100

#define RBMK_DAMAGE_OVERLAY_1           90       // light damage
#define RBMK_DAMAGE_OVERLAY_2           70
#define RBMK_DAMAGE_OVERLAY_3           50
#define RBMK_DAMAGE_OVERLAY_4           25       // heavy damage


/*************************************************************
 * Control Rod & Repair Constants
 *************************************************************/

#define RBMK_CONTROL_ROD_MAX            100

#define RBMK_REPAIRABLE_TEMP_RATIO      0.65
#define RBMK_REPAIRABLE_FLUX_LIMIT      200
#define RBMK_REPAIRABLE_PRESSURE_LIMIT  650


/*************************************************************
 * Coolant / Pressure System
 *************************************************************/

#define RBMK_COOLANT_VOLUME_MAX         1500

#define RBMK_INLET_RATE_MIN             1
#define RBMK_INLET_RATE_MAX             250

#define RBMK_OUTLET_PRESSURE_BASE       101.3
#define RBMK_OUTLET_PRESSURE_MAX        1200

#define RBMK_PRESSURE_WARNING           950
#define RBMK_PRESSURE_CRITICAL          1500
#define RBMK_PRESSURE_EXTREME           2000


/*************************************************************
 * Tritium (Optional Byproduct)
 *************************************************************/

#define RBMK_TRITIUM_RATE               0.00045  // flux → tritium moles


/*************************************************************
 * Meltdown Messaging / Explosion Behavior
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
 * Global Reactor Caps
 *************************************************************/

#define RBMK_MAX_RADIATION              700
#define RBMK_MAX_FLUX                   900
