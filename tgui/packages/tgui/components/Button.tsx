import { BooleanLike } from 'common/react';
import { ComponentProps } from 'react';
import { Button as TGUIButton } from 'tgui-core/components';

export const Button = (props: ComponentProps<typeof TGUIButton>) => {
  return <TGUIButton {...props} />;
};

type CheckboxPropsShim = ComponentProps<(typeof TGUIButton)['Checkbox']> &
  Partial<{
    transparent: boolean;
    checked: BooleanLike;
  }>;

Button.Checkbox = ({ checked, ...rest }: CheckboxPropsShim) => {
  return (
    <TGUIButton
      // we do not want transparent by default
      color={rest.color ?? undefined}
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest}
    />
  );
};

Button.File = TGUIButton.File;
Button.Confirm = TGUIButton.Confirm;
Button.Input = TGUIButton.Input;
