/* eslint-disable func-style */
import {
  createElement,
  CSSProperties,
  DOMAttributes,
  HTMLAttributes,
  ReactNode,
} from 'react';
import { CSS_COLORS } from '../constants';
import { type BooleanLike, classes } from 'common/react';

type UnitMapper = (value: unknown) => string | undefined;

// Do you get it? Are you feeling it now mr krabs?
type StyleCourier = (
  ...args: any[]
) => (style: CSSProperties, value: unknown) => void;

/**
 * Coverts our rem-like spacing unit into a CSS unit.
 */
export const unit: UnitMapper = (value) => {
  if (typeof value === 'string') {
    // Transparently convert pixels into rem units
    if (value.endsWith('px')) {
      return `${Number.parseFloat(value) / 12}rem`;
    }
    return value;
  }
  if (typeof value === 'number') {
    return `${value}rem`;
  }
};

/**
 * Same as `unit`, but half the size for integers numbers.
 */
export const halfUnit: UnitMapper = (value) => {
  if (typeof value === 'string') {
    return unit(value);
  }
  if (typeof value === 'number') {
    return unit(value * 0.5);
  }
};

function isColorCode(str: unknown): boolean {
  return !isColorClass(str);
}

function isColorClass(str: unknown): boolean {
  return typeof str === 'string' && CSS_COLORS.includes(str as any);
}

const mapRawPropTo: StyleCourier = (attrName: string) => (style, value) => {
  if (typeof value === 'number' || typeof value === 'string') {
    style[attrName] = value;
  }
};

const mapUnitPropTo: StyleCourier =
  (attrName: string, unitMapper: UnitMapper) => (style, value) => {
    if (typeof value === 'number' || typeof value === 'string') {
      style[attrName] = unitMapper(value);
    }
  };

const mapBooleanPropTo: StyleCourier =
  (attrName: string, attrValue: unknown) => (style, value) => {
    if (value) {
      style[attrName] = attrValue;
    }
  };

const mapDirectionalUnitPropTo: StyleCourier =
  (attrName: string, unitMapper: UnitMapper, dirs: string[]) =>
  (style, value) => {
    if (typeof value === 'number' || typeof value === 'string') {
      for (let i = 0; i < dirs.length; i++) {
        style[attrName + dirs[i]] = unitMapper(value);
      }
    }
  };

const mapColorPropTo: StyleCourier = (attrName: string) => (style, value) => {
  if (isColorCode(value)) {
    style[attrName] = value;
  }
};

export type StringStyleMap = Partial<{
  // Alignment

  /** Align text inside the box. */
  align: string | BooleanLike;
  /** A direct mapping to `position` CSS property. */
  position: string | BooleanLike;
  /** Vertical align property. */
  verticalAlign: string | BooleanLike;

  // Color props

  /** Sets background color. */
  backgroundColor: string | BooleanLike;
  /** Applies an atomic `color-<name>` class to the element. */
  color: string | BooleanLike;
  /** Opacity, from 0 to 1. */
  opacity: string | BooleanLike;
  /** Sets text color. */
  textColor: string | BooleanLike;

  // Margin

  /** Margin on all sides. */
  m: string | BooleanLike;
  /** Bottom margin. */
  mb: string | BooleanLike;
  /** Left margin. */
  ml: string | BooleanLike;
  /** Right margin. */
  mr: string | BooleanLike;
  /** Top margin. */
  mt: string | BooleanLike;
  /** Horizontal margin. */
  mx: string | BooleanLike;
  /** Vertical margin. */
  my: string | BooleanLike;

  /** Bottom margin. */
  bottom: string | BooleanLike;
  /** Left margin. */
  left: string | BooleanLike;
  /** Right margin. */
  right: string | BooleanLike;
  /** Top margin. */
  top: string | BooleanLike;

  // Gap

  /** Gap on all sides. */
  g: string | BooleanLike;
  /** Row gap. */
  gr: string | BooleanLike;
  /** Column gap. */
  gc: string | BooleanLike;

  // Overflow

  /** Overflow property. */
  overflow: string | BooleanLike;
  /** Overflow-X property. */
  overflowX: string | BooleanLike;
  /** Overflow-Y property. */
  overflowY: string | BooleanLike;

  // Padding

  /** Padding on all sides. */
  p: string | BooleanLike;
  /** Bottom padding. */
  pb: string | BooleanLike;
  /** Left padding. */
  pl: string | BooleanLike;
  /** Right padding. */
  pr: string | BooleanLike;
  /** Top padding. */
  pt: string | BooleanLike;
  /** Horizontal padding. */
  px: string | BooleanLike;
  /** Vertical padding. */
  py: string | BooleanLike;

  // Size

  /** Box height. */
  height: string | BooleanLike;
  /** Box maximum height. */
  maxHeight: string | BooleanLike;
  /** Box maximum width. */
  maxWidth: string | BooleanLike;
  /** Box minimum height. */
  minHeight: string | BooleanLike;
  /** Box minimum width. */
  minWidth: string | BooleanLike;
  /** Box width. */
  width: string | BooleanLike;

  // Text

  /** Font family. */
  fontFamily: string | BooleanLike;
  /** Font size. */
  fontSize: string | BooleanLike;
  /** Font weight. */
  fontWeight: string | BooleanLike;
  /** Directly affects the height of text lines. Useful for adjusting button height. */
  lineHeight: string | BooleanLike;
  /** Align text inside the box. */
  textAlign: string | BooleanLike;
}>;

