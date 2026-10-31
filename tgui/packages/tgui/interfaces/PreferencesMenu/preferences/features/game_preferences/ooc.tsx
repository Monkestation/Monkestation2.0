import {
  CheckboxInput,
  type Feature,
  FeatureColorInput,
  FeatureShortTextInput,
  type FeatureToggle,
} from '../base';

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
    'Pronouns to show in OOC when someone hovers over your username, Separated by forward slashes. Most common pronouns and neopronouns are accepted with a max of 4 (Staff can add custom text after pronouns, but please use it in good faith). Example: "she/it/fae"',
  component: FeatureShortTextInput,
};

export const twitch_public: FeatureToggle = {
  name: 'Publicize Twitch membership',
  category: 'CHAT',
  description:
    'When enabled, a Twitch logo will be shown next to your name in OOC.',
  component: CheckboxInput,
};

export const patreon_public: FeatureToggle = {
  name: 'Publicize Patreon membership',
  category: 'CHAT',
  description:
    'When enabled, a Patreon logo will be shown next to your name in OOC.',
  component: CheckboxInput,
};
