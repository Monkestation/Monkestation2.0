import { type CSSProperties, useState } from 'react';

import { useBackend } from '../../backend';
import { Box, Button } from '../../components';

type RodSlotData = {
  name?: string;
  type?: string;
  rod_type?: string;
  color?: string;
  active?: boolean;
  depleted?: boolean;
  empty?: boolean;
  occupied?: boolean;
  fuel_amount?: number;
  slot_kind: 'normal' | 'special';
  slot_index: number;
};

type ChannelSelection =
  | { kind: 'control' }
  | { kind: 'integrity' }
  | { kind: 'rod'; rod: RodSlotData };

const GRID_SIZE = 15;
const GRID_CENTER = 7;
const NORMAL_CHANNELS = [
  '2,7',
  '3,4',
  '3,10',
  '5,5',
  '5,9',
  '7,2',
  '7,12',
  '9,5',
  '9,9',
  '11,4',
  '11,10',
  '12,7',
];
const SPECIAL_CHANNELS = ['4,7', '7,4', '7,10', '10,7'];

const isRodOccupied = (rod: RodSlotData) => {
  if (typeof rod.occupied === 'boolean') {
    return rod.occupied;
  }
  if (typeof rod.empty === 'boolean') {
    return !rod.empty;
  }
  return (rod.name ?? rod.type ?? 'Empty') !== 'Empty';
};

const rodName = (rod: RodSlotData) => rod.name ?? rod.type ?? 'Empty';

const shortRodName = (rod: RodSlotData) =>
  rodName(rod).replace(/ fuel rod$/i, '').replace(/ rod$/i, '').toUpperCase();

const fuelDisplay = (rod: RodSlotData) => {
  const fuel = Number(rod.fuel_amount ?? 0);
  return Number.isFinite(fuel) ? `${Math.max(0, fuel).toFixed(0)}% FUEL` : '∞ FUEL';
};

