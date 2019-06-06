# Glimpse

## Implemented

- Click and hover home button to wake screen
    + unhover to sleep screen
    + shake device while hovering to keep screen awake after releasing finger
- Click and release home button as normal for normal wake UX
    + While screen is awake, hover/unhover sensor to sleep screen
    + While screen is awake, click home button (single or double) to unlock
- While screen is sleeping, double click home button to quickly unlock
- I think that's it.

## Things We Can Tune

- **GLIMPSE_UNHOVER_DELAY**: Delay for activator event; minimum ~350ms because that's how long the double click delay is.
- **GLIMPSE_UNHOVER_LISTENER_DELAY**: Delay for when to engage unhover listener. Shorter will let you purposely hover-unhover quickly but too low will result in lots of glitchy false positives. I personally like ~100ms.

## Idea

- touching down on the home button makes the screen wake up
- lifting your finger back up makes it go back to sleep
- clicking initiates the unlock
- if you click as soon as you touch down, it'll unlock immediately, so no time lost
- the sensor can read the fingerprint as soon as you touch down, but not actually unlock until you click so it'll be instant when you do click

## @TODO(Shrugs)

- implement method for unlocking device (without a passcode, with a passcode, with TouchID)
- ignore unhover listener when siri open
    -  reenable when Siri closes
- Ignore double tap timer if screen is on
    + May not be possible due to delayed single home click event
    + can't have it both ways, essentially.
- also cancel the dim method if the user touches the screen before it's executed?
- unload unhover event if touchID is doing its thing
