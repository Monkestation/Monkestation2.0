import { NumberInput as TGUINumberInput } from 'tgui-core/components';
import { ComponentProps } from 'react';

type Shim = Omit<
  ComponentProps<typeof TGUINumberInput>,
  'onChange' | 'onDrag' | 'minValue' | 'maxValue' | 'step'
> &
  Partial<{
    onChange: (event: Event, value: number) => void;
    onDrag: (event: Event, value: number) => void;
    minValue: number;
    maxValue: number;
    step: number;
  }>;

export function NumberInput(props: Shim) {
  const inputFn = props.onDrag ?? props.onChange ?? undefined;

  const min = props.minValue ?? Number.NEGATIVE_INFINITY;
  const max = props.maxValue ?? Number.POSITIVE_INFINITY;
  const step = props.step ?? 1;

  function onChangeHandler(value: number) {
    if (!inputFn) return;
    const event = new Event('change');
    inputFn(event, value);
  }

  return (
    <TGUINumberInput
      {...props}
      onDrag={undefined}
      onChange={onChangeHandler}
      minValue={min}
      maxValue={max}
      step={step}
    />
  );
}
