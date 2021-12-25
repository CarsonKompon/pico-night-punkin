# Pico Night Punkin'
A [Friday Night Funkin'](https://github.com/ninjamuffin99/Funkin) Demake made in PICO-8 for Pico Day 2021
by [Carson Kompon](https://twitter.com/CarsonKompon) and [Chris West](https://twitter.com/blstrManx)

Newgrounds: https://www.newgrounds.com/portal/view/791887

Itch: https://carsonk.itch.io/pico-night-punkin

Lexaloffle BBS: https://www.lexaloffle.com/bbs/?tid=42715

# Modding Info
If you want to mod the game, it was made to be pretty straight forward. However, spritesheet editing/optimization will be a pain and require you to change a lot of hardcoded draw calls if you move things around. (Obviously PICO-8 is required and so is basic knowledge of it & Lua)
 
 Here's a brief run-down of each cart:
- fnf-menu is the primary cart, this is where the game starts, and only contains the splash text/title screen
- fnf-select is the song select screen, this redirects you to all the other carts
- fnf-gameover is the game over screen, it is hardcoded to send you back to certain carts based on the songid, so make sure you have the cart redirect you properly
- The rest of the carts are the individual songs. Each song is given one cart, but each cart contains multiple chart difficulties. This is because one song takes up nearly all of PICO-8s patterns, and one character occupies the entire spritesheet when included alongside boyfriend and the additional art assets. As a result of spritesheet limitations, this also means that the backgrounds are drawn in code.

**IMPORTANT NOTE:**
If you are exporting the game, load carts via `LOAD("FNF-EXAMPLE.P8")`
If you are publishing the game to the BBS, load carts via `LOAD("#FNF_EXAMPLE")` on release, with `#FNF_EXAMPLE` being the cart's id.

# Getting Started
These next few sections will go over how to create a Custom Song and Chart, and will point you in the right direction if you'd like to go about modifying sprites.

**The best place to start is by making a copy of `fnf-pico.p8` as it's the cleanest to work with of all the carts.**

# Creating a Custom Song
Creating a custom song is very straight-forward, but requires you to already know how to make music in PICO-8. I recommend you watch [Gruber's PICO-8 Music Tutorials](https://www.youtube.com/watch?v=nwFcitLtCsA&list=PLur95ujyAigsqZR1aNTrVGAvXD7EqywdS) if you have little to no experience.

When creating your song, start on Pattern 0, and try to leave at least 1 pattern of silence at beginning and end of your song to give the player some time to prepare, and then react to their performance when the song has finished.

**DO NOT MODIFY SFX #01, as this is the missed note sound effect that plays in-game**

# Creating a Custom Chart
Once you've created your Custom Song, you're now going to need to edit some of the code to make the game run in-time with your song. To do this, we'll have to modify the `SYNCTIME` variable at the bottom of the `_INIT()` function.

`SYNCTIME` should be equal to `(The SPD of your music patterns) * 3.18`

Now, to start creating the Chart, go to tab 2 in the code editor, and delete everything from inside of `init_beatmap()` and `init_beatmap_hard()` except for the `MUSIC(0)` line at the bottom.

To add notes to the chart, use:

`map_add(_map,_offset,_notes)`
 
`_map` - If the character on the left, this should be `leftmap`, if boyfriend, this should be `rightmap`
 
`_offset` - This is the offset of all the notes you're about to add. If you're charting pattern 1 of the song, the first note's offset would be 0 in the pattern, but 32 overall. So this should equal 32.
 
`_notes` - This is a string that includes all of the notes you're about to add. Here's an example of a chart:
 
map_add(leftmap,32,"0,0:4,1:8,2:12,3")
 
In this example, each note is separated with a `:`, and each note is formatted by `offset,note` with `offset` being the note's offset in the current pattern, and `note` going from 0 to 3, being left, down, up, right.
 
A note can optionally be formatted as `offset,note,length` with `length` being how long the note's trail is in notes (default is 0).

**UPDATE: YOU CAN NOW GENERATE `_notes` STRINGS UP TO A LENGTH OF 32 WITH [#PNP_CHARTER](https://www.lexaloffle.com/bbs/?pid=95597#p)**
(There's also [#IMPROVECHARTER](https://www.lexaloffle.com/bbs/?pid=96077#p) which is a mod of #PNP_CHARTER with some more ui elements and additional support)

Once you've created your chart, you can change the note jump speed in the `arrows_init()` function in tab 3 of the code editor. `NOTETIME` is equal to the amount of frames a note is on screen for before it can be hit. If you change this value, you might have to also edit `arrows_draw()` and `arrows_draw_downscroll()` so that the length of the note trails are in-line with the new speed. (CTRL+F `(_T.LEN*12)` and increase `12` if you've increased `NOTETIME`, or lower it if you've lowered `NOTETIME` until it looks just right)

**NOTE: If your chart has both characters singing at the same time**, you'll have to edit below line 98, `--center camera on duet`
Change the 544 in `_duetstart` to the beat your duet starts.
Change the 64 in `_duetlength` to the length of your duet in beats.
If you have multiple duets in your chart, you can duplicate lines 99-103 and repeat to make as many as you want.

# Modifying the Spritesheet
I won't go into too much detail here, as it's very messy, but characters are drawn in tab 5 of the code editor. Not all carts are the same, so the following information may be inaccurate if you aren't using `fnf-pico.p8` as a base.

`char_animate()` includes the x,y,width,height of the sprite on the spritesheet for each direction. With 0 being the left character, 1 being the right. And the directions being 0,1,2,3 - left,down,up,right.

`char_update()` includes the x,y,width,height of the sprites on the spritesheet for the two resting sprites for each character. With 0 being the left character, 1 being the right.

Girlfriends' are also stored in `char_update()` and `char_draw()` under the lines `--girlfriend`.

Any other sprite assets are stored under `game_draw()`, with the exception of the game's arrows being under `arrows_draw()` and `arrows_draw_downscroll()`'

If you wanna get funky and include sprites outside of your spritesheet, you're going to have to use `fnf-sprite-cruncher.p8` to convert your sprites to a string. I recommend using `fnf-xmas.p8` as a base and using `draw_sheet(index, x, y, background_colour)` to draw the sheet at `index` in array `sheets`.

# Useful Tools

There are all pico-8 carts that have been made to assist you in developing your mod!

**[`#PNP_CHARTER`](https://www.lexaloffle.com/bbs/?pid=95597#p)** - A charting tool that generates `map_add` functions for both my engine aswell as [jo560hs](https://www.lexaloffle.com/bbs/?uid=45958)'s engine.

**[`#IMPROVECHARTER`](https://www.lexaloffle.com/bbs/?pid=96077#p)** - A modification of [jo560hs](https://www.lexaloffle.com/bbs/?uid=45958)'s charter that adds some additional ui elements and adds support for [evman2k](https://www.lexaloffle.com/bbs/?uid=43807)'s engine aswell as "ugh" style notes for this engine.

**[`#PNP_COMPRESS`](https://www.lexaloffle.com/bbs/?pid=95794#p)** - A tool that compresses large beatmaps so they don't take up as many tokens, however this can increase the character count.

# Made something cool? Post it to the BBS!
If you've made a mod of Pico Night Punkin', post it!

Tweet us [@CarsonKompon](https://twitter.com/CarsonKompon) & [@blstrManx](https://twitter.com/blstrManx)

And post it to the BBS under the Pico Night Punkin' forum post: https://www.lexaloffle.com/bbs/?tid=42715
