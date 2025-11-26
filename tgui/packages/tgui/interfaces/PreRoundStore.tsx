import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Divider,
  Flex,
  Stack,
  Section,
  Icon,
  DmIcon,
} from '../components';
import { Window } from '../layouts';
import { LobbyNotices, LobbyNoticesType } from './common/LobbyNotices';

type Item = {
  path: string;
  name: string;
  cost: number;
  icon: string;
  icon_state: string;
};

type Data = {
  notices: LobbyNoticesType;
  currently_owned?: string;
  balance: number;
  items: Item[];
};

const ItemListEntry = (props) => {
  const {
    product: { name, cost, icon, icon_state },
    disabled,
    onClick,
  } = props;

  return (
    <>
      <Flex direction="row" align="center">
        <Flex.Item>
          <DmIcon
            icon={icon}
            icon_state={icon_state}
            fallback={<Icon mr={1} name="spinner" spin />}
            height={'32px'}
            width={'32px'}
            verticalAlign="middle"
          />
        </Flex.Item>
        <Flex.Item grow={1}>
          <Box bold>{name}</Box>
        </Flex.Item>
        <Flex.Item>
          {`Cost: ${cost}`} <Icon name="coins" pr={1} />
        </Flex.Item>
        <Flex.Item>
          <Button onClick={onClick} disabled={disabled}>
            Buy
          </Button>
        </Flex.Item>
      </Flex>
      <Divider />
    </>
  );
};

export const PreRoundStore = (_props) => {
  const {
    act,
    data: { notices, balance, items, currently_owned },
  } = useBackend<Data>();

  return (
    <Window resizable title="Pre Round Shop" width={450} height={700}>
      <Window.Content scrollable>
        <Section>
          <LobbyNotices notices={notices} />
          <BlockQuote>
            Purchase an item that will spawn with you round start!
          </BlockQuote>
          <Stack vertical fill>
            {currently_owned ? (
              <Stack.Item>
                <Box>Held Item: {currently_owned}</Box>
              </Stack.Item>
            ) : (
              ''
            )}
            <Stack.Item>
              <Section>
                <Flex direction="row" align="center">
                  <Box>
                    Balance: {balance} <Icon name="coins" />
                  </Box>
                </Flex>
              </Section>
            </Stack.Item>
            <Stack.Item>
              {items.map((purchase) => {
                const { name, cost, path } = purchase;
                return (
                  <ItemListEntry
                    key={name}
                    product={purchase}
                    disabled={balance < cost}
                    onClick={() => act('attempt_buy', { path })}
                  />
                );
              })}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
