import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const damageTypes = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Oxygen',
    type: 'oxyLoss',
  },
];

export const Sleeper = (props) => {
  const { act, data } = useBackend();
  const {
    open,
    occupant = {},
    occupied,
    inject_amount,
    available_amounts,
  } = data;
  const chems = data.chems || [];

  return (
    <Window width={560} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {/* The upper half: Patient и Blood Chemicals */}
          <Stack.Item grow={1}>
            <Stack fill>
              <Stack.Item basis="50%">
                <Section
                  title={occupant.name ? occupant.name : 'No Occupant'}
                  fill
                  buttons={
                    !!occupant.stat && (
                      <Box inline bold color={occupant.statstate}>
                        {occupant.stat}
                      </Box>
                    )
                  }
                >
                  {!!occupied && (
                    <>
                      <ProgressBar
                        value={occupant.health}
                        minValue={occupant.minHealth}
                        maxValue={occupant.maxHealth}
                        ranges={{
                          good: [50, Infinity],
                          average: [0, 50],
                          bad: [-Infinity, 0],
                        }}
                      />
                      <Box mt={1} />
                      <LabeledList>
                        {damageTypes.map((type) => {
                          const damageValue = occupant[type.type];
                          return (
                            <LabeledList.Item
                              key={type.type}
                              label={type.label}
                            >
                              <ProgressBar
                                value={damageValue}
                                minValue={0}
                                maxValue={occupant.maxHealth}
                                ranges={{
                                  good: [-Infinity, 50],
                                  average: [50, 100],
                                  bad: [100, Infinity],
                                }}
                              />
                            </LabeledList.Item>
                          );
                        })}
                        <LabeledList.Item
                          label="Cells"
                          color={occupant.cloneLoss ? 'bad' : 'good'}
                        >
                          {occupant.cloneLoss ? 'Damaged' : 'Healthy'}
                        </LabeledList.Item>
                        <LabeledList.Item
                          label="Brain"
                          color={occupant.brainLoss ? 'bad' : 'good'}
                        >
                          {occupant.brainLoss ? 'Abnormal' : 'Healthy'}
                        </LabeledList.Item>

                        <LabeledList.Item label="Blood Volume">
                          <ProgressBar
                            value={occupant.blood_volume || 0}
                            minValue={0}
                            maxValue={560}
                            ranges={{
                              good: [448, 560],
                              average: [280, 448],
                              bad: [0, 280],
                            }}
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    </>
                  )}
                </Section>
              </Stack.Item>
              <Stack.Item basis="50%">
                <Section title="Blood Chemicals" fill>
                  {!occupied ? (
                    <Box color="grey" textAlign="center" mt={2}>
                      No occupant
                    </Box>
                  ) : !occupant.blood_chems ||
                    occupant.blood_chems.length === 0 ? (
                    <Box color="grey" textAlign="center" mt={2}>
                      No chemicals detected in blood
                    </Box>
                  ) : (
                    <Box>
                      {occupant.blood_chems.map((chem, index) => (
                        <Box key={index} mb={1}>
                          <Box color={chem.overdosed ? 'bad' : 'good'}>
                            {Math.round(chem.volume * 10) / 10} units of{' '}
                            {chem.name}
                            {chem.overdosed ? ' - OVERDOSING' : ''}
                          </Box>
                        </Box>
                      ))}
                    </Box>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {/* The lower half - Medicines */}
          <Stack.Item>
            <Section
              title="Medicines"
              buttons={
                <Button
                  icon={open ? 'door-open' : 'door-closed'}
                  content={open ? 'Open' : 'Closed'}
                  onClick={() => act('door')}
                />
              }
            >
              {/* Chem amount */}
              <Box mb={2}>
                <Box mb={1} fontSize="12px" color="label">
                  Injection Amount:
                </Box>
                <Stack spacing={1}>
                  {available_amounts?.map((amount) => (
                    <Stack.Item key={amount}>
                      <Button
                        content={`${amount} units`}
                        selected={inject_amount === amount}
                        color={inject_amount === amount ? 'green' : 'default'}
                        onClick={() => act('set_amount', { amount: amount })}
                      />
                    </Stack.Item>
                  ))}
                </Stack>
              </Box>

              {/* Medicine Buttons */}
              <Box display="flex" flexWrap="wrap" gap="4px">
                {chems.map((chem) => (
                  <Tooltip
                    key={chem.name}
                    content={
                      <Box backgroundColor="#1a1a1a" p={1}>
                        <Box color="green" bold>
                          {chem.full_name}
                        </Box>
                        <Box color="label" mt={0.5}>
                          {chem.description}
                        </Box>
                      </Box>
                    }
                    position="top"
                  >
                    <Button
                      icon="flask"
                      content={chem.name}
                      disabled={!occupied || !chem.allowed}
                      width="130px"
                      onClick={() =>
                        act('inject', {
                          chem: chem.id,
                        })
                      }
                    />
                  </Tooltip>
                ))}
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
