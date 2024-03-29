# Grim Focus Counter

Track stacks of Grim Focus and its morphs and displays
them in a visual and obvious way.

<p align="center">
    <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/GrimFocusCounter.gif?raw=true"><br>
</p>

## Installation
### From a Release
After downloading a zip from the [releases page](https://github.com/inimicus/GrimFocusCounter/releases),
unzip and move the `GrimFocusCounter` folder into your addons folder. Done, EZPZ.

### From Code/Source
Download a zip or clone this repository to obtain the source. Copy the
`GrimFocusCounter` folder within the code (the one that has `GrimFocusCounter.txt`
in it) into your AddOns folder. Do not copy the top level `GrimFocusCounter` (or
`GrimFocusCounter-branchname` if you downloaded a zip) into your AddOns folder,
it will not work.

To illustrate:
```
GrimFocusCounter/       <-- Do not copy this folder
├── art/
├── GrimFocusCounter/   <-- Copy this folder
│   ├── art/
│   ├── src/
│   └── GrimFocusCounter.txt
├── README-esoui.txt
└── README.md
```

## Purpose

_But there are already buff trackers that display how many
stacks there are. Why do I need this?_

That's true. Several existing buff trackers already provide
this capability, but how they display this information is less
than ideal. Having a large stack display is more useful and
obvious than a small text counter that can become lost among
other information or is difficult to see, especially if you're
visually impaired.

As one of the nightblade's key class abilities,
successful and timely procs of the spectral bow is crucial
to effective PvE DPS and lining up devastating burst in PvP.

This add-on aims to provide a lightweight and useful option
for those who need a more obvious cue, don't run other buff
trackers, or enjoy filling their screen with flair.

## Functionality

The stack display can be configured to not appear until the first
stack occurs or upon activation of the skill. Each stack will update
the display as they happen and returns to a zero state or disappears
when the buff expires or the proc is used -- depending on selected options.

This add-on is _not_ intended to be a tracker for uptime on
Grim Focus (or its morphs), just for the unique stacking mechanic.

## Implemented Features

- Tracks Grim Focus, Merciless Resolve, Relentless Focus stacks
- Select from different display styles
- Customizable size
- Configurable color overlay for display styles for added customization
- Lock to reticle for styles designed to decorate the crosshairs
- Movable to any place on the screen (and lockable once it's in position)
- Setting to show zero stacks (with supported display styles)
- Option to fade (transparency) of the stack display when the skill needs to be refreshed and still has stacks

## Planned Features

- Additional style variations
- Better colorization options

## Display Styles

<table border="0" cellmargin="2">
    <tr>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/Compass.gif?raw=true" width="150" height="150"><br>
            Compass (by Porkjet)
        </td>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/Dice.gif?raw=true" width="150" height="150"><br>
            Dice
        </td>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/DOOM.gif?raw=true" width="150" height="150"><br>
            DOOM
        </td>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/HorizontalDots.gif?raw=true" width="150" height="150"><br>
            Horizontal Dots
        <td>
    </tr>
    <tr>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/Numbers.gif?raw=true" width="150" height="150"><br>
            Numbers
        </td>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/NumberSquares.gif?raw=true" width="150" height="150"><br>
            Number Squares
        </td>
        <td align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/PlayMagsorc.gif?raw=true" width="150" height="150"><br>
            Play MagSorc
        </td>
        <td>&nbsp;</td>
    </tr>
        <td colspan="4" align="center">
            <img src="https://github.com/inimicus/GrimFocusCounter/blob/main/art/gifs/options/Options.gif?raw=true" width="150" height="150"><br>
            Color Overlay with option to fade display when skill expires
        </td>
    </tr>
</table>

## Bugs & Enhancements

If you find a bug or would like to request a new feature, please [open an issue on GitHub](http://github.com/inimicus/GrimFocusCounter/issues/new/choose).

# Enjoy!
