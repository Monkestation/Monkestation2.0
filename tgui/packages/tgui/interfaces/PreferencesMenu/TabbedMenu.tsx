import { Component, createRef, InfernoNode, RefObject } from 'inferno';
import { Button, Section, Stack } from '../../components';
import { Flex, FlexProps } from '../../components/Flex';

type TabbedMenuProps = {
  categoryEntries: [string, InfernoNode][];
  contentProps?: FlexProps;
  extra?: InfernoNode;
  name: string;
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
      <Stack vertical>
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
          <Section height="100%" title={this.props.name}>
            <Stack vertical width="150px">
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
          </Section>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item
          grow
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
