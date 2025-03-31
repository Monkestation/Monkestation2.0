import { useBackend, useLocalState } from '../backend';
import { Section, Button, Box, Flex, TextArea } from '../components';
import { Window } from '../layouts';
import { KEY_ENTER } from 'common/keycodes';

export const TicketPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const buttons = [
    [
      {
        name: '',
        act: 'adminmoreinfo',
        icon: 'question',
        disabled: !data.has_mob,
      },
      {
        name: 'PP',
        act: 'PP',
        icon: 'user',
        disabled: !data.has_mob,
      },
      {
        name: 'VV',
        act: 'VV',
        icon: 'cog',
        disabled: !data.has_mob,
      },
      {
        name: 'FLW',
        act: 'FLW',
        icon: 'arrow-up',
        disabled: !data.has_mob,
      },
      {
        name: 'TP',
        act: 'TP',
        icon: 'book-dead',
        disabled: !data.has_mob,
      },
      {
        name: 'Logs',
        act: 'Logs',
        icon: 'file',
        disabled: !data.has_mob,
      },
      {
        name: 'Smite',
        act: 'Smite',
        icon: 'bolt',
        disabled: !data.has_mob,
      },
    ],
    [
      {
        name: 'Notes',
        act: 'Notes',
        icon: 'paperclip',
      },
      {
        name: 'Claim',
        act: 'Administer',
        icon: 'folder-open',
      },
      {
        name: 'Popup',
        act: 'popup',
        icon: 'window-restore',
      },
      {
        name: 'Reject',
        act: 'Reject',
        icon: 'ban',
      },
      {
        name: data.is_resolved ? 'Reopen' : 'Resolve',
        act: data.is_resolved ? 'Reopen' : 'Resolve',
        icon: 'check',
      },
    ],
    [
      {
        name: 'IC',
        act: 'IC',
        icon: 'male',
        disabled: !data.has_client,
      },
      {
        name: 'MHelp',
        act: 'MHelp',
        icon: 'info',
        disabled: !data.has_client,
      },
      {
        name: 'Close',
        act: 'Close',
        icon: 'close',
      },
      {
        name: 'Replay',
        act: 'Replay',
        icon: 'rotate-right',
      },
    ],
  ];
  if (data.is_admin) {
    return (
      <Window
        theme="admintickets"
        title="Ticket Viewer"
        width={700}
        height={700}
        resizable
      >
        <Window.Content scrollable>
          <Section title={data.initiator_key_name + ': ' + data.name}>
            <span
              class="Section__titleText"
              style={{ 'font-weight': 'normal' }}
            >
              Assigned Admin: <b>{data.admin || 'Unassigned'}</b>
              <br />
              <span class={data.is_resolved ? 'color-good' : 'color-bad'}>
                Is{data.is_resolved ? '' : ' not'} resolved
              </span>
              <br />
              {data.opened_at}
            </span>
            <Section level="2" m="-5px">
              Job: <b>{data.role}</b> <br />
              Antag: <b>{data.antag || 'No'}</b>
              <br />
              Location: <b>{data.location}</b>
            </Section>
            <Section m="-5px" level="2">
              {buttons.map((button_row, i) => (
                <Flex key={i} direction="row">
                  {button_row.map((button) => (
                    <Flex.Item key={button.act} grow={1}>
                      <Button
                        fluid
                        m="2.5px"
                        icon={button.icon}
                        disabled={button.disabled}
                        selected={button.selected}
                        onClick={(
                          (val) => () =>
                            act(val)
                        )(button.act)}
                      >
                        {button.name}
                      </Button>
                    </Flex.Item>
                  ))}
                </Flex>
              ))}
            </Section>
          </Section>
          <TicketMessages ticket={data} title="Messages" />
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window title="Ticket Viewer" width={700} height={700} resizable>
      <Window.Content scrollable>
        <TicketMessages title={data.name} ticket={data} />
      </Window.Content>
    </Window>
  );
};

export const TicketMessages = (props, context) => {
  const { ticket, title } = props;
  const { act } = useBackend(context);

  const [message, setMessage] = useLocalState(context, '');

  return (
    <Section lineHeight={1.25} title={title}>
      {ticket.log.map(
        (entry) =>
          (
            <Box key={entry.time} m="2px">
              {entry.time} - <b>{entry.ckey}</b> - {entry.text}
            </Box>
          ) || '',
      )}
      <TextArea
        fluid
        placeholder="Message to send"
        selfclear
        value={message}
        className="replybox"
        resize="vertical"
        onChange={(e, value) => {
          if (e.keyCode === KEY_ENTER) {
            setMessage('');
            e.target.value = message;
            act('send_message', { message: value });
          } else {
            setMessage(value);
          }
        }}
      />
      <Button
        mt="5px"
        onClick={() => {
          act('send_message', { message: message });
          setMessage('');
        }}
      >
        Send Message
      </Button>
    </Section>
  );
};
