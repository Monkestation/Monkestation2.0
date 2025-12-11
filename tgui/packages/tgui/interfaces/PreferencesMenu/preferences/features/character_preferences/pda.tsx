import { Button, Stack } from '../../../../../components';
import {
  Feature,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureDropdownInput,
  FeatureShortTextInput,
  FeatureValueProps,
} from '../base';

export const pda_theme: FeatureChoiced = {
  name: 'PDA Theme',
  category: 'GAMEPLAY',
  component: FeatureDropdownInput,
};

export const pda_ringtone: Feature<string> = {
  name: 'PDA Ringtone',
  component: FeatureShortTextInput,
};

const FeaturePdaDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={() => {
            props.act('play_ringtone_sound');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
    </Stack>
  );
};

export const pda_ringtone_sound: Feature<string> = {
  name: 'PDA Ringtone Sound',
  // component: FeatureDropdownInput,
  component: FeaturePdaDropdownInput,
};
