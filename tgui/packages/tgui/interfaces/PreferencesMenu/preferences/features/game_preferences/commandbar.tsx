import { CheckboxInput, type FeatureToggle } from '../base';

export const commandbar_tab_autocomplete: FeatureToggle = {
  name: 'Use Tab to autocomplete',
  category: 'COMMAND BAR',
  description:
    'When disabled, Tab no longer autocompletes verbs in the command bar, but space still does',
  component: CheckboxInput,
};
