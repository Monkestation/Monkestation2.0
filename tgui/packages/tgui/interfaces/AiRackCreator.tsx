import type { BooleanLike } from 'common/react';
import { classes } from 'common/react';
import { Fragment, useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Modal, Section, Stack } from '../components';
import { formatPower, formatSiUnit } from '../format';
import { Window } from '../layouts';

const MATERIAL_KEYS = {
  iron: 'sheet-metal_3',
  glass: 'sheet-glass_3',
  silver: 'sheet-silver_3',
  gold: 'sheet-gold_3',
  'bluespace crystal': 'polycrystal',
};

type Data = {
  cpus: CpuData[];
  ram: RamData[];
  possible_ram: PossibleRamData[];
  total_cpu: number;
  total_ram: number;
  power_usage: number;
  efficiency: number;
  unlocked_cpu: number;
  unlocked_ram: number;
};

type CpuData = {
  speed: number;
  power_usage: number;
  efficiency: number;
};

type RamData = {
  name: string;
  capacity: number;
  cost: string;
};

type PossibleRamData = {
  name: string;
  unlocked: BooleanLike;
  id: string;
  cost: string;
  capacity: number;
};

export const AiRackCreator = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    cpus = [],
    ram = [],
    total_cpu,
    total_ram,
    power_usage,
    efficiency,
    unlocked_cpu,
    unlocked_ram,
    possible_ram = [],
  } = data;

  const [modalStatus, setModalStatus] = useState(false);

  const upperCaseWords = (string) => {
    if (!string) return;
    const words = string.split(' ');
    for (let i = 0; i < words.length; i++) {
      words[i] = words[i][0].toUpperCase() + words[i].substr(1);
    }
    return words.join(' ');
  };

  return (
    <Window width={700} height={878}>
      <Window.Content scrollable>
        <Stack align="center" direction="column" mb="5px">
          <Stack align="center">
            <Stack.Item ml={1} mr={1} mt={1} basis="content" grow={1}>
              <Section title="Materials">
                <Materials />
              </Section>
            </Stack.Item>
          </Stack>
        </Stack>
        <Section title="Central Processing Units">
          <Box>
            <Stack>
              <Stack.Item width="40%" textAlign="center">
                <Section title="CPU #1">
                  {(cpus.length <= 0 && (
                    <Button
                      color="transparent"
                      icon="microchip"
                      iconSize={5}
                      width="100%"
                      onClick={() => act('insert_cpu')}
                    />
                  )) || (
                    <Fragment>
                      <Button
                        color="transparent"
                        icon="microchip"
                        iconSize={5}
                        width="100%"
                        onClick={() => act('remove_cpu', { cpu_index: 1 })}
                      />
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        left="30px"
                      >
                        {cpus[0].speed}Thz
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        right="30px"
                      >
                        {cpus[0].power_usage}W
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="35px"
                        right="25px"
                      >
                        ({cpus[0].efficiency}%)
                      </Box>
                    </Fragment>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item grow={1} textAlign="center">
                <Box bold>Statistics</Box>
                <Box bold>Processing Power</Box>
                <Box>{total_cpu}Thz</Box>
                <Box bold>Power usage</Box>
                <Box>{formatPower(power_usage)}</Box>
                <Box bold>Efficiency</Box>
                <Box>{(Math.round(efficiency * 100) / 100) * 100}%</Box>
              </Stack.Item>
              <Stack.Item width="40%" textAlign="center">
                <Section title="CPU #2">
                  {(cpus.length <= 1 && (
                    <Button
                      color="transparent"
                      icon="microchip"
                      iconSize={5}
                      width="100%"
                      onClick={() => act('insert_cpu')}
                    />
                  )) || (
                    <Fragment>
                      <Button
                        color="transparent"
                        icon="microchip"
                        iconSize={5}
                        width="100%"
                        onClick={() => act('remove_cpu', { cpu_index: 2 })}
                      />
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        right="30px"
                      >
                        {cpus[1].speed}Thz
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        left="30px"
                      >
                        {cpus[1].power_usage}W
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="35px"
                        left="30px"
                      >
                        ({cpus[1].efficiency}%)
                      </Box>
                    </Fragment>
                  )}
                  {unlocked_cpu < 2 && (
                    <Dimmer>
                      <Box color="average">
                        Locked <br />
                        Requires Tech Improved CPU Sockets
                      </Box>
                    </Dimmer>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
            <Stack mt={2}>
              <Stack.Item width="40%" textAlign="center">
                <Section title="CPU #3">
                  {(cpus.length <= 2 && (
                    <Button
                      color="transparent"
                      icon="microchip"
                      iconSize={5}
                      width="100%"
                      onClick={() => act('insert_cpu')}
                    />
                  )) || (
                    <Fragment>
                      <Button
                        color="transparent"
                        icon="microchip"
                        iconSize={5}
                        width="100%"
                        onClick={() => act('remove_cpu', { cpu_index: 3 })}
                      />
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        left="30px"
                      >
                        {cpus[2].speed}Thz
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        right="30px"
                      >
                        {cpus[2].power_usage}W
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="35px"
                        right="25px"
                      >
                        ({cpus[2].efficiency}%)
                      </Box>
                    </Fragment>
                  )}
                  {unlocked_cpu < 3 && (
                    <Dimmer>
                      <Box color="average">
                        Locked <br />
                        Requires tech Advanced CPU Sockets
                      </Box>
                    </Dimmer>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item grow={1} textAlign="center">
                <Box bold>Memory Capacity</Box>
                <Box>{total_ram}Tb</Box>
              </Stack.Item>
              <Stack.Item width="40%" textAlign="center">
                <Section title="CPU #4">
                  {(cpus.length <= 3 && (
                    <Button
                      color="transparent"
                      icon="microchip"
                      iconSize={5}
                      width="100%"
                      onClick={() => act('insert_cpu')}
                    />
                  )) || (
                    <Fragment>
                      <Button
                        color="transparent"
                        icon="microchip"
                        iconSize={5}
                        width="100%"
                        onClick={() => act('remove_cpu', { cpu_index: 4 })}
                      />
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        right="30px"
                      >
                        {cpus[3].speed}Thz
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="50px"
                        left="30px"
                      >
                        {cpus[3].power_usage}W
                      </Box>
                      <Box
                        inline
                        bold
                        position="absolute"
                        bottom="35px"
                        left="30px"
                      >
                        ({cpus[3].efficiency}%)
                      </Box>
                    </Fragment>
                  )}
                  {unlocked_cpu < 4 && (
                    <Dimmer>
                      <Box color="average">
                        Locked <br />
                        Requires tech Bluespace CPU Sockets
                      </Box>
                    </Dimmer>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Box>
        </Section>
        <Section title="Random Access Memory">
          <Section title="Stick #1" textAlign="center">
            {(ram.length <= 0 && (
              <Button
                width="100%"
                icon="memory"
                iconSize={3}
                color="transparent"
                onClick={() => setModalStatus(true)}
              />
            )) || (
              <Fragment>
                <Button
                  width="100%"
                  icon="memory"
                  iconSize={3}
                  color="transparent"
                  onClick={() => act('remove_ram', { ram_index: 1 })}
                />
                <Box inline bold position="absolute" bottom="25px" left="125px">
                  {upperCaseWords(ram[0].name)}
                </Box>
                <Box inline position="absolute" bottom="25px" right="250px">
                  {ram[0].capacity}TB
                </Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">
                  {ram[0].cost.charAt(0).toUpperCase() + ram[0].cost.slice(1)}
                </Box>
              </Fragment>
            )}
          </Section>
          <Section title="Stick #2" textAlign="center">
            {(ram.length <= 1 && (
              <Button
                width="100%"
                icon="memory"
                iconSize={3}
                color="transparent"
                onClick={() => setModalStatus(true)}
              />
            )) || (
              <Fragment>
                <Button
                  width="100%"
                  icon="memory"
                  iconSize={3}
                  color="transparent"
                  onClick={() => act('remove_ram', { ram_index: 2 })}
                />
                <Box inline bold position="absolute" bottom="25px" left="125px">
                  {upperCaseWords(ram[1].name)}
                </Box>
                <Box inline position="absolute" bottom="25px" right="250px">
                  {ram[1].capacity}TB
                </Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">
                  {ram[1].cost.charAt(0).toUpperCase() + ram[1].cost.slice(1)}
                </Box>
              </Fragment>
            )}
            {unlocked_ram < 2 && (
              <Dimmer>
                <Box color="average">
                  Locked <br />
                  Requires tech Improved Memory Bus
                </Box>
              </Dimmer>
            )}
          </Section>
          <Section title="Stick #3" textAlign="center">
            {(ram.length <= 2 && (
              <Button
                width="100%"
                icon="memory"
                iconSize={3}
                color="transparent"
                onClick={() => setModalStatus(true)}
              />
            )) || (
              <Fragment>
                <Button
                  width="100%"
                  icon="memory"
                  iconSize={3}
                  color="transparent"
                  onClick={() => act('remove_ram', { ram_index: 3 })}
                />
                <Box inline bold position="absolute" bottom="25px" left="125px">
                  {upperCaseWords(ram[2].name)}
                </Box>
                <Box inline position="absolute" bottom="25px" right="250px">
                  {ram[2].capacity}TB
                </Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">
                  {ram[2].cost.charAt(0).toUpperCase() + ram[2].cost.slice(1)}
                </Box>
              </Fragment>
            )}
            {unlocked_ram < 3 && (
              <Dimmer>
                <Box color="average">
                  Locked <br />
                  Requires tech Advanced Memory Bus
                </Box>
              </Dimmer>
            )}
          </Section>
          <Section title="Stick #4" textAlign="center">
            {(ram.length <= 3 && (
              <Button
                width="100%"
                icon="memory"
                iconSize={3}
                color="transparent"
                onClick={() => setModalStatus(true)}
              />
            )) || (
              <Fragment>
                <Button
                  width="100%"
                  icon="memory"
                  iconSize={3}
                  color="transparent"
                  onClick={() => act('remove_ram', { ram_index: 4 })}
                />
                <Box inline bold position="absolute" bottom="25px" left="125px">
                  {upperCaseWords(ram[3].name)}
                </Box>
                <Box inline position="absolute" bottom="25px" right="250px">
                  {ram[3].capacity}TB
                </Box>
                <Box inline position="absolute" bottom="0px" left="0" right="0">
                  {ram[3].cost.charAt(0).toUpperCase() + ram[3].cost.slice(1)}
                </Box>
              </Fragment>
            )}
            {unlocked_ram < 4 && (
              <Dimmer>
                <Box color="average">
                  Locked <br />
                  Requires tech Bluespace Memory Bus
                </Box>
              </Dimmer>
            )}
          </Section>
        </Section>
        <Button.Confirm
          fontSize="20px"
          textAlign="center"
          icon="arrow-right"
          width="100%"
          color="good"
          onClick={() => act('finalize')}
        >
          Finalize
        </Button.Confirm>
      </Window.Content>
      {modalStatus && (
        <Modal width="600px">
          <Section title="Select RAM">
            {possible_ram.map((entry, index) => (
              <Section
                key={index}
                title={entry.name}
                buttons={
                  <Button
                    color="green"
                    tooltip={!entry.unlocked ? 'Not Unlocked!' : ''}
                    disabled={!entry.unlocked}
                    onClick={() => {
                      act('insert_ram', { ram_type: entry.id });
                      setModalStatus(false);
                    }}
                  >
                    Select
                  </Button>
                }
              >
                <Box inline bold>
                  Capacity:&nbsp;
                </Box>
                <Box inline>{entry.capacity}TB</Box>
                <br />
                <Box inline bold>
                  Cost:&nbsp;
                </Box>
                <Box italic inline>
                  {entry.cost.charAt(0).toUpperCase() + entry.cost.slice(1)}
                </Box>
              </Section>
            ))}
            <Button
              fontSize="18px"
              width="100%"
              textAlign="center"
              color="red"
              onClick={() => setModalStatus(false)}
            >
              Cancel
            </Button>
          </Section>
        </Modal>
      )}
    </Window>
  );
};

type MaterialsData = {
  materials: MaterialData[];
};

type MaterialData = {
  name: string;
  amount: number;
};

const Materials = (props) => {
  const { data } = useBackend<MaterialsData>();

  const { materials = [] } = data;

  return (
    <Stack wrap="wrap">
      {materials
        .filter((material) => MATERIAL_KEYS[material.name])
        .map((material) => (
          <Stack.Item width="80px" key={material.name}>
            <MaterialAmount
              name={material.name}
              amount={material.amount}
              formatsi
            />
            <Box mt={1} style={{ textAlign: 'center' }} />
          </Stack.Item>
        ))}
    </Stack>
  );
};

const MaterialAmount = (props) => {
  const { name, amount, formatsi, color, style } = props;

  if (MATERIAL_KEYS[name]) {
    return (
      <Stack direction="column" align="center">
        <Stack.Item>
          <Box
            className={classes(['sheetmaterials32x32', MATERIAL_KEYS[name]])}
            style={style}
          />
        </Stack.Item>
        <Stack.Item>
          <Box textColor={color} style={{ textAlign: 'center' }}>
            {formatsi && formatSiUnit(amount, 0)}
          </Box>
        </Stack.Item>
      </Stack>
    );
  }
};
