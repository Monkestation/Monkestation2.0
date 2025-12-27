import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';

enum CkeyPollEnum {
  PLEXORA_DOWN = -1,
  PLEXORA_CKEYPOLL_FAILED = 0,
  PLEXORA_CKEYPOLL_NOTLINKED,
  PLEXORA_CKEYPOLL_RECORDNOTVALID,
  PLEXORA_CKEYPOLL_LINKED,
  PLEXORA_CKEYPOLL_LINKED_ABSENT,
  PLEXORA_CKEYPOLL_LINKED_BANNED,
  PLEXORA_CKEYPOLL_LINKED_DELETED,
}
interface DiscordVerificationData {
  verification_code: string;
  discord_invite: string;
  discord_details: {
    status: CkeyPollEnum;
    id?: string;
    username?: string;
    displayname?: string;
  };
}

export const DiscordVerification = (props) => {
  const { data } = useBackend<DiscordVerificationData>();
  const { verification_code, discord_invite } = data;

  const getNoticeBox = () => {
    if (typeof data?.discord_details?.status !== 'number') {
      return (
        <NoticeBox danger>
          {`Plexora is either down, or the window wasn't given status information.`}
        </NoticeBox>
      );
    }

    const formatDiscordDetails = (
      details: DiscordVerificationData['discord_details'],
    ) => {
      if (details?.username && details?.displayname) {
        return `${details.username} (${details.displayname}) - ID: ${details.id}`;
      } else if (details?.username) {
        return `${details.username} (${details.displayname}) - ID: ${details.id}`;
      } else {
        return `Discord ID: ${details.id}`;
      }
    };

    switch (data?.discord_details?.status) {
      case CkeyPollEnum.PLEXORA_DOWN:
        return (
          <NoticeBox danger>
            {`Plexora is currently down, can'tt fetch verification data.`}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_FAILED:
        return (
          <NoticeBox danger>
            Plexora failed to get info.{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_NOTLINKED:
        return (
          <NoticeBox>Your ckey is not linked to a Discord account.</NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_RECORDNOTVALID:
        return <NoticeBox>The ckey record is invalid.</NoticeBox>;
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED:
        return (
          <NoticeBox success>
            Your ckey is successfully linked to Discord:{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_ABSENT:
        return (
          <NoticeBox>
            Your linked Discord account is no longer present:{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_BANNED:
        return (
          <NoticeBox danger>
            Your linked Discord account is banned:{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
      case CkeyPollEnum.PLEXORA_CKEYPOLL_LINKED_DELETED:
        return (
          <NoticeBox danger>
            Your linked Discord account shows as deleted:{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
      default:
        return (
          <NoticeBox>
            Unknown status. Discord details:{' '}
            {formatDiscordDetails(data.discord_details)}
          </NoticeBox>
        );
    }
  };
  return (
    <Window title="Discord Verification" width={700} height={800}>
      <Window.Content scrollable>
        {getNoticeBox()}
        <Section title="Your Verification Code">
          <Box>
            <Button
              icon="copy"
              onClick={() => navigator.clipboard.writeText(verification_code)}
            >
              Copy to clipboard
            </Button>
          </Box>
          <Box
            mt={1}
            p={1}
            style={{
              wordBreak: 'break-word',
              background: '#444',
              padding: '5px',
            }}
          >
            {verification_code}
          </Box>
        </Section>
        <Section title="Join the Discord">
          <Button icon="paperclip" as="a" href={discord_invite} target="_blank">
            Click to open in your browser
          </Button>
          <Box
            mt={1}
            p={1}
            style={{
              wordBreak: 'break-word',
              background: '#444',
              padding: '5px',
            }}
          >
            <a href={discord_invite}>{discord_invite}</a>
          </Box>
        </Section>

        <Section title="Verification Steps">
          <LabeledList>
            <LabeledList.Item label="Step 1">
              {`Click "Copy to Clipboard" or manually copy the code`}
              above.
            </LabeledList.Item>
            <LabeledList.Item label="Step 2">
              Join the Discord server using the invite link above.
            </LabeledList.Item>
            <LabeledList.Item label="Step 3">
              Read the rules and instructions in the Discord server.
            </LabeledList.Item>
            <LabeledList.Item label="Step 4">
              Navigate to <b>#bot-dump</b> and type in <b>/verifydiscord</b>.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image1.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 5">
              Paste your verification code into the code field then hit enter.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image2.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 6">
              {`Select `}
              <b>MRP1 or MRP2</b>
              {` from the server dropdown. (It doesn't matter)`}
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image3.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Step 7">
              After selecting the server, you should be verified and
              reconnected.
              <Box mt={1}>
                <img
                  src={resolveAsset('dverify_image4.png')}
                  style={{ 'max-width': '100%' }}
                />
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
