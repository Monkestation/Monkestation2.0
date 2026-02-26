# Modularization

"things will be a lot less ambiguous and messy." they said.

From this point on, we are killing modularization. Do not follow modularization guidelines.

--

# No more modularization

Monke is very behind from Tgstation and it is way too late to start caring.

## We are behind 17k commits, comparing the following commits

TG Head right now - [a375d5331d1c2edb7c3a9046c2a9f6a97614c2ce](https://github.com/tgstation/tgstation/commit/a375d5331d1c2edb7c3a9046c2a9f6a97614c2ce)
Monkestation Head right now - [0ea11c6ea013cdc912e601a5e39db1db7ffcc5d4](https://github.com/Monkestation/Monkestation2.0/commit/0ea11c6ea013cdc912e601a5e39db1db7ffcc5d4)

```
git rev-list --left-right --count
a375d5331d1c2edb7c3a9046c2a9f6a97614c2ce...0ea11c6ea013cdc912e601a5e39db1db7ffcc5d4

17810   10794
```

Left: Commits behind - Right: Commits ahead

And by the way, each commit is essentially a PR since TG merges PRs via "Squash and Merge" (Divided by like 2 since CI changelog actions are their own commits, BUT STILL, thats about 8.8k PRs). Suffice to say, we're very.. very out of date, and there's no chance at saving this. So with that said...

# We are killing modularization

Any PRs going forward **should not participate in modularization or follow its guidelines**.

We've deviated from TG so much that it's starting to bite us in the ass with how our features are spread between `code` and `monkestation/code`.

We’re not doing a mass deletion/demodularization (yet). Stuff that’s modular will stay that way until it’s touched again by whoever feels like demodularizing. Put new stuff in `code` instead of `monkestation`

# TL;DR

- We're killing modularization, do not follow the guidelines from this point on.
