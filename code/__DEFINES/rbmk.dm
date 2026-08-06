// Simulation timing and display limits
/// Default temperature for newly initialized RBMK gas and machinery state.
#define RBMK_AMBIENT_TEMP 293
/// Baseline machinery cycle used to convert legacy per-tick tuning into per-second rates.
#define RBMK_MACHINERY_PROCESS_SECONDS 2
/// Baseline atmos cycle used by RBMK port flow defaults.
#define RBMK_ATMOS_PROCESS_SECONDS 0.5
/// Upper bound used when graphing reactor temperature.
#define RBMK_TEMP_DISPLAY_MAX 20000

// Temperature limits
/// Temperature where ordinary thermal integrity stress begins.
#define RBMK_TEMP_STRESS_THRESHOLD 8000
/// Temperature where severe thermal integrity damage begins.
#define RBMK_TEMP_DAMAGE_RAMP 9500
/// Passive vessel-to-room thermal loss per normal machinery cycle. This is
/// deliberately weak compared with forced coolant exchange.
#define RBMK_PASSIVE_AIR_EXCHANGE_COEFFICIENT 0.0015

// Moderator rod bonuses
/// Per-rod increase to the reactor's thermal stress limits from plasma moderation.
#define RBMK_MODIFIER_PLASMA_TEMP_LIMIT_BONUS 1250
/// Maximum combined thermal-limit increase from plasma moderator rods.
#define RBMK_MODIFIER_PLASMA_TEMP_LIMIT_BONUS_MAX 4000
/// Per-rod increase to coolant heat exchange from bluespace moderation.
#define RBMK_MODIFIER_BLUESPACE_COOLANT_BONUS 0.20
/// Maximum combined coolant-exchange increase from bluespace moderator rods.
#define RBMK_MODIFIER_BLUESPACE_COOLANT_BONUS_MAX 0.80
/// Per-rod increase to neutron flux from diamond moderation.
#define RBMK_MODIFIER_DIAMOND_FLUX_MULT_BONUS 0.12
/// Maximum combined flux increase from diamond moderator rods.
#define RBMK_MODIFIER_DIAMOND_FLUX_MULT_BONUS_MAX 0.48

// Operating temperature bands
/// Minimum temperature treated as active reactor operation.
#define RBMK_TEMP_RUNNING 500
/// Moderate operating-temperature display threshold.
#define RBMK_TEMP_MODERATE 1500
/// Hot operating-temperature display threshold.
#define RBMK_TEMP_HOT 3000
/// Very-hot operating-temperature display threshold.
#define RBMK_TEMP_VERYHOT 4000
/// Highest nominal safe operating-temperature display threshold.
#define RBMK_TEMP_MAXSAFE 6000
/// Temperature that initiates the primary meltdown path.
#define RBMK_TEMP_MELTDOWN 8000

// Positive void coefficient
/// Temperature contribution to the positive void coefficient.
#define RBMK_VC_TEMP_COEFF 0.00008
/// Maximum temperature contribution to the void coefficient.
#define RBMK_VC_TEMP_COMPONENT_MAX 1.2
/// Maximum pressure contribution to the void coefficient.
#define RBMK_VC_PRESSURE_COMPONENT_MAX 1
/// Maximum coolant-starvation contribution to the void coefficient.
#define RBMK_VC_COOLANT_COMPONENT_MAX 0.8
/// Coolant inventory at which the starvation contribution reaches zero.
#define RBMK_VC_COOLANT_MOLES_TARGET 450
/// Absolute upper bound for the reactor's void coefficient.
#define RBMK_VC_MAX 3.0

