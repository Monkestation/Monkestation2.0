/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { classes } from 'common/react';
import React, { RefObject, useEffect, useRef, useState } from 'react';
import { computeBoxClassName, computeBoxProps } from 'tgui-core/ui';
import { KEY, isEscape } from 'common/keys';
import { debounce } from 'es-toolkit';
import { TextInputProps } from './Input';

type Props = Partial<{
  /**
   * Disables 'enter' functionality so the textarea does not submit on
   * enter key press
   */
  disableEnter: boolean;
  /** Don't use tab for indent */
  dontUseTabForIndent: boolean;
  /** Ref to the textarea element. */
  ref: RefObject<HTMLTextAreaElement | null>;
  /**
   * Provides a Record with key: markupChar entries which can be used for
   * ctrl + key combinations to surround a selected text with the markup
   * character
   */
  userMarkup: Record<string, string>;
}> &
  TextInputProps<HTMLTextAreaElement>;

function getMarkupString(
  inputText: string,
  markupType: string,
  startPosition: number,
  endPosition: number,
): string {
  return `${inputText.substring(0, startPosition)}${markupType}${inputText.substring(startPosition, endPosition)}${markupType}${inputText.substring(endPosition)}`;
}

// Prevent input parent change event from being called too often
const textareaDebounce = debounce((onChange: () => void) => onChange(), 250);

/**
 * ## Textarea
 *
 * An input for larger amounts of text. Use this when you want inputs larger
 * than one row.
 *
 * - [View documentation on tgui core](https://tgstation.github.io/tgui-core/?path=/docs/components-textarea--docs)
 * - [View inherited Box props](https://tgstation.github.io/tgui-core/?path=/docs/components-box--docs)
 */
export function TextArea(props: Props) {
  const {
    autoFocus,
    autoSelect,
    className,
    disabled,
    disableEnter,
    dontUseTabForIndent,
    expensive,
    fluid,
    maxLength,
    monospace,
    onBlur,
    onChange,
    onInput,
    onEnter,
    onEscape,
    onKeyDown,
    placeholder,
    ref,
    selfClear,
    spellcheck = false,
    userMarkup,
    value,
    ...rest
  } = props;

  const ourRef = useRef<HTMLTextAreaElement>(null);
  const textareaRef = ref ?? ourRef;

  const inputFn = onInput ?? onChange ?? undefined;

  const [innerValue, setInnerValue] = useState(value ?? '');

  function handleBlur(_event: React.FocusEvent<HTMLTextAreaElement>) {
    onBlur?.(innerValue);
  }

  function handleChange(event: React.ChangeEvent<HTMLTextAreaElement>) {
    const value = event.currentTarget.value;
    setInnerValue(value);

    if (!inputFn) return;
    if (expensive) {
      textareaDebounce(() => inputFn(event, value));
    } else {
      inputFn(event, value);
    }
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLTextAreaElement>) {
    onKeyDown?.(event);

    // Enter
    if (!disableEnter && event.key === KEY.Enter && !event.shiftKey) {
      event.preventDefault();
      onEnter?.(event, event.currentTarget.value);
      if (selfClear) {
        setInnerValue('');
      }
      event.currentTarget.blur();
      return;
    }

    // Escape
    if (isEscape(event.key)) {
      onEscape?.(event, event.currentTarget.value);
      event.currentTarget.blur();
      return;
    }

    // Tab
    if (!dontUseTabForIndent && event.key === KEY.Tab) {
      event.preventDefault();
      const { value, selectionStart, selectionEnd } = event.currentTarget;
      setInnerValue(
        `${value.substring(0, selectionStart)}\t${value.substring(selectionEnd)}`,
      );
      event.currentTarget.selectionEnd = selectionStart + 1;
      onInput?.(event as any, event.currentTarget.value);
      return;
    }

    // User markup
    if (
      userMarkup &&
      (event.ctrlKey || event.metaKey) &&
      userMarkup[event.key]
    ) {
      event.preventDefault();

      const { selectionStart, selectionEnd, value } = event.currentTarget;
      const markupString = userMarkup[event.key];
      setInnerValue(
        getMarkupString(value, markupString, selectionStart, selectionEnd),
      );
      event.currentTarget.selectionEnd = selectionEnd + markupString.length * 2;
      onInput?.(event as any, event.currentTarget.value);
      return;
    }
  }

  /** Focuses the input on mount */
  useEffect(() => {
    if (autoFocus || autoSelect) {
      setTimeout(() => {
        textareaRef.current?.focus();
        if (autoSelect) {
          textareaRef.current?.select();
        }
      }, 1);
    }
  }, []);

  /** Updates the initial value on props change */
  useEffect(() => {
    if (
      textareaRef.current &&
      document.activeElement !== textareaRef.current &&
      value !== innerValue
    ) {
      setInnerValue(value ?? '');
    }
  }, [value]);

  const boxProps = computeBoxProps(rest);
  const clsx = classes([
    'Input',
    'TextArea',
    fluid && 'Input--fluid',
    monospace && 'Input--monospace',
    disabled && 'Input--disabled',
    computeBoxClassName<HTMLTextAreaElement>(rest),
    className,
  ]);

  return (
    <textarea
      {...boxProps}
      autoComplete="off"
      className={clsx}
      maxLength={maxLength}
      onBlur={handleBlur}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      placeholder={placeholder}
      ref={textareaRef as React.RefObject<HTMLTextAreaElement>}
      spellCheck={spellcheck}
      value={innerValue}
    />
  );
}
