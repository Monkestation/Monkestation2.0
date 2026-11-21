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

type Beaker = {
  maxVolume: number;
  currentVolume: number;
  contents: { name: string; volume: number }[];
};

type Data = {
  amount: number;
  purity: number;
  beaker: Beaker | null;
};

export const ChemDebugSynthesizer = (props) => {
  const { act, data } = useBackend<Data>();
  const { amount, purity, beaker } = data;
  const isBeakerLoaded = !!beaker;
  const beakerCurrentVolume = beaker?.currentVolume || 0;
  const beakerMaxVolume = beaker?.maxVolume || 0;
  const beakerContents = beaker?.contents || [];

  return (
    <Window width={520} height={330}>
      <Window.Content scrollable>
        <Section
          title="Recipient"
          buttons={
            isBeakerLoaded ? (
              <>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('ejectBeaker')}
                />
                <NumberInput
                  value={amount}
                  unit="u"
                  minValue={1}
                  maxValue={beakerMaxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={purity}
                  unit="%"
                  minValue={0}
                  maxValue={120}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('purity', {
                      amount: value,
                    })
                  }
                />
                <Button
                  icon="plus"
                  content="Input"
                  onClick={() => act('input')}
                />
                <Button
                  icon="search"
                  content="Search Reagent"
                  onClick={() => act('search')}
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
          {isBeakerLoaded ? (
            <>
              <Box>
                <AnimatedNumber value={beakerCurrentVolume} />
                {` / ${beakerMaxVolume} u`}
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
