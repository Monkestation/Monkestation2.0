import { NumberInput as TGUINumberInput } from 'tgui-core/components';
import { ComponentProps } from 'react';

type BaseShim = Omit<
  ComponentProps<typeof TGUINumberInput>,
  'minValue' | 'maxValue'
> & {
  step?: number;
};

type MinProps =
  | { minValue: number; minValueInfinity?: never }
  | { minValueInfinity: true; minValue?: never };

type MaxProps =
  | { maxValue: number; maxValueInfinity?: never }
  | { maxValueInfinity: true; maxValue?: never };

type ConstrainedBounds = BaseShim & MinProps & MaxProps & { infinity?: false };

type BothInfinity = BaseShim & {
  infinity: true;
  minValue?: never;
  maxValue?: never;
  minValueInfinity?: never;
  maxValueInfinity?: never;
};

export type Shim = ConstrainedBounds | BothInfinity;

export function NumberInput(props: Shim) {
  const {
    infinity,
    minValueInfinity,
    maxValueInfinity,
    minValue,
    maxValue,
    ...rest
  } = props as any;
  // const test = (
  //   <>
  //     {/* all should error */}
  //     <NumberInput step={1} value={1} />
  //     <NumberInput minValue={0} value={1} step={1} />
  //     <NumberInput minValueInfinity step={1} value={1} />
  //     <NumberInput maxValue={1} step={1} value={1} />

  //     {/* all should pass */}
  //     <NumberInput minValue={1} maxValue={1} step={1} value={1} />
  //     <NumberInput minValue={1} maxValueInfinity step={1} value={1} />
  //     <NumberInput minValueInfinity maxValue={1} step={1} value={1} />
  //     <NumberInput infinity step={1} value={1} />
  //   </>
  // );

  return (
    <TGUINumberInput
      {...rest}
      minValue={
        infinity || minValueInfinity ? Number.NEGATIVE_INFINITY : minValue
      }
      maxValue={
        infinity || maxValueInfinity ? Number.POSITIVE_INFINITY : maxValue
      }
    />
  );
}
