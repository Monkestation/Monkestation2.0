import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  bark_groups: Record<string, [string, string][]>;
  selected: string;
};

export const BarkScreen = (props) => {
  const { data, act } = useBackend<Data>();

  return (
    <Window title="Bark Sound" width={270} height={500} theme="generic">
      <Window.Content scrollable>
        {Object.keys(data.bark_groups).map((group_name, index) => (
          <BarkGroup
            key={index}
            name={group_name}
            barks={data.bark_groups[group_name]}
            selected={data.selected}
          />
        ))}
      </Window.Content>
    </Window>
  );
};

const BarkGroup = (props: {
  name: string;
  barks: [string, string][];
  selected: string;
}) => {
  return (
    <Box>
      <h3>{props.name}</h3>
      <Box>
        {props.barks.map((bark, index) => (
          <Bark key={index} name={bark} selected={props.selected} />
        ))}
      </Box>
    </Box>
  );
};

const Bark = (props: { name: [string, string]; selected: string }) => {
  const { act } = useBackend<Data>();

  return (
    <Stack style={{ margin: '5px 0px' }}>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play', { selected: props.name[1] });
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('select', { selected: props.name[1] });
          }}
          selected={props.name[1] === props.selected}
          width="100%"
          height="100%"
        >
          {props.name[0]}
        </Button>
      </Stack.Item>
    </Stack>
  );
};
