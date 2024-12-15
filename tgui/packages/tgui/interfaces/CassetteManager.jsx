import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Table, Button } from '../components';

export const CassetteManager = (props) => {
  const { act, data } = useBackend();
  const { cassettes } = data;

  return (
    <Window width={600} height={313}>
      <Window.Content>
        <Section title="Cassette Manager">
          {cassettes && Object.keys(cassettes).length > 0 ? (
            <Table>
              <Table.Row header>
                <Table.Cell>Cassette ID</Table.Cell>
                <Table.Cell>Submitter</Table.Cell>
                <Table.Cell>Title</Table.Cell>
                <Table.Cell>Reviewed</Table.Cell>
                <Table.Cell>Action</Table.Cell>
              </Table.Row>
              {Object.entries(cassettes || {}).map(
                ([cassetteId, cassetteData]) => (
                  <Table.Row key={cassetteId}>
                    <Table.Cell>{cassetteId}</Table.Cell>
                    <Table.Cell>
                      {cassetteData.submitter_name || 'Unknown'}
                    </Table.Cell>
                    <Table.Cell>
                      {cassetteData.tape_name || 'Untitled'}
                    </Table.Cell>
                    <Table.Cell>
                      {cassetteData.reviewed ? 'Yes' : 'No'}
                    </Table.Cell>
                    <Table.Cell>
                      <Button onClick={() => act(cassetteId)}>Review</Button>
                    </Table.Cell>
                  </Table.Row>
                ),
              )}
            </Table>
          ) : (
            <b>Nothing to review. The Jam&apos;s must flow.</b>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
