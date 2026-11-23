import { Button, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';

type Props = {
  /** Current layout state, which will be passed. */
  state: string;
  /** useState function that must be passed in order to make a toggle functional. */
  setState: (newState: string) => void;
};

export enum LAYOUT {
  Grid = 'grid',
  List = 'list',
}

export function getLayoutState() {
  const { config } = useBackend();
  return config.interface.layout;
}

export function LayoutToggle(props: Props) {
  const { setState, state } = props;
  const { act } = useBackend();

  const handleClick = () => {
    const newState = state === LAYOUT.Grid ? LAYOUT.List : LAYOUT.Grid;
    setState(newState);
    act('change_ui_state', {
      new_state: newState,
    });
  };

  return (
    <Stack.Item>
      <Button
        icon={state === LAYOUT.Grid ? 'list' : 'border-all'}
        tooltip={state === LAYOUT.Grid ? 'View as List' : 'View as Grid'}
        tooltipPosition={'bottom-end'}
        onClick={handleClick}
      />
    </Stack.Item>
  );
}
