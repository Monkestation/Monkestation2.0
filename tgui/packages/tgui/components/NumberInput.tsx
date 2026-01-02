// HEY! WHEN THE NEXT VERSION OF TGUI-CORE IS RELEASED, THESE CHANGES BELOW WILL BE MERGED, DELETE THIS FILE THEN.

import {
  Component,
  createRef,
  type FocusEventHandler,
  type KeyboardEventHandler,
} from 'react';
import { AnimatedNumber, Box } from 'tgui-core/components';
import { BooleanLike, classes } from 'tgui-core/react';
import { BoxProps } from './Box';
import { clamp, round } from 'common/math';
import { isEscape, KEY } from 'tgui-core/keys';

type Props = Required<{
  /** Value itself. */
  value: number | string;
}> &
  Partial<{
    /** Highest possible value. */
    maxValue: number;
    /** Lowest possible value. */
    minValue: number;
    /** Adjust value by this amount when dragging the input. */
    step: number;
    /** Animates the value if it was changed externally. */
    animated: boolean;
    /** Makes the input field uneditable & non draggable to prevent user changes */
    disabled: boolean;
    /** onChange also fires about every 500ms when you drag the input up and down. */
    tickWhileDragging: boolean;
    /** Format value using this function before displaying it. */
    format: (value: number) => string;
    /** Adjusts the width to 100% of its parent container */
    fluid: boolean;
    /** An event which fires when you release the input or successfully enter a number. */
    onChange: (value: number) => void;
    /** Screen distance mouse needs to travel to adjust value by one `step`. */
    stepPixelSize: number;
    /** Unit to display to the right of value. */
    unit: string;
  }> &
  BoxProps;

type State = {
  currentValue: number;
  dragging: BooleanLike;
  editing: BooleanLike;
  origin: number;
  previousValue: number;
};

