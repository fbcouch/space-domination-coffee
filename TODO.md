SPACE DOMINATION (COFFEE)

v0.2:
- player profiles
    - stats (mission time, kills, deaths, shots fired, hit, accuracy, etc all for each mission and total)
- advanced mission dev: triggers
    - timer (win/lose/event on expire)
    - kill all, kill type, defend all, defend type
    - chat messages (on ...)
- abstract preloader so that a different type can be used in prod vs dev
    - image atlas
- rest api
    - missions --> the mission list
    - missions/:slug --> retrieve "slug" mission
    - pilots --> list all pilots
    - pilots/:id --> get info for pilot
- gamepad for mobile

v0.1:
+ basic controls
    + turn, accel, brake, fire
+ basic combat
    + fly around, shoot things
    + lasers fire from correct places, hit correctly
    + same for missiles
+ basic animations
    + engine glow
    + laser hit burst
    + ship explosions
+ scrolling background
    + less dense starfield than original
+ two missions
    + training mission : kill crates
    + training mission : kill drones
+ basic menus
    + TextButton
    + Mission Select
    + Pause
+ victory/loss conditions
    + simple: player does --> loss, all enemies dead --> win
+ basic ai
+ fix collision logic