import { BooleanLike } from 'common/react';
import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import {
  Dimmer,
  Stack,
  Divider,
  Section,
  Button,
  TextArea,
  Box,
} from '../components';

type Data = {
  rating: number;
  comment: string;
  max_length: number;
  is_centcom: BooleanLike;
};

export const NtosNtRep = (props) => {
  return (
    <NtosWindow width={400} height={425}>
      <NtosWindow.Content>
        <NtosNtRepContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
export const NtosNtRepContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { rating, comment, max_length, is_centcom } = data;

  const RatingFeedback = (value) => {
    switch (rating) {
      case 1:
        return 'Disastrous';
      case 2:
        return 'Subpar';
      case 3:
        return 'Mediocre';
      case 4:
        return 'Acceptable';
      case 5:
        return 'Satisfactory';
      default:
        return 'None';
    }
  };
  const StarColor = (value) => {
    switch (rating) {
      case 1:
        return 'crimson';
      case 2:
        return 'red';
      case 3:
        return 'orange';
      case 4:
        return 'yellow';
      case 5:
        return 'green';
      default:
        return 'None';
    }
  };
  return (
    <Stack vertical fill>
      {!is_centcom && (
        <Dimmer>
          <Box
            color="red"
            fontFamily={'Bahnschrift'}
            fontSize={3}
            textAlign="center"
            my={1}
          >
            Non-Centcom ID detected.
          </Box>
        </Dimmer>
      )}
      <Section title="Rating">
        <Box fontSize={1.1}>
          How much would you recommend this station to a Central Command member?
        </Box>
        <Divider />
        <Button
          icon={rating >= 1 ? 'fa-solid fa-star' : 'fa-regular fa-star'}
          color={StarColor(rating)}
          onClick={() => act('change_rating', { new_rating: 1 })}
        />
        <Button
          icon={rating >= 2 ? 'fa-solid fa-star' : 'fa-regular fa-star'}
          color={StarColor(rating)}
          onClick={() => act('change_rating', { new_rating: 2 })}
        />
        <Button
          icon={rating >= 3 ? 'fa-solid fa-star' : 'fa-regular fa-star'}
          color={StarColor(rating)}
          onClick={() => act('change_rating', { new_rating: 3 })}
        />
        <Button
          icon={rating >= 4 ? 'fa-solid fa-star' : 'fa-regular fa-star'}
          color={StarColor(rating)}
          onClick={() => act('change_rating', { new_rating: 4 })}
        />
        <Button
          icon={rating >= 5 ? 'fa-solid fa-star' : 'fa-regular fa-star'}
          color={StarColor(rating)}
          onClick={() => act('change_rating', { new_rating: 5 })}
        />
        {'  ' + RatingFeedback(rating)}
      </Section>

      <Section title="Review" fill>
        <Stack direction="column" align="stretch" fill>
          <Stack.Item mb={1} grow>
            <TextArea
              scrollbar
              height="100%"
              placeholder="Leave your review/thoughts/comments..."
              maxLength={max_length}
              value={comment}
              onChange={(e, value) =>
                act('set_text', {
                  new_review: value,
                })
              }
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Stack>
  );
};