/**
 * ## NumberInput
 *
 * A fancy, interactive number input, which you can either drag up and down
 * to fine tune the value, or single click it to manually type a number.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-numberinput--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export class NumberInput extends Component<Props, State> {
  // Ref to the input field to set focus & highlight
  inputRef = createRef<HTMLInputElement>();

  // After this time has elapsed we are in drag mode so no editing when dragging ends
  dragTimeout: NodeJS.Timeout;

  // Call onChange if tickWhileDragging at this interval
  dragInterval: NodeJS.Timeout;

  // default values for the number input state
  state: State = {
    currentValue: Number(this.props.value ?? 0),
    dragging: false,
    editing: false,
    origin: 0,
    previousValue: Number(this.props.value ?? 0),
  };

  static defaultProps: Partial<Props> = {
    minValue: Number.NEGATIVE_INFINITY,
    maxValue: Number.POSITIVE_INFINITY,
    step: 1,
  };

  componentDidMount(): void {
    const displayValue = Number.parseFloat(this.props.value.toString());

    this.setState({
      currentValue: displayValue,
      previousValue: displayValue,
    });
  }

  handleDragStart: React.MouseEventHandler<HTMLDivElement> = (event) => {
    const { value, disabled } = this.props;
    const { editing } = this.state;
    if (disabled || editing) {
      return;
    }
    document.body.style['pointer-events'] = 'none';

    const parsedValue = Number.parseFloat(value.toString());
    this.setState({
      currentValue: parsedValue,
      dragging: false,
      origin: event.screenY,
      previousValue: parsedValue,
    });

    this.dragTimeout = setTimeout(() => {
      this.setState({
        dragging: true,
      });
    }, 250);
    this.dragInterval = setInterval(() => {
      const { dragging, currentValue, previousValue } = this.state;
      const { onChange, tickWhileDragging } = this.props;
      if (dragging && tickWhileDragging && currentValue !== previousValue) {
        this.setState({
          previousValue: currentValue,
        });
        onChange?.(currentValue);
      }
    }, 400);

    document.addEventListener('mousemove', this.handleDragMove);
    document.addEventListener('mouseup', this.handleDragEnd);
  };

  handleDragMove = (event: MouseEvent) => {
    const {
      minValue = Number.NEGATIVE_INFINITY,
      maxValue = Number.POSITIVE_INFINITY,
      step = 1,
      stepPixelSize,
      disabled,
    } = this.props;
    if (disabled) {
      return;
    }

    this.setState((prevState) => {
      const state = { ...prevState };

      const offset = state.origin - event.screenY;
      if (prevState.dragging) {
        // Translate mouse movement to value
        // Give it some headroom (by increasing clamp range by 1 step)
        const stepSize = stepPixelSize || 1;
        const internalValue = clamp(
          state.currentValue + (offset * step) / stepSize,
          minValue - step,
          maxValue + step,
        );
        if (Math.abs(internalValue - state.currentValue) >= step) {
          state.currentValue = clamp(
            round(internalValue / step, 0) * step,
            minValue,
            maxValue,
          );
          // Set the new origin
          state.origin = event.screenY;
        } else if (Math.abs(offset) > stepSize) {
          state.origin = event.screenY;
        }
      } else if (Math.abs(offset) > 4) {
        state.dragging = true;
      }
      return state;
    });
  };

  handleDragEnd = (_event: MouseEvent) => {
    const { dragging, currentValue } = this.state;
    const { onChange, disabled } = this.props;
    if (disabled) {
      return;
    }
    document.body.style['pointer-events'] = 'auto';

    clearInterval(this.dragInterval);
    clearTimeout(this.dragTimeout);

    this.setState({
      dragging: false,
      editing: !dragging,
      previousValue: currentValue,
    });
    if (dragging) {
      onChange?.(currentValue);
    } else if (this.inputRef) {
      const input = this.inputRef.current;
      if (input) {
        input.value = `${currentValue}`;
        setTimeout(() => {
          input.focus();
          input.select();
        }, 10);
      }
    }

    document.removeEventListener('mousemove', this.handleDragMove);
    document.removeEventListener('mouseup', this.handleDragEnd);
  };

  handleBlur: FocusEventHandler<HTMLInputElement> = (event) => {
    const { editing, previousValue } = this.state;
    const { minValue, maxValue, onChange, disabled } = this.props;
    if (disabled || !editing) {
      return;
    }

    const targetValue = clamp(
      Number.parseFloat(event.target.value),
      minValue ?? 0,
      maxValue ?? 100,
    );
    if (Number.isNaN(targetValue)) {
      this.setState({
        editing: false,
      });
      return;
    }

    this.setState({
      currentValue: targetValue,
      editing: false,
      previousValue: targetValue,
    });
    if (previousValue !== targetValue) {
      onChange?.(targetValue);
    }
  };

  handleKeyDown: KeyboardEventHandler<HTMLInputElement> = (event) => {
    const { minValue, maxValue, onChange, disabled } = this.props;
    if (disabled) {
      return;
    }
    const { previousValue } = this.state;

    if (event.key === KEY.Enter) {
      const targetValue = clamp(
        Number.parseFloat(event.currentTarget.value),
        minValue ?? 0,
        maxValue ?? 100,
      );
      if (Number.isNaN(targetValue)) {
        this.setState({
          editing: false,
        });
        return;
      }

      this.setState({
        currentValue: targetValue,
        editing: false,
        previousValue: targetValue,
      });
      if (previousValue !== targetValue) {
        onChange?.(targetValue);
      }
    } else if (isEscape(event.key)) {
      this.setState({
        editing: false,
      });
    }
  };

  render() {
    const { dragging, editing, currentValue } = this.state;

    const {
      className,
      fluid,
      animated,
      unit,
      value,
      minValue,
      maxValue,
      height,
      width,
      lineHeight,
      fontSize,
      format,
    } = this.props;

    let displayValue = Number.parseFloat(value.toString());
    if (dragging) {
      displayValue = currentValue;
    }

    const contentElement = (
      <div className="NumberInput__content">
        {animated && !dragging ? (
          <AnimatedNumber format={format} value={displayValue} />
        ) : format ? (
          format(displayValue)
        ) : (
          displayValue
        )}

        {unit ? ` ${unit}` : ''}
      </div>
    );

    return (
      <Box
        className={classes([
          'NumberInput',
          fluid && 'NumberInput--fluid',
          className,
        ])}
        fontSize={fontSize}
        lineHeight={lineHeight}
        minHeight={height}
        minWidth={width}
        onMouseDown={this.handleDragStart}
      >
        <div className="NumberInput__barContainer">
          <div
            className="NumberInput__bar"
            style={{
              height: `${clamp(
                // biome-ignore lint/style/noNonNullAssertion: will never be undefined
                ((displayValue - minValue!) / (maxValue! - minValue!)) * 100,
                0,
                100,
              )}%`,
            }}
          />
        </div>
        {contentElement}
        <input
          className="NumberInput__input"
          onBlur={this.handleBlur}
          onKeyDown={this.handleKeyDown}
          ref={this.inputRef}
          style={{
            display: !editing ? 'none' : 'inline',
            fontSize: fontSize as string | number,
            height: height as string | number,
            lineHeight: lineHeight as string | number,
          }}
        />
      </Box>
    );
  }
}