// Reaction output and decay
/// Base fraction of rod output added to reactor flux each machinery cycle.
#define RBMK_FLUX_GAIN 0.8
/// Base reactor heat gain converted to a per-second rate.
#define RBMK_TEMP_GAIN_PER_SECOND (0.24 / RBMK_MACHINERY_PROCESS_SECONDS)
/// Passive flux decay converted to a per-second rate.
#define RBMK_FLUX_DECAY_PER_SECOND (0.05 / RBMK_MACHINERY_PROCESS_SECONDS)
/// Passive radiation decay converted to a per-second rate.
#define RBMK_RADIATION_DECAY_PER_SECOND (0.12 / RBMK_MACHINERY_PROCESS_SECONDS)
/// Fraction of current flux converted into radiation output.
#define RBMK_RADIATION_FLUX_MULT 0.10
/// Fraction of vessel temperature converted into radiation output.
#define RBMK_RADIATION_TEMP_MULT 0.00035
/// Fraction of active fuel-rod radiation that remains with the control rods fully inserted.
#define RBMK_RESIDUAL_RADIATION_MULTIPLIER 0.15

// Vessel integrity
/// Default and maximum vessel integrity.
#define RBMK_MAX_INTEGRITY 100
/// Maximum thermal integrity damage applied per second.
#define RBMK_INTEGRITY_DAMAGE_CAP_PER_SECOND 0.75
/// Maximum pressure integrity damage applied per second.
#define RBMK_PRESSURE_INTEGRITY_DAMAGE_CAP_PER_SECOND 0.35
/// Maximum coolant-related integrity damage applied per second.
#define RBMK_INTEGRITY_COOLDOWN_DAMAGE_CAP_PER_SECOND 0.25
/// Integrity percentage that triggers the stationwide critical warning.
#define RBMK_INTEGRITY_GLOBAL_WARNING_THRESHOLD 10
/// Integrity threshold for the first damage overlay.
#define RBMK_DAMAGE_OVERLAY_1 90
/// Integrity threshold for the second damage overlay.
#define RBMK_DAMAGE_OVERLAY_2 70
/// Integrity threshold for the third damage overlay.
#define RBMK_DAMAGE_OVERLAY_3 50
/// Integrity threshold for the fourth damage overlay.
#define RBMK_DAMAGE_OVERLAY_4 25

// Rods and controls
/// Fully inserted control-rod depth percentage.
#define RBMK_CONTROL_ROD_MAX 100
/// Maximum distance at which an RBMK console can link to its reactor.
#define RBMK_CONSOLE_SCAN_RANGE 7
/// Maximum samples retained for reactor telemetry graphs.
#define RBMK_TELEMETRY_HISTORY_LENGTH 60
/// Identifier for the reactor's ordinary fuel-rod bank.
#define RBMK_ROD_SLOT_NORMAL "normal"
/// Identifier for the reactor's moderator and exotic-rod bank.
#define RBMK_ROD_SLOT_SPECIAL "special"
/// Generic or empty fuel-rod identifier.
#define RBMK_ROD_TYPE_EMPTY "empty"
/// Uranium fuel-rod identifier.
#define RBMK_ROD_TYPE_URANIUM "uranium"
/// Thorium fuel-rod identifier.
#define RBMK_ROD_TYPE_THORIUM "thorium"
/// Plutonium fuel-rod identifier.
#define RBMK_ROD_TYPE_PLUTONIUM "plutonium"
/// Plasma moderator-rod identifier.
#define RBMK_ROD_TYPE_PLASMA "plasma"
/// Bluespace moderator-rod identifier.
#define RBMK_ROD_TYPE_BLUESPACE "bluespace"
/// Diamond moderator-rod identifier.
#define RBMK_ROD_TYPE_DIAMOND "diamond"
/// Supermatter fuel-rod identifier.
#define RBMK_ROD_TYPE_SUPERMATTER "supermatter"

