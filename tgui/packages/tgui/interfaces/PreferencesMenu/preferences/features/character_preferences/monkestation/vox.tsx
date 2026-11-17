import { sortBy } from 'common/collections';
import {
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureColorInput,
  FeatureDropdownInput,
  type FeatureValueProps,
  type HexValue,
  StandardizedPalette,
} from '../../base';

type VoxSkinToneServerData = FeatureChoicedServerData & {
  display_names: NonNullable<FeatureChoicedServerData['display_names']>;
  to_hex: Record<string, HexValue>;
};

const sortHexValues = sortBy<[string, HexValue]>(
  ([_, hexValue]) => -hexValue.lightness,
);

export const feature_vox_skin_tone: Feature<
  string,
  string,
  VoxSkinToneServerData
> = {
  name: 'Skin Tone',
  component: (
    props: FeatureValueProps<string, string, VoxSkinToneServerData>,
  ) => {
    const { handleSetValue, serverData, value } = props;

    if (!serverData) {
      return null;
    }

    return (
      <StandardizedPalette
        choices={sortHexValues(Object.entries(serverData.to_hex)).map(
          ([key]) => key,
        )}
        choices_to_hex={Object.fromEntries(
          Object.entries(serverData.to_hex).map(([key, hex]) => [
            key,
            hex.value,
          ]),
        )}
        displayNames={serverData.display_names}
        onSetValue={handleSetValue}
        value={value}
      />
    );
  },
};

export const feature_vox_quills: FeatureChoiced = {
  name: 'Quillstyle',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_vox_quills_color: Feature<string> = {
  name: 'Quill Color',
  small_supplemental: true,
  description: "The color of your character's quills.",
  component: FeatureColorInput,
};

export const feature_vox_facial_quills: FeatureChoiced = {
  name: 'Facial Quillstyle',
  small_supplemental: false,
  component: FeatureDropdownInput,
};

export const feature_vox_facial_quills_color: Feature<string> = {
  name: 'Facial Quill Color',
  small_supplemental: true,
  description: "The color of your character's facial quills.",
  component: FeatureColorInput,
};

export const feature_vox_body_markings: FeatureChoiced = {
  name: 'Body Markings',
  component: FeatureDropdownInput,
};

export const feature_vox_body_markings_color: Feature<string> = {
  name: 'Body Markings Color',
  component: FeatureColorInput,
};

export const feature_vox_tail_markings: FeatureChoiced = {
  name: 'Tail Markings',
  component: FeatureDropdownInput,
};

export const feature_vox_tail_markings_color: Feature<string> = {
  name: 'Tail Markings Color',
  component: FeatureColorInput,
};

export const feature_quill_gradientstyle: FeatureChoiced = {
  name: 'Quill Gradient',
  component: FeatureDropdownInput,
};

export const feature_quill_gradientcolor: Feature<string> = {
  name: 'Quill Gradient Color',
  component: FeatureColorInput,
};

export const feature_vox_tank_type: FeatureChoiced = {
  name: 'N² Tank',
  description: 'The nitrogen tank your character starts the shift with.',
  component: FeatureDropdownInput,
};

export const feature_vox_mask: FeatureChoiced = {
  name: 'Mask',
  description: 'The breath mask your character starts the shift with.',
  component: FeatureDropdownInput,
};
