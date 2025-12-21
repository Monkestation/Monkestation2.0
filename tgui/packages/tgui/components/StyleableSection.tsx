import { Box } from './Box';

// The cost of flexibility and prettiness.
export const StyleableSection: React.FC<{
  style?;
  titleStyle?;
  textStyle?;
  title?;
  titleSubtext?;
  children?;
}> = (props) => {
  return (
    <Box style={props.style}>
      {/* Yes, this box (line above) is missing the "Section" class. This is very intentional, as the layout looks *ugly* with it.*/}
      <Box className="Section__title" style={props.titleStyle}>
        <Box className="Section__titleText" style={props.textStyle}>
          {props.title}
        </Box>
        <div className="Section__buttons">{props.titleSubtext}</div>
      </Box>
      <Box className="Section__rest">
        <Box className="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};