// Repairs and manual rod extraction
/// Highest vessel temperature at which welding repairs are allowed.
#define RBMK_REPAIRABLE_TEMP_LIMIT 2500
/// Integrity restored by one completed welding repair.
#define RBMK_WELDER_REPAIR_AMOUNT 5
/// Duration of one welding repair action.
#define RBMK_WELDER_REPAIR_TIME 6 SECONDS
/// Welder fuel consumed by one repair action.
#define RBMK_WELDER_REPAIR_FUEL_COST 1
/// Highest vessel temperature at which console rod extraction is permitted.
#define RBMK_ROD_CONSOLE_SAFE_TEMP_LIMIT 2500
/// Extraction time for an ordinary rod.
#define RBMK_ROD_TOOL_REMOVE_TIME_NORMAL 3 SECONDS
/// Extraction time for a moderator or exotic rod.
#define RBMK_ROD_TOOL_REMOVE_TIME_SPECIAL 6 SECONDS
/// Extraction time for a supermatter rod during an active cascade.
#define RBMK_ROD_TOOL_REMOVE_TIME_CASCADE 15 SECONDS
/// Temperature at which extracting a rod produces a heat knockback.
#define RBMK_ROD_TOOL_HOT_KNOCKBACK_TEMP 2500
/// Radius of ordinary hot-rod extraction knockback.
#define RBMK_ROD_TOOL_HOT_KNOCKBACK_RANGE 4
/// Radius of supermatter cascade extraction knockback.
#define RBMK_ROD_TOOL_CASCADE_KNOCKBACK_RANGE 7

// Coolant flow and pressure
/// Internal coolant capacity in liters.
#define RBMK_COOLANT_VOLUME_MAX 2000
/// Minimum inlet flow setting in moles per second.
#define RBMK_INLET_RATE_MIN 0
/// Default inlet flow setting in moles per second.
#define RBMK_INLET_RATE_DEFAULT 75
/// Maximum inlet flow setting in moles per second.
#define RBMK_INLET_RATE_MAX 250
/// Maximum pressure rise the reactor coolant injector can overcome above its supply pressure.
#define RBMK_INLET_PUMP_HEAD 6500
/// Minimum outlet flow setting in moles per second.
#define RBMK_OUTLET_RATE_MIN 0
/// Default outlet flow setting in moles per second.
#define RBMK_OUTLET_RATE_DEFAULT 75
/// Maximum outlet flow setting in moles per second.
#define RBMK_OUTLET_RATE_MAX 750
/// Prevents a single atmos update from evacuating the hot core and causing a pressure rebound on the next inlet update.
#define RBMK_OUTLET_MAX_INVENTORY_FRACTION 0.5
/// Pressure at which the operator UI shows a warning.
#define RBMK_PRESSURE_WARNING 8000
/// Pressure at which critical pressure damage begins.
#define RBMK_PRESSURE_CRITICAL 10000
/// Pressure at which the extreme pressure damage bonus applies.
#define RBMK_PRESSURE_EXTREME 12000
/// Divisor used to scale ordinary overpressure integrity damage.
#define RBMK_PRESSURE_DAMAGE_DIVISOR 1200
/// Divisor used to scale critical overpressure integrity damage.
#define RBMK_PRESSURE_CRITICAL_DAMAGE_DIVISOR 700
/// Flat integrity damage bonus at extreme pressure.
#define RBMK_PRESSURE_EXTREME_DAMAGE_BONUS 2

// Core-to-coolant heat exchange
/// Effective heat capacity of the reactor vessel.
#define RBMK_CORE_HEAT_CAPACITY 450000
/// Coolant inventory that provides full heat-exchange effectiveness.
#define RBMK_COOLANT_EFFECTIVE_MOLES_TARGET 900
/// Flow ratio below which coolant is considered stagnant.
#define RBMK_COOLANT_STAGNANT_FLOW_RATIO 0.05
/// Heat-exchange multiplier when only one coolant port is available.
#define RBMK_COOLANT_ONE_PORT_FLOW_MULT 0.35
/// Base vessel-to-coolant heat-exchange coefficient.
#define RBMK_COOLANT_EXCHANGE_COEFFICIENT 0.10
/// Maximum additional exchange coefficient supplied by coolant flow.
#define RBMK_COOLANT_EXCHANGE_FLOW_BONUS 0.50
/// Maximum vessel temperature change during one coolant exchange.
#define RBMK_COOLANT_MAX_CORE_TEMP_CHANGE 450
/// Maximum coolant temperature change during one coolant exchange.
#define RBMK_COOLANT_MAX_GAS_TEMP_CHANGE 1800
/// Keeps tritium useful as a coolant byproduct without letting it overwhelm pressure control every process tick.
#define RBMK_TRITIUM_PRODUCTION_RATE 0.005

