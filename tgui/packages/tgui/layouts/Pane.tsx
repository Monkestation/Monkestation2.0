/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Box } from '../components';
import type { BoxProps } from '../components/Box';
import { Layout } from './Layout';

type Props = Partial<{
  canSuspend: boolean;
  theme: string;
}> &
  BoxProps;

export function Pane(props: Props) {
  const { theme, canSuspend, children, className, ...rest } = props;
  const { suspended } = useBackend();

  const isSuspended = canSuspend && suspended;

  return (
    <Layout className={classes(['Window', className])} theme={theme} {...rest}>
      <Box fillPositionedParent>{!isSuspended && children}</Box>
    </Layout>
  );
}

type ContentProps = Partial<{
  fitted: boolean;
  scrollable: boolean;
}> &
  BoxProps;

function PaneContent(props: ContentProps) {
  const { className, fitted, children, ...rest } = props;

  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {fitted ? (
        children
      ) : (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
}

Pane.Content = PaneContent;
