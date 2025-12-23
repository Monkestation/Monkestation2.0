import { KEY, isEscape } from 'common/keys';
import { classes } from 'common/react';
import { debounce } from 'es-toolkit';
import { RefObject, useRef, useState, useEffect } from 'react';
import { BoxProps, computeBoxProps, computeBoxClassName } from './Box';

export type BaseInputProps<TElement = HTMLInputElement> = Partial<{
  /** Automatically focuses the input on mount */
  autoFocus: boolean;
  /** Automatically selects the input value on focus */
  autoSelect: boolean;
  /** Custom css classes */
  className: string;
  /** Disables the input. Outlined in gray */
  disabled: boolean;
  /**
   * Whether to debounce the onChange event.
   *
   * Do this if it's performing expensive ops on each input, like filtering or
   * sending the value immediate to Byond (via act).
   *
   * It will only fire once every 250ms.
   */
  expensive: boolean;
  /** Fills the parent container */
  fluid: boolean;
  /** Mark this if you want to use a monospace font */
  monospace: boolean;
  /** Allows to toggle on spellcheck on inputs */
  spellcheck: boolean;
}> &
  BoxProps<TElement>;

export type TextInputProps<TElement = HTMLInputElement> = Partial<{
  /** The maximum length of the input value */
  maxLength: number;
  /** Fires each time focus leaves the input, including if Esc or Enter are pressed */
  onBlur: (value: string) => void;
  /** Fires each time the input has been changed */
  onChange: (event: React.ChangeEvent<TElement>, value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (event: React.KeyboardEvent<TElement>, value: string) => void;
  /** Fires once the escape key is pressed */
  onEscape: (event: React.KeyboardEvent<TElement>, value: string) => void;
  /** The placeholder text when everything is cleared */
  placeholder: string;
  /** Clears the input value on enter */
  selfClear: boolean;
  /**
   * Generally, input can handle its own state value. You might not NEED this.
   *
   * Use this if you want to hold the value in the parent for external
   * manipulation. For instance:
   *
   * Clearing the input
   *
   * ```tsx
   * const [value, setValue] = useState('');
   *
   * return (
   *  <>
   *    <Button onClick={() => act('inputVal', {inputVal: value})}>
   *      Submit
   *    </Button>
   *    <Input
   *      value={value}
   *      onChange={setValue} />
   *    <Button onClick={() => setValue('')}>
   *      Clear
   *    </Button>
   *  </>
   * )
   * ```
   *
   * Updating the value from the backend
   *
   * ```tsx
   * const { data } = useBackend<Data>();
   * const { valveSetting } = data;
   *
   * return (
   *  <Input
   *    value={valveSetting}
   *    onEnter={(value) => act('submit', { valveSetting: value })}
   *  />
   * )
   * ```
   */
  value: string;
}> &
  BaseInputProps<TElement>;

type Props = Partial<{
  /** Ref of the input element */
  ref: RefObject<HTMLInputElement | null>;
}> &
  BaseInputProps &
  TextInputProps;

// Prevent input parent change event from being called too often
const inputDebounce = debounce((onChange: () => void) => onChange(), 250);

/**
 * ## Input
 *
 * A basic text input which allow users to enter text into a UI.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-input--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function Input(props: Props) {
  const {
    autoFocus,
    autoSelect,
    className,
    disabled,
    expensive,
    fluid,
    maxLength,
    monospace,
    onBlur,
    onChange,
    onEnter,
    onEscape,
    onKeyDown,
    placeholder,
    ref,
    selfClear,
    spellcheck = false,
    value,
    ...rest
  } = props;

  const ourRef = useRef<HTMLInputElement>(null);
  const inputRef = ref ?? ourRef;

  const [innerValue, setInnerValue] = useState(value ?? '');

  function handleChange(event: React.ChangeEvent<HTMLInputElement>): void {
    const value = event.currentTarget.value;
    setInnerValue(value);
    if (expensive) {
      inputDebounce(() => onChange?.(event, value));
    } else {
      onChange?.(event, value);
    }
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLInputElement>): void {
    onKeyDown?.(event);

    if (event.key === KEY.Enter) {
      event.preventDefault();
      onEnter?.(event, event.currentTarget.value);
      if (selfClear) {
        setInnerValue('');
      }
      event.currentTarget.blur();
      return;
    }

    if (isEscape(event.key)) {
      event.preventDefault();
      onEscape?.(event, event.currentTarget.value);
      event.currentTarget.blur();
    }
  }

  /** Focuses the input on mount */
  useEffect(() => {
    let timer: NodeJS.Timeout;

    if (autoFocus || autoSelect) {
      timer = setTimeout(() => {
        inputRef.current?.focus();
        if (autoSelect) {
          inputRef.current?.select();
        }
      }, 1);
    }

    return () => clearTimeout(timer);
  }, []);

  /** Updates the value on props change */
  useEffect(() => {
    if (
      inputRef.current &&
      document.activeElement !== inputRef.current &&
      value !== innerValue
    ) {
      setInnerValue(value ?? '');
    }
  }, [value]);

  const boxProps = computeBoxProps(rest);
  const clsx = classes([
    'Input',
    disabled && 'Input--disabled',
    fluid && 'Input--fluid',
    monospace && 'Input--monospace',
    computeBoxClassName<HTMLInputElement>(rest),
    className,
  ]);

  return (
    <input
      {...boxProps}
      autoComplete="off"
      className={clsx}
      disabled={disabled}
      maxLength={maxLength}
      onBlur={() => onBlur?.(innerValue)}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      placeholder={placeholder}
      ref={inputRef as React.RefObject<HTMLInputElement>}
      spellCheck={spellcheck}
      type="text"
      value={innerValue}
    />
  );
}
