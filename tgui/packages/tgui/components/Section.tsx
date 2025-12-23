/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import {
  ReactNode,
  RefObject,
  useEffect,
  useRef,
} from 'react';
import { addScrollableNode, removeScrollableNode } from '../events';
import { canRender, classes } from 'common/react';

type Props = Partial<{
  /** Buttons to render aside the section title. */
  buttons: ReactNode;
  /** id to assosiate with the parent div element used by this section, for uses with procs like getElementByID */
  container_id: string;
  /** If true, fills all available vertical space. */
  fill: boolean;
  /** If true, removes all section padding. */
  fitted: boolean;
  /** If true, fills the area without forcing height to 100% */
  flexGrow: boolean;
  /** If true, removes the section top padding */
  noTopPadding: boolean;
  /** @member Callback function for the `scroll` event */
  onScroll: ((this: GlobalEventHandlers, ev: Event) => any) | null;
  /** Ref to the section element. */
  ref: RefObject<HTMLDivElement | null>;
  /** Shows or hides the scrollbar. */
  scrollable: boolean;
  /** Shows or hides the horizontal scrollbar. */
  scrollableHorizontal: boolean;
  /** If true, filly the area except for -3rem */
  stretchContents: boolean;
  /** Title of the section. */
  title: ReactNode;
}> &
  BoxProps;

/**
 * ## Section
 *
 * Section is a surface that displays content and actions on a single topic.
 *
 * They should be easy to scan for relevant and actionable information.
 * Elements, like text and images, should be placed in them in a way that
 * clearly indicates hierarchy.
 *
 * Sections can now be nested, and will automatically font size of the
 * header according to their nesting level. Previously this was done via `level`
 * prop, but now it is automatically calculated.
 *
 * Section can also be titled to clearly define its purpose.
 *
 * Example:
 *
 * ```tsx
 * <Section title="Cargo">Here you can order supply crates.</Section>
 * ```
 *
 * If you want to have a button on the right side of an section title
 * (for example, to perform some sort of action), there is a way to do that:
 *
 * Example:
 *
 * ```tsx
 * <Section title="Cargo" buttons={<Button>Send shuttle</Button>}>
 *   Here you can order supply crates.
 * </Section>
 * ```
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-section--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function Section(props: Props) {
  const {
    buttons,
    children,
    className,
    container_id = '',
    fill,
    fitted,
    flexGrow,
    noTopPadding,
    onScroll,
    ref,
    scrollable,
    scrollableHorizontal,
    stretchContents,
    title,
    ...rest
  } = props;

  const hasTitle = canRender(title) || canRender(buttons);

  const ourRef = useRef<HTMLDivElement>(null);
  const nodeRef = ref ?? ourRef;

  useEffect(() => {
    // Doesn't use early returns here as we're in useEffect
    if (nodeRef.current) {
      if (scrollable || scrollableHorizontal) {
        addScrollableNode(nodeRef.current);
      }
    }

    return () => {
      if (nodeRef.current) {
        removeScrollableNode(nodeRef.current);
      }
    };
  }, []);

  return (
    <div
      className={classes([
        'Section',
        fill && 'Section--fill',
        fitted && 'Section--fitted',
        scrollable && 'Section--scrollable',
        scrollableHorizontal && 'Section--scrollableHorizontal',
        flexGrow && 'Section--flex',
        className,
        computeBoxClassName(rest),
      ])}
      id={container_id}
      {...computeBoxProps(rest)}
    >
      {hasTitle && (
        <div className="Section__title">
          <span className="Section__titleText">{title}</span>
          <div className="Section__buttons">{buttons}</div>
        </div>
      )}
      <div className="Section__rest">
        <div
          className={classes([
            'Section__content',
            stretchContents && 'Section__content--stretchContents',
            noTopPadding && 'Section__content--noTopPadding',
          ])}
          onScroll={onScroll}
          // For posterity: the forwarded ref needs to be here specifically
          // to actually let things interact with the scrolling.
          // @ts-expect-error you know what, shut up. im sure youll function just fine.
          ref={nodeRef}
        >
          {children}
        </div>
      </div>
    </div>
  );
}
