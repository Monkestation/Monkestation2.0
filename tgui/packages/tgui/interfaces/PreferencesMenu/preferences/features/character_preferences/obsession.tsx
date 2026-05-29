import { CheckboxInput, type FeatureToggle } from '../base';

export const obsession_target: FeatureToggle = {
  name: 'Obsession Target',
  description:
    'If checked, you will be eligible to become a target for an Obsession.',
  component: CheckboxInput,
};
