# Digger script

> Your own personal digging turtle that doesn't know what a square area is!

This script aims to *automate* digging of a certain area.

## How to use it

Suppose you have the following area:

```
height
+-------------------+
|                   |
|                   |   |, -    = border
|                   |   +       = corner
|                   |   V       = turtle (and facing direction)
|                   |   CC      = chest (double)
|                   |
V-------------------+ width
CC
```

The turtle will dig the whole level column by column, then it will return to
its starting position, drop items in the chest and dig the next level until it
reaches the height specified on startup.

Every time a level is digged, it will go up, drop items in the chest, and
return to the next level (which is highly inefficient fuel-wise, I know). This
might prevent its inventory from becoming full in general cases.

## About the fuel

Every time the turtle is about to move, it will check the fuel level and ask
for more fuel if needed. **The fuel should be placed in slot 16**, which is
reserved for that case explicitly. If no fuel is found, it will stay put until
it can consume something from said slot.

**Recommendation:** start the program with enough fuel in slot 16.
