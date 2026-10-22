const fs = require("fs");
const path = require("path");
const { parse } = require("@babel/parser");
const traverse = require("@babel/traverse").default;

// function scanFile(file) {
//   const code = fs.readFileSync(file, "utf8");

//   const ast = parse(code, {
//     sourceType: "module",
//     plugins: ["jsx", "typescript"],
//   });

//   traverse(ast, {
//     JSXOpeningElement(p) {
//       const n = p.node;
//       if (n.name.type !== "JSXIdentifier") return;
//       if (n.name.name !== "Section") return;

//       const hasRef = n.attributes.some(
//         (a) => a.type === "JSXAttribute" && a.name.name === "ref",
//       );

//       if (hasRef) {
//         const loc = n.loc?.start;
//         console.log(`${file}:${loc?.line ?? "?"}`);
//       }
//     },
//   });
// }

// check for if elements A or B have both attributes named onInput and onChange.
function scanFile(file) {
  const code = fs.readFileSync(file, "utf8");

  const ast = parse(code, {
    sourceType: "module",
    plugins: ["jsx", "typescript"],
  });

  traverse(ast, {
    JSXOpeningElement(p) {
      const n = p.node;

      if (n.name.type !== "JSXIdentifier") return;
      if (n.name.name !== "Input" && n.name.name !== "TextArea") return;

      let hasOnInput = false;
      let hasOnChange = false;

      for (const attr of n.attributes) {
        if (attr.type !== "JSXAttribute") continue;
        if (attr.name.name === "oninput") hasOnInput = true;
        if (attr.name.name === "onInput") hasOnInput = true;
        if (attr.name.name === "onChange") hasOnChange = true;
        if (attr.name.name === "onchange") hasOnChange = true;
      }

      if (hasOnInput && hasOnChange) {
        const loc = n.loc?.start;
        console.log(
          `${file}:${loc?.line ?? "?"} <${n.name.name}> has both onInput and onChange`,
        );
      }
    },
  });
}

function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full);
    else if (/\.(jsx|tsx)$/.test(entry.name)) scanFile(full);
  }
}

walk(path.join(__dirname, "..", "..", "tgui", "packages"));
