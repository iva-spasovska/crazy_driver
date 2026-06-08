# Crazy Driver

Crazy Driver is a 3D endless-runner driving game built in Godot 4. The player
drives a taxi through an endless city road, switches between three lanes, jumps
over traffic, collects coins, and uses those coins to unlock new car colors.

The project was created as a small arcade game focused on lane-based movement,
obstacle avoidance, procedural world generation, and a simple in-game shop.

## Demo

- Video demonstration: [Google Drive folder](https://drive.google.com/drive/folders/1DMdHS3HQQ7oF-IafIvI0HHSdzpc0jDou?usp=sharing)

## Gameplay

The goal is to survive for as long as possible while the road moves faster over
time. Traffic cars spawn in the lanes ahead of the player, so the player must
react by changing lanes or jumping at the right moment. Coins appear in short
lines and can be collected during the run. The collected coins can then be used
in the car shop to buy and select different car colors.

## Controls

| Key | Action |
| --- | --- |
| Left Arrow | Move one lane left |
| Right Arrow | Move one lane right |
| Space | Jump |
| Enter | Start or restart the game |
| P | Open the car shop |
| Esc | End the current run |

The shop can also be opened with the button in the top-right corner of the game
screen. When the shop is open during a run, the game is paused automatically and
continues after the shop is closed.

## Features

- Three-lane driving system with smooth lane switching.
- Jump mechanic for avoiding traffic cars.
- Collision detection between the player car and traffic cars.
- Coin collection system.
- In-game shop with 8 car colors:
  - Yellow Cab
  - Hot Red
  - Snow White
  - Ocean Blue
  - Lime Green
  - Purple
  - Midnight
  - Orange Blaze
- Score system that increases while the player survives.
- Game speed increases over time, making the run more difficult.
- Random traffic spawning with increasingly shorter spawn intervals.
- Random coin rows spawned across the lanes.
- Procedural road chunks, lane markings, sidewalks, curbs, traffic cars,
  coins, and buildings.
- No imported 3D models are required; the scene is built with Godot primitives
  and GDScript.
- Camera follow system that tracks the player car.
- Start screen, game-over screen, score display, coin display, and shop UI.

## Technical Overview

The project uses one main scene and several focused GDScript files. The game is
structured around a global `GameManager` autoload that stores the run state,
score, coins, speed, and selected car color.

| File | Responsibility |
| --- | --- |
| `scenes/main.tscn` | Main game scene containing the player, camera, UI, and spawners |
| `scripts/Main.gd` | Starts and restarts runs, updates UI, opens and closes the shop |
| `scripts/GameManager.gd` | Global game state, score, coins, speed, color ownership |
| `scripts/PlayerCar.gd` | Lane movement, jumping, collision checks, coin collection, car color |
| `scripts/TrafficSpawner.gd` | Generates traffic cars in random lanes |
| `scripts/TrafficCar.gd` | Moves traffic cars and removes them after they pass the player |
| `scripts/CoinSpawner.gd` | Spawns rows of collectible coins |
| `scripts/Coin.gd` | Moves and rotates coins |
| `scripts/RoadManager.gd` | Generates and recycles road chunks |
| `scripts/BuildingSpawner.gd` | Generates procedural buildings on both sides of the road |
| `scripts/CameraFollow.gd` | Smoothly follows the player car |
| `scripts/ShopMenu.gd` | Builds the car color shop UI and handles purchases |

## Procedural Generation

Most visual elements are created directly through code:

- The road is split into reusable chunks that move toward the player and respawn
  ahead to create an endless-road effect.
- Buildings are generated with random sizes, colors, window layouts, and rooftop
  details.
- Traffic cars are built from simple mesh primitives and spawned in random lanes.
- Coins are generated as spinning cylinder meshes and arranged in short rows.

This keeps the project lightweight and makes the endless-runner environment feel
dynamic without relying on external 3D assets.

## Difficulty Progression

At the start of each run, the game begins at a lower speed. While the player is
alive, `GameManager` gradually increases `current_speed` up to a maximum value.
This affects the movement of the road, traffic, coins, and buildings. Traffic
also spawns more frequently as the speed increases, so the player has less time
to react.

The jump duration is adjusted based on the current speed, which makes timing
more important later in the run.

## Car Shop

The car shop allows the player to buy and switch between different car colors.
The first color, Yellow Cab, is available by default. Locked colors have coin
prices, and owned colors can be selected again without buying them twice.

When the player selects a color, the material on the car body and roof is
updated immediately.

## How to Run

1. Install Godot 4.
2. Clone this repository:

```bash
git clone https://github.com/iva-spasovska/crazy_driver.git
```

3. Open Godot.
4. Click **Import** and select the `project.godot` file.
5. Open the project and press **Run**.

## Project Requirements Covered

- Lane-based player movement.
- Jumping over other cars.
- Obstacle avoidance with game-over behavior.
- Coin collection as an additional gameplay system.
- Car color shop as an additional feature.
- Procedural generation of the road, buildings, traffic, and coins.

