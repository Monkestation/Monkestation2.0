import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { Box, Button, Section, Stack } from '../../components';
import { Flex, FlexProps } from '../../components/Flex';

type TabbedMenuProps = {
  categoryEntries: [string, InfernoNode][];
  contentProps?: FlexProps;
  extra?: InfernoNode;
};

export class TabbedMenu extends Component<TabbedMenuProps> {
  categoryRefs: Record<string, RefObject<HTMLDivElement>> = {};
  sectionRef: RefObject<HTMLDivElement> = createRef();

  getCategoryRef(category: string): RefObject<HTMLDivElement> {
    if (!this.categoryRefs[category]) {
      this.categoryRefs[category] = createRef();
    }

    return this.categoryRefs[category];
  }

  render() {
    const pageContents = (
      <Stack vertical maxWidth="900px">
        {this.props.categoryEntries.map(([category, children]) => {
          return (
            <Stack.Item key={category} innerRef={this.getCategoryRef(category)}>
              <Section fill title={category}>
                {children}
              </Section>
            </Stack.Item>
          );
        })}
      </Stack>
    );

    return (
      <Stack horizontal height="100%">
        <Stack.Item>
          <Stack vertical width="150px">
            <Stack.Item>
              <Box align="center" fontSize="1.5em">
                Hehe Monke
              </Box>
            </Stack.Item>
            <Stack.Divider />
            {this.props.categoryEntries.map(([category]) => {
              return (
                <Stack.Item key={category} grow basis="content">
                  <Button
                    align="center"
                    fontSize="1.2em"
                    fluid
                    onClick={() => {
                      const offsetTop =
                        this.categoryRefs[category].current?.offsetTop;

                      if (offsetTop === undefined) {
                        return;
                      }

                      const currentSection = this.sectionRef.current;

                      if (!currentSection) {
                        return;
                      }

                      currentSection.scrollTop = offsetTop;
                    }}
                  >
                    {category}
                  </Button>
                </Stack.Item>
              );
            })}
            {this.props.extra !== null ? (
              <>
                <Stack.Divider />
                <Stack.Item>{this.props.extra}</Stack.Item>
              </>
            ) : (
              <Flex />
            )}
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item
          innerRef={this.sectionRef}
          overflowY="scroll"
          {...{
            ...this.props.contentProps,

            // Otherwise, TypeScript complains about invalid prop
            className: undefined,
          }}
        >
          {pageContents}
        </Stack.Item>
      </Stack>
    );
  }
}
