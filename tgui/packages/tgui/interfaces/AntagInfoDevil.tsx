import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivePrintout, Objective } from './common/Objectives';

type Info = {
  antag_name: string;
  true_name: string;
  objectives: Objective[];
};

export const AntagInfoDevil = (props) => {
  const { data } = useBackend<Info>();
  const { antag_name, true_name, objectives } = data;
  return (
    <Window width={560} height={350} theme="syndicate">
      <Window.Content style={{ backgroundImage: 'none' }}>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="20px">
              You are the {antag_name}!
            </Stack.Item>
            <Stack.Item>
              Your true name is: {true_name}, others yelling it outloud will
              stun you alongside dealing mediocre damage to you. <br />
              it will be written on contracts you sign so be carefull.
              <br />
              <br />
            </Stack.Item>
            <Stack.Item>
              You start with the following abilities:
              <br />
              - Devilish revival: On a cooldown of 5 minutes, you can fully
              revive.
              <br />
              - Demonic Phase Shift: On a cooldown of 1 minute, you can go
              incorporeal for 5 seconds, use may be stopped by holy magic.
              <br />
              - Summon devilish contract: Summons a contract, you can edit its
              clauses with a pen before a person signs it. Making these and
              handing them out is your primary objective, use may be stopped by
              holy magic.
              <br />
              After someone signs it, you will have to sign it yourself for the
              contract to take effect.
              <br />
              <br />
            </Stack.Item>
            <Stack.Item>
              <ObjectivePrintout objectives={objectives} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
