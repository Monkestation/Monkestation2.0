import { Box } from '../../components';
import { createSearch } from 'common/string';

import { LootBox } from './LootBox';
import { SearchItem } from './types';

type Props = {
  contents: SearchItem[];
  searchText: string;
};

export const RawContents = (props: Props) => {
  const { contents, searchText } = props;

  const filteredContents = contents.filter(
    createSearch(searchText, (item: SearchItem) => item.name),
  );

  return (
    <Box m={-0.5}>
      {filteredContents.map((item) => (
        <LootBox key={item.ref} item={item} />
      ))}
    </Box>
  );
};
