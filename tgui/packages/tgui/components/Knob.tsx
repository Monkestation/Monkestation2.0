import { ComponentProps } from 'react';
import { Knob as TGUIKnob } from 'tgui-core/components';

type Shim = Omit<ComponentProps<typeof TGUIKnob>, 'onDrag'> & {
  onDrag: (event: Event, value: number) => void;
};

export function Knob(props: Shim) {
  const inputFn = props.onChange ?? props.onDrag ?? undefined;

  function handleChange(event: Event, value: number) {
    inputFn?.(event, value);
  }

  return (
    <TGUIKnob
      {...props}
      onDrag={undefined}
      onChange={handleChange}
      tickWhileDragging={!!props.onDrag}
    />
  );
}
