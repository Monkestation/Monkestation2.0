import { Dropdown, NumberInput, Stack } from '../../../../../components';
import type { Feature, FeatureNumericData, FeatureValueProps } from '../base';

type FpsServerData = FeatureNumericData & {
  recommended_fps: number;
};

const FpsInput = (props: FeatureValueProps<number, number, FpsServerData>) => {
  const { handleSetValue, serverData } = props;
  const value = props.value!;

  const recommendedValue = serverData?.recommended_fps ?? 60;
  const recommendedLabel = `Recommended (${recommendedValue})`;

  const presets = ['72', '90', '120', '144'];

  let selected: string;
  if (value === -1) {
    selected = recommendedLabel;
  } else if (presets.includes(String(value))) {
    selected = String(value);
  } else {
    selected = 'Custom';
  }

  return (
    <Stack fill>
      <Stack.Item basis="70%">
        <Dropdown
          width="100%"
          options={[recommendedLabel, ...presets, 'Custom']}
          selected={selected}
          onSelected={(opt) => {
            if (opt === recommendedLabel) {
              handleSetValue(-1);
              return;
            }

            if (opt === 'Custom') {
              handleSetValue(
                value !== -1 && !presets.includes(String(value))
                  ? value
                  : recommendedValue + 1,
              );
              return;
            }

            handleSetValue(Number(opt));
          }}
        />
      </Stack.Item>

      <Stack.Item shrink={0}>
        {serverData && value !== -1 && !presets.includes(value?.toString()) && (
          <NumberInput
            minValue={1}
            maxValue={serverData.maximum}
            step={1}
            value={value || recommendedValue}
            onChange={(v) => handleSetValue(v)}
          />
        )}
      </Stack.Item>
    </Stack>
  );
};

export const clientfps: Feature<number, number, FpsServerData> = {
  name: 'FPS',
  category: 'GAMEPLAY',
  component: FpsInput,
};
