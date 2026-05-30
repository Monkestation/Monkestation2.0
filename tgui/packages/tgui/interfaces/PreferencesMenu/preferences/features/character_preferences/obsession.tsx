import { CheckboxInput, type FeatureToggle } from '../base';

export const obsession_target: FeatureToggle = {
  name: 'Obsession Target',
  description:
    'If unchecked, you will be less likely to become a target for an Obsession.',
  component: CheckboxInput,
};
