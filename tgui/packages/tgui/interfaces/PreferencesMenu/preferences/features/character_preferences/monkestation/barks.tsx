import { Button, Stack } from '../../../../../../components';

import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
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

export const bark_pitch_range: FeatureNumeric = {
  name: 'Character Voice Range',
  description:
    '[0.1 - 0.8] Lower number, less range. Higher number, more range.',

  component: FeatureNumberInput,
};

export const bark_sound: FeatureChoiced = {
  name: 'Character Voice',
  component: FeatureBarkDropdownInput,
};

export const bark_speech_speed: FeatureNumeric = {
  name: 'Character Voice Duration',
  description:
    '[2 - 16] Lower number, faster speed. Higher number, slower speed.',
  component: FeatureNumberInput,
};

export const bark_speech_pitch: FeatureNumeric = {
  name: 'Character Voice Pitch',
  description:
    '[0.4 - 2] Lower number, deeper pitch. Higher number, higher pitch.',
  component: FeatureNumberInput,
};

export const hear_sound_bark: FeatureToggle = {
  name: 'Enable Character Voice hearing',
  category: 'SOUND',
  component: CheckboxInput,
};

export const sound_bark_volume: Feature<number> = {
  name: 'Character Voice Volume',
  category: 'SOUND',
  description: 'The volume that the Vocal Barks sounds will play at.',
  component: FeatureNumberInput,
};
