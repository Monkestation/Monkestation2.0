import type { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Dropdown, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  voices: string[];
  say_verb: string;
  loud: BooleanLike;
  name: string;
  selected: string;
};

export const AiVoiceChanger = (props) => {
  const { act, data } = useBackend<Data>();
  const { loud, name, on, say_verb, voices, selected } = data;

  return (
    <Window title="Voice changer settings" width={400} height={200}>
      <Section fill>
        <LabeledList>
          <LabeledList.Item label="Power">
            <Button
              icon={on ? 'power-off' : 'times'}
              content={on ? 'On' : 'Off'}
              selected={on}
              onClick={() => act('power')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Accent">
            <Dropdown
              selected={selected}
              options={voices}
              onSelected={(value) =>
                act('look', {
                  look: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Verb">
            <Input
              placeholder={say_verb}
              onChange={(value) =>
                act('verb', {
                  verb: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Volume">
            <Button
              icon={loud ? 'power-off' : 'times'}
              content={loud ? 'Loudmode on' : 'Loudmode Off'}
              selected={loud}
              onClick={() => act('loud')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Fake name">
            <Input
              placeholder={name}
              onChange={(value) =>
                act('name', {
                  name: value,
                })
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Window>
  );
};
