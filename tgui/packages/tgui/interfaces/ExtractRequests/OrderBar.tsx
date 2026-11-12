import {
  Box,
  Button,
  Icon,
  Input,
  RestrictedInput,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { REASON_LENGTH } from './types';

type Props = {
  name: string;
  /** Null when there's no ID to order with. */
  balance: number | null;
  count: number;
  reason: string;
  offer: number;
  onCount: (count: number) => void;
  onReason: (reason: string) => void;
  onOffer: (offer: number) => void;
  onSubmit: () => void;
};

export function OrderBar(props: Props) {
  const {
    name,
    balance,
    count,
    reason,
    offer,
    onCount,
    onReason,
    onOffer,
    onSubmit,
  } = props;
  const over = balance !== null && offer > balance;

  return (
    <Box className="ExtractRequests__order">
      <Box className="ExtractRequests__stepper">
        <Button
          circular
          icon="minus"
          disabled={count <= 1}
          onClick={() => onCount(count - 1)}
        />
        <Box className="ExtractRequests__count-value">{count}</Box>
        <Button
          circular
          icon="plus"
          disabled={count >= 5}
          onClick={() => onCount(count + 1)}
        />
      </Box>
      <Box className="ExtractRequests__field">
        Reason
        <Input
          fluid
          className="ExtractRequests__input"
          maxLength={REASON_LENGTH}
          value={reason}
          placeholder="What's it for?"
          onChange={onReason}
        />
      </Box>
      <Box
        className={classes([
          'ExtractRequests__pay',
          over && 'ExtractRequests__pay--over',
        ])}
      >
        <Icon name="coins" />
        <RestrictedInput
          minValue={0}
          maxValue={99999}
          value={offer}
          onChange={onOffer}
        />
        cr
      </Box>
      <Button
        className="ExtractRequests__button"
        icon="paper-plane"
        disabled={balance === null || over}
        tooltip={over ? `You have ${balance} cr` : undefined}
        onClick={onSubmit}
      >
        Request {count}x {name}
      </Button>
    </Box>
  );
}
