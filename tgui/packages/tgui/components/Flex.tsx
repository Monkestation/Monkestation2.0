/* eslint-disable func-style */
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps, unit } from './Box';
import type { BoxProps } from './Box';

export type FlexProps = Partial<{
  /**
   * Default alignment of all children.
   *
   * - `stretch` (default) - stretch to fill the container.
   * - `start` - items are placed at the start of the cross axis.
   * - `end` - items are placed at the end of the cross axis.
   * - `center` - items are centered on the cross axis.
   * - `baseline` - items are aligned such as their baselines align.
   */
  align: string | boolean;
  /**
   * This establishes the main-axis, thus defining the direction flex items are placed in the flex container.
   *
   *  - `row` (default) - left to right.
   *  - `row-reverse` - right to left.
   *  - `column` - top to bottom.
   *  - `column-reverse` - bottom to top.
   */
  direction: string;
  /** Makes flexbox container inline, with similar behavior to an `inline` property on a `Box`. */
  inlineFlex: boolean;
  /**
   * This defines the alignment along the main axis. It helps distribute extra free space leftover when either all the flex items on a line are
   * inflexible, or are flexible but have reached their maximum size. It also exerts some control over the alignment of items when they overflow
   * the line.
   *
   *   - `flex-start` (default) - items are packed toward the start of the
   *  flex-direction.
   * - `flex-end` - items are packed toward the end of the flex-direction.
   * - `space-between` - items are evenly distributed in the line; first item is
   *   on the start line, last item on the end line
   * - `space-around` - items are evenly distributed in the line with equal space
   *   around them. Note that visually the spaces aren't equal, since all the items
   *   have equal space on both sides. The first item will have one unit of space
   *   against the container edge, but two units of space between the next item
   *  because that next item has its own spacing that applies.
   *  - `space-evenly` - items are distributed so that the spacing between any two
   *  items (and the space to the edges) is equal.
   */
  justify: string;
  /** By default, flex items will all try to fit onto one line. You can change that and allow the items to wrap as needed with this property. */
  scrollable: boolean;
  /**
   * This defines the alignment along the cross axis. It helps distribute extra free space leftover when either all the flex items on a line are
   *  inflexible, or are flexible but have reached their maximum size. It also exerts some control over the alignment of items when they overflow
   *  the line.
   *
   *  - `nowrap` (default) - all flex items will be on one line
   *  - `wrap` - flex items will wrap onto multiple lines, from top to bottom.
   *  - `wrap-reverse` - flex items will wrap onto multiple lines from bottom to top.
   */
  wrap: string | boolean;
}> &
  BoxProps;

export function computeFlexClassName(props: FlexProps): string {
  return classes([
    'Flex',
    props.inlineFlex && 'Flex--inline',
    computeBoxClassName(props),
  ]);
}

export function computeFlexProps(props: FlexProps) {
  const { direction, wrap, align, justify, ...rest } = props;

  return computeBoxProps({
    style: {
      ...rest.style,
      alignItems: align,
      flexDirection: direction,
      flexWrap: wrap === true ? 'wrap' : wrap,
      justifyContent: justify,
    },
    ...rest,
  });
}

/**
 * ## Flex
 *
 * Quickly manage the layout, alignment, and sizing of grid columns, navigation,
 * components, and more with a full suite of responsive flexbox utilities.
 *
 * If you are new to or unfamiliar with flexbox, we encourage you to read this
 * [CSS-Tricks flexbox guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/).
 *
 * Consists of two elements: `<Flex>` and `<Flex.Item>`. Both of them provide
 * the most straight-forward mapping to flex CSS properties as possible.
 *
 * One of the most basic usage of flex, is to align certain elements
 * to the left, and certain elements to the right:
 *
 * Example:
 *
 * ```tsx
 * <Flex>
 *   <Flex.Item grow>Button description</Flex.Item>
 *   <Flex.Item>
 *     <Button>Perform an action</Button>
 *   </Flex.Item>
 * </Flex>
 * ```
 *
 * Flex item with `grow` property will grow to take all available empty space,
 * while flex items without grow will take the minimum amount of space. This
 * effectively places the last flex item to the very end of the flex container.
 *
 * @deprecated - Use
 * [Stack](https://github.com/tgstation/tgui-core/tree/main/lib/components/Stack.tsx)
 * where possible.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-flex--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function Flex(props) {
  const { className, ...rest } = props;

  return (
    <div
      className={classes([className, computeFlexClassName(rest)])}
      {...computeFlexProps(rest)}
    />
  );
}

export function computeFlexItemClassName(props: FlexItemProps): string {
  return classes(['Flex__item', computeBoxClassName(props)]);
}

export type FlexItemProps = Partial<{
  /** This allows the default alignment (or the one specified by align-items) to be overridden for individual flex items. */
  align: string | boolean;
  /**
   * This defines the default size of an element
   * before any flex-related calculations are done. Has to be a length
   * (e.g. `20%`, `5rem`), an `auto` or `content` keyword.
   *
   * - **Important:** IE11 flex is buggy, and auto width/height calculations
   * can sometimes end up in a circular dependency. This usually happens, when
   * working with tables inside flex (they have wacky internal widths and such).
   * Setting basis to `0` breaks the loop and fixes all of the problems.
   */
  basis: string | number;
  /**
   * This defines the ability for a flex item to grow if necessary. It accepts a unitless value that serves as a proportion.
   * It dictates what amount of the available space inside the flex container the item should take up.
   * This number is unit-less and is relative to other siblings.
   */
  grow: number | boolean;
  /**
   * By default, flex items are laid out in the source order. However, the order property controls the order in which they appear in the
   * flex container
   */
  order: number;
  /** This defines the ability for a flex item to shrink if necessary. Inverse of `grow`. */
  shrink: number | boolean;
}> &
  BoxProps;

export function computeFlexItemProps(props: FlexItemProps) {
  const { style, grow, order, shrink, basis, align, ...rest } = props;

  const computedBasis =
    basis ??
    // IE11: Set basis to specified width if it's known, which fixes certain
    // bugs when rendering tables inside the flex.
    props.width ??
    // If grow is used, basis should be set to 0 to be consistent with
    // flex css shorthand `flex: 1`.
    (grow !== undefined ? 0 : undefined);

  return computeBoxProps({
    style: {
      ...style,
      alignSelf: align,
      flexBasis: unit(computedBasis),
      flexGrow: grow !== undefined && Number(grow),
      flexShrink: shrink !== undefined && Number(shrink),
      order: order,
    },
    ...rest,
  });
}

function FlexItem(props) {
  const { className, ...rest } = props;

  return (
    <div
      className={classes([className, computeFlexItemClassName(props)])}
      {...computeFlexItemProps(rest)}
    />
  );
}

Flex.Item = FlexItem;
