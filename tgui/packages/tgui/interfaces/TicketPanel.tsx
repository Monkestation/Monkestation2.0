import { useBackend } from '../backend';
import {
  Section,
  Button,
  Box,
  Flex,
  TextArea,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';
import { createRef, useCallback, useEffect, useRef, useState } from 'react';
import { Component } from 'react';
import { BooleanLike } from 'common/react';
import { KEY_BACKSPACE } from 'common/keycodes';

const getButtons = (data: TicketData) => [
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
      name: 'Smite',
      act: 'Smite',
      icon: 'bolt',
      disabled: !data.has_mob,
    },
  ],
  [
    {
      name: 'Logs',
      act: 'Logs',
      icon: 'file',
      disabled: !data.has_mob,
    },
    {
      name: 'Notes',
      act: 'Notes',
      icon: 'paperclip',
    },
    // {
    //   name: 'Claim',
    //   act: 'Claim',
    //   icon: 'folder-open',
    // },
    {
      name: 'Popup',
      act: 'popup',
      icon: 'window-restore',
    },
  ],
  [
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
  ],
];

const State2Color = (state) => {
  switch (state) {
    case TicketState.ACTIVE:
      return 'color-grey';
    case TicketState.CLOSED:
      return 'color-bad';
    case TicketState.RESOLVED:
      return 'color-good';
  }
};

interface TicketData {
  is_admin: BooleanLike;
  name: string;
  id: string;
  ourckey: string;
  admin: string | null;
  is_resolved: BooleanLike;
  state: TicketState;

  initiator_key_name: string;
  opened_at: string;

  has_client: BooleanLike;
  has_mob: BooleanLike;
  role: string;
  antag: string | null;
  currently_typing: string[] | string;

  location: string;
  log: Array<{
    text: string;
    time: string;
    ckey: string;
  }>;

  related_tickets: {
    id: string;
    title: string;
  }[];
}

enum TicketState {
  ACTIVE = 1,
  CLOSED,
  RESOLVED,
}

const TicketStateString = {
  [TicketState.ACTIVE]: 'Active',
  [TicketState.CLOSED]: 'Closed',
  [TicketState.RESOLVED]: 'Resolved',
};

interface TicketPanelState {
  autoscroll: boolean;
}

export class TicketPanel extends Component<{}, TicketPanelState> {
  logRef = createRef<HTMLDivElement>();
  act = useBackend().act;

  constructor(props) {
    super(props);
    this.state = {
      autoscroll: true,
    };
  }

  componentDidUpdate() {
    if (!this.state?.autoscroll) return;

    const el = this.logRef.current;
    if (el) {
      el.scrollTop = el.scrollHeight;
    }
  }

  handleToggleAutoScroll = () => {
    this.setState((prev) => ({ autoscroll: !prev.autoscroll }));
  };

