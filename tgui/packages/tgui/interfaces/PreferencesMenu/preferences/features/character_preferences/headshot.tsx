import { type Feature, FeatureShortTextInput } from '../base';

export const headshot: Feature<string> = {
  name: 'Character Artwork',
  description:
    'Paste a direct HTTPS image link from Catbox/Imgbox/Gyazo/Lensdump Supported formats: JPG, PNG, and JPEG',
  component: FeatureShortTextInput,
};
