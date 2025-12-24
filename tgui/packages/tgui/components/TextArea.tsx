import { TextArea as TGUITextArea } from 'tgui-core/components';
import { ComponentProps } from 'react';

type Shim = Omit<
  ComponentProps<typeof TGUITextArea>,
  'onChange' | 'onInput' | 'onEnter'
> &
  Partial<{
    onChange: (event: Event, value: string) => void;
    onInput: (event: Event, value: string) => void;
    onEnter: (event: Event, value: string) => void;
  }>;

export function TextArea(props: Shim) {
  const inputFn = props.onChange ?? props.onInput;

  function handleInput(val: string) {
    if (!inputFn) return;

    const event = {} as Event;
    inputFn?.(event, val);
  }

  function handleEnter(val: string) {
    if (!props.onEnter) return;

    const event = {} as Event;
    props.onEnter?.(event, val);
  }

  return (
    <TGUITextArea {...props} onChange={handleInput} onEnter={handleEnter} />
  );
}
