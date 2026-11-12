import { CCPostHeader } from './CCPostTheme';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Layout, Window } from '../layouts';

type SupplyPackageContent = {
  name: string;
  quantity: number;
};

type SupplyPackage = {
  id: string;
  name: string;
  description: string;
  category: string;
  cost: number;
  round_limit?: number;
  contents: SupplyPackageContent[];
  can_order: boolean;
  recall_locked: boolean;
  requisition_failure?: string;
  routing_status: string;
  authorization_delay: number;
  dispatch_delay: number;
  transit_delay: number;
  estimated_total_delay: number;
  freight_reasons: string[];
  package_specific_reasons: string[];
  has_package_specific_routing: boolean;
};

type Shipment = {
  code: string;
  package_name: string;
  cost: number;
  requested_by: string;
  requested_at: string;
  status: string;
  updated_at: string;
  authorization_delay: number;
  dispatch_delay: number;
  transit_delay: number;
  freight_condition_status: string;
  freight_condition_reasons: string[];
  failure_reason?: string;
};

type LedgerEntry = {
  time: string;
  amount: number;
  reason: string;
  actor: string;
};

type Data = {
  outpost_offline?: boolean | number;
  read_only?: boolean;
  allocation: number;
  reserved_allocation: number;
  available_allocation: number;
  max_allocation: number;

  active_shipments: number;
  max_active_shipments: number;

  freight_status: string;
  authorization_delay: number;
  dispatch_delay: number;
  transit_delay: number;
  freight_reasons: string[];
  medical_recall_active: boolean;
  restricted_procurement_suspended: boolean;
  restricted_procurement_seconds: number;

  inspection_reference?: string | null;
  inspection_history?: string[];
  inspection_status?: string;
  inspection_can_certify?: boolean | number;
  inspection_seconds?: number;
  catalog: SupplyPackage[];
  shipments: Shipment[];
  ledger: LedgerEntry[];
};

enum LogisticsTab {
  Requisitions,
  Shipments,
  Ledger,
  Inspections,
}

const formatFreightDuration = (totalSeconds: number) => {
  const seconds = Math.max(0, Math.round(totalSeconds));
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;

  if (!minutes) {
    return `${remainingSeconds}s`;
  }

  return `${minutes}m ${remainingSeconds}s`;
};

const formatRequisitionFailure = (failure?: string) => {
  switch (failure) {
    case 'requisition authorization denied':
      return 'This package requires a restricted procurement routing override.';
    case 'restricted procurement suspended':
      return 'Restricted procurement is suspended by Internal Compliance.';
    case 'medical supply recall active':
      return 'Medical requisitions are suspended during the active supply recall.';
    case 'round requisition limit reached':
      return 'This package has reached its shift requisition limit.';
    case 'shipment queue full':
      return 'Maximum active requisition capacity has been reached.';
    case 'insufficient allocation':
      return 'Insufficient Operational Allocation is available for this requisition.';
    case 'invalid requisition':
      return 'This requisition is no longer available.';
    default:
      return failure || 'This requisition is currently unavailable.';
  }
};

