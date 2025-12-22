/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Placement } from '@popperjs/core';
import { BooleanLike, classes } from 'common/react';
import { PropsWithChildren, ReactNode } from 'react';
import { Box, unit } from './Box';
import { Divider } from './Divider';
import { Tooltip } from './Tooltip';

// @eslint-ignore
export const LabeledList = (props: PropsWithChildren) => {
  const { children } = props;

  return (
    <table className="LabeledList">
      <tbody>{children}</tbody>
    </table>
  );
};

type LabeledListItemProps = Partial<{
  /** Buttons to render aside the content. */
  buttons: ReactNode;
  /** Content of this labeled item. */
  children: ReactNode;
  /** Applies a CSS class to the element. */
  className: string | BooleanLike;
  /** Sets the color of the content text. */
  color: string;
  /** @deprecated */
  content: any;
  /**
   * Sometimes this does not properly register in TS.
   * See [react key docs](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key) for more info.
   */
  key: string | number;
  /** Item label. Appends a colon at the end. */
  label: ReactNode;
  /** Sets the color of the label. */
  labelColor: string;
  /** Lets the label wrap and makes it not take the minimum width. */
  labelWrap: boolean;
  /**
   * Align the content text.
   *
   * - `left` (default)
   * - `center`
   * - `right`
   */
  textAlign: string;
  /** Tooltip text. */
  tooltip: string;
  /** Tooltip position. See Tooltip for valid values. */
  tooltipPosition: Placement;
  /**
   * Align both the label and the content vertically.
   *
   * - `baseline` (default)
   * - `top`
   * - `middle`
   * - `bottom`
   */
  verticalAlign: string;
  /** Preserves line-breaks and spacing in Labeled.Item text. */
  preserveWhitespace: boolean;
}>;

const LabeledListItem = (props: LabeledListItemProps) => {
  const {
    className,
    label,
    labelColor = 'label',
    labelWrap,
    color,
    textAlign,
    buttons,
    content,
    children,
    verticalAlign = 'baseline',
    preserveWhitespace,
    tooltip,
    tooltipPosition,
  } = props;

  let innerLabel: ReactNode;
  if (label) {
    innerLabel = label;
    if (typeof label === 'string') innerLabel += ':';
  }

  if (tooltip !== undefined) {
    innerLabel = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        <Box
          as="span"
          style={{
            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
          }}
        >
          {innerLabel}
        </Box>
      </Tooltip>
    );
  }

  const labelChild = (
    <Box
      as="td"
      className={classes([
        'LabeledList__cell',
        // Kinda flipped because we want nowrap as default. Cleaner CSS this way though.
        !labelWrap && 'LabeledList__label--nowrap',
      ])}
      color={labelColor}
      preserveWhitespace={preserveWhitespace}
      verticalAlign={verticalAlign}
    >
      {innerLabel}
    </Box>
  );

  return (
    <tr className={classes(['LabeledList__row', className])}>
      {labelChild}
      <Box
        as="td"
        className="LabeledList__cell"
        color={color}
        // @ts-ignore
        colSpan={buttons ? undefined : 2}
        textAlign={textAlign}
        verticalAlign={verticalAlign}
      >
        {content}
        {children}
      </Box>
      {buttons && (
        <td className="LabeledList__cell LabeledList__buttons">{buttons}</td>
      )}
    </tr>
  );
};

type LabeledListDividerProps = {
  /** Size of the divider. */
  size?: number;
};

const LabeledListDivider = (props: LabeledListDividerProps) => {
  const padding = props.size ? unit(Math.max(0, props.size - 1)) : 0;

  return (
    <tr className="LabeledList__row">
      <td
        colSpan={3}
        style={{
          paddingBottom: padding,
          paddingTop: padding,
        }}
      >
        <Divider />
      </td>
    </tr>
  );
};

/**
 * ## LabeledList
 *
 * LabeledList is a continuous, vertical list of text and other content, where
 * every item is labeled.
 *
 * It works just like a two column table, where first column is labels, and
 * second column is content.
 *
 * Example:
 *
 * ```tsx
 * <LabeledList>
 *   <LabeledList.Item label="Item">Content</LabeledList.Item>
 * </LabeledList>
 * ```
 *
 * If you want to have a button on the right side of an item (for example,
 * to perform some sort of action), there is a way to do that:
 *
 * Example:
 *
 * ```tsx
 * <LabeledList>
 *   <LabeledList.Item label="Item" buttons={<Button>Click me!</Button>}>
 *     Content
 *   </LabeledList.Item>
 * </LabeledList>
 * ```
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-labeledlist--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
/** Adds some empty space between LabeledList items. */
LabeledList.Divider = LabeledListDivider;
LabeledList.Item = LabeledListItem;
