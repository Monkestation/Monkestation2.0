import { multiline } from 'common/string';
import { type Antagonist, Category } from '../base';

const ClockCultist: Antagonist = {
  key: 'clockcultist',
  name: 'Clock Cultist',
  description: [
    multiline`
      You are one of the last remaining servants of
      Ratvar, The Clockwork Justicar.
      After a long and destructive war, Ratvar was imprisoned
      inside a dimension of suffering.
      You must free him by protecting The Ark so that his light may
      shine again.
    `,

    multiline`
      Gather power by putting Integration Cogs inside APCs
      and fortify Reebe and The Ark aganist the crew's assault
      long enough for it to open.
    `,
  ],
  category: Category.Roundstart,
};

export default ClockCultist;
