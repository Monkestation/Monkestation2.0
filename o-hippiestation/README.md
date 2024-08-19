>you can press control + shift + v in visual studio code to make this document **beautiful**
# Modularization
due to the absurd nature of branching open source games, Its important to follow certain standards to make maintaining and contributing easier. 
For the sake of standardization, we will be following Monkestations protocols which are found [here](../monkestation/README.md). Huge thanks to [ZoneSpace](https://www.byond.com/members/zonespace) for explaining everything so clearly. 

## History and practices

> [Ascenti, our current head] has been trying for 4 years to glue some random codebase together. - Don Karma

Hippiestation is currently downstream from Monkestation, which is downstream from /tg/station, which is downstream from Goonstation.
However, Goonstation does its own thing so we consider /tg/ the root.

 Because of our policies and the conduct of our past staff, there is a lot of vitriol between hippie and the rest of the community. While we don't particularly care to much about this, it's still a good idea contribute upstream when possible for several reasons.
 - It can **ease tensions** and encourage **cooperation**
 - It reduces the amount of code we have to maintain and **eliminates merge conflicts**.
 - If something gets merged upstream, It will be **maintained** and **optimized** by a broader group of people.

## Where to contribute

Monkestation, /tg/station, and Hippiestation all have different goals and playstyles.
something that Monkestation might accept may get rejected by /tg/ and vise versa. below are some guidelines for seeing if your changes will be accepted.
### /tg/station
/tg/ is the oldest of the three branches and has a robust and dedicated army of contributors. The catch is they are the most conservative option. Its preferable to get your feature or change added here and then cherry pick it. [design docs](https://hackmd.io/@tgstation)
- **fantasy** and **magic** based features will likely be **rejected**.
- **silly**, **unrealistic**, or **goofy** features will likely be **rejected**
- **overpowered**, **game changing**, or **unbalanced** features will likely be **rejected**
- **tech based**, **sci-fi**, and **roleplay** features will likely be **accepted**
- **bug fixes** and **optimizations** will be **accepted** and should always be merged here
- don't mention the feature or change is originating from hippie, you might get less resistance.

### Monkestation
Monkestation aligns closer our playstyle. However it is run by a twitch streamer so they have tighter restrictions on antagonist, nsfw content and roleplay standards. [rules](https://wiki.monkestation.com/)

- anything **dark** (like the noose) will likely be **rejected**
- anything overly **nsfw** or **gory** (like cavity searches or teeth pulling) will likely be **rejected**
- **silly**, **unrealistic**, or **goofy** features will likely be **accepted**
- don't mention the feature or change is originating from hippie, you might get less resistance.

### Hippiestation
We are pretty liberal on what we accept, feel free to run any bizzare idea by us, the worst we can do is say no.

## o-hippiestation folder

Our root folder is called **`/o-hippiestation`** it sits after the **`/monkestation`** folder, enabling us to hook and overwrite any of their changes. You shouldn't need to touch **`/monkestation`** folder at all. the same practices [here](../monkestation/README.md) apply for our folder as well. we attached and modified the following section about non-modular changes below

### Non-modular Changes to the Core Code - IMPORTANT

>**You shouldn't need to modify code in `/monkestation`, simply overwrite it in `/o-hippiestation`**

Every once in a while, there comes a time, where editing the core files becomes inevitable.

In those cases, this is the following convention, with examples:

- **Addition:**

  ```byond
  //HIPPIE EDIT START - reason (optional)
  var/adminEmergencyNoRecall = FALSE
  var/lastMode = SHUTTLE_IDLE
  var/lastCallTime = 6000
  //HIPPIE EDIT END
  ```

- **Removal:**

  ```byond
  //HIPPIE REMOVAL START - reason (optional)
  /*
  for(var/obj/docking_port/stationary/S in stationary)
    if(S.id = id)
      return S
  */
  //HIPPIE REMOVAL END
  WARNING("couldn't find dock with id: [id]")
  ```


- **Change:**

  ```byond
  //HIPPIE EDIT START - reason (optional)
  //if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE) - HIPPIE EDIT ORIGINAL
  if(SHUTTLE_STRANDED, SHUTTLE_ESCAPE, SHUTTLE_DISABLED)
  //HIPPIE EDIT END
      return 1
   ```
