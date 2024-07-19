import { useBackend } from '../backend';
import { Button } from '../components';
import { Window } from '../layouts';

export const BombActualizer = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={200} height={200}>
      <Window.Content>
        <BombActualizer />
      </Window.Content>
    </Window>
  );
};

export const BombActualizerContent = (props) => {
  const { act } = useBackend();
  const color = 'rgba(13, 13, 213, 0.7)';
  const backColor = 'rgba(0, 0, 69, 0.5)';
  return (
    <Button
      mb={-0.1}
      fluid
      icon="arrow-up"
      content="Start Countdown"
      textAlign="center"
      onClick={() => act('start_timer')}
    />
  );
};
