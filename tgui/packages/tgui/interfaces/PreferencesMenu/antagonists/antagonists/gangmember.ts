import { multiline } from 'common/string';
import { Antagonist, Category } from '../base';

const GangMember: Antagonist = {
  key: 'gangmember',
  name: 'Syndicate Gang Member',
  description: [
    multiline`A Syndicate Gang Boss who can convert the members of the crew to
    their side to fight against the other gangs. Tag areas and get paid.`,
    multiline`Have more reputation then any other gang at the end of the shift
    in order to prove yourself to syndicate command.`,
  ],
  category: Category.Roundstart,
};

export default GangMember;
