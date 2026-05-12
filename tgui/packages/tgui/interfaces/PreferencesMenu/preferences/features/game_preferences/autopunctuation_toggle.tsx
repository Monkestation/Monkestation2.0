import { CheckboxInput, type FeatureToggle } from '../base';

export const autopunctuation: FeatureToggle = {
  name: 'Enable autopunctuation',
  category: 'CHAT',
  description: 'Toggle autopunctuation on/off (ex. at the end of messages)',
  component: CheckboxInput,
};
