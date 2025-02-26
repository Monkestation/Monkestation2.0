import {
  CheckboxInput,
  FeatureToggle,
  FeatureChoiced,
  FeatureDropdownInput,
} from '../../base';

/* Limb Choice */
export const prosthetic: FeatureChoiced = {
  name: 'Prosthetic',
  component: FeatureDropdownInput,
};

export const monoplegic: FeatureChoiced = {
  name: 'Paralysed Limb',
  component: FeatureDropdownInput,
};

/* Missing */

export const prosthetic_missing: FeatureToggle = {
  name: 'Prosthetic Missing',
  component: CheckboxInput,
};

export const monoplegic_missing: FeatureToggle = {
  name: 'Paralysed Limb Missing',
  component: CheckboxInput,
};

export const hemiplegic_limbs_missing: FeatureToggle = {
  name: 'Paralysed Limbs Missing',
  component: CheckboxInput,
};

export const paraplegic_limbs_missing: FeatureToggle = {
  name: 'Paralysed Limbs Missing',
  component: CheckboxInput,
};

/* Hemiplegic Side */

export const hemiplegic_side: FeatureChoiced = {
  name: 'Paralysed Side',
  component: FeatureDropdownInput,
};