// Meltdown effects
/// Prefix used by station announcements concerning RBMK failure.
#define RBMK_MELTDOWN_PREFIX "RBMK MELTDOWN"
/// Radius of the meltdown radiation pulse.
#define RBMK_MELTDOWN_RAD_RANGE 20
/// Minimum radiation pulse exposure threshold.
#define RBMK_MELTDOWN_RAD_THRESHOLD 0.05
/// Devastation radius of the physical meltdown explosion.
#define RBMK_MELTDOWN_DEV_RANGE 0
/// Heavy-impact radius of the physical meltdown explosion.
#define RBMK_MELTDOWN_HEAVY_RANGE 5
/// Light-impact radius of the physical meltdown explosion.
#define RBMK_MELTDOWN_LIGHT_RANGE 15
/// Flash radius of the physical meltdown explosion.
#define RBMK_MELTDOWN_FLASH_RANGE 18
/// Delay between the meltdown warning and destructive effects.
#define RBMK_MELTDOWN_WARNING_DELAY 8 SECONDS
/// Delay used to sequence consecutive meltdown effects.
#define RBMK_MELTDOWN_EFFECT_STAGGER (0.1 SECONDS)
/// Delay before reactor fallout weather begins.
#define RBMK_MELTDOWN_FALLOUT_DELAY 1 MINUTES
/// Interval between radiation pulses from a slagged reactor core.
#define RBMK_SLAGGED_CORE_RAD_PULSE_INTERVAL 2 SECONDS
/// Radius of the slagged core radiation field.
#define RBMK_SLAGGED_CORE_RAD_RANGE 20
/// Minimum exposure threshold for slagged core radiation.
#define RBMK_SLAGGED_CORE_RAD_THRESHOLD 0.05
/// Radius in which meltdown effects damage station floors.
#define RBMK_MELTDOWN_FLOOR_DAMAGE_RANGE 5
/// Percentage chance for damaged floors to become space.
#define RBMK_MELTDOWN_FLOOR_SPACE_CHANCE 45

// Simulation caps
/// Maximum reactor radiation value used by its simulation and displays.
#define RBMK_MAX_RADIATION 700
/// Maximum reactor flux value used by its simulation and displays.
#define RBMK_MAX_FLUX 1200

// Flux anomalies
/// Flux at which low-tier anomaly spawning begins.
#define RBMK_FLUX_ANOMALY_THRESHOLD 350
/// Flux at which high-tier anomaly timing begins.
#define RBMK_FLUX_ANOMALY_HIGH 700
/// Flux at which extreme-tier anomaly timing begins.
#define RBMK_FLUX_ANOMALY_EXTREME 1000
/// Anomaly cooldown at the lowest eligible flux tier.
#define RBMK_FLUX_ANOMALY_COOLDOWN_LOW 35 SECONDS
/// Anomaly cooldown at the high flux tier.
#define RBMK_FLUX_ANOMALY_COOLDOWN_HIGH 25 SECONDS
/// Anomaly cooldown at the extreme flux tier.
#define RBMK_FLUX_ANOMALY_COOLDOWN_EXTREME 18 SECONDS

// Reactor sound states
/// Low reactor looping-sound state.
#define RBMK_SOUND_LOW 1
/// High reactor looping-sound state.
#define RBMK_SOUND_HIGH 2
/// Maximum-intensity reactor looping-sound state.
#define RBMK_SOUND_MAX 3

/// Rounds RBMK telemetry to two decimal places.
#define RBMK_ROUND2(x) (round((x), 0.01))
