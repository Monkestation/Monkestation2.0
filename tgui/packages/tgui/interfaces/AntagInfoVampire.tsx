import type { BooleanLike } from 'common/react';
import { type SetStateAction, useState } from 'react';
import { sanitizeText } from 'tgui/sanitize';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

type VampireInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  powers: PowerInfo[];
  vassal_count: number;
  max_vassals: number;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

type ClanInfo = {
  name: string;
  description: string;
  icon: string;
  icon_state: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
  icon_state: string;
  cost: string;
  constant_cost: string;
  cooldown: string;
};

enum InfoTab {
  General = 1,
  Basics,
  Powers,
}

export const AntagInfoVampire = () => {
  // Set default to 2 so Basics (now in the middle) opens by default
  const [tab, setTab] = useState(InfoTab.Basics);

  return (
    <Window width={700} height={750} theme="spookyconsole">
      <Window.Content>
        <Box align="center" style={{ width: '100%' }}>
          <Tabs className="vamp-top-tabs">
            <Tabs.Tab
              className="vamp-top-tab"
              selected={tab === InfoTab.General}
              onClick={() => setTab(InfoTab.General)}
            >
              General Guide
            </Tabs.Tab>

            <Tabs.Tab
              className="vamp-top-tab vamp-top-tab--featured"
              selected={tab === InfoTab.Basics}
              onClick={() => setTab(InfoTab.Basics)}
            >
              Basics
            </Tabs.Tab>

            <Tabs.Tab
              className="vamp-top-tab"
              selected={tab === InfoTab.Powers}
              onClick={() => setTab(InfoTab.Powers)}
            >
              Powers
            </Tabs.Tab>
          </Tabs>
        </Box>

        {tab === InfoTab.General && <VampireGuide />}
        {tab === InfoTab.Basics && <VampireIntroduction setTab={setTab} />}
        {tab === InfoTab.Powers && <PowerSection />}
      </Window.Content>
    </Window>
  );
};

