import { Dropdown as TGUIDropdown } from 'tgui-core/components';
import type { ComponentProps, ReactNode } from 'react';

type Shim = Omit<
  ComponentProps<typeof TGUIDropdown>,
  'displayText' | 'selected'
> &
  Partial<{
    displayText: ReactNode;
    selected: string;
  }>;

export function Dropdown(props: Shim) {
  return (
    <TGUIDropdown {...props} selected={props.displayText ?? props.selected} />
  );
}