// String / number props
export const stringStyleMap: Record<keyof StringStyleMap, any> = {
  align: mapRawPropTo('textAlign'),
  backgroundColor: mapColorPropTo('backgroundColor'),
  bottom: mapUnitPropTo('bottom', unit),
  // Color props
  color: mapColorPropTo('color'),
  fontFamily: mapRawPropTo('fontFamily'),
  fontSize: mapUnitPropTo('fontSize', unit),
  fontWeight: mapRawPropTo('fontWeight'),
  // Gap
  g: mapUnitPropTo('gap', halfUnit),
  gc: mapUnitPropTo('columnGap', halfUnit),
  gr: mapUnitPropTo('rowGap', halfUnit),
  height: mapUnitPropTo('height', unit),
  left: mapUnitPropTo('left', unit),

  lineHeight: (style, value) => {
    if (typeof value === 'number') {
      style.lineHeight = value;
    } else if (typeof value === 'string') {
      style.lineHeight = unit(value);
    }
  },
  // Margin
  m: mapDirectionalUnitPropTo('margin', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  maxHeight: mapUnitPropTo('maxHeight', unit),
  maxWidth: mapUnitPropTo('maxWidth', unit),
  mb: mapUnitPropTo('marginBottom', halfUnit),
  minHeight: mapUnitPropTo('minHeight', unit),
  minWidth: mapUnitPropTo('minWidth', unit),
  ml: mapUnitPropTo('marginLeft', halfUnit),
  mr: mapUnitPropTo('marginRight', halfUnit),
  mt: mapUnitPropTo('marginTop', halfUnit),
  mx: mapDirectionalUnitPropTo('margin', halfUnit, ['Left', 'Right']),
  my: mapDirectionalUnitPropTo('margin', halfUnit, ['Top', 'Bottom']),
  opacity: mapRawPropTo('opacity'),
  overflow: mapRawPropTo('overflow'),
  overflowX: mapRawPropTo('overflowX'),
  overflowY: mapRawPropTo('overflowY'),
  // Padding
  p: mapDirectionalUnitPropTo('padding', halfUnit, [
    'Top',
    'Bottom',
    'Left',
    'Right',
  ]),
  pb: mapUnitPropTo('paddingBottom', halfUnit),
  pl: mapUnitPropTo('paddingLeft', halfUnit),
  position: mapRawPropTo('position'),
  pr: mapUnitPropTo('paddingRight', halfUnit),
  pt: mapUnitPropTo('paddingTop', halfUnit),
  px: mapDirectionalUnitPropTo('padding', halfUnit, ['Left', 'Right']),
  py: mapDirectionalUnitPropTo('padding', halfUnit, ['Top', 'Bottom']),
  right: mapUnitPropTo('right', unit),
  textAlign: mapRawPropTo('textAlign'),
  textColor: mapColorPropTo('color'),
  top: mapUnitPropTo('top', unit),
  verticalAlign: mapRawPropTo('verticalAlign'),
  width: mapUnitPropTo('width', unit),
};

export type BooleanStyleMap = Partial<{
  /** Make text bold. */
  bold: boolean;
  /** Fill positioned parent. */
  fillPositionedParent: boolean;
  /** Forces the `Box` to appear as an `inline-block`. */
  inline: boolean;
  /** Make text italic. */
  italic: boolean;
  /** Stops text from wrapping. */
  nowrap: boolean;
  /** Preserves line-breaks and spacing in text. */
  preserveWhitespace: boolean;
  wrap: boolean;
}>;

// Boolean props
export const booleanStyleMap: Record<keyof BooleanStyleMap, any> = {
  bold: mapBooleanPropTo('fontWeight', 'bold'),
  fillPositionedParent: (style: CSSProperties, value: unknown) => {
    if (value) {
      style.position = 'absolute';
      style.top = 0;
      style.bottom = 0;
      style.left = 0;
      style.right = 0;
    }
  },
  inline: mapBooleanPropTo('display', 'inline-block'),
  italic: mapBooleanPropTo('fontStyle', 'italic'),
  nowrap: mapBooleanPropTo('whiteSpace', 'nowrap'),
  wrap: mapBooleanPropTo('whiteSpace', 'normal'),
  preserveWhitespace: mapBooleanPropTo('whiteSpace', 'pre-wrap'),
};

export function computeBoxProps(props): Record<string, any> {
  const computedProps: Record<string, any> = {};
  const computedStyles: Record<string, string | number> = {};

  // Compute props
  for (const propName in props) {
    if (propName === 'style') {
      continue;
    }

    const propValue = props[propName];

    const mapPropToStyle =
      stringStyleMap[propName] || booleanStyleMap[propName];

    if (mapPropToStyle) {
      mapPropToStyle(computedStyles, propValue);
    } else {
      computedProps[propName] = propValue;
    }
  }

  // Merge computed styles and any directly provided styles
  computedProps.style = { ...computedStyles, ...props.style };

  return computedProps;
}

export function computeBoxClassName<TElement = HTMLDivElement>(
  props: BoxProps<TElement>,
): string {
  const color = props.textColor || props.color;
  const { backgroundColor } = props;

  return classes([
    isColorClass(color) && `color-${color}`,
    isColorClass(backgroundColor) && `color-bg-${backgroundColor}`,
  ]);
}

/** Short list of accepted DOM event handlers */
export const eventHandlers = [
  'onClick',
  'onContextMenu',
  'onDoubleClick',
  'onKeyDown',
  'onKeyUp',
  'onMouseDown',
  'onMouseLeave',
  'onMouseMove',
  'onMouseOver',
  'onMouseUp',
  'onScroll',
  'onWheel',
  'onDrag',
  'onDragEnd',
  'onDragEnter',
  'onDragExit',
  'onDragLeave',
  'onDragOver',
  'onDragStart',
  'onDrop',
] as const;

export type EventHandlers<TElement = HTMLDivElement> = Pick<
  DOMAttributes<TElement>,
  (typeof eventHandlers)[number]
>;

export type BoxInternalProps = Partial<{
  /**
   * The component used for the root node.
   * @default <div>
   */
  as: string;
  /** The content of the component. */
  children: ReactNode;
  /** Class name to pass into the component. */
  className: string | BooleanLike;
  /** The unique id of the component. */
  id: string;
  /** The inline style of the component. */
  style: CSSProperties;
}>;

type LiftedHTMLAttributes<TElement> = {
  /** Whether this element is draggable.
   * @see https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/draggable
   */
  draggable?: HTMLAttributes<TElement>['draggable'];
};

// You may wonder why we don't just use ComponentProps<typeof Box> here.
// This is because I'm trying to isolate DangerDoNotUse from the rest of the props.
// While you still can technically use ComponentProps, it won't throw an error if someone uses dangerouslySet.
export interface BoxProps<TElement = HTMLDivElement>
  extends BoxInternalProps,
    BooleanStyleMap,
    StringStyleMap,
    LiftedHTMLAttributes<TElement>,
    EventHandlers<TElement>,
    Record<string, any> {} // HACK: Just ignore bad props for now

// Don't you dare put this elsewhere
type DangerDoNotUse = {
  dangerouslySetInnerHTML?: {
    __html: any;
  };
};

/**
 * ## Box
 *
 * The Box component serves as a wrapper component for most of the CSS utility
 * needs. It creates a new DOM element, a `<div>` by default that can be changed
 * with the `as` property. Let's say you want to use a `<span>` instead:
 *
 * Example:
 *
 * ```tsx
 * <Box as="span" m={1}>
 *   <Button />
 * </Box>
 * ```
 *
 * This works great when the changes can be isolated to a new DOM element.
 * For instance, you can change the margin this way.
 *
 * However, sometimes you have to target the underlying DOM element.
 * For instance, you want to change the text color of the button. The Button
 * component defines its own color. CSS inheritance doesn't help.
 *
 * To workaround this problem, the Box children accept a render props function.
 * This way, `Button` can pull out the `className` generated by the `Box`.
 *
 * Example:
 *
 * ```tsx
 * <Box color="primary">{(props) => <Button {...props} />}</Box>
 * ```
 *
 * ## Box Units
 *
 * `Box` units, like width, height and margins can be defined in two ways:
 *
 * - By plain numbers
 *   - 1 unit equals `1rem` for width, height and positioning properties.
 *   - 1 unit equals `0.5rem` for margins and paddings.
 * - By strings with proper CSS units
 *   - For example: `100px`, `2em`, `1rem`, `100%`, etc.
 *
 * If you need more precision, you can always use fractional numbers.
 *
 * Default font size (`1rem`) is equal to `12px`.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function Box<TElement = HTMLDivElement>(
  props: BoxProps<TElement> & DangerDoNotUse,
) {
  const { as = 'div', className, children, ...rest } = props;

  const computedClassName = className
    ? `${className} ${computeBoxClassName<TElement>(rest)}`
    : computeBoxClassName<TElement>(rest);

  const computedProps = computeBoxProps({
    ...rest,
  });

  return createElement(
    as,
    {
      ...computedProps,
      className: computedClassName,
    },
    children,
  );
}
