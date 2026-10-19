import { useBackend } from '../backend';

import { Button, Section } from '../components';
import { Window } from '../layouts';

export const ArtifactForm = (props) => {
  const { act, data } = useBackend();
  const {
    allorigins,
    chosenorigin,
    allfaults,
    chosenfault,
    alltypes,
    chosentype,
    alltriggers,
    chosentriggers,
  } = data;
  return (
    <Window width={480} height={600} title={'Analysis Form'} theme={'paper'}>
      <Window.Content overflowY="auto">
        <Section title="Origin">
          {allorigins.map((key) => (
            <Button
              key={key}
              icon={chosenorigin === key ? 'check-square-o' : 'square-o'}
              content={key}
              selected={chosenorigin === key}
              textColor="black"
              onClick={() =>
                act('origin', {
                  origin: key,
                })
              }
            />
          ))}
        </Section>
        <Section title="Fault">
          {allfaults.map((thing) => (
            <Button
              key={thing}
              icon={chosenfault === thing ? 'check-square-o' : 'square-o'}
              content={thing}
              selected={chosenfault === thing}
              textColor="black"
              onClick={() =>
                act('fault', {
                  fault: thing,
                })
              }
            />
          ))}
        </Section>
        <Section title="Type">
          {alltypes.map((x) => (
            <Button
              key={x}
              icon={chosentype.includes(x) ? 'check-square-o' : 'square-o'}
              content={x}
              selected={chosentype.includes(x)}
              textColor="black"
              onClick={() =>
                act('type', {
                  type: x,
                })
              }
            />
          ))}
        </Section>
        <Section title="Triggers">
          {alltriggers.map((trig) => (
            <Button
              key={trig}
              icon={
                chosentriggers.includes(trig) ? 'check-square-o' : 'square-o'
              }
              content={trig}
              selected={chosentriggers.includes(trig)}
              textColor="black"
              onClick={() =>
                act('trigger', {
                  trigger: trig,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
