import { Component } from 'inferno';
import { useBackend } from '../../backend';

import { Box, Button, Modal, Stack } from '../../components';
import { PreferencesMenuData } from './data';

interface DeleteCharacterPopupProps {
  close: () => void;
}

interface DeleteCharacterPopupState {
  secondsLeft: number;
}

export class DeleteCharacterPopup extends Component<
  DeleteCharacterPopupProps,
  DeleteCharacterPopupState
> {
  private interval: NodeJS.Timeout | null = null;

  state: DeleteCharacterPopupState = {
    secondsLeft: 3,
  };

  public componentDidMount(): void {
    this.interval = setInterval(() => {
      this.setState((prevState) => ({
        secondsLeft: prevState.secondsLeft - 1,
      }));
    }, 1000);
  }

  public componentWillUnmount(): void {
    if (this.interval !== null) {
      clearInterval(this.interval);
      this.interval = null;
    }
  }

  public render() {
    const { close } = this.props;
    const { act, data } = useBackend<PreferencesMenuData>();
    const { secondsLeft } = this.state;

    return (
      <Modal>
        <Stack vertical textAlign="center" align="center">
          <Stack.Item>
            <Box fontSize="3em">Wait!</Box>
          </Stack.Item>

          <Stack.Item maxWidth="300px">
            <Box>
              {`You're about to delete `}
              <b>{data.character_preferences.names[data.name_to_use]}</b>{' '}
              {`forever. Are you sure you want to do this?`}
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Stack fill>
              <Stack.Item>
                {/* Explicit width so that the layout doesn't shift */}
                <Button
                  color="danger"
                  disabled={secondsLeft > 0}
                  width="80px"
                  onClick={() => {
                    act('remove_current_slot');
                    close();
                  }}
                >
                  {secondsLeft <= 0 ? 'Delete' : `Delete (${secondsLeft})`}
                </Button>
              </Stack.Item>

              <Stack.Item>
                <Button onClick={close}>{"No, don't delete"}</Button>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Modal>
    );
  }
}
