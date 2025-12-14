import { sortStrings } from 'common/collections';
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
  const serverData = props.serverData;
  if (!serverData) {
    return null;
  }

  const choices = sortStrings(serverData.choices);
  const currentIndex = choices.indexOf(props.value ?? '');
  const prevIndex = currentIndex > 0 ? currentIndex - 1 : choices.length - 1;
  const nextIndex =
    currentIndex < choices.length - 1 && currentIndex !== -1
      ? currentIndex + 1
      : 0;

  const handleBackward = () => {
    props.handleSetValue(choices[prevIndex]);
    props.act('play_ringtone_sound');
  };

  const handleForward = () => {
    props.handleSetValue(choices[nextIndex]);
    props.act('play_ringtone_sound');
  };

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
      <Stack.Item>
        <Button
          onClick={handleBackward}
          icon="step-backward"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={handleForward}
          icon="step-forward"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
};

export const pda_ringtone_sound: Feature<string> = {
  name: 'PDA Ringtone Sound',
  // component: FeatureDropdownInput,
  component: FeaturePdaDropdownInput,
};
