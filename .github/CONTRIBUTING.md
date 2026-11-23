[CONTRIBUTING.MD.md](https://github.com/user-attachments/files/35296231/CONTRIBUTING.MD.md)

# CONTRIBUTING

1. [Monkestation Design Axioms](#monkestation-design-axioms)
2. [Reporting Issues](#reporting-issues)
3. [Introduction](#introduction)
4. [Getting Started](#getting-started)
5. [Meet the Team](#meet-the-team)
   1. [Maintainers](#maintainers)
6. [Development Guides](#development-guides)
7. [Pull Request Process](#pull-request-process)
8. [Porting features/sprites/sounds/tools from other codebases](#porting-featuresspritessoundstools-from-other-codebases)
9. [Banned content](#banned-content)
10. [A word on Git](#a-word-on-git)

## Monkestation Design Axioms

As a contributor, please consider if your work aligns with our design philosophy.

- We should improve/rework content instead of removing it, whenever possible.
- We should attempt to preserve the cultural artifacts and rich history of SS13 whilst still striving to improve it as a game.
- We should allow some features to remain stupid and/or potentially broken if they are fun or (positively) engaging. Think: is an issue fundamental to the item or mechanic, or is a player's abuse causing fatigue? If one person ruins the fun, the problem may be administrative rather than mechanical.
- In place of direct nerfs to powerful items or mechanic combinations, we should consider including escalating chances for backfire or major drawbacks, without taking away what makes those items or mechanics special. Don't nerf something to the ground just because it killed you, and do remember that the game is supposed to be unfair to a degree.

## Reporting Issues

If you ever encounter a bug in-game, the best way to let a coder know about it is with our GitHub Issue Tracker. Please make sure you use the supplied issue template, and include the round ID for the server.

(If you don't have an account, making a new one takes only one minute.)

If you have difficulty, ask for help in the #coding-general channel on our discord.

## Introduction

Hello and welcome to Monkestation's contributing page. You are here because you are curious or interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at Monkestation, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to hold up to those specifications. It's in everyone's best interests - including yours! - if the same bug doesn't have to be fixed twice because of duplicated code.

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## Getting Started

Monkestation doesn't have a list of goals and features to add; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game. Here are some useful starting guides, if you want to contribute or if you want to know what challenges you can tackle with zero knowledge about the game's code structure.

If you want to contribute the first thing you'll need to do is set up Git so you can download the Monkestation source code. You can use /tg/station's [Git setup guide](https://hackmd.io/@tgstation/HJ8OdjNBc) as an example to set up our repository: just use [Monkestation/Monkestation2.0](https://github.com/Monkestation/Monkestation2.0) wherever it mentions the tgstation repository.
After setting it up, optionally navigate your git commandline to the project folder and run the command: `git config blame.ignoreRevsFile .git-blame-ignore-revs`.

You may also want to read /tg/station's [guide to contributing](https://github.com/tgstation/tgstation/blob/master/.github/CONTRIBUTING.md). While we do have different rules, it's a good place to start.

We have a [Coding Tools guide on our wiki](https://wiki.monkestation.com/Coding_Tools) that will help you get started contributing to Monkestation with Git and Dream Maker. For beginners, it is recommended you work on small projects like bugfixes at first. If you need help learning to program in BYOND, check out this [repository of resources](http://www.byond.com/developer/articles/resources).

There is an open list of issues for [your inspiration here](https://github.com/Monkestation/Monkestation2.0/issues).

You can of course, as always, ask for help on the Discord channels or the forums. We're just here to have fun and help out, so please don't expect professional support.

## Meet the Team

### Maintainers

Maintainers are quality control. If a proposed pull request doesn't meet the following specifications, they can request you to change it, or simply just close the pull request. Maintainers are required to give a reason for closing the pull request.

Maintainers have the final decision on which code changes get in and which don't. If you're unsure whether a contribution is OK, you should ideally talk to a maintainer and get their approval first, to avoid wasting your time and work.

Maintainers can revert your changes if they feel they are not worth maintaining or if they did not live up to the quality specifications.

When maintainers disagree, the Maintainer Council votes. The Host (Aberra) breaks any ties.

<details>
<summary>Maintainer Guidelines</summary>

These are the few directives we have for project maintainers.

- Do not merge PRs you create. The only exception is emergency fixes, which you may merge yourself.
- Do not merge other people's Balance, Feature, Mapping or Removal PRs until 24 hours have passed since they were opened.
- Do not merge PRs that contain content from the [banned content list](./CONTRIBUTING.md#banned-content).
- Do not close PRs purely for breaking a template if the same information is contained without it.
- Do not merge PRs with the Do Not Merge (`Process: do not merge`) label, and do not remove the label, without the consent of the maintainer who applied it.
- PRs with the `Process: do not merge` label are closed after a week, unless another maintainer disputes the label. In that case, the Maintainer Council votes to either lift the label or close the PR.
- In case of a conflict between maintainers, the Maintainer Council votes on whether the PR gets approved. In case of a tie, the Host acts as the tiebreaker.

These are not steadfast rules as maintainers are expected to use their best judgement when operating.

Our team is entirely voluntary, as such we extend our thanks to maintainers and contributors alike for helping keep the project alive.

</details>

## Development Guides

#### Writing readable code

[Style guide](./guides/STYLE.md)

#### Writing sane code

[Code standards](./guides/STANDARDS.md)

#### Writing understandable code

[Autodocumenting code](./guides/AUTODOC.md)

#### Misc

- [AI Datums](../code/datums/ai/learn_ai.md)
- [Embedding TGUI Components in Chat](../tgui/docs/chat-embedded-components.md)
- [Hard Deletes](./guides/HARDDELETES.md)
- [MC Tab Guide](./guides/MC_tab.md)
- [Policy Configuration System](./guides/POLICYCONFIG.md)
- [Quickly setting up a development database with ezdb](./guides/EZDB.md)
- [Required Tests (Continuous Integration)](./guides/CI.md)
- [Splitting up pull requests, aka atomization](./guides/ATOMIZATION.md)
- [UI Development](../tgui/README.md)
- [Visual Effects and Systems](./guides/VISUALS.md)

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

- Make sure your pull request complies to the requirements outlined here

- You are expected to have tested your pull requests if it is anything that would warrant testing. Text only changes, single number balance changes, and similar generally don't need testing, but anything else does. This means by extension web edits are disallowed for larger changes.

- You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data. Should you be optimizing a routine you must provide proof by way of profiling that your changes are faster.

- We ask that you use the changelog system to document your player facing changes, which prevents our players from being caught unaware by said changes - you can find more information about this [on this wiki page](https://wiki.tgstation13.org/Guide_to_Changelogs).

- If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

- If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

- If your pull request is not finished, you may open it as a draft for potential review. If you open it as a full-fledged PR make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

- While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality _before_ you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

- After leaving reviews on an open pull request, maintainers may convert it to a draft. Once you have addressed all their comments to the best of your ability, feel free to mark the pull as `Ready for Review` again.

## Justifying Your Changes

You must explain why you are submitting the pull request in the "Why It's Good For The Game" section of your pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting your pull request wholesale, or requiring that you fix it before your pull request is merged. A reasonable justification for your changes is a requirement.

Your "Why It's Good For The Game" section must make a good faith and reasonable attempt to:

- Assert and argue that the current state of affairs in the game is not good, and needs changing.
- Assert and argue that your pull request will either fix or help fix the problems you described.
- Assert and argue that any downsides introduced by your solution as a matter of design, if any, are worth it, and why they are worth it.

More controversial changes have higher standards for justification to be considered reasonable. A bugfix for example does not typically require any effort at all in justification as its value to the game is usually self evident, however a major feature overhaul or balance change may require significant explanation to adequately justify its supposed benefit to the game.

This is still a requirement if your pull request is supported and/or requested by maintainers before it is opened. This is still a requirement if your pull request is supported and/or requested by the Host before it is opened. The purpose of arguing for your changes is not to convince just the maintainer team of its merits, it is to document the "why" behind your changes to the game to a necessary level of detail. The reason behind a change must exist as it is the purpose of this codebase to improve the game, thus said reasoning must be adequately stated and explained.

This is also still a requirement if your pull request has a corresponding design document that justifies your changes inside it. You must always properly justify changes (those that actually need justification) within the pull request, even if you also do it elsewhere. This is to ensure that:

1. All reviewers can easily see the reasoning behind your changes on the pull request itself, no reliance on other sites required.
2. The actual, manifested implementation of the idea behind the design document is being justified after said implementation is actually realized. This is in contrast to any reasoning put on the design document itself, which very well may have been made before any work was done on it, possibly even by an author different from the author of the pull request. Any idea in the design document may have had compromises put into it due to complications not seen in the original vision, thus the current state of the implementation (the pull request as it stands) must be defended, explained, and ultimately justified in and of itself. Of course, you should still list the design document the pull request is implementing, and may even use arguments from the design document if said arguments are applicable to the current reality of your proposed changes.

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All Monkestation assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.

## Banned content

Do not add any of the following in a Pull Request or risk getting the PR closed:

- National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
- Code which violates GitHub's [terms of service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service).
- Anything AI-generated, including code, sprites, sounds and text such as PR descriptions, bug reports, comments or reviews.
  - Using AI to help you learn how to code is completely fine, but you should be writing the code yourself.

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## A word on Git

This repository uses `LF` line endings for all code as specified in the **.gitattributes** and **.editorconfig** files.

Unless overridden or a non standard git binary is used the line ending settings should be applied to your clone automatically.

Note: VSC requires an [extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) to take advantage of editorconfig.

Github actions that require additional configuration are disabled on the repository until ACTION_ENABLER secret is created with non-empty value.

## Using the Maintainer Council Ping in Discord

The `@SS13 Maintainer Council` role should be used only to ping maintainers when your PR has had the "Stale" label applied. Using it before then can be met with escalating timeouts and referral to the Discord moderators for further infractions.

Feel free to engage and obtain general feedback in the Coding General channel without the role ping before your PR goes stale to build interest and get reviews.
