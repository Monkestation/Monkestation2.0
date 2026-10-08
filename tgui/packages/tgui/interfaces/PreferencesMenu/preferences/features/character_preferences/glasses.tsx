import {
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureIconnedDropdownInput,
  type FeatureValueProps,
} from '../base';

export const glasses: FeatureChoiced = {
  name: 'Glasses',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureIconnedDropdownInput buttons {...props} />;
  },
};
