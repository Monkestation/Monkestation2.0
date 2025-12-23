import { scale, keyOfMatchingRange, clamp01 } from 'common/math';
import { classes } from 'common/react';
import { PropsWithChildren, CSSProperties } from 'react';
import { CSS_COLORS } from '../constants';
import { BoxProps, computeBoxProps, computeBoxClassName } from './Box';

type Props = {
  /**
   * Current progress as a floating point number between `minValue` (default: 0) and `maxValue` (default: 1).
   * Determines the percentage and how filled the bar is.
   */
  value: number;
} & Partial<{
  /**
   * Color of the progress bar. Can take any of the following formats:
   * - `#ffffff` - Hex format
   * - `rgb(r,g,b) / rgba(r,g,b,a)` - RGB format
   * - `<name>` - the name of a `color-<name>` CSS class. See `CSS_COLORS` in `constants.js`.
   * - `<name>` - the name of a base CSS color, if not overridden by the definitions above.
   */
  color: string;
  /** Highest possible value. */
  maxValue: number;
  /** Lowest possible value. */
  minValue: number;
  /**
   * Applies a `color` to the progress bar based on whether the value lands in the range between `from` and `to`.
   * This takes an object with the following format:
   * ```tsx
   * {
   *   (colorname): [from, to]
   * }
   * ```
   * For example:
   * ```tsx
   * <ProgressBar
   *   value={0.5}
   *   ranges={{
   *     bad: [0, 0.5],
   *     good: [0.5, 1],
   *   }}
   * />
   * ```
   *
   */
  ranges: Readonly<Record<string, Readonly<[number, number]>>>;
  /** Removes progress percentage text, makes no sense if children are present */
  empty: boolean;
  /** The number of digits to appear after the percent's decimal point. */
  fractionDigits: number;
}> &
  BoxProps &
  PropsWithChildren;

/**
 * ## ProgressBar
 *
 * Progress indicators inform users about the status of ongoing processes.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-progressbar--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function ProgressBar(props: Props) {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    empty,
    children,
    fractionDigits = 0,
    ...rest
  } = props;
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;

  const effectiveColor =
    color || keyOfMatchingRange(value, ranges) || 'default';

  // We permit colors to be in hex format, rgb()/rgba() format,
  // a name for a color-<name> class, or a base CSS class.
  const outerProps = computeBoxProps(rest);

  const outerClasses = ['ProgressBar', className, computeBoxClassName(rest)];
  const fillStyles: CSSProperties = {
    width: `${clamp01(scaledValue) * 100}%`,
  };
  if (
    CSS_COLORS.includes(effectiveColor as any) ||
    effectiveColor === 'default'
  ) {
    // If the color is a color-<name> class, just use that.
    outerClasses.push(`ProgressBar--color--${effectiveColor}`);
  } else {
    // Otherwise, set styles directly.
    outerProps.style = { ...outerProps.style, borderColor: effectiveColor };
    fillStyles.backgroundColor = effectiveColor;
  }

  return (
    <div className={classes(outerClasses)} {...outerProps}>
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={fillStyles}
      />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : !empty && `${(scaledValue * 100).toFixed(fractionDigits)}%`}
      </div>
    </div>
  );
}
