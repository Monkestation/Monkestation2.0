import { strict as assert } from 'node:assert';
import { get_updated_label_set } from './autoLabel.js';

const empty_pr = {
  action: 'opened',
  pull_request: {
    body: 'This PR will have no labels',
    title: 'Pr with no labels',
    mergeable: true,
  },
};
const empty_label_set = await get_updated_label_set({
  github: null,
  context: { payload: empty_pr },
});
assert.equal(empty_label_set.length, 0, 'No labels should be added');

const cl = `
My Awesome PR

:cl: Awesome Dude
add: Adds Awesome Stuff
refactor: refactored some code
:/cl:
`;
const cl_pr = {
  action: 'opened',
  pull_request: {
    body: cl,
    title: 'Awesome PR',
    mergeable: false,
  },
};
const cl_label_set = await get_updated_label_set({
  github: null,
  context: { payload: cl_pr },
});
assert.ok(
  cl_label_set.includes('Merge Conflict'),
  'Merge Conflict label should be added',
);
assert.ok(
  cl_label_set.includes('Feature: Feature'),
  'Feature label should be added',
);
assert.ok(
  cl_label_set.includes('Feature: Refactor/Rework'),
  'Refactor label should be added',
);

const title_pr = {
  action: 'opened',
  pull_request: {
    title: 'Remove monkeys',
    mergeable: true,
  },
};
const title_label_set = await get_updated_label_set({
  github: null,
  context: { payload: title_pr },
});
assert.ok(title_label_set.includes('Removal'), 'Removal label should be added');
