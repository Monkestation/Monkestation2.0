import { ComponentProps } from 'react';
import { Input as TGUIInput } from 'tgui-core/components';

type Shim = Omit<
  ComponentProps<typeof TGUIInput>,
  'onInput' | 'onChange' | 'onEnter'
> &
  Partial<{
    onInput: (event: Event, value: string) => void;
    onChange: (event: Event, value: string) => void;
    onEnter: (event: Event, value: string) => void;
  }>;

export function Input(props: Shim) {
  const inputFn = props.onInput ?? props.onChange;

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

  return <TGUIInput {...props} onChange={handleInput} onEnter={handleEnter} />;
}
