# Valley of Shaders
Small project to learn shaders and optimalization in Godot Engine

## Goals

- terrain shader optimalization
- [done] terrain shader coloring (without textures)
- units movement optimalization (using heightmap)
- camera movement
  - desined for gamepad
  - left stick oves
  - right stick camera rotation 
- selecting/giving orders to units
- easy changing levels (terrains)

## Game ideas to test
- height define unit speed
- units when in battle calculates height difference
  - bonus for unit that is heiger
  - penality for unis at mountain level
- mountans gets more noise contrast
- water gives damage
- units movement
  - selects target angle (random or closest taret)
  - if target is at water skip move (and shorten ai timer for next turn)
  - move, mark dirty
  - master tower checks dirty flag and adjust y position (from heightmap)
- master tower
  - units spawn from it
  - timer tick
    - lock heightmap 
    - loop thru slave units
    - adjust y pos
    - unlock
- own units
  - player have 4 teams
  - each button sets target for team
  - team healt == unit count
    - 8 at start
- battle
  - teams roll dices
  - each unit == one dice
  - each odd result = +1 damage
  - overall count on dices if better than enemy = +1 damage
  - min 0 damage; max 9
  - final damage is divided by 5, rounded up
  - units are removed


