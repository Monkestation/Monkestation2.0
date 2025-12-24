import { ComponentProps } from 'react';
import { Slider as TGUISlider } from 'tgui-core/components';

type Shim = Omit<ComponentProps<typeof TGUISlider>, 'onDrag'> &
  Partial<{
    onChange: (event: Event, value: number) => void;
    onDrag: (event: Event, value: number) => void;
  }>;

export function Slider(props: Shim) {
  return (
    <TGUISlider
      {...props}
      onDrag={undefined}
      onChange={(event, val) => {
        props.onChange?.(event, val);
      }}
    />
  );
}
