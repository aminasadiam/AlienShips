const std = @import("std");
const rl = @import("raylib");
const main = @import("main.zig");

pub const Menu = struct {
    pub const State = enum {
        Main,
        InGame,
        GameOver,
        Instructions,
        Exit,
    };

    state: State,
};

pub fn init() Menu {
    return Menu{
        .state = Menu.State.Main,
    };
}

pub fn update(menu: *Menu, game: *main.Game, rand: std.rand.DefaultPrng) void {
    if (menu.state == Menu.State.Main) {
        if (rl.isKeyPressed(rl.KeyboardKey.one)) {
            menu.state = Menu.State.InGame;
            var new_game = main.init(rand);
            // Initialize enemies with random spawn delays
            for (&new_game.enemies) |*e| {
                e.x = new_game.random.random().float(f32) * 800;
                e.y = new_game.random.random().float(f32) * 600;
                e.speed = 1;
                e.active = false;
                e.shootDelay = @rem(new_game.random.random().int(i32), 300); // Random shoot delay
                e.spawnDelay = @rem(new_game.random.random().int(i32), 600); // Random spawn delay
                e.respawnDelay = 0; // Initialize respawn delay to zero
            }
            game.* = new_game;
        } else if (rl.isKeyPressed(rl.KeyboardKey.two)) {
            menu.state = Menu.State.Instructions;
        } else if (rl.isKeyPressed(rl.KeyboardKey.three)) {
            menu.state = Menu.State.Exit;
        }
    } else if (menu.state == Menu.State.GameOver) {
        if (rl.isKeyPressed(rl.KeyboardKey.one)) {
            menu.state = Menu.State.Main;
        }
    } else if (menu.state == Menu.State.Instructions) {
        if (rl.isKeyPressed(rl.KeyboardKey.one)) {
            menu.state = Menu.State.Main;
        }
    } else if (menu.state == Menu.State.Exit) {
        if (rl.isKeyPressed(rl.KeyboardKey.one)) {
            rl.closeWindow();
        }
    }
}

pub fn draw(menu: *Menu) void {
    rl.clearBackground(rl.Color.black);

    switch (menu.state) {
        Menu.State.Main => {
            rl.drawText("1. Start Game", 350, 200, 20, rl.Color.white);
            rl.drawText("2. Instructions", 350, 250, 20, rl.Color.white);
            rl.drawText("3. Exit", 350, 300, 20, rl.Color.white);
        },
        Menu.State.InGame => {
            rl.drawText("Starting...", 350, 250, 20, rl.Color.white);
        },
        Menu.State.GameOver => {
            rl.drawText("Game Over", 350, 250, 20, rl.Color.white);
            rl.drawText("1. Main Menu", 350, 300, 20, rl.Color.white);
        },
        Menu.State.Instructions => {
            rl.drawText("Instructions:", 350, 200, 20, rl.Color.white);
            rl.drawText("Use WASD to move", 350, 250, 20, rl.Color.white);
            rl.drawText("Use mouse to aim and shoot", 350, 300, 20, rl.Color.white);
            rl.drawText("Press 1 to go back", 350, 350, 20, rl.Color.white);
        },
        Menu.State.Exit => {
            rl.drawText("Exiting...", 350, 250, 20, rl.Color.white);
        },
    }
}
