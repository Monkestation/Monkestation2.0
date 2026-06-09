import type { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  NumberInput,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';

type Data = {
  numberLootboxes: number;
  canWithdrawLootbox: BooleanLike;
  coins: number;
};

export const LootboxMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const { canWithdrawLootbox, numberLootboxes, coins } = data;
  const [lootboxamount, setLootboxAmount] = useLocalState(`lootboxamount`, 1);
  const [buyboxamount, setbuyboxAmount] = useLocalState(`buyboxamount`, 1);
  return (
    <Window title="Lootbox Menu" width={350} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Section
            title="Lootbox Mangement"
            fill
            buttons=<Button
              icon="eject"
              content="Withdraw Lootbox"
              tooltip="Withdraw a single lootbox to your mob's hands. Requires you be a mob, and be able to hold things."
              disabled={!canWithdrawLootbox}
              onClick={() => act('withdraw_lootbox')}
            />
          >
            <Box textAlign="center" fontSize="20px" bold>
              <Box textAlign="center" fontSize="15px" bold>
                Total Lootboxes
                <Divider />
              </Box>
              {numberLootboxes}
            </Box>
            <Section
              title="Purchase Options"
              fill
              buttons=<Button
                content={coins > 0 ? coins : '0'}
                icon="coins"
                tooltip="Your total Monkecoins"
              />
            >
              <Table>
                <Table.Row>
                  <Table.Cell>
                    <Button
                      content={
                        coins / 5000 > 1 ? 'Buy Lootboxes' : 'Buy Lootbox'
                      }
                      disabled={coins / 5000 < 1}
                      tooltip="Buy lootboxes! Costs 5000 monkecoins per lootbox."
                      position="center"
                      color="blue"
                      style={{
                        width: '100%',
                        textAlign: 'center',
                        fontSize: '20px',
                      }}
                      onClick={() =>
                        act('buyboxes', {
                          buyboxamount,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <NumberInput
                      value={buyboxamount}
                      step={1}
                      disabled={coins / 5000 < 1}
                      width="50px"
                      lineHeight="25px"
                      fontSize="20px"
                      minValue={1}
                      maxValue={Math.floor(coins / 5000)}
                      onChange={(value) => setbuyboxAmount(Math.round(value))}
                    />
                  </Table.Cell>
                </Table.Row>
                <Divider hidden />
                <Table.Row>
                  <Table.Cell>
                    <Button
                      content={
                        numberLootboxes > 1 ? 'Open Lootboxes' : 'Open Lootbox'
                      }
                      disabled={numberLootboxes < 1}
                      tooltip="Open Lootboxes!"
                      position="center"
                      color="green"
                      style={{
                        width: '100%',
                        textAlign: 'center',
                        fontSize: '20px',
                      }}
                      onClick={() =>
                        act('openboxes', {
                          lootboxamount,
                        })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <NumberInput
                      value={lootboxamount}
                      disabled={numberLootboxes < 1}
                      step={1}
                      width="50px"
                      lineHeight="25px"
                      fontSize="20px"
                      minValue={1}
                      maxValue={numberLootboxes}
                      onChange={(value) => setLootboxAmount(Math.round(value))}
                    />
                  </Table.Cell>
                </Table.Row>
                <Divider hidden />
                <Table.Row>
                  <Button
                    content="Open All Lootboxes"
                    tooltip=<b>
                      <i>Lets go gambling!!!</i>
                    </b>
                    position="center"
                    color="gold"
                    bold
                    style={{
                      width: '120%',
                      textAlign: 'center',
                      fontSize: '20px',
                    }}
                    onClick={() => act('open_all_boxes')}
                  />
                </Table.Row>
              </Table>
            </Section>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
