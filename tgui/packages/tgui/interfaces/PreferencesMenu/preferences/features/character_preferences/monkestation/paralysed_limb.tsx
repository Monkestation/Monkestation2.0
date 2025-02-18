import {
  CheckboxInput,
  FeatureChoiced,
  FeatureDropdownInput,
  FeatureToggle,
} from '../../base';

export const paralysed_limb: FeatureChoiced = {
  name: 'Paralysed Limb',
  component: FeatureDropdownInput,
};
export const paralysed_limb_missing: FeatureToggle = {
  name: 'Paralysed Limb Missing',
  component: CheckboxInput,
};
