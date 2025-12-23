/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from 'common/react';
import { Component, createRef, RefObject } from 'inferno';
import { Box, BoxProps } from './Box';
import { toInputValue } from './Input';
import { KEY_ENTER, KEY_ESCAPE, KEY_TAB } from 'common/keycodes';

/* ---------- Types ---------- */

export interface TextAreaProps {
  value?: string;
  displayedValue?: string;
  placeholder?: string;
  maxLength?: number;
  resize?: CSSStyleDeclaration['resize'];
  scrollbar?: boolean;
  noborder?: boolean;
  fluid?: boolean;
  nowrap?: boolean;
  autoFocus?: boolean;
  autoSelect?: boolean;
  selfClear?: boolean;
  dontUseTabForIndent?: boolean;
  innerRef?: RefObject<HTMLTextAreaElement>;

  onInput?: (e: KeyboardEvent, value: string) => void;
  onChange?: (e: Event, value: string) => void;
  onKeyDown?: (e: KeyboardEvent, value: string) => void;
  onKeyPress?: (e: KeyboardEvent, value: string) => void;
  onKey?: (e: KeyboardEvent, value: string) => void;
  onEnter?: (e: KeyboardEvent, value: string) => void;
  onEscape?: (e: KeyboardEvent) => void;
  onFocus?: (e: FocusEvent) => void;
  onBlur?: (e: FocusEvent) => void;

  className?: string;
  style?: Record<string, any>;
  textareaStyle?: Record<string, any>;
}

interface TextAreaState {
  editing: boolean;
  scrolledAmount: number;
}

/* ---------- Component ---------- */

export class TextArea extends Component<
  BoxProps & TextAreaProps,
  TextAreaState
> {
  textareaRef: RefObject<HTMLTextAreaElement>;
  handleOnInput: (e: Event) => void;
  handleOnChange: (e: Event) => void;
  handleKeyPress: (e: KeyboardEvent) => void;
  handleKeyDown: (e: KeyboardEvent) => void;
  handleFocus: (_e: FocusEvent) => void;
  handleBlur: (e: FocusEvent) => void;
  handleScroll: (e) => void;
  state: TextAreaState = {
    editing: false,
    scrolledAmount: 0,
  };

  constructor(props: TextAreaProps) {
    super(props);

    this.textareaRef = props.innerRef || createRef<HTMLTextAreaElement>();
    this.state = {
      editing: false,
      scrolledAmount: 0,
    };
    const { dontUseTabForIndent = false } = props;

    this.handleOnInput = (e: KeyboardEvent) => {
      const { onInput } = this.props;
      const target = e.target as HTMLTextAreaElement;

      if (!this.state?.editing) this.setEditing(true);
      onInput?.(e, target.value);
    };

    this.handleOnChange = (e: KeyboardEvent) => {
      const { onChange } = this.props;
      const target = e.target as HTMLTextAreaElement;

      if (this.state?.editing) this.setEditing(false);
      onChange?.(e, target.value);
    };

    this.handleKeyPress = (e: KeyboardEvent) => {
      const { onKeyPress } = this.props;
      const target = e.target as HTMLTextAreaElement;

      if (!this.state?.editing) this.setEditing(true);
      onKeyPress?.(e, target.value);
    };

    this.handleKeyDown = (e: KeyboardEvent) => {
      const { onChange, onInput, onEnter, onKey, selfClear } = this.props;
      const target = e.target as HTMLTextAreaElement;

      if (e.keyCode === KEY_ENTER) {
        this.setEditing(false);
        onChange?.(e, target.value);
        onInput?.(e, target.value);
        onEnter?.(e, target.value);

        if (selfClear) {
          target.value = '';
          target.blur();
        }
        return;
      }
      if (e.keyCode === KEY_ESCAPE) {
        this.props.onEscape?.(e);
        this.setEditing(false);

        if (selfClear) {
          target.value = '';
        } else {
          target.value = toInputValue(this.props.value);
          target.blur();
        }
        return;
      }

      if (!this.state?.editing) this.setEditing(true);
      // Custom key handler
      onKey?.(e, target.value);

      if (!dontUseTabForIndent && e.keyCode === KEY_TAB) {
        e.preventDefault();
        const { value, selectionStart, selectionEnd } = target;

        target.value =
          value.substring(0, selectionStart!) +
          '\t' +
          value.substring(selectionEnd!);

        target.selectionEnd = (selectionStart ?? 0) + 1;
        onInput?.(e, target.value);
      }
    };

    this.handleFocus = (_e: FocusEvent) => {
      if (!this.state?.editing) this.setEditing(true);
    };

    this.handleBlur = (e: FocusEvent) => {
      const { onChange } = this.props;
      const target = e.target as HTMLTextAreaElement;

      if (this.state?.editing) {
        this.setEditing(false);
        onChange?.(e, target.value);
      }
    };
    this.handleScroll = (e) => {
      const { displayedValue } = this.props;
      const input = this.textareaRef.current;
      if (displayedValue && input) {
        this.setState({
          scrolledAmount: input.scrollTop,
        });
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input) {
      input.value = toInputValue(nextValue);
    }
    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        input?.focus();

        if (this.props.autoSelect) {
          input?.select();
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input && typeof nextValue === 'string' && prevValue !== nextValue) {
      input.value = toInputValue(nextValue);
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  getValue(): string | undefined {
    return this.textareaRef.current?.value;
  }

  render() {
    // Input only props
    const {
      onChange,
      onKeyDown,
      onKeyPress,
      onInput,
      onFocus,
      onBlur,
      onEnter,
      value,
      maxLength,
      placeholder,
      scrollbar,
      noborder,
      displayedValue,
      resize,
      textareaStyle,
      ...boxProps
    } = this.props;
    // Box props
    const { className, fluid, nowrap, ...rest } = boxProps;
    const { scrolledAmount } = this.state;
    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          noborder && 'TextArea--noborder',
          className,
        ])}
        {...rest}
        style={{
          ...rest.style,
          'min-height': resize && rest.height ? rest.height : '',
          height: resize && rest.height ? 'max-content' : rest.height,
        }}
      >
        {!!displayedValue && (
          <Box position="absolute" width="100%" height="100%" overflow="hidden">
            <div
              className={classes([
                'TextArea__textarea',
                'TextArea__textarea_custom',
              ])}
              style={{
                transform: `translateY(-${scrolledAmount}px)`,
              }}
            >
              {displayedValue}
            </div>
          </Box>
        )}
        <textarea
          ref={this.textareaRef}
          className={classes([
            'TextArea__textarea',
            scrollbar && 'TextArea__textarea--scrollable',
            nowrap && 'TextArea__nowrap',
          ])}
          placeholder={placeholder}
          onChange={this.handleOnChange}
          onKeyDown={this.handleKeyDown}
          onKeyPress={this.handleKeyPress}
          onInput={this.handleOnInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur}
          onScroll={this.handleScroll}
          maxLength={maxLength}
          style={{
            color: displayedValue ? 'rgba(0, 0, 0, 0)' : 'inherit',
            // i cant find the fucking type for css propertys so fuck you
            resize: resize as 'none',
            position: resize !== 'none' ? 'relative' : undefined,
            'min-height':
              resize !== 'none' ? String(rest?.height || 'inherit') : 'inherit',
            height: resize !== 'none' ? 'max-content' : 'inherit',
            ...textareaStyle,
          }}
        />
      </Box>
    );
  }
}
