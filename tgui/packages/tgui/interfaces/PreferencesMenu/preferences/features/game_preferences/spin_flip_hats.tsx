import { multiline } from 'common/string';
import { CheckboxInput, type FeatureToggle } from '../base';

export const spin_flip_hats: FeatureToggle = {
  name: 'Lose hat stacks when spinning or flipping',
  category: 'GAMEPLAY',
  description: multiline`
    When on, you will lose any stacked hats when you use the *spin or *flip emotes.
    When off, disables this behavior.
  `,
  component: CheckboxInput,
};
