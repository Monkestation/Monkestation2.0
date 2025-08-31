import { FeatureChoiced, FeatureDropdownInput } from '../base';

/* Limb Choice */
export const prosthetic: FeatureChoiced = {
  name: 'Prosthetic',
  component: FeatureDropdownInput,
};

export const monoplegic: FeatureChoiced = {
  name: 'Paralysed Limb',
  component: FeatureDropdownInput,
};

/* Hemiplegic Side */
export const hemiplegic_side: FeatureChoiced = {
  name: 'Paralysed Side',
  component: FeatureDropdownInput,
};
