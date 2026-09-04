import { AccountingConsoleContents } from './AccountingConsole/index';
import { NtosWindow } from '../layouts';

export const NtosAccountingConsole = () => {
  return (
    <NtosWindow width={680} height={475}>
      <NtosWindow.Content fontFamily="Tahoma">
        <AccountingConsoleContents />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
