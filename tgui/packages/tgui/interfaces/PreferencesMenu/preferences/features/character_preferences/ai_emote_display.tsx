import {
  FeatureIconnedDropdownInput,
  FeatureValueProps,
  FeatureChoicedServerData,
  FeatureChoiced,
} from '../base';

export const preferred_ai_emote_display: FeatureChoiced = {
  name: 'AI Emote Display',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureIconnedDropdownInput buttons {...props} />;
  },
};
