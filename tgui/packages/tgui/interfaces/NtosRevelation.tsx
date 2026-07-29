import { Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  filedesc: string;
  armed: BooleanLike;
};

export const NtosRevelation = () => {
  const { act, data } = useBackend<Data>();
  const { filedesc, armed } = data;

  return (
    <NtosWindow width={400} height={180}>
      <NtosWindow.Content>
        <Section>
          <Button.Input
            fluid
            value={filedesc}
            buttonText="Set Program Name..."
            onCommit={(value) =>
              act('PRG_obfuscate', {
                new_name: value,
              })
            }
            mb={1}
          />
          <LabeledList>
            <LabeledList.Item
              label="Payload Status"
              buttons={
                <Button
                  color={armed ? 'bad' : 'average'}
                  onClick={() => act('PRG_arm')}
                >{armed ? 'ARMED' : 'DISARMED'}</Button>
              }
            />
          </LabeledList>
          <Button.Confirm
            fluid
            my={1}
            bold
            tooltip="This will set off the bomb without needing to re-open the app"
            textAlign="center"
            color="bad"
            disabled={!armed}
            confirmColor="good"
            onClick={() => act('PRG_activate')}>
              ACTIVATE
          </Button.Confirm>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
