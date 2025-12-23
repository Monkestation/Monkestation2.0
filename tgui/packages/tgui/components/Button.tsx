/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Placement } from '@popperjs/core';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from 'common/keycodes';
import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import {
  ChangeEvent,
  Component,
  createRef,
  FocusEvent,
  InfernoKeyboardEvent,
  InfernoMouseEvent,
  InfernoNode,
  RefObject,
} from 'inferno';
import { createLogger } from '../logging';
import { Box, BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

const logger = createLogger('Button');

export type Props = {
  captureKeys?: boolean;
  fluid?: boolean;
  icon?: any;
  iconRotation?: number;
  iconSpin?: BooleanLike;
  iconColor?: any;
  iconRight?: boolean;
  disabled?: BooleanLike;
  selected?: BooleanLike;
  tooltip?: InfernoNode;
  tooltipPosition?: Placement;
  ellipsis?: boolean;
  compact?: boolean;
  circular?: boolean;
  onClick?: (e: any) => void;
  verticalAlignContent?: string;
} & BoxProps;

export const Button = (props: Props) => {
  const {
    className,
    fluid,
    icon,
    iconRotation,
    iconSpin,
    iconColor,
    color,
    disabled,
    selected,
    iconRight,
    tooltip,
    tooltipPosition,
    ellipsis,
    compact,
    circular,
    content,
    children,
    onClick,
    verticalAlignContent,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  const toDisplay: InfernoNode = content || children;

  let buttonContent = (
    <div
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        circular && 'Button--circular',
        compact && 'Button--compact',
        iconRight && 'Button--iconPosition--right',
        verticalAlignContent && 'Button--flex',
        verticalAlignContent && fluid && 'Button--flex--fluid',
        verticalAlignContent &&
          'Button--verticalAlignContent--' + verticalAlignContent,
        color && typeof color === 'string'
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={disabled ? undefined : 0}
      onClick={(e) => {
        if (!disabled && onClick) {
          onClick(e);
        }
      }}
      onKeyDown={(e) => {
        if (!props.captureKeys) {
          return;
        }
        const keyCode = e.keyCode;
        // Simulate a click when pressing space or enter.z
        if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (keyCode === KEY_ESCAPE) {
          e.preventDefault();
          return;
        }
      }}
      {...computeBoxProps(rest)}
    >
      <div className="Button__content">
        {icon && !iconRight && (
          <Icon
            name={icon}
            color={iconColor}
            rotation={iconRotation}
            spin={iconSpin}
          />
        )}
        {toDisplay}
        {icon && iconRight && (
          <Icon
            name={icon}
            color={iconColor}
            rotation={iconRotation}
            spin={iconSpin}
          />
        )}
      </div>
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
};

Button.defaultHooks = pureComponentHooks;

type CheckProps = Partial<{
  checked: BooleanLike;
}> &
  Props;

export const ButtonCheckbox = (props: CheckProps) => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest}
    />
  );
};

Button.Checkbox = ButtonCheckbox;

type ConfirmProps = {
  confirmContent?: string;
  confirmColor?: string;
  confirmIcon?: string;
} & Props;
export class ButtonConfirm extends Component<ConfirmProps> {
  state = {
    clickedOnce: false,
  };

  handleClick(event: InfernoMouseEvent<HTMLDivElement>): void {
    if (!this.state.clickedOnce) {
      this.setClickedOnce(true);
      return;
    }

    this.props.onClick?.(event);
    this.setClickedOnce(false);
  }