export const CCPostLogistics = () => {
  const { data, act } = useBackend<Data>();

  const {
    outpost_offline = false,
    read_only = false,
    allocation,
    reserved_allocation,
    available_allocation,
    max_allocation,
    active_shipments,
    max_active_shipments,
    freight_status,
    authorization_delay,
    dispatch_delay,
    transit_delay,
    freight_reasons = [],
    medical_recall_active = false,
    restricted_procurement_suspended = false,
    restricted_procurement_seconds = 0,
    catalog = [],
    shipments = [],
    ledger = [],
  } = data;

  const [tab, setTab] = useLocalState(
    'tab',
    LogisticsTab.Requisitions,
  );

  const [manualOpen, setManualOpen] = useLocalState('ccpostLogisticsManual', false);
  const [freightExpanded, setFreightExpanded] = useLocalState('ccpostFreightExpanded', false);

  if (outpost_offline) {
    return (
      <Window title="Central Command Logistics" width={720} height={270} theme="ntos">
        <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Regional Logistics" division="CENTRAL COMMAND" />
          <Layout.Content scrollable className="CCPostAdminBody">
          <NoticeBox danger>INSTALLATION OFFLINE. Central procurement routing and allocation services are unavailable following loss of the Liaison Outpost.</NoticeBox>
        
          </Layout.Content>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window
      title="Central Command Logistics"
      width={760}
      height={720}
      theme="ntos"
    >
      <Window.Content className="ccpost-theme ccpost-theme--sage ccpost-admin-v2">
          <CCPostHeader title="Regional Logistics" division="CENTRAL COMMAND" />
          <div className="CCPostAdminNav"><Tabs fluid>
              <Tabs.Tab
                icon="boxes-stacked"
                selected={tab === LogisticsTab.Requisitions}
                onClick={() => setTab(LogisticsTab.Requisitions)}
              >
                Requisitions
              </Tabs.Tab>

              <Tabs.Tab
                icon="truck"
                selected={tab === LogisticsTab.Shipments}
                onClick={() => setTab(LogisticsTab.Shipments)}
              >
                Shipments
              </Tabs.Tab>

              <Tabs.Tab
                icon="file-invoice-dollar"
                selected={tab === LogisticsTab.Ledger}
                onClick={() => setTab(LogisticsTab.Ledger)}
              >
                Allocation
              </Tabs.Tab>
              <Tabs.Tab icon="clipboard-check" selected={tab === LogisticsTab.Inspections} onClick={() => setTab(LogisticsTab.Inspections)}>Inspections{data.inspection_reference ? ' (1)' : ''}</Tabs.Tab>
            </Tabs></div>
          <Layout.Content scrollable className="CCPostAdminBody">
        {Boolean(read_only) && (<NoticeBox>OBSERVER MODE: Read-only. Requisitions and printing remain restricted to Central Command personnel.</NoticeBox>)}
        <Stack vertical>
          <Stack.Item>
            <div className="CCPostWorkspaceToolbar">
              <div><strong>Procurement Operations</strong><span>Requisitions · Allocation · Freight</span></div>
              <Button icon="question-circle" onClick={() => setManualOpen(!manualOpen)}>{manualOpen ? 'Hide Manual' : 'Operating Manual'}</Button>
            </div>
            {manualOpen && (
              <Section title="Requisitions & Allocation Procedures">
                <Box>Confirm allocation, package contents and current routing before placing a requisition. Inspection consignments are not discretionary supplies. Security must compare contents, remove undeclared goods, stamp the original manifest, return it inside the closed crate, select Swipe Security ID under Regional Freight Inspections, then dispatch via the outbound lane. Reserved CU remains committed until the freight request is resolved.</Box>
                <Box mt={1}>Medical recalls, restricted procurement holds and sector transit conditions may limit dispatch. All actions are recorded for Central Command audit.</Box>
              </Section>
            )}
          </Stack.Item>
          <Stack.Item>
            <div className="CCPostMetricRow">
              <div className="CCPostMetric"><div className="CCPostMetric__value">{allocation} / {max_allocation}</div><div className="CCPostMetric__label">TOTAL ALLOCATION (CU)</div></div>
              <div className="CCPostMetric"><div className="CCPostMetric__value">{available_allocation} CU</div><div className="CCPostMetric__label">AVAILABLE</div></div>
              <div className="CCPostMetric"><div className="CCPostMetric__value">{reserved_allocation} CU</div><div className="CCPostMetric__label">RESERVED</div></div>
              <div className="CCPostMetric"><div className="CCPostMetric__value">{active_shipments} / {max_active_shipments}</div><div className="CCPostMetric__label">ACTIVE FREIGHT</div></div>
            </div>
          </Stack.Item>

          <Stack.Item>
            <div className="CCPostFreightStrip">
              <div className="CCPostFreightStrip__stat"><span>ROUTING</span><FreightConditionStatus status={freight_status} /></div>
              <div className="CCPostFreightStrip__stat"><span>Authorization</span><strong>{formatFreightDuration(authorization_delay)}</strong></div>
              <div className="CCPostFreightStrip__stat"><span>Dispatch</span><strong>{formatFreightDuration(dispatch_delay)}</strong></div>
              <div className="CCPostFreightStrip__stat"><span>Transit</span><strong>{formatFreightDuration(transit_delay)}</strong></div>
              <Button icon={freightExpanded ? 'chevron-up' : 'chevron-down'} onClick={() => setFreightExpanded(!freightExpanded)}>
                {freightExpanded ? 'Hide Advisories' : `Sector Factors (${freight_reasons.length})`}
              </Button>
              {freightExpanded && (
                <div className="CCPostFreightStrip__detail">
                  {!freight_reasons.length ? <Box color="label">No exceptional routing conditions currently reported.</Box> : freight_reasons.map((reason, index) => <Box key={index}>• {reason}</Box>)}
                </div>
              )}
            </div>
          </Stack.Item>

          

          <Stack.Item grow>
            {tab === LogisticsTab.Requisitions && (
              <RequisitionsTab
                catalog={catalog}
                availableAllocation={available_allocation}
                activeShipments={active_shipments}
                maxActiveShipments={max_active_shipments}
                medicalRecallActive={medical_recall_active}
                restrictedProcurementSuspended={
                  restricted_procurement_suspended
                }
                restrictedProcurementSeconds={
                  restricted_procurement_seconds
                }
              />
            )}

            {tab === LogisticsTab.Shipments && (
              <ShipmentsTab shipments={shipments} />
            )}

            {tab === LogisticsTab.Inspections && (
              <>
                <Section title="Regional Freight Inspections">
                  <div className="CCPostInspectionHeading"><div><small>ACTIVE CONSIGNMENT</small><strong>{data.inspection_reference || 'No active consignment'}</strong></div><span className="CCPostStatusTag">{data.inspection_status || 'STANDBY'}</span></div>
                  {data.inspection_reference ? <>
                    <Box color="label" mt={1}>Clearance window: {formatFreightDuration(data.inspection_seconds || 0)}</Box>
                    <div className="CCPostInspectionSteps"><div><b>01</b> Check the physical manifest and remove discrepancies.</div><div><b>02</b> Stamp the original, return it inside the crate and close the lid.</div><div><b>03</b> Swipe your registered Security ID here, then return the consignment via the outbound lane.</div></div>
                    <Button fluid icon="id-card" color="good" disabled={Boolean(read_only) || !data.inspection_can_certify || data.inspection_status === 'CERTIFIED'} onClick={() => act('certify_inspection', { reference: data.inspection_reference })}>{data.inspection_status === 'CERTIFIED' ? 'Consignment Certified' : 'Swipe Security ID'}</Button>
                    {!data.inspection_can_certify && <Box color="label" mt={1}>Certification requires the assigned Security Officer wearing their registered ID, and an arrived consignment.</Box>}
                  </> : <Box color="label" mt={1}>Awaiting a regional consignment for Security clearance.</Box>}
                </Section>
                <Section title="Clearance History">{(data.inspection_history || []).length ? (data.inspection_history || []).map((entry, index) => <div className="CCPostInspectionHistory" key={index}>{entry}</div>) : <Box color="label">No inspection outcomes recorded.</Box>}</Section>
              </>
            )}
            {tab === LogisticsTab.Ledger && (
              <LedgerTab ledger={ledger} />
            )}
          </Stack.Item>
        </Stack>
      
          </Layout.Content>
        </Window.Content>
    </Window>
  );
};

const FreightConditionStatus = (props: { status: string }) => {
  const { status } = props;

  if (status === 'DEGRADED') {
    return <Box inline bold color="bad">{status}</Box>;
  }

  if (status === 'PRIORITY') {
    return <Box inline bold color="good">{status}</Box>;
  }

  if (status === 'MIXED') {
    return <Box inline bold color="average">{status}</Box>;
  }

  return <Box inline bold color="good">{status || 'NORMAL'}</Box>;
};

const RequisitionsTab = (props: {
  catalog: SupplyPackage[];
  availableAllocation: number;
  activeShipments: number;
  maxActiveShipments: number;
  medicalRecallActive: boolean;
  restrictedProcurementSuspended: boolean;
  restrictedProcurementSeconds: number;
}) => {
  const { act } = useBackend<Data>();

  const {
    catalog,
    availableAllocation,
    activeShipments,
    maxActiveShipments,
    medicalRecallActive,
    restrictedProcurementSuspended,
    restrictedProcurementSeconds,
  } = props;

  const [selectedCategory, setSelectedCategory] = useLocalState(
    'requisitionCategory',
    'Administration',
  );

  const [priceAscending, setPriceAscending] = useLocalState('ccpostPriceAscending', true);
  const [packageSearch, setPackageSearch] = useLocalState('ccpostPackageSearch', '');
  const [expandedPackageId, setExpandedPackageId] = useLocalState(
    'expandedPackageId',
    '',
  );

  if (!catalog.length) {
    return (
      <Section title="Central Command Requisitions">
        <NoticeBox>No procurement packages are currently available.</NoticeBox>
      </Section>
    );
  }

  const preferredCategoryOrder = [
    'Administration',
    'Sustenance',
    'Medical',
    'Engineering',
    'Materials',
    'Technical',
    'Emergency',
    'Security',
    'Entertainment',
    'Restricted',
  ];

  const categories: string[] = [];

  catalog.forEach((pack) => {
    if (!categories.includes(pack.category)) {
      categories.push(pack.category);
    }
  });

  categories.sort((a, b) => {
    const aIndex = preferredCategoryOrder.indexOf(a);
    const bIndex = preferredCategoryOrder.indexOf(b);

    if (aIndex === -1 && bIndex === -1) {
      return a.localeCompare(b);
    }

    if (aIndex === -1) {
      return 1;
    }

    if (bIndex === -1) {
      return -1;
    }

    return aIndex - bIndex;
  });

  const activeCategory = categories.includes(selectedCategory)
    ? selectedCategory
    : categories[0];

  const activeCategoryPackages = catalog.filter(
    (pack) => pack.category === activeCategory && (!packageSearch.trim() || `${pack.name} ${pack.description}`.toLowerCase().includes(packageSearch.trim().toLowerCase())),
  ).sort((a, b) => (priceAscending ? a.cost - b.cost : b.cost - a.cost) || a.name.localeCompare(b.name));

  const activeCategoryRecallLocked =
    activeCategory === 'Medical' && Boolean(medicalRecallActive);

  const activeCategoryComplianceLocked =
    activeCategory === 'Restricted' &&
    Boolean(restrictedProcurementSuspended);

  const restrictedHoldMinutes = Math.max(
    1,
    Math.ceil(restrictedProcurementSeconds / 60),
  );

  return (
    <Section
      title={`Requisitions | ${availableAllocation} CU available`}
      buttons={<Button icon={priceAscending ? "sort-amount-down-alt" : "sort-amount-down"} onClick={() => setPriceAscending(!priceAscending)}>{priceAscending ? "Price: Low to High" : "Price: High to Low"}</Button>}
    >
      {activeShipments >= maxActiveShipments && (
        <NoticeBox danger>
          Maximum active requisition capacity reached. Wait for an active
          shipment to be delivered before submitting another order.
        </NoticeBox>
      )}

      {Boolean(medicalRecallActive) && (
        <NoticeBox danger>
          Central Medical Logistics recall active. Medical requisitions remain
          visible for reference, but all Medical-category packages are locked
          until the recall is cleared.
        </NoticeBox>
      )}

      {Boolean(restrictedProcurementSuspended) && (
        <NoticeBox danger>
          INTERNAL COMPLIANCE HOLD: Restricted procurement privileges are
          suspended for approximately {restrictedHoldMinutes} more minute
          {restrictedHoldMinutes === 1 ? '' : 's'}. Routine requisitions remain
          available.
        </NoticeBox>
      )}

      <div className="CCPostCatalogueSearch"><Input fluid placeholder="Search packages in this category" value={packageSearch} onChange={setPackageSearch} /></div>
      <Stack className="CCPostCatalogueLayout">
        <Stack.Item minWidth="150px" shrink={0} basis={0}>
          <Tabs vertical>
            {categories.map((category) => {
              const categoryRecallLocked =
                category === 'Medical' && Boolean(medicalRecallActive);

              const categoryComplianceLocked =
                category === 'Restricted' &&
                Boolean(restrictedProcurementSuspended);

              const categoryLocked =
                categoryRecallLocked || categoryComplianceLocked;

              let categoryLabel = category;

              if (categoryRecallLocked) {
                categoryLabel = `${category} [RECALL]`;
              } else if (categoryComplianceLocked) {
                categoryLabel = `${category} [HOLD]`;
              }

              return (
                <Tabs.Tab
                  key={category}
                  icon={categoryLocked ? 'lock' : undefined}
                  selected={activeCategory === category}
                  onClick={() => setSelectedCategory(category)}
                >
                  {categoryLabel}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Stack.Item>

        <Stack.Item grow>
          <Section
            title={`Available Packages | ${activeCategory}`}
            buttons={
              activeCategoryRecallLocked ? (
                <Box bold color="bad">
                  RECALL LOCKED
                </Box>
              ) : activeCategoryComplianceLocked ? (
                <Box bold color="bad">
                  COMPLIANCE HOLD
                </Box>
              ) : undefined
            }
          >
            <Stack vertical>
              {!activeCategoryPackages.length && <Box color="label">No packages match this search.</Box>}
              {activeCategoryPackages.map((pack) => {
                const recallLocked = Boolean(pack.recall_locked);

                const complianceLocked =
                  pack.category === 'Restricted' &&
                  Boolean(restrictedProcurementSuspended);

                const packageLocked =
                  recallLocked || complianceLocked;

                const requisitionFailure = pack.can_order
                  ? undefined
                  : formatRequisitionFailure(pack.requisition_failure);

                const isExpanded = expandedPackageId === pack.id;

                return (
                  <Stack.Item key={pack.id}>
                    <Section
                      title={pack.name}
                      className="CCPostPackageCard"
                      buttons={
                        <>
                          <Button
                            icon={
                              isExpanded ? 'chevron-up' : 'list-ul'
                            }
                            onClick={() =>
                              setExpandedPackageId(
                                isExpanded ? '' : pack.id,
                              )
                            }
                          >
                            {isExpanded
                              ? 'Hide Contents'
                              : 'View Contents'}
                          </Button>

                          <Button
                            icon={
                              packageLocked ? 'lock' : 'cart-plus'
                            }
                            disabled={!pack.can_order}
                            tooltip={requisitionFailure}
                            onClick={() =>
                              act('order_package', {
                                package_id: pack.id,
                              })
                            }
                          >
                            {recallLocked
                              ? 'Recall Locked'
                              : complianceLocked
                                ? 'Compliance Hold'
                                : 'Requisition'}
                          </Button>
                        </>
                      }
                    >
                      <LabeledList>
                        <LabeledList.Item label="Description">{pack.description}{!!pack.round_limit && <Box color="label">Shift limit: {pack.round_limit} requisition(s).</Box>}</LabeledList.Item>

                        <LabeledList.Item label="Allocation Cost">
                          <Box
                            inline
                            bold
                            color={
                              pack.cost <= availableAllocation
                                ? 'good'
                                : 'bad'
                            }
                          >
                            {pack.cost} CU
                          </Box>
                        </LabeledList.Item>

                        <LabeledList.Item label="Estimated Delivery">
                          <Box
                            inline
                            bold
                            color={
                              pack.has_package_specific_routing
                                ? 'average'
                                : undefined
                            }
                          >
                            {formatFreightDuration(
                              pack.estimated_total_delay,
                            )}
                          </Box>
                        </LabeledList.Item>

                        {Boolean(pack.has_package_specific_routing) && (
                          <>
                            <LabeledList.Item label="Package Routing">
                              <FreightConditionStatus
                                status={pack.routing_status}
                              />
                            </LabeledList.Item>

                            <LabeledList.Item label="Routing Breakdown">
                              Authorization {pack.authorization_delay}s
                              {' | '}
                              Dispatch {pack.dispatch_delay}s
                              {' | '}
                              Transit {pack.transit_delay}s
                            </LabeledList.Item>
                          </>
                        )}
                      </LabeledList>

                      {isExpanded && (
                        <Section
                          title="Declared Package Contents"
                          buttons={
                            <Button
                              icon="print"
                              onClick={() =>
                                act('print_package_manifest', {
                                  package_id: pack.id,
                                })
                              }
                            >
                              Print Manifest
                            </Button>
                          }
                        >
                          {pack.contents?.length ? (
                            pack.contents.map((item, index) => (
                              <Box
                                key={`${pack.id}-content-${index}`}
                                mb={0.5}
                              >
                                <Box inline bold color="label">
                                  {item.quantity}x{' '}
                                </Box>
                                {item.name}
                              </Box>
                            ))
                          ) : (
                            <Box color="label">
                              No contents have been declared for this
                              package.
                            </Box>
                          )}

                          <Box mt={1} color="label">
                            Contents reflect the declared supply
                            manifest. Items inside sealed boxes and
                            containers may not be listed individually.
                          </Box>
                        </Section>
                      )}

                      {Boolean(pack.has_package_specific_routing) && (
                        <Box
                          mt={1}
                          p={1}
                          backgroundColor="rgba(255, 255, 255, 0.04)"
                        >
                          <Box bold color="average" mb={0.5}>
                            Package-Specific Sector Conditions
                          </Box>

                          {pack.package_specific_reasons.length ? (
                            pack.package_specific_reasons.map(
                              (reason, index) => (
                                <Box
                                  key={`${pack.id}-routing-${index}`}
                                >
                                  • {reason}
                                </Box>
                              ),
                            )
                          ) : (
                            <Box color="label">
                              This package currently follows a
                              different freight profile from the
                              sector-wide estimate.
                            </Box>
                          )}
                        </Box>
                      )}

                      {!pack.can_order && requisitionFailure && (
                        <NoticeBox danger mt={1}>
                          Requisition unavailable: {requisitionFailure}
                        </NoticeBox>
                      )}
                    </Section>
                  </Stack.Item>
                );
              })}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ShipmentsTab = (props: { shipments: Shipment[] }) => {
  const { act } = useBackend<Data>();
  const { shipments } = props;

  return (
    <Section
      title="Shipment Tracking"
      buttons={
        <Button
          icon="print"
          onClick={() => act('print_shipment_log')}
        >
          Print Shipment Log
        </Button>
      }
    >
      {!shipments.length ? (
        <NoticeBox>
          No requisitions have been submitted.
        </NoticeBox>
      ) : (
        <Stack vertical>
          {shipments.map((shipment) => (
            <Stack.Item key={shipment.code}>
              <Section
                title={shipment.code}
                buttons={
                  <Button
                    icon="print"
                    onClick={() =>
                      act('print_shipment', {
                        shipment_code: shipment.code,
                      })
                    }
                  >
                    Print
                  </Button>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Package">
                    {shipment.package_name}
                  </LabeledList.Item>

                  <LabeledList.Item label="Cost">
                    {shipment.cost} CU
                  </LabeledList.Item>

                  <LabeledList.Item label="Status">
                    <ShipmentStatus status={shipment.status} />
                  </LabeledList.Item>

                  <LabeledList.Item label="Requested By">
                    {shipment.requested_by}
                  </LabeledList.Item>

                  <LabeledList.Item label="Requested">
                    {shipment.requested_at}
                  </LabeledList.Item>

                  <LabeledList.Item label="Last Update">
                    {shipment.updated_at}
                  </LabeledList.Item>

                  <LabeledList.Item label="Sector Profile">
                    <FreightConditionStatus
                      status={shipment.freight_condition_status}
                    />
                  </LabeledList.Item>

                  <LabeledList.Item label="Processing Times">
                    Auth {shipment.authorization_delay}s
                    {' | '}
                    Dispatch {shipment.dispatch_delay}s
                    {' | '}
                    Transit {shipment.transit_delay}s
                  </LabeledList.Item>

                  {!!shipment.failure_reason && (
                    <LabeledList.Item label="Failure">
                      <Box color="bad">
                        {shipment.failure_reason}
                      </Box>
                    </LabeledList.Item>
                  )}
                </LabeledList>

                {!!shipment.freight_condition_reasons?.length && (
                  <Box mt={1}>
                    <Box bold mb={0.5}>
                      Applied Sector Factors
                    </Box>

                    {shipment.freight_condition_reasons.map(
                      (reason, index) => (
                        <Box key={index}>
                          • {reason}
                        </Box>
                      ),
                    )}
                  </Box>
                )}
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const ShipmentStatus = (props: { status: string }) => {
  const { status } = props;

  if (status === 'QUEUED') {
    return <Box inline bold color="average">{status}</Box>;
  }

  if (status === 'AUTHORIZED') {
    return <Box inline bold color="good">{status}</Box>;
  }

  if (status === 'IN TRANSIT') {
    return <Box inline bold color="blue">{status}</Box>;
  }

  if (status === 'DELIVERED') {
    return <Box inline bold color="good">{status}</Box>;
  }

  if (status === 'FAILED') {
    return <Box inline bold color="bad">{status}</Box>;
  }

  return <Box inline bold>{status}</Box>;
};

const LedgerTab = (props: { ledger: LedgerEntry[] }) => {
  const { act } = useBackend<Data>();
  const { ledger } = props;

  return (
    <Section
      title="Operational Allocation Ledger"
      buttons={
        <Button
          icon="print"
          onClick={() => act('print_ledger')}
        >
          Print Ledger
        </Button>
      }
    >
      {!ledger.length ? (
        <NoticeBox>
          No allocation transactions have been recorded.
        </NoticeBox>
      ) : (
        <Stack vertical>
          {ledger.map((entry, index) => (
            <Stack.Item key={index}>
              <Section
                title={`${entry.time} | ${
                  entry.amount > 0 ? '+' : ''
                }${entry.amount} CU`}
              >
                <LabeledList>
                  <LabeledList.Item label="Transaction">
                    <Box
                      color={
                        entry.amount > 0 ? 'good' : 'bad'
                      }
                      bold
                    >
                      {entry.amount > 0 ? '+' : ''}
                      {entry.amount} CU
                    </Box>
                  </LabeledList.Item>

                  <LabeledList.Item label="Reason">
                    {entry.reason}
                  </LabeledList.Item>

                  <LabeledList.Item label="Recorded By">
                    {entry.actor}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};