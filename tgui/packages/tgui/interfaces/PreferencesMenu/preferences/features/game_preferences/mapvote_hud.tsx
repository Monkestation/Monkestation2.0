import { CheckboxInput, FeatureToggle } from '../base';

export const mapvote_hud: FeatureToggle = {
  name: 'Show votes as a HUD element',
  category: 'UI',
  description:
    'Show any new votes as a HUD element on the top-right section of the screen',
  component: CheckboxInput,
};

export const mapvote_autoclose: FeatureToggle = {
  name: 'Automatically close voting HUD after voting',
  category: 'UI',
  description:
    'Automatically close the voting HUD element after you select a choice.',
  component: CheckboxInput,
};
