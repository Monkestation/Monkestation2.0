import { FeatureColorInput, Feature, FeatureShortTextInput } from '../base';

export const ooccolor: Feature<string> = {
  name: 'OOC color',
  category: 'CHAT',
  description: 'The color of your OOC messages.',
  component: FeatureColorInput,
};

export const oocpronouns: Feature<string> = {
  name: 'OOC pronouns',
  category: 'CHAT',
  description:
    'Pronouns to show in OOC when someone hovers over your username, Separated by forward slashes. Most common pronouns and neopronouns are accepted with a max of 4 (Staff are exempt from limits but please use it in good faith). Example: "she/it/fae"',
  component: FeatureShortTextInput,
};
