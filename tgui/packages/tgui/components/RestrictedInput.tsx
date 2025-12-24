import { RestrictedInput as TguiRestrictedInput } from 'tgui-core/components';
import { ComponentProps } from 'react';

type Shim = Omit<
  ComponentProps<typeof TguiRestrictedInput>,
  'onChange' | 'onEnter'
> & {
  onChange: (event: React.ChangeEvent<HTMLInputElement>, value: number) => void;
  onEnter?: (
    event: React.KeyboardEvent<HTMLInputElement>,
    value: number,
  ) => void;
};

export function RestrictedInput(props: Shim) {
  function handleInput(val: number) {
    if (!props.onChange) return;
    const event = {} as React.ChangeEvent<HTMLInputElement>;
    props.onChange?.(event, val);
  }

  function handleEnter(val: number) {
    if (!props.onEnter) return;

    const event = {} as React.KeyboardEvent<HTMLInputElement>;
    props.onEnter?.(event, val);
  }

  return (
    <TguiRestrictedInput
      {...props}
      onChange={handleInput}
      onEnter={handleEnter}
    />
  );
}
