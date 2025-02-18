import {
  CheckboxInput,
  FeatureToggle,
  FeatureChoiced,
  FeatureDropdownInput,
} from '../../base';

export const hemiplegic_limbs_missing: FeatureToggle = {
  name: 'Hemiplegic Limbs Missing',
  component: CheckboxInput,
};

export const hemiplegic_side: FeatureChoiced = {
  name: 'Hemiplegic',
  component: FeatureDropdownInput,
};
