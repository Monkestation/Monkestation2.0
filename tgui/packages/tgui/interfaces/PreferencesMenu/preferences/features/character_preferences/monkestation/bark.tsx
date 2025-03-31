import { Box, Button, Slider, Stack } from '../../../../../../components';

import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumeric,
  FeatureNumericData,
  FeatureValueProps,
} from '../../base';

const FeatureBarkDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_bark');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('open_bark_screen');
          }}
          width="100%"
          height="100%"
        >
          {props.value}
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const bark_sound: FeatureChoiced = {
  name: 'Bark',
  component: FeatureBarkDropdownInput,
};

const FeatureSliderInput = (
  props: FeatureValueProps<number, number, FeatureNumericData>,
) => {
  if (!props.serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <Slider
      onChange={(_, value: number) => {
        props.handleSetValue(value);
      }}
      minValue={props.serverData.minimum}
      maxValue={props.serverData.maximum}
      step={props.serverData.step}
      value={props.value}
    />
  );
};

export const bark_pitch_range: FeatureNumeric = {
  name: 'Bark Pitch Range',
  component: FeatureSliderInput,
};

export const bark_speech_speed: FeatureNumeric = {
  name: 'Bark Duration',
  component: FeatureSliderInput,
};

export const bark_speech_pitch: FeatureNumeric = {
  name: 'Bark Pitch',
  component: FeatureSliderInput,
};
