# Modularization

"things will be a lot less ambiguous and messy." they said.

From this point on, we are killing modularization. Do not follow modularization guidelines.

See the following announcement from the discord below

--

# We need to talk about modularization on Monkestation.

Modularization. It's a core part of our codebase and we've preached it a lot in the past before, especially in the days we we're just a baby fork of Tgstation. It was supposed to be our savior for keeping things balanced with features pulled from upstream (upstream being TG). But a lot of time and commits have passed since then, **and late last year we deforked from TG due to how many problems it caused.**

## We are behind 17k commits,  comparing the following commits

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

Modularization aimed to make things easier and give coders less of a headache, but as I just said, we've deviated from TG so much that it's starting to bite us in the ass with how our features are spread between `code` and `monkestation/code`.

We’re not doing a mass deletion/demodularization (yet). Stuff that’s modular will stay that way until it’s touched again by whoever feels like demodularizing. But new stuff? Put it in `code`. You are unleashed.

# TL;DR

- We're killing modularization, do not follow the guidelines from this point on.
