/* eslint-disable react/jsx-max-depth */
import { useBackend } from '../backend';
import {
  Section,
  Button,
  Box,
  Flex,
  Stack,
  Tooltip,
  TextArea,
} from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';
import {
  ComponentProps,
  forwardRef,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';
import { BooleanLike } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'tgui-core/ui';
import { classes } from 'tgui-core/react';

type TicketButton = {
  name: string;
  act: string;
  icon: string;
  disabled?: boolean;
  tooltip?: string;
};
const getButtons: (data: TicketData) => TicketButton[][] = (
  data: TicketData,
) => [
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
    {
      name: 'Popup',
      act: 'popup',
      icon: 'window-restore',
      disabled: !data.can_popup,
      tooltip: !data.can_popup
        ? "Can't popup, player is in the lobby."
        : undefined,
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

const State2Color = (state: TicketState) => {
  switch (state) {
    case TicketState.ACTIVE:
      return 'color-light-grey';
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
  role: {
    type: string;
    title: string;
  };
  antag: string | null;
  currently_typing: string[] | string;

  location: string;
  log: Array<{
    text: string;
    time: string;
    ckey: string;
  }>;
  can_popup?: BooleanLike;

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

export function TicketPanel() {
  const { data, act } = useBackend<TicketData>();
  const logRef = useRef<HTMLDivElement>(null);

  const [autoscroll, setAutoscroll] = useState(true);

  useEffect(() => {
    if (!autoscroll) return;

    const el = logRef.current;
    if (el) {
      el.scrollTop = el.scrollHeight;
    }
  });

  const handleToggleAutoScroll = () => {
    setAutoscroll((prev) => !prev);
  };

  if (data.is_admin) {
    return (
      <Window
        theme="admintickets"
        title={`Ticket #${data.id} - ${data.initiator_key_name} - ${data.is_resolved ? 'Resolved' : 'Unresolved'}`}
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
                      <Stack
                        style={{
                          display: 'flex',
                          width: '100%',
                        }}
                      >
                        <Stack.Item>
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
                        </Stack.Item>
                        <Stack.Item
                          style={{
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                            overflow: 'hidden',
                            flex: 1,
                          }}
                        >
                          - {data.initiator_key_name}: {data.name}
                        </Stack.Item>
                      </Stack>
                    }
                  >
                    <Stack vertical fill>
                      <Stack.Item>
                        Assigned Admin:{' '}
                        <b>
                          {data.admin || 'Unassigned'}{' '}
                          <Button
                            m="1.0px"
                            icon={data.admin ? 'folder-closed' : 'folder-open'}
                            onClick={() =>
                              act(data.admin ? 'Unclaim' : 'Claim')
                            }
                            disabled={data.is_resolved}
                            lineHeight="1.3em"
                          >
                            {data.admin ? 'Unclaim' : 'Claim'}
                          </Button>
                        </b>
                        <br />
                        {data.opened_at}
                        <br />
                        Job:{' '}
                        <b>
                          {data.role?.title} ({data.role?.type})
                        </b>{' '}
                        <br />
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
                                  tooltip={button.tooltip}
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
                    ref={logRef}
                    buttons={
                      <Button
                        icon={autoscroll ? 'lock' : 'unlock'}
                        selected={autoscroll}
                        onClick={handleToggleAutoScroll}
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

interface TicketMessagesProps {
  title: string;
  showTicketLog?: boolean;
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
      if (!value || value.trim() === '') return;

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

      if (value.trim() === '') {
        act('typing', { stopped: true });
      } else if (!lastTyping || now - lastTyping >= 500) {
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

  const typing = ticket.currently_typing;

  function Typing() {
    if (!typing) return null;

    if (typeof typing === 'object') {
      const keys = Object.keys(typing);
      if (keys.length === 0) return null;

      const names = keys.join(', ');
      const verb = keys.length > 1 ? 'are' : 'is';
      return (
        <span>
          {names} {verb} typing…
        </span>
      );
    }

    return <span>{typing} is typing…</span>;
  }

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

          <TguiRawTextArea
            fluid
            ref={textareaRef}
            placeholder="Enter your message (Ctrl+Enter to send)"
            className="replybox"
            style={{
              lineHeight: '1em',
              resize: 'vertical',
              height: showTicketLog ? '100px' : '250px',
            }}
          />

          <div>
            <Button
              mt="5px"
              onClick={() => sendMessage(message)}
              disabled={!isTicketActive()}
            >
              Send Message
            </Button>

            <Typing />
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

export const TguiRawTextArea = forwardRef<
  HTMLTextAreaElement,
  ComponentProps<typeof TextArea>
>(
  // eslint-disable-next-line prefer-arrow-callback
  function TguiRawTextArea(props, ref) {
    const { className, fluid, monospace, disabled, ...rest } = props;

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
      <textarea {...boxProps} ref={ref} className={clsx} autoComplete="off" />
    );
  },
);
