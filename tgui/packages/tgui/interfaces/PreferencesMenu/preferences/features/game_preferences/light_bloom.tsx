import { type Feature, FeatureSliderInput } from '../base';

export const light_bloom: Feature<number> = {
  name: 'Light bloom strength',
  category: 'GAMEPLAY',
  description: 'How much very bright light brightens the floor around it. 0 turns it off.',
  component: FeatureSliderInput,
};