  render() {
    const { data, act } = useBackend<TicketData>();

    if (data.is_admin) {
      return (
        <Window
          theme="admintickets"
          title={`Ticket #${data.id} - ${data.name} - ${data.is_resolved ? 'Resolved' : 'Unresolved'}`}
          width={1200}
          height={700}
        >
          <Window.Content>
            <Stack direction="row" fill>
              <Stack.Item width="60%">
                <Stack vertical fill>
                  <Stack.Item>
                    <Section
                      title={
                        <>
                          <Tooltip
                            content={`Status: ${TicketStateString[data.state]}`}
                            position="bottom"
                          >
                            <span
                              className={State2Color(data.state)}
                              style={{
                                textDecoration: 'underline',
                              }}
                            >
                              Ticket #{data.id}
                            </span>{' '}
                          </Tooltip>
                          - {data.initiator_key_name}: {data.name}
                        </>
                      }
                    >
                      <Stack vertical fill>
                        <Stack.Item>
                          <span>
                            Assigned Admin:{' '}
                            <b>
                              <>
                                {data.admin || 'Unassigned'}{' '}
                                <Button
                                  m="1.0px"
                                  icon={
                                    data.admin ? 'folder-closed' : 'folder-open'
                                  }
                                  onClick={() =>
                                    act(data.admin ? 'Unclaim' : 'Claim')
                                  }
                                  lineHeight="1.3em"
                                >
                                  {data.admin ? 'Unclaim' : 'Claim'}
                                </Button>
                              </>
                            </b>
                            <br />
                            {data.opened_at}
                          </span>
                        </Stack.Item>
                        <Stack.Item>
                          Job: <b>{data.role}</b> <br />
                          Antag: <b>{data.antag || 'No'}</b>
                          <br />
                          Location: <b>{data.location}</b>
                        </Stack.Item>
                        <Stack.Item>
                          {getButtons(data).map((button_row, i) => (
                            <Flex key={i} direction="row">
                              {button_row.map((button) => (
                                <Flex.Item key={button.act} grow={1}>
                                  <Button
                                    fluid
                                    m="2.5px"
                                    icon={button.icon}
                                    disabled={button.disabled}
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
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow={1} height="100%">
                    <Section
                      title="Event log"
                      fill
                      scrollable
                      // scrollableRef={this.logRef}
                      ref={this.logRef}
                      buttons={
                        <Button
                          icon={this.state?.autoscroll ? 'lock' : 'unlock'}
                          selected={this.state?.autoscroll}
                          onClick={this.handleToggleAutoScroll}
                          tooltip="Toggle autoscroll"
                        />
                      }
                    >
                      {data.log.map((entry) => (
                        <Box key={entry.time} m="2px">
                          {entry.time} - <b>{entry.ckey}</b> -{' '}
                          {decodeHtmlEntities(entry.text)}
                        </Box>
                      ))}
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item width="40%">
                <TicketMessages title="Message" />
              </Stack.Item>
            </Stack>
          </Window.Content>
        </Window>
      );
    }
    return (
      <Window title="Ticket Viewer" width={700} height={700}>
        <Window.Content scrollable>
          <TicketMessages title={data.name} showTicketLog />
        </Window.Content>
      </Window>
    );
  }
}

interface TicketMessagesProps {
  title: string;
  showTicketLog?: boolean;
}

interface TicketMessagesState {
  message: string;
  lastTyping: number;
}

export function TicketMessages(props: TicketMessagesProps) {
  const { title, showTicketLog } = props;

  const textareaRef = useRef<HTMLTextAreaElement | null>(null);
  const { act, data: ticket } = useBackend<TicketData>();

  const [message, setMessage] = useState('');
  const [lastTyping, setLastTyping] = useState(0);

  const isTicketActive = useCallback(
    () => ticket.state === TicketState.ACTIVE,
    [ticket.state],
  );

  const sendMessage = useCallback(
    (value: string) => {
      if (!value) return;

      act('send_message', { message: value });
      setMessage('');

      if (textareaRef.current) {
        textareaRef.current.value = '';
        textareaRef.current.focus();
      }
    },
    [act],
  );

  useEffect(() => {
    const el = textareaRef.current;
    if (!el) return;

    const onInput = () => {
      const value = el.value;
      const now = Date.now();

      if (!lastTyping || now - lastTyping >= 500) {
        act('typing');
        setLastTyping(now);
      }

      setMessage(value);
    };

    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Enter' && e.ctrlKey) {
        e.preventDefault();
        sendMessage(el.value);
      }
    };

    el.addEventListener('input', onInput);
    el.addEventListener('keydown', onKeyDown);

    return () => {
      el.removeEventListener('input', onInput);
      el.removeEventListener('keydown', onKeyDown);
    };
  }, [act, lastTyping, sendMessage]);

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.disabled = !isTicketActive();
    }
  }, [isTicketActive]);

  const typing =
    typeof ticket.currently_typing === 'string'
      ? ticket.currently_typing
      : ticket.currently_typing
        ? Object.keys(ticket.currently_typing).filter(
            (e) => e !== ticket.ourckey,
          )
        : [];

  return (
    <Stack vertical>
      <Stack.Item>
        <Section lineHeight={1.25} title={title}>
          {!!showTicketLog &&
            ticket.log.map((entry) => (
              <Box key={entry.time} m="2px">
                {entry.time} - <b>{entry.ckey}</b> -{' '}
                {decodeHtmlEntities(entry.text)}
              </Box>
            ))}

          <TextArea
            fluid
            ref={textareaRef}
            placeholder="Enter your message (Ctrl+Enter to send)"
            className="replybox"
            style={{ resize: 'vertical' }}
            height="350px"
          />

          <div>
            <Button
              mt="5px"
              onClick={() => sendMessage(message)}
              disabled={!isTicketActive()}
            >
              Send Message
            </Button>

            {!!typing?.length &&
              (ticket.is_admin ? (
                <span>
                  {(typing as string[]).join(', ')}{' '}
                  {typing.length > 1 ? 'are typing' : 'is typing'}...
                </span>
              ) : (
                <span>An admin is typing...</span>
              ))}
          </div>
        </Section>
      </Stack.Item>

      <Stack.Item>
        {ticket.related_tickets.length > 0 && ticket.is_admin && (
          <Section title="Related Tickets" mt="5px">
            {ticket.related_tickets.map((related) => (
              <Box key={related.id} m="2px">
                <a
                  href="#"
                  onClick={(e) => {
                    e.preventDefault();
                    act('open_ticket', { ticket_id: related.id });
                  }}
                >
                  <b>#{related.id}</b>
                </a>
                : {related.title}
              </Box>
            ))}
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
}
