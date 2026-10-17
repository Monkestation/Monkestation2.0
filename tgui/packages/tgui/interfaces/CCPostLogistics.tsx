import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

type SupplyPackage = {
  id: string;
  name: string;
  description: string;
  category: string;
  cost: number;
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

  catalog: SupplyPackage[];
  shipments: Shipment[];
  ledger: LedgerEntry[];
};

enum LogisticsTab {
  Requisitions,
  Shipments,
  Ledger,
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
  const { data } = useBackend<Data>();

  const {
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

  return (
    <Window
      title="Central Command Logistics"
      width={760}
      height={720}
      theme="ntos"
    >
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Operational Allocation">
              <LabeledList>
                <LabeledList.Item label="Total Allocation">
                  <Box
                    inline
                    bold
                    color={allocation > 0 ? 'good' : 'bad'}
                  >
                    {allocation} CU
                  </Box>
                  {' / '}
                  {max_allocation} CU
                </LabeledList.Item>

                <LabeledList.Item label="Reserved Allocation">
                  {reserved_allocation} CU
                </LabeledList.Item>

                <LabeledList.Item label="Available to Spend">
                  <Box
                    inline
                    bold
                    color={available_allocation > 0 ? 'good' : 'bad'}
                  >
                    {available_allocation} CU
                  </Box>
                </LabeledList.Item>

                <LabeledList.Item label="Active Requisitions">
                  <Box
                    inline
                    bold
                    color={
                      active_shipments >= max_active_shipments
                        ? 'bad'
                        : 'good'
                    }
                  >
                    {active_shipments} / {max_active_shipments}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Sector Freight Conditions">
              <LabeledList>
                <LabeledList.Item label="Routing Status">
                  <FreightConditionStatus status={freight_status} />
                </LabeledList.Item>

                <LabeledList.Item label="Authorization">
                  {authorization_delay} seconds
                </LabeledList.Item>

                <LabeledList.Item label="Dispatch">
                  {dispatch_delay} seconds
                </LabeledList.Item>

                <LabeledList.Item label="Transit">
                  {transit_delay} seconds
                </LabeledList.Item>
              </LabeledList>

              {!!freight_reasons.length && (
                <Box mt={1}>
                  <Box bold mb={0.5}>
                    Active Sector Factors
                  </Box>
                  {freight_reasons.map((reason, index) => (
                    <Box key={index}>• {reason}</Box>
                  ))}
                </Box>
              )}

              {!freight_reasons.length && (
                <Box mt={1} color="average">
                  No exceptional sector routing conditions are currently
                  affecting freight operations.
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs fluid>
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
                Allocation Ledger
              </Tabs.Tab>
            </Tabs>
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

            {tab === LogisticsTab.Ledger && (
              <LedgerTab ledger={ledger} />
            )}
          </Stack.Item>

        </Stack>
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
    (pack) => pack.category === activeCategory,
  );
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
      title={`Central Command Requisitions - ${availableAllocation} CU Available`}
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

      <Stack>
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
            title={activeCategory}
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
              {activeCategoryPackages.map((pack) => {
                const recallLocked = Boolean(pack.recall_locked);
                const complianceLocked =
                  pack.category === 'Restricted' &&
                  Boolean(restrictedProcurementSuspended);
                const packageLocked = recallLocked || complianceLocked;
                const requisitionFailure = pack.can_order
                  ? undefined
                  : formatRequisitionFailure(pack.requisition_failure);

                return (
                  <Stack.Item key={pack.id}>
                    <Section
                      title={`${pack.name} - ${pack.cost} CU`}
                      buttons={
                        <Button
                          icon={packageLocked ? 'lock' : 'cart-plus'}
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
                      }
                    >
                      <LabeledList>
                        <LabeledList.Item label="Description">
                          {pack.description}
                        </LabeledList.Item>

                        <LabeledList.Item label="Allocation Cost">
                          <Box
                            inline
                            bold
                            color={
                              pack.cost <= availableAllocation ? 'good' : 'bad'
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
                              Boolean(pack.has_package_specific_routing)
                                ? 'average'
                                : undefined
                            }
                          >
                            {formatFreightDuration(pack.estimated_total_delay)}
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
                              Authorization {pack.authorization_delay}s // Dispatch{' '}
                              {pack.dispatch_delay}s // Transit {pack.transit_delay}s
                            </LabeledList.Item>
                          </>
                        )}
                      </LabeledList>

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
                            pack.package_specific_reasons.map((reason, index) => (
                              <Box key={`${pack.id}-routing-${index}`}>
                                • {reason}
                              </Box>
                            ))
                          ) : (
                            <Box color="label">
                              This package currently follows a different freight
                              profile from the sector-wide estimate.
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
        <Button icon="print" onClick={() => act('print_shipment_log')}>
          Print Shipment Log
        </Button>
      }
    >
      {!shipments.length ? (
        <NoticeBox>No requisitions have been submitted.</NoticeBox>
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
                    Auth {shipment.authorization_delay}s | Dispatch{' '}
                    {shipment.dispatch_delay}s | Transit{' '}
                    {shipment.transit_delay}s
                  </LabeledList.Item>

                  {!!shipment.failure_reason && (
                    <LabeledList.Item label="Failure">
                      <Box color="bad">{shipment.failure_reason}</Box>
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
                        <Box key={index}>• {reason}</Box>
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
        <Button icon="print" onClick={() => act('print_ledger')}>
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
                      color={entry.amount > 0 ? 'good' : 'bad'}
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
