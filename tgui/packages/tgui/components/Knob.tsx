import { ComponentProps } from 'react';
import { Knob as TGUIKnob } from 'tgui-core/components';

type Shim = Omit<ComponentProps<typeof TGUIKnob>, 'onDrag'> & {
  onDrag: (event: Event, value: number) => void;
};

export function Knob(props: Shim) {
  return (
    <TGUIKnob
      {...props}
      onDrag={undefined}
      onChange={(event, val) => {
        props.onDrag?.(event, val);
      }}
    />
  );
}