  setClickedOnce(clickedOnce: boolean) {
    this.setState({
      clickedOnce,
    });
    if (clickedOnce) {
      setTimeout(() => window.addEventListener('click', this.handleClick));
    } else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  render() {
    const {
      confirmContent = 'Confirm?',
      confirmColor = 'bad',
      confirmIcon,
      ellipsis = true,
      icon,
      color,
      content,
      onClick,
      ...rest
    } = this.props;
    return (
      <Button
        // content={this.state.clickedOnce ? confirmContent : content}
        icon={this.state.clickedOnce ? confirmIcon : icon}
        color={this.state.clickedOnce ? confirmColor : color}
        onClick={this.handleClick}
        {...rest}
      >
        {this.state.clickedOnce ? confirmContent : this.props.children}
      </Button>
    );
  }
}

Button.Confirm = ButtonConfirm;

type InputProps = Partial<{
  /** Text to display on the button exclusively. If left blank, displays the value */
  buttonText: string;
  /** Use the value prop. This is done to be uniform with other inputs. */
  children: never;
  /** Max length of the input */
  maxLength: number;
  /** Action on outside click or enter key */
  onCommit: (value: string) => void;
  /** Reference to the inner input */
  ref?: RefObject<HTMLInputElement>;
  /** The value of the input */
  value: string;
}> &
  Props;

export class ButtonInput extends Component<InputProps> {
  state = {
    inInput: false,
  };

  setInInput(inInput: boolean) {
    this.setState({
      inInput,
    });
    if (this.props.ref?.current) {
      const input = this.props.ref.current;
      if (inInput) {
        input.value = this.props.currentValue || '';
        try {
          input.focus();
          input.select();
        } catch {}
      }
    }
  }

  commitResult(
    e: FocusEvent<HTMLInputElement> | InfernoKeyboardEvent<HTMLInputElement>,
  ) {
    if (this.props.ref && this.props.ref.current) {
      const input = this.props.ref.current;
      const hasValue = input.value !== '';
      if (hasValue) {
        this.props.onCommit?.(input.value);
        return;
      } else {
        if (!this.props.defaultValue) {
          return;
        }
        this.props.onCommit?.(this.props.defaultValue);
      }
    }
  }

  render() {
    const {
      fluid,
      content,
      icon,
      iconRotation,
      iconSpin,
      tooltip,
      tooltipPosition,
      color = 'default',
      placeholder,
      maxLength,
      ...rest
    } = this.props;

    let buttonContent = (
      <Box
        className={classes([
          'Button',
          fluid && 'Button--fluid',
          'Button--color--' + color,
        ])}
        {...rest}
        onClick={() => this.setInInput(true)}
      >
        {icon && <Icon name={icon} rotation={iconRotation} spin={iconSpin} />}
        <div>{content}</div>
        <input
          ref={this.props.ref}
          className="NumberInput__input"
          style={{
            display: !this.state.inInput ? 'none' : undefined,
            'text-align': 'left',
          }}
          onBlur={(e) => {
            if (!this.state.inInput) {
              return;
            }
            this.setInInput(false);
            this.commitResult(e);
          }}
          onKeyDown={(e) => {
            if (e.keyCode === KEY_ENTER) {
              this.setInInput(false);
              this.commitResult(e);
              return;
            }
            if (e.keyCode === KEY_ESCAPE) {
              this.setInInput(false);
            }
          }}
        />
      </Box>
    );

    if (tooltip) {
      buttonContent = (
        <Tooltip content={tooltip} position={tooltipPosition}>
          {buttonContent}
        </Tooltip>
      );
    }

    return buttonContent;
  }
}

Button.Input = ButtonInput;

type FileProps = {
  accept: string;
  multiple?: boolean;
  onSelectFiles: (files: string | string[]) => void;
} & Props;

export class ButtonFile extends Component<FileProps> {
  inputRef = createRef<HTMLInputElement>();

  async read(files: FileList): Promise<string[]> {
    const promises = Array.from(files).map((file) => {
      const reader = new FileReader();

      return new Promise<string>((resolve) => {
        reader.onload = () => resolve(reader.result as string);
        reader.readAsText(file);
      });
    });

    return await Promise.all(promises);
  }

  async handleChange(event: ChangeEvent<HTMLInputElement>): Promise<void> {
    const files = event.target.files;
    if (files?.length) {
      const readFiles = await this.read(files);
      this.props.onSelectFiles(this.props.multiple ? readFiles : readFiles[0]);
    }
  }

  render() {
    const { onSelectFiles, accept, multiple, ...rest } = this.props;
    return (
      <>
        <Button {...rest} onClick={() => this.inputRef.current?.click()} />
        <input
          hidden
          type="file"
          ref={this.inputRef}
          accept={accept}
          multiple={multiple}
          onChange={this.handleChange}
        />
      </>
    );
  }
}

Button.File = ButtonFile;
