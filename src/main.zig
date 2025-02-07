const std = @import("std");
const rl = @import("raylib");
const player = @import("entities/player.zig");
const bullet = @import("entities/bullet.zig");

const Game = struct {
    player: player.Player,
};

pub fn main() !void {
    rl.initWindow(800, 600, "Alien Ships");
    rl.setTargetFPS(60);
    defer rl.closeWindow();

    var game = Game{
        .player = player.Player{
            .x = 400,
            .y = 300,
            .mouseX = 0,
            .mouseY = 0,
        },
    };

    while (!rl.windowShouldClose()) {
        update(&game);

        rl.beginDrawing();
        draw(&game);
        rl.endDrawing();
    }
}

fn draw(g: *Game) void {
    rl.clearBackground(rl.Color.sky_blue);

    const angle = calculateRotationAngle(g);
    rl.drawRectanglePro(rl.Rectangle{ .x = g.player.x, .y = g.player.y, .width = 30, .height = 15 }, rl.Vector2{ .x = 15, .y = 7.5 }, angle, rl.Color.red);
}

fn update(g: *Game) void {
    // Move player
    if (rl.isKeyDown(rl.KeyboardKey.d)) {
        if (g.player.x < 785) {
            g.player.x += 5;
        }
    }
    if (rl.isKeyDown(rl.KeyboardKey.a)) {
        if (g.player.x > 0) {
            g.player.x -= 5;
        }
    }
    if (rl.isKeyDown(rl.KeyboardKey.w)) {
        if (g.player.y > 0) {
            g.player.y -= 5;
        }
    }
    if (rl.isKeyDown(rl.KeyboardKey.s)) {
        if (g.player.y < 570) {
            g.player.y += 5;
        }
    }

    // Rotate player with mouse
    g.player.mouseX = @floatFromInt(rl.getMouseX());
    g.player.mouseY = @floatFromInt(rl.getMouseY());
}

fn calculateRotationAngle(g: *Game) f32 {
    const dx = g.player.mouseX - g.player.x;
    const dy = g.player.mouseY - g.player.y;
    return std.math.atan2(dy, dx) * (180.0 / std.math.pi);
}
