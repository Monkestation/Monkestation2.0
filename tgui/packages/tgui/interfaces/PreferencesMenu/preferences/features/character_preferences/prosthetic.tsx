import {
  CheckboxInput,
  FeatureChoiced,
  FeatureDropdownInput,
  FeatureToggle,
} from '../base';

export const prosthetic: FeatureChoiced = {
  name: 'Prosthetic',
  component: FeatureDropdownInput,
};

export const prosthetic_missing: FeatureToggle = {
  name: 'Prosthetic Missing',
  component: CheckboxInput,
};
