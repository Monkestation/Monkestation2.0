import { Box } from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import { LootBox } from './LootBox';
import type { SearchItem } from './types';

type Props = {
  contents: Record<string, SearchItem[]>;
  searchText: string;
};

export function GroupedContents(props: Props) {
  const { contents, searchText } = props;

  const filteredContents = Object.entries(contents).filter(
    createSearch(searchText, ([_, items]) => items[0].name),
  );

  return (
    <Box m={-0.5}>
      {filteredContents.map(([key, items]) => (
        <LootBox key={key} group={{ amount: items.length, item: items[0] }} />
      ))}
    </Box>
  );
}