const VampireIntroduction = (props: {
  setTab: React.Dispatch<SetStateAction<InfoTab>>;
}) => {
  const { data } = useBackend<VampireInformation>();
  const { objectives, vassal_count, max_vassals, can_change_objective } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow maxHeight="220px">
        <Section fill scrollable title="Objectives">
          <ObjectivePrintout
            objectives={objectives}
            titleMessage=""
            objectiveFollowup={
              <ReplaceObjectivesButton
                can_change_objective={can_change_objective}
                button_title={'Acquire New Tastes'}
                button_colour={'red'}
              />
            }
          />
        </Section>
      </Stack.Item>
      <Stack.Item textAlign="center">
        <Box
          fontSize="130%"
          mb={1}
          bold
          className={vassal_count >= max_vassals ? 'vamp-blood' : undefined}
        >
          Vassals: {vassal_count} / {max_vassals}
        </Box>
      </Stack.Item>
      <Stack.Item textAlign="center">
        <Button
          fluid
          align="middle"
          fontSize="200%"
          onClick={() => props.setTab(InfoTab.General)}
        >
          Confused? Read the guide!
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

enum GuideTab {
  Basics = 1,
  Humanity,
  Leveling,
  Vitae,
  Combat,
  Haven,
  Structures,
  Vassals,
}

const VampireGuide = () => {
  const [tab, setTab] = useState(GuideTab.Basics);

  return (
    <Section title="Guide">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Basics}
              onClick={() => setTab(GuideTab.Basics)}
            >
              The Basics
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Humanity}
              onClick={() => setTab(GuideTab.Humanity)}
            >
              Humanity
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Leveling}
              onClick={() => setTab(GuideTab.Leveling)}
            >
              Leveling
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Vitae}
              onClick={() => setTab(GuideTab.Vitae)}
            >
              Vitae
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Combat}
              onClick={() => setTab(GuideTab.Combat)}
            >
              Combat
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Haven}
              onClick={() => setTab(GuideTab.Haven)}
            >
              Your Haven
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Structures}
              onClick={() => setTab(GuideTab.Structures)}
            >
              Structures
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              className="vamp-guide-tab"
              selected={tab === GuideTab.Vassals}
              onClick={() => setTab(GuideTab.Vassals)}
            >
              Vassals
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
          {tab === GuideTab.Basics && (
            <Box>
              <Box fontSize="18px" className="vamp-arcane" bold>
                So you&apos;re a big bad vampire. Congrats.
              </Box>
              <Box fontSize="26px" className="vamp-blood" bold>
                Now keep it to yourself.
              </Box>
              <Box align="right" fontSize="10px" className="vamp-muted">
                - &apos;Smiling&apos; Jack, Los Angeles, circa 2001-2008.
              </Box>
              <br />
              Vampires survive because mortals think they&apos;re myths.
              That&apos;s the{' '}
              <Box inline className="vamp-masquerade">
                Masquerade
              </Box>
              . The wolf doesn&apos;t want the sheep to know they&apos;re there.
              Except these sheep have guns.
              <Box inline fontSize="14px" className="vamp-blood" bold>
                {' '}
                You <i>must</i> stay hidden.
              </Box>
              <br />
              <br />
              <Box fontSize="16px" className="vamp-masquerade" bold>
                Blending In
              </Box>
              You&apos;re dead: no breath, heartbeat, or need for food. That
              makes you stand out. Avoid doctors, health scans, and especially
              the{' '}
              <Box inline className="vamp-curator">
                Curator
              </Box>
              . They know vampires exist and can expose you.
              <Box mt={1} className="vamp-tip">
                <b>Tip:</b> You have incredible powers, but using them draws
                attention. Wise kindred blend in by acting like mortals. Use a
                gun instead of claws. Walk instead of leaping across rooms.
                Reserve your powers for when you truly need them.
              </Box>
              <br />
              <Box fontSize="16px" className="vamp-haven" bold>
                First Steps
              </Box>
              Take a moment to look at your screen. See those icons on the left?
              That&apos;s your vampire HUD. Each icon gives you important
              information, so click through them and learn what they show.
              <br />
              <br />
              Your next priority should be finding another kindred. They can
              help you learn the ropes.
              <br />
              <Box mt={1} className="vamp-danger-box">
                <Box
                  fontSize="15px"
                  className="vamp-blood"
                  bold
                  textAlign="center"
                >
                  #1 RULE OF SURVIVAL
                </Box>
                <Box
                  fontSize="18px"
                  className="vamp-masquerade"
                  bold
                  textAlign="center"
                >
                  Keep vitae above 300.
                </Box>
                <Box fontSize="12px" textAlign="center">
                  A starving vampire is a dead vampire. Panic leads to mistakes.
                </Box>
                <Box fontSize="11px" className="vamp-muted" textAlign="center">
                  Feed often. Feed smart. Stay alive.
                </Box>
              </Box>
            </Box>
          )}
          {tab === GuideTab.Humanity && (
            <Box>
              <Box fontSize="18px" className="vamp-arcane" bold>
                Humanity
              </Box>
              <Box fontSize="13px" className="vamp-arcane">
                Are we human? Or are we dancer?
              </Box>
              <br />
              Most{' '}
              <Box inline className="vamp-kindred">
                Kindred
              </Box>{' '}
              were human before their Embrace. Clinging to{' '}
              <Box inline className="vamp-arcane">
                humanity
              </Box>{' '}
              is how they resist the{' '}
              <Box inline className="vamp-beast">
                Beast&apos;s
              </Box>{' '}
              feral nature.
              <br />
              <br />
              Your{' '}
              <Box inline className="vamp-arcane">
                humanity
              </Box>{' '}
              is how much you still pass for a mortal. At 7 or more, you gain
              the{' '}
              <Box inline className="vamp-masquerade">
                Blush of Life
              </Box>
              , which fools health analyzers and the{' '}
              <Box inline className="vamp-curator">
                Curator&apos;s
              </Box>{' '}
              <Box inline className="vamp-arcane">
                Archive of the Kindred
              </Box>
              . <b>However, you will not heal normally while it is active.</b>
              <Box mt={1} className="vamp-tip">
                <b>Tip:</b> Too many bloodloss patients in medbay is just as
                suspicious as a bloodless corpse in the halls.
              </Box>
              <br />
              <Box fontSize="16px" className="vamp-blood" bold>
                Below 7
              </Box>
              <Box fontSize="13px" ml={1}>
                • You lose the Blush of Life
                <br />• You look deathly pale to anyone close, unless every inch
                of you is covered
                <br />• Monster hunters and chaplains may treat you as fair game
                <br />• At 2 or less you look deathly pale from across the room
                and burn in the chapel
              </Box>
              <br />
              <Box fontSize="16px" className="vamp-arcane" bold>
                What costs humanity
              </Box>
              <Box fontSize="13px" ml={1}>
                • Frenzy: 2
                <br />• Killing someone by feeding on them: 1
                <br />• Draining another vampire dry: a third of theirs
              </Box>
              <Box mt={1} className="vamp-gold-note">
                Click the humanity counter on your HUD for detailed information.
              </Box>
              <br />
              Why call it{' '}
              <Box inline className="vamp-arcane">
                Humanity
              </Box>{' '}
              when not all{' '}
              <Box inline className="vamp-kindred">
                kindred
              </Box>{' '}
              were human? Simple: tradition. Centuries-old vampires are slow to
              change their ways.
            </Box>
          )}
          {tab === GuideTab.Leveling && (
            <Box>
              <Box fontSize="32px" className="vamp-beast" bold>
                Leveling
              </Box>
              <Box fontSize="16px" className="vamp-blood-dark" bold>
                Growing in Power
              </Box>
              As a vampire, you grow stronger over time by meeting your feeding
              requirements. Click your blood meter on the HUD to see your
              current progress toward the next rank.
              <br />
              If you have consumed enough vitae to meet your goal, you will gain
              a Rank whenever you next sleep in a coffin. Each rank provides
              significant benefits:
              <Box fontSize="13px" ml={1}>
                • Increased physical strength
                <br />• Faster feeding rate
                <br />• Higher blood capacity
                <br />• Additional discipline points to unlock new powers
              </Box>
              <br />
              In addition, you also passively gain a few ranks over time, and
              will gain one rank whenever you vassalize a mortal into your
              servant.
            </Box>
          )}
          {tab === GuideTab.Vitae && (
            <Box>
              <Box fontSize="18px" className="vamp-blood" bold>
                Vitae
              </Box>
              <br />
              <Box inline className="vamp-blood">
                Vitae
              </Box>{' '}
              is the lifeblood that sustains every vampire. The{' '}
              <Box inline className="vamp-beast">
                Beast
              </Box>{' '}
              within you demands constant feeding, and ignoring this need is not
              an option. When your blood reserves reach zero, you will
              experience blurred vision, impaired healing, and far worse
              consequences.
              <br />
              <br />
              Your current rank determines how much{' '}
              <Box inline className="vamp-blood">
                vitae
              </Box>{' '}
              you can store and utilize at any given time.
              <br />
              <br />
              <Box bold>
                Sources of{' '}
                <Box inline className="vamp-blood">
                  vitae
                </Box>
                :
              </Box>
              <Box fontSize="13px">
                • Crewmembers
                <br />• Monkeys
                <br />• Mice
                <br />• Bloodbags
              </Box>
              <Box mt={1} className="vamp-tip">
                <b>Tip:</b> Feed from crew regularly. Mice and monkeys will not
                sustain you in the long run.
              </Box>
              <br />
              <Box fontSize="16px" className="vamp-beast" bold>
                Frenzy
              </Box>
              When your{' '}
              <Box inline className="vamp-blood">
                vitae
              </Box>{' '}
              is completely depleted, you lose control and enter a state known
              as{' '}
              <Box inline className="vamp-beast">
                frenzy
              </Box>
              . In this feral state, the{' '}
              <Box inline className="vamp-beast">
                Beast
              </Box>{' '}
              takes over and compels you to attack the nearest mortal without
              hesitation.
              <br />
              <br />
              While in{' '}
              <Box inline className="vamp-beast">
                frenzy
              </Box>
              , you gain the ability to grab victims instantly, making you
              extremely dangerous but also highly conspicuous. The only way to
              regain control of yourself is to feed until you have enough{' '}
              <Box inline className="vamp-blood">
                vitae
              </Box>{' '}
              to suppress the{' '}
              <Box inline className="vamp-beast">
                Beast
              </Box>
              .
              <br />
              <br />
              <Box fontSize="16px" className="vamp-arcane" bold>
                Powers & Vitae
              </Box>
              All of your vampiric powers require{' '}
              <Box inline className="vamp-blood">
                vitae
              </Box>{' '}
              to use. Some abilities drain blood continuously while they remain
              active, while others have an upfront cost when activated. Check
              the Powers tab for specific costs and details on each ability.
            </Box>
          )}
          {tab === GuideTab.Combat && (
            <Box>
              <Box fontSize="18px" className="vamp-arcane" bold>
                Combat
              </Box>
              <br />
              As a vampire, you have significant advantages in combat, but also
              critical weaknesses that can be exploited.
              <br />
              <br />
              <Box fontSize="15px" className="vamp-haven" bold>
                Strengths
              </Box>
              <Box fontSize="13px">
                <b>Enhanced Senses:</b> Night vision and thermal vision let you
                track prey in complete darkness.
                <br />
                <br />
                <b>Undead Physiology:</b> No need to breathe, sleep, or eat. You
                are immune to disease. Fatal wounds put you into{' '}
                <Box inline className="vamp-beast">
                  Torpor
                </Box>{' '}
                instead of killing you. You will rise again if you have{' '}
                <Box inline className="vamp-blood">
                  vitae
                </Box>{' '}
                and are not staked.
                <br />
                <br />
                <b>Resilience:</b> Immune to cold, radiation, and toxins.
                Critical injuries do not knock you down.
                <br />
                <br />
                <b>Supernatural Strength:</b> Your fists deal devastating
                damage, scaling with your rank.
              </Box>
              <br />
              <Box fontSize="15px" className="vamp-blood" bold>
                Weaknesses
              </Box>
              <Box fontSize="13px">
                <b>Stakes:</b> Paralyze you, disable powers, halt healing, and
                prevent revival from{' '}
                <Box inline className="vamp-beast">
                  Torpor
                </Box>
                .
                <br />
                <br />
                <b>Fire and Lasers:</b> Deal devastating damage. Fortitude
                offers minimal protection.
                <br />
                <br />
                <b>Losing your humanity:</b> Below 7 you look deathly pale, and
                hunters, chaplains, and royalty may hunt you.
              </Box>
            </Box>
          )}
          {tab === GuideTab.Haven && (
            <Box>
              <Box fontSize="18px" className="vamp-haven" bold>
                Your Haven
              </Box>
              <br />A{' '}
              <Box inline className="vamp-haven">
                haven
              </Box>{' '}
              is a location you have claimed as your own, where you can rest in
              your coffin and perform certain vampiric rituals. Some vampires
              find them useful. Many more have been caught because of them.
              <br />
              <br />
              <Box bold>
                Do You Need a{' '}
                <Box inline className="vamp-haven">
                  Haven
                </Box>
                ?
              </Box>
              <Box fontSize="13px">
                Honestly? Probably not. A{' '}
                <Box inline className="vamp-haven">
                  haven
                </Box>{' '}
                is only necessary if you want to use vampiric structures.
              </Box>
              <br />
              <Box bold>
                Claiming a{' '}
                <Box inline className="vamp-haven">
                  Haven
                </Box>
              </Box>
              <Box fontSize="13px">
                If you still want one: acquire a coffin from the Chapel or craft
                one via the Furniture category. Find somewhere{' '}
                <i>truly hidden</i>, place the coffin, and rest inside to claim
                the area. Once claimed, you can anchor vampiric structures like
                the{' '}
                <Box inline className="vamp-kindred">
                  Vassalization Rack
                </Box>{' '}
                or{' '}
                <Box inline className="vamp-blood-dark">
                  Blood Throne
                </Box>
                .
              </Box>
              <br />
              <Box mt={1} className="vamp-tip">
                <b>Warning:</b> Maintenance is the first place people look. If
                someone finds your haven, they find everything: your coffin,
                your structures, your vassals, and you.
              </Box>
            </Box>
          )}
          {tab === GuideTab.Structures && (
            <Box>
              <Box fontSize="18px" className="vamp-arcane" bold>
                Structures
              </Box>
              <Box fontSize="13px" className="vamp-arcane">
                These can be built via the Vampire crafting tab.
              </Box>
              <br />
              <Box className="vamp-kindred" bold>
                Vassalization Rack
              </Box>
              <Box fontSize="13px">
                Holds a victim still so you can share your blood with them.
                Strap in one of your own{' '}
                <Box inline className="vamp-kindred">
                  vassals
                </Box>{' '}
                and click the rack to teach them a lesser version of one of your
                disciplines: Auspex, Celerity, Fortitude or Obfuscate. A vassal
                knows one taught power at a time, and teaching costs{' '}
                <Box inline className="vamp-blood">
                  150 blood
                </Box>
                .
                <br />
                <br />
                <b>Usage:</b> Secure the rack in your{' '}
                <Box inline className="vamp-haven">
                  haven
                </Box>{' '}
                → drag someone onto the rack → click the rack.
              </Box>
              <br />
              <Box className="vamp-ember" bold>
                Candelabrum
              </Box>
              <Box fontSize="13px">
                A vampiric candelabra that radiates an unsettling aura. Any
                mortal who gazes upon its{' '}
                <Box inline className="vamp-beast">
                  flame
                </Box>{' '}
                will find their sanity slowly draining away.
              </Box>
              <br />
              <Box className="vamp-blood-dark" bold>
                Blood Throne
              </Box>
              <Box fontSize="13px">
                When you sit upon a Blood Throne, your words are broadcast
                telepathically to all{' '}
                <Box inline className="vamp-kindred">
                  kindred
                </Box>{' '}
                on the station. Other vampires will need their own throne if
                they wish to respond.
              </Box>
            </Box>
          )}
          {tab === GuideTab.Vassals && (
            <Box>
              <Box fontSize="18px" className="vamp-kindred" bold>
                Vassals
              </Box>
              <br />
              <Box inline className="vamp-kindred">
                Vassals
              </Box>{' '}
              are mortals who have been rendered addicted to your vitae, binding
              them to your will. They serve as your eyes, ears, and hands among
              the living, carrying out your commands while you remain hidden in
              the shadows.
              <br />
              <br />
              <Box bold>Creating Vassals</Box>
              <Box fontSize="13px">
                Use{' '}
                <Box inline className="vamp-blood">
                  Share Blood
                </Box>{' '}
                on someone next to you who is held: aggressively grabbed by you,
                restrained, buckled, or unconscious. Each drink takes 5 seconds,
                and drinks keep coming as long as they stay held.
                <Box ml={1}>
                  • One drink: they crave more. Nothing else happens yet.
                  <br />• Two drinks: they can no longer bring themselves to
                  attack you, but they can still run, talk, and call for help.
                  <br />• Three drinks: they become your vassal, and you gain a
                  rank.
                </Box>
                A bond you never finish fades after 15 minutes.
              </Box>
              <br />
              <Box bold>Their Blood</Box>
              <Box fontSize="13px">
                Your vassals' powers run on your{' '}
                <Box inline className="vamp-blood">
                  blood
                </Box>
                , which drains out of them over about 25 minutes. Use Share
                Blood on your own vassal to refill it in one drink. They don't
                need to be held for that.
              </Box>
              <br />
              <Box bold>Limitations</Box>
              <Box fontSize="13px">
                Crewmembers protected by{' '}
                <Box inline className="vamp-arcane">
                  mindshields
                </Box>{' '}
                cannot be bonded at all, and getting one breaks a half-finished
                bond. Those with strong existing loyalties must accept your
                third drink. Those who serve{' '}
                <Box inline className="vamp-kindred">
                  eldritch powers
                </Box>{' '}
                are completely immune and can never be turned.
                <br />
                <br />
                Once someone has become your vassal, the only way to free them
                is through implantation of a{' '}
                <Box inline className="vamp-arcane">
                  mindshield
                </Box>
                .
              </Box>
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PowerSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { powers } = data;
  if (!powers) {
    return <Section minHeight="220px" />;
  }

  const [tab, setTab] = useState(0);
  return (
    <Section title="Powers">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            {powers.map((power, index) => (
              <Tabs.Tab
                key={index}
                selected={tab === index}
                onClick={() => setTab(index)}
              >
                <Stack align="center">
                  <Stack.Item>
                    <DmIcon
                      inline
                      icon={power.icon}
                      icon_state={power.icon_state}
                      fallback={
                        <Icon mr={1} name="spinner" spin fontSize="30px" />
                      }
                      width="32px"
                      style={{
                        imageRendering: 'pixelated',
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>{power.name}</Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          {powers.map(
            (power, index) =>
              tab === index && (
                <Box key={index}>
                  <Box inline bold className="vamp-blood">
                    {power.cost !== '0' && <>BLOOD COST: {power.cost}</>}
                    {power.cost !== '0' && power.constant_cost !== '0' && (
                      <br />
                    )}
                    {power.constant_cost !== '0' && (
                      <>BLOOD DRAIN: {power.constant_cost}</>
                    )}
                    {(power.cost !== '0' || power.constant_cost !== '0') &&
                      power.cooldown !== '0' && (
                        <>
                          <br />
                          <br />
                        </>
                      )}
                    {power.cooldown !== '0' && (
                      <>
                        COOLDOWN: {power.cooldown} seconds
                        <br />
                        <br />
                      </>
                    )}
                  </Box>
                  <Box
                    style={{ whiteSpace: 'pre-wrap' }}
                    dangerouslySetInnerHTML={{
                      __html: sanitizeText(
                        power.explanation.replace(/\n/g, '\n\n'),
                      ),
                    }}
                  />
                </Box>
              ),
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ClanSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section title="Clan">
        <Stack vertical>
          <Stack.Item fontSize="20px">
            <Box inline className="vamp-blood">
              You are not in a clan!
            </Box>
          </Stack.Item>
          <Stack.Item>
            To determine your clan, utilize the clan selection ability.
          </Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Section title="Clan">
      {clan.map((ClanInfo, index) => (
        <Stack key={index}>
          <Stack.Item>
            <DmIcon
              icon={ClanInfo.icon}
              icon_state={ClanInfo.icon_state}
              fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
              width="128px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack.Item textAlign="center">
              <Box inline fontSize="20px" className="vamp-blood">
                You are part of the <b>{ClanInfo.name}!</b>
              </Box>
            </Stack.Item>
            <Box
              fontSize="16px"
              dangerouslySetInnerHTML={{ __html: ClanInfo.description }}
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
