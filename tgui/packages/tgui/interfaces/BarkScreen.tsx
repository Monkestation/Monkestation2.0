import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  bark_groups: Record<string, [string, string][]>;
};

export const BarkScreen = (props) => {
  const { data, act } = useBackend<Data>();

  return (
    <Window
      title="Character Bark Sound"
      width={300}
      height={500}
      theme="generic"
    >
      <Window.Content>
        <Stack fill vertical>
          {Object.keys(data.bark_groups).map((group_name, index) => (
            <BarkGroup
              key={index}
              name={group_name}
              barks={data.bark_groups[group_name]}
            />
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BarkGroup = (props: { name: string; barks: [string, string][] }) => {
  return (
    <Box>
      <Stack.Item>{props.name}</Stack.Item>
      <Stack.Item>
        {props.barks.map((bark, index) => (
          <Bark key={index} name={bark} />
        ))}
      </Stack.Item>
    </Box>
  );
};

const Bark = (props: { name: [string, string] }) => {
  const { act } = useBackend<Data>();

  return (
    <Box>
      <Stack>
        <Stack.Item>
          <Button
            onClick={() => {
              act('select_item');
            }}
            width="100%"
            height="100%"
          >
            {props.name[0]}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => {
              act('play');
            }}
            icon="play"
            width="100%"
            height="100%"
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
