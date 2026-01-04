import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Button, Image, Input, Section, Stack, Tooltip } from '../components';
import { NtosWindow } from '../layouts';
import { useState } from 'react';
import { createSearch } from 'tgui-core/string';

type Emoji = {
  name: string;
};

type Data = {
  emoji_list: Emoji[];
};

export function NtosEmojipedia(props) {
  const { data } = useBackend<Data>();
  const { emoji_list } = data;
  const [filter, updatefilter] = useState('');

  const search = createSearch<Emoji>(filter, (emoji) => emoji.name);
  const filteredEmojis = emoji_list.filter(search);

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section
          // required: follow semantic versioning every time you touch this file
          title={'Emojipedia V2.7.10' + (filter ? ` - ${filter}` : '')}
          buttons={
            <Stack>
              <Input
                placeholder="Search by name"
                value={filter}
                onChange={(_, value) => updatefilter(value)}
              />
              <Button
                tooltip="Click on an emoji to copy its tag!"
                tooltipPosition="bottom"
                icon="circle-question"
              />
            </Stack>
          }
        >
          {filteredEmojis.map((emoji) => (
            <Tooltip content={emoji.name} key={emoji.name}>
              <Image
                key={emoji.name}
                className={classes(['emojipedia16x16', emoji.name])}
                as="img"
                m={0}
                onClick={() => {
                  copyText(emoji.name);
                }}
              />
            </Tooltip>
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function copyText(text: string): void {
  const input = document.createElement('input');
  input.value = text;
  document.body.appendChild(input);
  input.select();
  document.execCommand('copy');
  document.body.removeChild(input);
}