export const RBMKRods = () => {
  const { data, act } = useBackend<any>();
  const [selection, setSelection] = useState<ChannelSelection>({
    kind: 'control',
  });

  const rods: RodSlotData[] = data?.rods || [];
  const maxNormal = Number(data?.max_normal_slots ?? 12);
  const maxSpecial = Number(data?.max_special_slots ?? 4);
  const integrity = Number(data?.integrity ?? 0);
  const maxIntegrity = Math.max(Number(data?.max_integrity ?? 100), 1);
  const integrityRatio = Math.max(0, Math.min(1, integrity / maxIntegrity));
  const controlDepth = Number(data?.control_rods ?? 0);
  const maxControlDepth = Math.max(Number(data?.max_control_rod ?? 100), 1);
  const controlRatio = Math.max(0, Math.min(1, controlDepth / maxControlDepth));

  const normalRods = rods
    .filter((rod) => rod.slot_kind === 'normal')
    .sort((a, b) => a.slot_index - b.slot_index);
  const specialRods = rods
    .filter((rod) => rod.slot_kind === 'special')
    .sort((a, b) => a.slot_index - b.slot_index);
  const channelRods = new Map<string, RodSlotData>();
  NORMAL_CHANNELS.forEach((channel, index) => {
    const rod = normalRods[index];
    if (rod) channelRods.set(channel, rod);
  });
  SPECIAL_CHANNELS.forEach((channel, index) => {
    const rod = specialRods[index];
    if (rod) channelRods.set(channel, rod);
  });

  const normalInstalled = normalRods.filter(isRodOccupied).length;
  const specialInstalled = specialRods.filter(isRodOccupied).length;
  const integrityState =
    integrityRatio >= 0.75
      ? 'nominal'
      : integrityRatio >= 0.5
        ? 'warning'
        : integrityRatio >= 0.25
          ? 'critical'
          : 'danger';
  const controlState =
    controlRatio >= 0.7
      ? 'safe'
      : controlRatio >= 0.4
        ? 'warning'
        : controlRatio >= 0.15
          ? 'low'
          : 'danger';

  let monitorTitle = 'CONTROL ROD';
  let monitorValue = `${(controlRatio * 100).toFixed(0)}% INSERTED`;
  let selectedRod: RodSlotData | undefined;
  if (selection.kind === 'integrity') {
    monitorTitle = 'CORE INTEGRITY';
    monitorValue = `${(integrityRatio * 100).toFixed(0)}%`;
  } else if (selection.kind === 'rod') {
    selectedRod = selection.rod;
    if (isRodOccupied(selection.rod)) {
      monitorTitle = shortRodName(selection.rod);
      monitorValue = selection.rod.depleted
        ? 'DEPLETED'
        : fuelDisplay(selection.rod);
    } else {
      monitorTitle = 'EMPTY';
      monitorValue = `${selection.rod.slot_kind.toUpperCase()} SLOT`;
    }
  }

  return (
    <Box className="RBMKConsole__CorePanel">
      <Box className="RBMKConsole__CoreStatus">
        <Box>
          <b>CORE CHANNEL MAP</b>
          <span>LIVE REACTOR LAYOUT</span>
        </Box>
        <Box className="RBMKConsole__CoreStatusReadout">
          FUEL {normalInstalled}/{maxNormal} &nbsp; MOD {specialInstalled}/
          {maxSpecial} &nbsp; RODS {(controlRatio * 100).toFixed(0)}%
        </Box>
      </Box>

      <Box className="RBMKConsole__CoreBoard">
        <Box className="RBMKConsole__CoreGrid">
          {Array.from({ length: GRID_SIZE * GRID_SIZE }, (_, index) => {
            const row = Math.floor(index / GRID_SIZE);
            const column = index % GRID_SIZE;
            const channel = `${row},${column}`;
            const distance =
              (row - GRID_CENTER) ** 2 + (column - GRID_CENTER) ** 2;
            const isCenter = row >= 6 && row <= 8 && column >= 6 && column <= 8;

            if (distance > 45 || isCenter) {
              return <span key={channel} className="RBMKConsole__ChannelVoid" />;
            }

            if (distance > 32) {
              return (
                <button
                  type="button"
                  key={channel}
                  aria-label="Core integrity"
                  className={`RBMKConsole__IntegrityCell RBMKConsole__IntegrityCell--${integrityState}`}
                  onClick={() => setSelection({ kind: 'integrity' })}
                  onFocus={() => setSelection({ kind: 'integrity' })}
                  onMouseEnter={() => setSelection({ kind: 'integrity' })}
                />
              );
            }

            const rod = channelRods.get(channel);
            if (rod) {
              const occupied = isRodOccupied(rod);
              const rodState = !occupied
                ? 'empty'
                : rod.depleted
                  ? 'depleted'
                  : 'active';
              return (
                <button
                  type="button"
                  key={channel}
                  aria-label={occupied ? rodName(rod) : `Empty ${rod.slot_kind} slot`}
                  className={`RBMKConsole__FuelChannel RBMKConsole__FuelChannel--${rodState}`}
                  style={
                    {
                      '--rbmk-rod-color': occupied
                        ? rod.color || '#8c9498'
                        : '#737b80',
                    } as CSSProperties
                  }
                  onClick={() => setSelection({ kind: 'rod', rod })}
                  onFocus={() => setSelection({ kind: 'rod', rod })}
                  onMouseEnter={() => setSelection({ kind: 'rod', rod })}
                >
                  <span />
                </button>
              );
            }

            return (
              <button
                type="button"
                key={channel}
                aria-label="Control rod"
                className={`RBMKConsole__ControlChannel RBMKConsole__ControlChannel--${controlState}`}
                onClick={() => setSelection({ kind: 'control' })}
                onFocus={() => setSelection({ kind: 'control' })}
                onMouseEnter={() => setSelection({ kind: 'control' })}
              >
                <span className="RBMKConsole__ControlTrack">
                  <span
                    className="RBMKConsole__ControlFill"
                    style={{ height: `${controlRatio * 100}%` }}
                  />
                </span>
              </button>
            );
          })}

          <Box className="RBMKConsole__CoreMonitor">
            <Box className="RBMKConsole__CoreMonitorTitle">{monitorTitle}</Box>
            <Box className="RBMKConsole__CoreMonitorValue">{monitorValue}</Box>
          </Box>
        </Box>
      </Box>

      <Box className="RBMKConsole__CoreFooter">
        <Box className="RBMKConsole__CoreLegend">
          <span className="RBMKConsole__LegendKey RBMKConsole__LegendKey--active" />
          ACTIVE
          <span className="RBMKConsole__LegendKey RBMKConsole__LegendKey--depleted" />
          DEPLETED
          <span className="RBMKConsole__LegendLed" /> ROD MATERIAL
        </Box>
        {selectedRod && isRodOccupied(selectedRod) && (
          <Button
            icon="eject"
            color="bad"
            content="Eject selected"
            onClick={() =>
              act('remove_rod', {
                kind: selectedRod.slot_kind,
                index: selectedRod.slot_index,
              })
            }
          />
        )}
      </Box>
    </Box>
  );
};

export default RBMKRods;
