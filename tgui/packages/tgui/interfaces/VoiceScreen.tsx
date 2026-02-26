import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  voice_pack_groups: Record<string, [string, string][]>;
  selected: string;
};

export const VoiceScreen = () => {
  const { data } = useBackend<Data>();

  return (
    <Window title="Voice Sound" width={270} height={500} theme="generic">
      <Window.Content scrollable>
        {Object.keys(data.voice_pack_groups).map((group_name, index) => (
          <VoicePackGroup
            key={index}
            name={group_name}
            voice_packs={data.voice_pack_groups[group_name]}
            selected={data.selected}
          />
        ))}
      </Window.Content>
    </Window>
  );
};

const VoicePackGroup = (props: {
  name: string;
  voice_packs: [string, string][];
  selected: string;
}) => {
  return (
    <Box>
      <h3>{props.name}</h3>
      <Box>
        {props.voice_packs.map((voice_pack, index) => (
          <VoicePack key={index} name={voice_pack} selected={props.selected} />
        ))}
      </Box>
    </Box>
  );
};

const VoicePack = (props: { name: [string, string]; selected: string }) => {
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
