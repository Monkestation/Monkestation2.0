import type { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from '../components';
import { Window } from '../layouts';

type DispensableReagent = {
  title: string;
  id: string;
  pH: number;
  color: string;
  pHCol: string;
};

type TransferableBeaker = Beaker & {
  transferAmounts: number[];
};

type Data = {
  showpH: BooleanLike;
  amount: number;
  energy: number;
  maxEnergy: number;
  displayedUnits: string;
  displayedMaxUnits: string;
  chemicals: DispensableReagent[];
  recipes: string[];
  recordingRecipe: string[];
  recipeReagents: string[];
  beaker: TransferableBeaker;
};

export type BeakerReagent = {
  name: string;
  volume: number;
};

export type Beaker = {
  maxVolume: number;
  pH: number;
  currentVolume: number;
  contents: BeakerReagent[];
};

type BeakerProps = {
  beaker: Beaker;
  replace_contents?: BeakerReagent[];
  title_label?: string;
  showpH?: BooleanLike;
};

export const ChemDebugSynthesizer = (props: BeakerProps) => {
  const { act, data } = useBackend<Data>();
  const { beaker, replace_contents, title_label, showpH } = data;
  const beakerContents = replace_contents || beaker?.contents || [];

  return (
    <Window width={390} height={330}>
      <Window.Content scrollable>
        <Section
          title="Recipient"
          buttons={
            beaker ? (
              <>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('ejectBeaker')}
                />
                <NumberInput
                  value={data.amount}
                  unit="u"
                  minValue={1}
                  maxValue={beaker.maxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <Button
                  icon="plus"
                  content="Input"
                  onClick={() => act('input')}
                />
              </>
            ) : (
              <Button
                icon="plus"
                content="Create Beaker"
                onClick={() => act('makecup')}
              />
            )
          }
        >
          {beaker ? (
            <>
              <Box>
                <AnimatedNumber value={beaker.maxVolume} />
                {` / ${beaker.maxVolume} u`}
              </Box>
              {beakerContents.length > 0 ? (
                <LabeledList>
                  {beakerContents.map((chem) => (
                    <LabeledList.Item key={chem.name} label={chem.name}>
                      {chem.volume} u
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              ) : (
                <Box color="bad">Recipient Empty</Box>
              )}
            </>
          ) : (
            <Box color="average">No Recipient</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
