import { CheckboxInput, FeatureToggle } from '../base';

export const mapvote_hud: FeatureToggle = {
  name: 'Show votes as a HUD element',
  category: 'UI',
  description:
    'Show any new votes as a HUD element on the top-right section of the screen',
  component: CheckboxInput,
};
