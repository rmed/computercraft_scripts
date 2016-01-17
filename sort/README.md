# Sorter script

> Your own personal sorting turtle that ends up putting everything in the same
> chest!

Silly sorting that may be very bothersome to configure.

## How to use it

Build something like this:

```
+-------------------+
|C CC CC CC CC CC  C|
|C                 C|   |, -    = border
|                   |   +       = corner
|C                 C|   V       = turtle (and facing direction)
|C                 C|   CC      = chest (double)
|                   |   X       = elevator space (up/down a floor)
|C                 C|
|C                 C|
|           V     X |
| CC       CC  CC   |
+--------  ---------+ Floor 1 (base)
```

Edit the `catalog` file to your liking.

### General positions

General coordinates that you should edit:

- `FLOORS = {}`: array with the Y coordinate of each floor (feet height)
- `ELEVATOR = {x=0,z=0}`: X,Z coordinates of the space used for the *elevator*.
  This column should not have any block in each floor so that the turtle can go
  up/down
- `START = {x=0,y=0,z=0,f=1,dir=0}`: starting position for the turtle. You can
  get the coordinates using F3. Regarding direction:

```
North and south are Z
East and west are X

0 = south (+)
1 = west (-)
2 = north (-)
3 = east (+)
```

### Chests

The catalog uses *categories* based on mods (`mod_name:item_name`) and then
gets the chest defined for that category. Examples for base minecraft types are
included as example.

In the `chests` attribute, you define X,Z,floor coordinates for each type. In
the `items` attribute you may define 1-1 relation between items and types. In
the `patterns` attribute you may define regular expressions for general cases.

There must be a `MISC` chest where unknown items will end up.

## Go sort!

The turtle follows this procedure:

- Get items from main chest (just drop everything there!)
- Get position of chest for item in corresponding slot
- Go to the chest
- Drop stuff
    - If the chest is full, you can put one above
    - If the chest above is full... bad luck
- Repeat until the main chest is empty

Of course, this takes into account the floor of the chest.

## About the fuel

Every time the turtle is about to move, it will check the fuel level and ask
for more fuel if needed. **The fuel should be placed in slot 16**, which is
reserved for that case explicitly. If no fuel is found, it will stay put until
it can consume something from said slot.

**Recommendation:** start the program with enough fuel in slot 16.
