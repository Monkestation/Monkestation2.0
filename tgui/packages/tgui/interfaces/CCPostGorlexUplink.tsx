/**
 * Operation Severance: one interaction layout, two distinct corporate identities.
 * Server-owned inventories and objective state remain authoritative.
 * Landing-page navigation; server-owned extraction, warrant and recall state.
 */
import './CCPostTheme.scss';
import { CCPostPersonnelPortrait } from './CCPostTheme';
import { useBackend } from '../backend';
import { useEffect, useState } from 'react';
import { Box, Button, Icon, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type CatalogueItem = {
  id: string;
  name: string;
  category: string;
  description: string;
  cost: number;
  limit: number;
  purchased: number;
  stock: number;
  quantity: number;
  shared_stock?: boolean | number;
  complexity?: number | null;
};

type Personnel = { name: string; role: string; portrait?: string; medical: string };
type Mission = {
  data: boolean;
  armed: boolean;
  detonated: boolean;
  extracted: boolean;
  data_present: boolean;
  cartridge_complete: boolean;
  black_warrant: boolean;
};
type Data = {
  authorized?: boolean | number;
  brand?: 'gorlex' | 'cybersun';
  adp7_authorization_code?: string | null;
  telecrystals?: number;
  catalogue?: CatalogueItem[];
  equipment_icons?: Record<string, string>;
  mission?: Mission;
  personnel?: Personnel[];
  target?: { name: string; status: string };
  recall_implemented?: boolean | number;
  extraction_implemented?: boolean | number;
  extraction_status?: string;
  extraction_seconds?: number;
  extraction_location?: string;
  extraction_ready?: boolean | number;
  landing_available?: boolean | number;
  warrant_seconds?: number;
  cartridge_held?: boolean | number;
  recall_ready?: boolean | number;
  cybersun_recovered?: boolean | number;
  recalled?: boolean | number;
  recall_pending?: boolean | number;
  requisitions_locked?: boolean | number;
  implant_seconds?: number;
  implant_duration?: number;
  mission_duration?: number;
  mission_seconds?: number;
  mission_timer_active?: boolean | number;
  forced_recall?: boolean | number;
};

const pages = [
  { id: 'contract', gorlex: 'Contract Details', cybersun: 'Contract Details', index: '01' },
  { id: 'requisitions', gorlex: 'Field Requisitions', cybersun: 'Equipment Requisition', index: '02' },
  { id: 'intelligence', gorlex: 'Personnel Intelligence', cybersun: 'Target Intelligence', index: '03' },
  { id: 'extraction', gorlex: 'Extraction Control', cybersun: 'Recall Authorization', index: '04' },
];

const status = (ok: boolean) => ok ? 'COMPLETE' : 'PENDING';
const countdown = (seconds = 0) => {
  const remaining = Math.max(0, Math.ceil(seconds));
  return `${Math.floor(remaining / 60).toString().padStart(2, '0')}:${(remaining % 60).toString().padStart(2, '0')}`;
};

const FactionMark = ({ cybersun }: { cybersun: boolean }) => (
  cybersun ? (
                <svg viewBox="0 0 300 300" role="img" aria-label="Cybersun Industries emblem" className="CCPostOpsBrand__logo">
                  <path d="M76.5 48H200.7L224.7 78L190.7 105.5L179.5 92H103.8L74.7 150L103.8 208H179.5L190.7 194.5L224.7 222L200.7 252H76.5L25.6 150Z" fill="#000" stroke="#000" strokeWidth="32" strokeLinejoin="round" strokeLinecap="round" />
                  <path d="M235.8 89.4L274.5 110.5L252.7 150L274.5 189.5L235.8 210.6L213.4 170.5H170V129.5H213.4Z" fill="#000" stroke="#000" strokeWidth="32" strokeLinejoin="round" strokeLinecap="round" />
                  <path d="M76.5 48H200.7L224.7 78L190.7 105.5L179.5 92H103.8L74.7 150L103.8 208H179.5L190.7 194.5L224.7 222L200.7 252H76.5L25.6 150Z" fill="#E3DDC3" />
                  <path d="M235.8 89.4L274.5 110.5L252.7 150L274.5 189.5L235.8 210.6L213.4 170.5H170V129.5H213.4Z" fill="#FF7300" />
                </svg>
              ) : <Icon name="tg-syndicate-logo" />
);

const MissionClock = ({ seconds = 0, duration = 1, cybersun }: { seconds?: number; duration?: number; cybersun: boolean }) => (
  <div className={`CCPostOpsClock ${seconds <= 60 ? 'CCPostOpsClock--urgent' : ''}`}>
    <div className="CCPostOpsClock__digits">{countdown(seconds)}</div>
    <div className="CCPostOpsClock__meter" role="progressbar" aria-label={cybersun ? 'Operational authorization remaining' : 'Corporate failsafe remaining'} aria-valuemin={0} aria-valuemax={Math.max(1, duration)} aria-valuenow={Math.max(0, Math.min(seconds, duration))}>
      <div style={{ width: `${Math.max(0, Math.min(100, 100 * seconds / Math.max(1, duration)))}%` }} />
    </div>
  </div>
);

export const CCPostGorlexUplink = () => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useState('home');
  const [category, setCategory] = useState('All');
  const navigate = (next: string) => setTab(next);
  const selectCategory = (next: string) => setCategory(next);
  const cybersun = data.brand === 'cybersun';
  const corporation = cybersun ? 'CYBERSUN INDUSTRIES' : 'GORLEX MARAUDERS';
  const funds = data.telecrystals ?? 0;
  const mission = data.mission;
  const terminated = !cybersun && !!mission?.black_warrant;
  const requisitionsLocked = !!data.requisitions_locked;
  const currentTab = requisitionsLocked && tab === 'requisitions' ? 'home' : tab;
  useEffect(() => {
    if (requisitionsLocked && tab === 'requisitions') {
      setTab('home');
    }
  }, [requisitionsLocked, tab]);
  const catalogue = data.catalogue || [];
  const categories = ['All', ...Array.from(new Set(catalogue.map((item) => item.category)))];
  const items = category === 'All' ? catalogue : catalogue.filter((item) => item.category === category);
  const title = (id: string) => pages.find((page) => page.id === id)?.[cybersun ? 'cybersun' : 'gorlex'] || '';
  const missionItems = cybersun ? [
    { title: 'Contractor Termination', description: 'Locate and eliminate the single contractor designated by the Black Warrant.', done: data.target?.status === 'DECEASED' },
    { title: 'Classified Intelligence Recovery', description: 'Recover the original encrypted Tasking Server cartridge and complete authorized withdrawal.', done: !!data.cybersun_recovered },
    { title: 'Authorized Personnel Recall', description: 'Complete both directives, then request bluespace extraction.', done: !!data.recalled },
  ] : [
    { title: 'Classified Data Acquisition', description: 'Download classified tasking records to your issued cartridge.', done: !!mission?.data },
    { title: 'NT-ADP-7 Authorization', description: 'Acquire the authentication disk and arm the device using your issued code.', done: !!mission?.armed },
    { title: 'Authorized Retrieval', description: 'Board the assigned Gorlex pod with classified intelligence.', done: !!mission?.extracted },
    { title: 'Asset Denial', description: 'Confirm NT-ADP-7 destroys the Liaison Outpost. Additional sabotage result.', done: !!mission?.detonated },
  ];

  return (
    <Window title={corporation} theme="ntos" width={900} height={710}>
      <Window.Content scrollable className={`ccpost-theme ccpost-theme--operations ccpost-theme--severance-polish ${cybersun ? 'ccpost-theme--cybersun' : 'ccpost-theme--gorlex'} ${currentTab === 'requisitions' && data.authorized ? 'CCPostOpsRequisitionsPage' : ''}`}>
        <div className="CCPostOpsBackdrop" aria-hidden="true">
          <div className="CCPostOpsWatermark"><FactionMark cybersun={cybersun} /></div>
          {cybersun && <svg className="CCPostOpsCircuit" viewBox="0 0 120 80"><path d="M0 12H49L63 26H120M0 35H25L44 54H120M20 80V65L53 32H87L103 16H120"/><circle cx="49" cy="12" r="2"/><circle cx="44" cy="54" r="2"/><circle cx="87" cy="32" r="2"/></svg>}
        </div>
        <div className="CCPostOpsHeader">
          <div className="CCPostOpsBrand">
            <div className="CCPostOpsBrand__mark" aria-label="Corporate mark">
              <FactionMark cybersun={cybersun} />
            </div>
            <div>
              <div className="CCPostOpsBrand__company">{corporation}</div>
              <div className="CCPostOpsBrand__subtitle">{cybersun ? 'SECURE ENFORCEMENT NETWORK / BLACK WARRANT' : 'OPERATION SEVERANCE / SECURE CONTRACT CHANNEL'}</div>
            </div>
          </div>
          <div className="CCPostOpsBalance"><strong>{requisitionsLocked ? 'REVOKED' : `${funds} TC`}</strong><small>FIELD ALLOCATION</small></div>
        </div>
        {!data.authorized ? (
          <NoticeBox danger>Unauthorized access. This terminal is bound to its assigned contractor.</NoticeBox>
        ) : (
          <div className="CCPostOpsLayout">
            <div className="CCPostOpsMain">
              {currentTab !== 'home' && <button type="button" className="CCPostOpsBack" onClick={() => navigate('home')}><Icon name="arrow-left" /> Back to Home</button>}
              <div className="CCPostOpsEyebrow"><span>{cybersun ? (mission?.black_warrant ? 'CORPORATE SECURITY / ACTIVE WARRANT' : 'CORPORATE SECURITY / DIRECTIVE NETWORK') : (mission?.black_warrant ? 'GORLEX OPERATIONS / CONTRACT TERMINATED' : 'GORLEX OPERATIONS / ACTIVE CONTRACT')}</span><span className="CCPostOpsSecure">{cybersun ? '◆ SECURE LINK' : '● ENCRYPTED SESSION'}</span></div>
              {currentTab !== 'home' && <div className="CCPostOpsTitle">{title(currentTab)}</div>}

              {!cybersun && !!mission?.black_warrant && <NoticeBox danger>BLACK WARRANT ISSUED. Contract terminated; extraction and requisitions revoked.</NoticeBox>}
              {!cybersun && !mission?.black_warrant && !!data.warrant_seconds && <NoticeBox danger>UNAUTHORIZED WITHDRAWAL: return to the operational area within {data.warrant_seconds}s to avoid a Black Warrant.</NoticeBox>}
              {currentTab === 'home' && (
                <>
                  {cybersun && <><div className="CCPostOpsHomeTitle">Enforcement Operations</div><div className="CCPostOpsLead">Authorized access to Black Warrant directives and enforcement systems.</div></>}
                  <div className="CCPostOpsCards">
                    {pages.map((page) => (
                      <button type="button" className="CCPostOpsCard" key={page.id} disabled={requisitionsLocked && page.id === 'requisitions'} onClick={() => { setCategory('All'); navigate(page.id); }}>
                        <div className="CCPostOpsCard__inner">
                        <div className="CCPostOpsCard__top"><Icon name={page.id === 'contract' ? 'file-alt' : page.id === 'requisitions' ? 'box-open' : page.id === 'intelligence' ? 'crosshairs' : 'satellite-dish'} /><small>{page.index} / SECURE ACCESS</small></div>
                        <strong>{title(page.id)}</strong>
                        <span>{page.id === 'contract' ? (cybersun ? 'Termination and asset recovery directives' : 'Full contract dossier and live objective progress') : page.id === 'requisitions' ? (requisitionsLocked ? 'REVOKED: requisitions unavailable' : 'Authorized field purchases and stock limits') : page.id === 'intelligence' ? (cybersun ? 'Subject profile and current status' : 'Registered Liaison personnel health signals') : (cybersun ? 'Bluespace personnel recovery' : 'Authorized contractor extraction')}</span>
                        </div>
                      </button>
                    ))}
                  </div>
                  <div className="CCPostOpsStatus">
                    <div><small>ASSIGNMENT</small><strong>{cybersun ? (mission?.black_warrant ? 'BLACK WARRANT' : 'NO ACTIVE WARRANT') : terminated ? 'CONTRACT TERMINATED' : 'OPERATION SEVERANCE'}</strong></div>
                    <div><small>INTELLIGENCE</small><strong>{cybersun ? (data.cybersun_recovered || data.cartridge_held ? 'SECURED' : 'RECOVERY PENDING') : mission?.data ? 'ACQUIRED' : 'NOT SECURED'}</strong></div>
                    <div><small>RETRIEVAL</small><strong>{cybersun ? (data.recalled ? 'SUCCESS' : 'PENDING') : mission?.extracted ? 'SUCCESS' : terminated ? 'REVOKED' : 'PENDING'}</strong></div>
                  </div>
                </>
              )}

              {currentTab === 'contract' && (
                <>
                  {cybersun && !mission?.black_warrant && <NoticeBox>No Black Warrant has been issued. Enforcement directives are unavailable until authorized.</NoticeBox>}
                  {cybersun && <div className="CCPostOpsHero">
                  {!!data.mission_timer_active && (
                    <Section title="OPERATIONAL AUTHORIZATION REMAINING">
                      <MissionClock seconds={data.mission_seconds} duration={data.mission_duration} cybersun />
                      <Box mt={1}>{data.forced_recall ? 'Authorization expired. Compulsory withdrawal in progress.' : 'Compulsory bluespace withdrawal will commence when your authorization expires, regardless of objective completion.'}</Box>
                    </Section>
                  )}
                  <Section title="DESIGNATED WARRANT SUBJECT">
                      <div className="CCPostOpsSubject">{data.target?.name || 'UNASSIGNED SUBJECT'}</div>
                      <Box color="label" mt={1}>Affiliation: Gorlex Marauders · Rogue contractor</Box>
                      <div className="CCPostOpsSignal"><span>◆</span> {data.target?.status || 'SIGNAL UNAVAILABLE'}</div>
                      <Box mt={1} color="label">Use your Warrant Tracker for general vicinity. Alt-click switches between the subject and the original cartridge.</Box>
                    </Section>
                  </div>}
                  {terminated ? (
                    <>
                      <NoticeBox danger>CONTRACT TERMINATED. Unauthorized withdrawal constitutes a breach of contract. Extraction authorization and equipment requisitions have been permanently revoked.</NoticeBox>
                      <Section title="CORPORATE FAILSAFE ACTIVATED">
                        <MissionClock seconds={data.implant_seconds} duration={data.implant_duration} cybersun={false} />
                        <Box color="label" mt={1}>Remaining time before explosive implant detonation. The countdown cannot be cancelled or disabled.</Box>
                      </Section>
                    </>
                  ) : (
                    <div className="CCPostOpsAlert"><b>{cybersun ? 'BLACK WARRANT AUTHORIZATION' : 'CONTRACT AUTHORIZATION'}</b><span>{cybersun ? 'Terminate the designated rogue contractor and recover corporate intelligence. Unrelated personnel are not valid targets.' : 'Retrieve the classified Tasking Server intelligence, arm NT-ADP-7, then use the assigned Gorlex pod. The main station is prohibited.'}</span></div>
                  )}
                  {!cybersun && data.adp7_authorization_code && (
                    <Section title="CLASSIFIED AUTHORIZATION INTELLIGENCE">
                      <Box color="label">NT-ADP-7 AUTHORIZATION CODE</Box>
                      <Box fontSize={2} bold>{data.adp7_authorization_code}</Box>
                      <Box mt={1}>Code acquired prior to deployment. Recover the physical authentication disk and enter this code to arm NT-ADP-7.</Box>
                    </Section>
                  )}
                  <Section title={cybersun ? 'MANDATORY ENFORCEMENT DIRECTIVES' : 'CONTRACT OBJECTIVES'}>
                    <div className="CCPostOpsObjectives">
                      {missionItems.map((item, index) => (
                        <div className="CCPostOpsObjective" key={index}>
                          <div className="CCPostOpsObjective__num">0{index + 1}</div>
                          <div className="CCPostOpsObjective__body"><strong>{item.title}</strong><div>{item.description}</div></div>
                          <span className={`CCPostOpsObjective__status ${item.done ? 'CCPostOpsObjective__status--complete' : ''}`}>{status(item.done)}</span>
                        </div>
                      ))}
                    </div>
                  </Section>
                  <Section title={cybersun ? 'JURISDICTIONAL RESTRICTIONS' : 'OPERATIONAL RESTRICTIONS'}>
                    <Box>{cybersun ? 'The primary station lies outside your authorized enforcement zone. Entry, interference with station operations and unrelated personnel engagement are prohibited. Only the designated subject and original intelligence are authorized.' : 'The primary station is outside your authorized operational zone. Entry, interference with station operations and engagement with personnel outside the mission area are prohibited. Unauthorized withdrawal after data acquisition may trigger a Black Warrant.'}</Box>
                  </Section>
                  {(cybersun || !terminated) && (
                    <NoticeBox>{cybersun ? 'Recall requires confirmed termination and physical recovery of the original cartridge. Only the assigned Enforcer may complete recall.' : 'Successful authorized boarding with the original intelligence cartridge completes the contract. Nuclear detonation is tracked as a separate sabotage result.'}</NoticeBox>
                  )}
                </>
              )}

              {currentTab === 'requisitions' && (
                <div className="CCPostOpsShop">
                    <div className="CCPostOpsCategories">
                      {categories.map((entry) => (
                        <button type="button" key={entry} className={`CCPostOpsCategory ${entry === category ? 'CCPostOpsCategory--active' : ''}`} onClick={() => selectCategory(entry)}>
                          {entry} <small>{entry === 'All' ? catalogue.length : catalogue.filter((item) => item.category === entry).length}</small>
                        </button>
                      ))}
                    </div>
                    <div className="CCPostOpsCatalog" key={category} tabIndex={0} role="region" aria-label="Equipment catalogue">
                      {items.map((item) => {
                        const stock = Math.max(0, item.stock ?? item.limit - item.purchased);
                        const sprite = data.equipment_icons?.[item.id];
                        const unavailable = requisitionsLocked || stock === 0 || funds < item.cost;
                        return (
                          <div className="CCPostOpsCatalogItem" key={item.id}>
                            <div className="CCPostOpsCatalogItem__info">
                              <div className="CCPostOpsCatalogItem__identity">
                                <div className="CCPostOpsCatalogItem__sprite">
                                  {sprite ? <img src={`data:image/png;base64,${sprite}`} alt="" /> : <Icon name="box-open" />}
                                </div>
                                <div className="CCPostOpsCatalogItem__text">
                                  <strong>{item.name}</strong>
                                  <div className="CCPostOpsCatalogItem__description">{item.description}</div>
                                </div>
                              </div>
                              <div className="CCPostOpsCatalogItem__meta">
                                <span>Qty: {item.quantity ?? 1}</span>
                                {item.complexity != null && <span>MOD complexity: {item.complexity}</span>}
                              </div>
                            </div>
                            <div className="CCPostOpsCatalogItem__stock">
                              <span>{item.shared_stock ? 'Shared stock' : 'Stock'}: {stock}/{item.limit}</span>
                              {!!item.shared_stock && <small>C-4 / X-4 combined</small>}
                              {stock === 0 ? <small>Out of stock</small> : funds < item.cost ? <small>Insufficient TC</small> : null}
                            </div>
                            <button type="button" className="CCPostOpsPurchase" disabled={unavailable} onClick={() => act('purchase', { id: item.id })}>
                              Purchase: {item.cost} TC
                            </button>
                          </div>
                        );
                      })}
                      {!items.length && <Box>No equipment available in this category.</Box>}
                    </div>
                  </div>
              )}

              {currentTab === 'intelligence' && (
                cybersun ? (
                  <Section title="BLACK WARRANT SUBJECT">
                      <div className="CCPostOpsSubject">{data.target?.name || 'UNASSIGNED SUBJECT'}</div>
                      <Box color="label" mt={1}>Affiliation: Rogue Gorlex Marauders Operative</Box>
                      <div className="CCPostOpsSignal"><span>◆</span> {data.target?.status || 'SIGNAL UNAVAILABLE'}</div>
                      <Box mt={1} color="label">Use your Warrant Tracker for approximate direction and vicinity. Alt-click switches to the original cartridge. Pursuit is restricted to permitted off-station areas.</Box>
                    </Section>
                ) : (
                  <>
                    <Box mb={2} color="label">Authenticated Liaison personnel directory. Health indicators update with available personnel signals; location tracking is not provided.</Box>
                    <div className="CCPostOpsPersonnel">
                      {(data.personnel || []).map((person, index) => (
                        <div className="CCPostOpsPerson" key={`${person.name}-${index}`}>
                          <CCPostPersonnelPortrait portrait={person.portrait} label="PERSONNEL FILE" />
                          <div className="CCPostOpsPerson__body">
                            <strong>{person.name}</strong><span>{person.role}</span>
                            <div className={`CCPostECG CCPostECG--${person.medical.toLowerCase().replace(/[^a-z]+/g, '-')}`}><i /><i /><i /><i /><i /><i /><i /><i /><i /><i /><i /><i /></div>
                            <small>{person.medical}</small>
                          </div>
                        </div>
                      ))}
                      {!(data.personnel || []).length && <NoticeBox>No registered Liaison records available.</NoticeBox>}
                    </div>
                  </>
                )
              )}

              {currentTab === 'extraction' && (
                <>
                  <div className="CCPostOpsAlert"><b>{cybersun ? 'PERSONNEL RECALL / BLUESPACE' : 'AUTHORIZED GORLEX RETRIEVAL'}</b><span>{cybersun ? 'Eliminate the rogue contractor and physically secure the stolen intelligence before personnel recall can be authorized.' : 'After arming NT-ADP-7, request an 80-second extraction. Only the assigned Gorlex operative may board the retrieval pod.'}</span></div>
                  <Section title="EXTRACTION AUTHORIZATION">
                    <div className="CCPostOpsObjectives">
                      {(cybersun ? [
                        { name: 'Contractor termination', ready: data.target?.status === 'DECEASED' },
                        { name: 'Intelligence secured', ready: !!data.cartridge_held || !!data.cybersun_recovered },
                        { name: 'Bluespace recall ready', ready: !!data.recall_ready || !!data.recall_pending || !!data.recalled },
                      ] : [
                        { name: 'Classified intelligence downloaded', ready: !!mission?.data },
                        { name: 'NT-ADP-7 armed', ready: !!mission?.armed },
                        { name: 'Original cartridge in possession', ready: !!data.cartridge_held },
                      ]).map((item, index) => (
                        <div className="CCPostOpsObjective" key={index}><div className="CCPostOpsObjective__num">0{index + 1}</div><div className="CCPostOpsObjective__body"><strong>{item.name}</strong></div><span className={`CCPostOpsObjective__status ${item.ready ? 'CCPostOpsObjective__status--complete' : ''}`}>{status(item.ready)}</span></div>
                      ))}
                    </div>
                  </Section>
                  {cybersun ? (
                    <Section title="BLUESPACE RECALL CONTROL">
                      <Box mb={2}>{data.recalled ? 'Recall completed.' : data.forced_recall ? 'Compulsory withdrawal in progress.' : data.recall_pending ? 'Recall preparing. Remain stationary for 15 seconds; movement or incapacitation interrupts withdrawal.' : 'Recall becomes available after the warrant subject is dead and you possess the original encrypted cartridge.'}</Box>
                      <Button.Confirm fluid icon="satellite-dish" disabled={!data.recall_ready || !!data.recall_pending || !!data.recalled || !!data.forced_recall} confirmContent="Begin 15-second bluespace recall?" onClick={() => act('request_recall')}>REQUEST RECALL</Button.Confirm>
                    </Section>
                  ) : (
                    <Section title="RETRIEVAL POD CONTROL">
                      <Box bold mb={1}>{data.extraction_status || 'NOT REQUESTED'}</Box>
                      {!!data.extraction_seconds && <Box mb={1}>Arrival in {data.extraction_seconds}s</Box>}
                      <Box mb={1}>Landing: {data.extraction_location || 'UNASSIGNED'}</Box>
                      <Box color="label" mb={2}>Landing availability: {data.landing_available ? 'AVAILABLE' : 'UNAVAILABLE'}</Box>
                      {!data.landing_available && <NoticeBox danger>No suitable landing zone identified. Contact command.</NoticeBox>}
                      <Button.Confirm fluid icon="satellite-dish" disabled={!data.extraction_ready || !data.landing_available} confirmContent="Dispatch your retrieval pod? Arrival in 80 seconds." onClick={() => act('request_extraction')}>REQUEST EXTRACTION</Button.Confirm>
                      <Box mt={1} color="label">Use the boarding hatch to buckle into the landed pod while carrying the original completed cartridge. NT-ADP-7 detonation remains a separate sabotage result.</Box>
                    </Section>
                  )}
                </>
              )}
            </div>
          </div>
        )}
        <div className="CCPostOpsFooter"><span>{cybersun ? 'CYS / ENFORCEMENT SYSTEMS' : 'GRX / FIELD OPS'}</span><span>{cybersun ? '◆ SECURE LINK' : '● ENCRYPTED SESSION'}</span></div>
      </Window.Content>
    </Window>
  );
};
