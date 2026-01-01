import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Section,
  Table,
  TextArea,
  Grid,
  Stack,
} from '../components';
import { BoxProps } from '../components/Box';
import { Window } from '../layouts';

type PlayerData = {
  name?: string;
  old_name?: string;
  job?: string;
  ckey?: string;
  is_antagonist: boolean;
  last_ip?: string;
  ref: string;
};

const TextOrNA = (props: { text?: string } & BoxProps) => {
  const { text, ...rest } = props;
  const color = !text ? 'grey' : null;
  return (
    <Box inline color={color} {...rest}>
      {text || 'N/A'}
    </Box>
  );
};

const handleAction = (action: string, params?: Record<string, any>) => {
  const { act } = useBackend();
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useLocalState(
    'selectedPlayerCkey',
    '',
  );

  // If params has a ckey, set it as the selected ckey
  if (params?.ckey) {
    setSelectedPlayerCkey(params.ckey); // Fixed: Use params.ckey instead of PlayerData.ckey
  }

  // Send the action to the backend with the selected ckey
  act(action, {
    ...params,
    selectedPlayerCkey: params?.ckey || selectedPlayerCkey,
  });
};

const PlayerActions = (props: { player: PlayerData }) => {
  const { player } = props;
  const { act } = useBackend();
  return (
    <>
      <Button
        m={0.5}
        onClick={() =>
          handleAction('sendPrivateMessage', {
            ckey: player.ckey, // Use player.ckey instead of selectedPlayerCkey
          })
        }
      >
        PM
      </Button>
      <Button
        m={0.5}
        onClick={() =>
          handleAction('follow', {
            ckey: player.ckey,
          })
        }
        content="Follow"
      />
      <Button
        m={0.5}
        onClick={() =>
          handleAction('smite', {
            ckey: player.ckey,
          })
        }
        content="Smite"
      />
      <Button
        m={0.5}
        onClick={() =>
          handleAction('openAdditionalPanel', {
            ckey: player.ckey,
          })
        }
        content="PP"
        icon="external-link"
      />
      <Button
        m={0.5}
        icon="book"
        content="Logs"
        onClick={() => act('logs', { selectedPlayerCkey: player.ckey })}
      />
      <Button
        m={0.5}
        icon="clipboard"
        content="Notes"
        onClick={() => act('notes', { selectedPlayerCkey: player.ckey })}
      />
      <Button
        m={0.5}
        content="VV"
        onClick={() => act('vv', { selectedPlayerCkey: player.ckey })}
      />
      <Button
        m={0.5}
        content="TP"
        onClick={() => act('tp', { selectedPlayerCkey: player.ckey })}
      />
    </>
  );
};

const PlayerRow = (props: { player: PlayerData }) => {
  const { player } = props;

  return (
    <Table.Row key={player.ckey} className="candystripe">
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.ckey} px={1} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.name} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.old_name} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.job} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        {player.is_antagonist ? (
          <Box color="red">Yes</Box>
        ) : (
          <Box color="green">No</Box>
        )}
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center">
        <TextOrNA text={player.last_ip} />
      </Table.Cell>
      <Table.Cell verticalAlign="middle" textAlign="center" py={1}>
        <PlayerActions player={player} />
      </Table.Cell>
    </Table.Row>
  );
};

const AdminHelpers = () => {
  return (
    <Section>
      <Grid>
        <Grid.Column>
          <Button
            fluid
            content="Check Players"
            onClick={() => handleAction('checkPlayers')}
          />
          <Button
            fluid
            content="Game Panel"
            onClick={() => handleAction('gamePanel')}
          />
        </Grid.Column>
        <Grid.Column>
          <Button
            fluid
            content="Old PP"
            onClick={() => handleAction('oldPP')}
          />
          <Button
            fluid
            content="Check Antags"
            onClick={() => handleAction('checkAntags')}
          />
          <Button
            fluid
            content="Combo HUD"
            onClick={() => handleAction('comboHUD')}
          />
        </Grid.Column>
        <Grid.Column>
          <Button
            fluid
            content="Fax Panel"
            onClick={() => handleAction('faxPanel')}
          />
          <Button
            fluid
            content="Admin VOX"
            onClick={() => handleAction('adminVOX')}
          />
          <Button
            fluid
            content="Generate Code"
            onClick={() => handleAction('generateCode')}
          />
        </Grid.Column>
        <Grid.Column>
          <Button
            fluid
            content="View Opfors"
            onClick={() => handleAction('viewOpfors')}
          />
          <Button
            fluid
            content="Create Command Report"
            onClick={() => handleAction('createCommandReport')}
          />
          <Button
            fluid
            content="Toggle Admin AI Interact"
            onClick={() => handleAction('adminaiinteract')}
          />
        </Grid.Column>
      </Grid>
    </Section>
  );
};

export const VethPlayerPanel = (_props) => {
  const { data, act } = useBackend<{ Data: PlayerData[] }>();
  const playerData = data?.Data || [];

  const [searchTerm, setSearchTerm] = useLocalState('searchTerm', '');
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useLocalState(
    'selectedPlayerCkey',
    '',
  );
  // Filter player data based on the search term
  const filteredData = searchTerm
    ? playerData.filter((player) =>
        [
          player.name?.toLowerCase() || '',
          player.job?.toLowerCase() || '',
          player.ckey?.toLowerCase() || '',
          player.old_name?.toLowerCase() || '',
        ].some((field) => field.includes(searchTerm.toLowerCase())),
      )
    : playerData;

  const handleAction = (action: string, params?: Record<string, any>) => {
    // If params has a ckey, set it as the selected ckey
    if (params?.ckey) {
      setSelectedPlayerCkey(params.ckey); // Fixed: Use params.ckey instead of PlayerData.ckey
    }

    // Send the action to the backend with the selected ckey
    act(action, {
      ...params,
      selectedPlayerCkey: params?.ckey || selectedPlayerCkey,
    });
  };
  return (
    <Box>
      <Window title="Player Panel Veth" width={1000} height={640}>
        <Window.Content>
          <Stack fill vertical>
            <Stack.Item>
              <AdminHelpers />
            </Stack.Item>

            <Stack.Item grow>
              <Section
                title={`Players (${filteredData.length})`}
                fill
                scrollable
                className="VethPlayerPanel__header"
                buttons={
                  <Stack>
                    <Stack.Item>
                      <TextArea
                        autoFocus
                        placeholder="Search by name, old name, job, or ckey"
                        value={searchTerm}
                        onInput={(_, value) => setSearchTerm(value)}
                        rows={1}
                        height="2rem"
                        width="500px"
                        className="VethPlayerPanel__search"
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="refresh"
                        content="Refresh"
                        onClick={() => handleAction('refresh')}
                      />
                    </Stack.Item>
                  </Stack>
                }
              >
                <Table className={'VethPlayerPanel'}>
                  <Table.Row header>
                    <Table.Cell textAlign="center">Ckey</Table.Cell>
                    <Table.Cell textAlign="center">Char Name</Table.Cell>
                    <Table.Cell textAlign="center">Also Known As</Table.Cell>
                    <Table.Cell textAlign="center">Job</Table.Cell>
                    <Table.Cell textAlign="center">Antagonist</Table.Cell>
                    <Table.Cell textAlign="center">Last IP</Table.Cell>
                    <Table.Cell textAlign="center">Actions</Table.Cell>
                  </Table.Row>
                  {filteredData.map((player) => (
                    <PlayerRow key={player.ckey} player={player} />
                  ))}
                </Table>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    </Box>
  );
};
