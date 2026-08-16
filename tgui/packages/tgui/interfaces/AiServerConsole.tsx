import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Box, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  servers: ServerData[];
};

type ServerData = {
  area: string;
  working: BooleanLike;
  total_cpu: number;
  ram: number;
  card_capacity: string;
  temp: number;
};

export const AiServerConsole = () => {
  const { data } = useBackend<Data>();

  const { servers = [] } = data;

  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        <Section title="Server Overview">
          {servers.map((server, index) => {
            return (
              <Section key={index}>
                <Box textAlign="center">
                  Location:{' '}
                  <Box inline bold>
                    {server.area}
                  </Box>
                </Box>
                <Box textAlign="center" bold>
                  Status:{' '}
                  <Box inline color={server.working ? 'good' : 'bad'}>
                    {server.working ? 'ONLINE' : 'OFFLINE'}
                  </Box>
                </Box>
                <ProgressBar
                  ranges={{
                    good: [-Infinity, 250],
                    average: [250, 500],
                    bad: [500, Infinity],
                  }}
                  value={server.temp}
                  maxValue={500}
                >
                  {server.temp}K
                </ProgressBar>
                <Box textAlign="center">
                  Capacity:{' '}
                  <Box inline bold>
                    {server.card_capacity} cards
                  </Box>
                </Box>
                <Box textAlign="center">
                  CPU Power:{' '}
                  <Box inline bold>
                    {server.total_cpu} THz
                  </Box>
                </Box>
                <Box textAlign="center">
                  RAM Capacity:{' '}
                  <Box inline bold>
                    {server.ram} TB
                  </Box>
                </Box>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
