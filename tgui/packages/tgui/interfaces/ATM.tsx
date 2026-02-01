import type { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type ATMData = {
  flash_sale_present: BooleanLike;
  flash_sale_name?: string;
  flash_sale_desc?: string;
  flash_sale_cost: number;
  meta_balance: number;
  cash_balance: number;
  lottery_pool: number;
};
export const ATM = () => {
  const { act, data } = useBackend<ATMData>();

  const {
    flash_sale_present,
    flash_sale_name,
    flash_sale_desc,
    flash_sale_cost,
    meta_balance,
    cash_balance,
    lottery_pool,
  } = data;

  return (
    <Window
      title="Automated Teller Machine"
      width={360}
      height={flash_sale_present ? 500 : 420}
    >
      <Window.Content>
        <Stack vertical fill>
          <Section title="Account Overview">
            <Stack vertical>
              <Box textAlign="center" fontSize="20px" bold>
                ${cash_balance}
              </Box>

              <Stack justify="space-between">
                <Box>
                  <Icon name="coins" mr={1} />
                  Monkecoins
                </Box>
                <Box bold>{meta_balance}</Box>
              </Stack>

              <Stack justify="space-between">
                <Box>
                  <Icon name="ticket" mr={1} />
                  Lottery Pool
                </Box>
                <Box>{lottery_pool}</Box>
              </Stack>
            </Stack>
          </Section>

          <Section title="Transactions">
            <Stack vertical>
              <Button fluid icon="arrow-down" onClick={() => act('withdraw')}>
                Withdraw Monkecoins
              </Button>

              <Button
                fluid
                icon="money-bill"
                onClick={() => act('withdraw_cash')}
              >
                Withdraw Cash
              </Button>

              <Button fluid icon="ticket" onClick={() => act('lottery_buy')}>
                Buy Lottery Tickets
              </Button>

              <Button fluid icon="gift" onClick={() => act('buy_lootbox')}>
                Purchase Lootbox
              </Button>
            </Stack>
          </Section>

          {!!flash_sale_present && (
            <Section title="Limited-Time Offer" color="yellow">
              <Stack vertical>
                <Box bold color="yellow">
                  {flash_sale_name}
                </Box>

                <Box italic>{flash_sale_desc}</Box>

                <Box>
                  Price: <b>{flash_sale_cost}</b> <Icon name="coins" />
                </Box>

                <Button
                  color="yellow"
                  icon="bolt"
                  onClick={() => act('buy_flash')}
                >
                  Buy Now
                </Button>
              </Stack>
            </Section>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
