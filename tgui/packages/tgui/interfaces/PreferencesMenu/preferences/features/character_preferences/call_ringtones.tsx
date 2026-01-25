import { sortStrings } from 'common/collections';
import { Button, Stack } from '../../../../../components';
import {
  Feature,
  FeatureChoicedServerData,
  FeatureDropdownInput,
  FeatureValueProps,
} from '../base';

const FeatureRingtoneDropdownInput = (
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
  };

  const handleForward = () => {
    props.handleSetValue(choices[nextIndex]);
  };

  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={() => props.act('play_call_ringtone_sound')}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => props.act('stop_call_ringtone_sound')}
          icon="stop"
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

export const call_ringtone: Feature<string> = {
  name: 'Call Ringtone Sound (Modlinks)',
  // component: FeatureDropdownInput,
  component: FeatureRingtoneDropdownInput,
};
