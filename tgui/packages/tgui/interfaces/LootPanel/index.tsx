import { SearchItem } from './types';
import { BooleanLike } from 'common/react';
import { Component } from 'inferno';
import { useBackend } from '../../backend';
import { clamp } from 'common/math';
import { Stack, Section, Button, Input } from '../../components';
import { Window } from '../../layouts';
import { GroupedContents } from './GroupedContents';
import { isEscape } from 'common/keys';
import { RawContents } from './RawContents';

type Data = {
  contents: SearchItem[];
  searching: BooleanLike;
};

type LootPanelState = {
  grouping: boolean;
  searchText: string;
  contentsByPathName: Record<string, SearchItem[]>;
};

export class LootPanel extends Component<{}, LootPanelState> {
  state = {
    grouping: true,
    searchText: '',
    contentsByPathName: {},
  };
  lastContents?: SearchItem[];

  componentDidMount() {
    this.populateContentsByPathName();
  }

  componentDidUpdate() {
    const { data } = useBackend<Data>();

    if (data.contents !== this.lastContents) {
      this.populateContentsByPathName();
    }
  }

  populateContentsByPathName() {
    const {
      data: { contents },
    } = useBackend<Data>();

    const acc: Record<string, SearchItem[]> = {};

    for (let i = 0; i < contents.length; i++) {
      const item = contents[i];
      if (item.path) {
        if (!acc[item.path + item.name]) {
          acc[item.path + item.name] = [];
        }
        acc[item.path + item.name].push(item);
      } else {
        acc[item.ref] = [item];
      }
    }
    this.lastContents = contents;
    this.setState({ contentsByPathName: acc });
  }

  render() {
    const { act, data } = useBackend<Data>();
    const { contents = [], searching } = data;
    const headerHeight = 38;
    const itemHeight = 38;
    const minHeight = headerHeight + itemHeight;
    const maxHeight = headerHeight + itemHeight * 10;
    const height: number = clamp(
      headerHeight +
        (!this.state.grouping
          ? contents.length
          : Object.keys(this.state.contentsByPathName).length) *
          itemHeight,
      minHeight,
      maxHeight,
    );

    return (
      <Window
        width={300}
        height={height}
        buttons={
          <Stack align="center">
            <Input
              onInput={(_, value) => this.setState({ searchText: value })}
              placeholder="Search items..."
              value={this.state.searchText}
            />
            <Button
              m={0}
              icon={this.state.grouping ? 'layer-group' : 'object-ungroup'}
              selected={this.state.grouping}
              onClick={() =>
                this.setState((prevState) => ({
                  grouping: !prevState.grouping,
                }))
              }
              tooltip="Toggle Grouping"
            />
            <Button
              icon="sync"
              onClick={() => act('refresh')}
              tooltip="Refresh"
            />
          </Stack>
        }
      >
        <Window.Content
          fitted
          scrollable={height === maxHeight}
          onKeyDown={(event) => {
            if (isEscape(event.key)) {
              Byond.sendMessage('close');
            }
          }}
        >
          <Section>
            {this.state.grouping ? (
              <GroupedContents
                contents={this.state.contentsByPathName}
                searchText={this.state.searchText}
              />
            ) : (
              <RawContents
                contents={contents}
                searchText={this.state.searchText}
              />
            )}
          </Section>
        </Window.Content>
      </Window>
    );
  }
}
