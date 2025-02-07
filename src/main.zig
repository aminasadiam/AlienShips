const std = @import("std");
const rl = @import("raylib");
const player = @import("entities/player.zig");
const bullet = @import("entities/bullet.zig");

const Game = struct {
    player: player.Player,
    bullets: [100]bullet.Bullet,
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
        // null is used to initialize the array with empty bullets
        .bullets = std.mem.zeroes([100]bullet.Bullet),
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

    // Draw bullets
    for (g.bullets) |b| {
        if (b.speed > 0) {
            rl.drawCircle(@intFromFloat(b.x), @intFromFloat(b.y), 5, rl.Color.yellow);
        }
    }
}

fn update(g: *Game) void {
    // Move player
    if (rl.isKeyDown(rl.KeyboardKey.d) and g.player.x < 785) {
        g.player.x += 5;
    }
    if (rl.isKeyDown(rl.KeyboardKey.a) and g.player.x > 0) {
        g.player.x -= 5;
    }
    if (rl.isKeyDown(rl.KeyboardKey.w) and g.player.y > 0) {
        g.player.y -= 5;
    }
    if (rl.isKeyDown(rl.KeyboardKey.s) and g.player.y < 570) {
        g.player.y += 5;
    }

    // Rotate player with mouse
    g.player.mouseX = @floatFromInt(rl.getMouseX());
    g.player.mouseY = @floatFromInt(rl.getMouseY());

    // Shoot bullet
    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        for (&g.bullets) |*b| {
            if (b.speed == 0) {
                b.x = g.player.x;
                b.y = g.player.y;
                b.angle = calculateRotationAngle(g);
                b.speed = 10;
                break;
            }
        }
    }

    for (&g.bullets) |*b| {
        if (b.speed > 0) {
            b.x += b.speed * std.math.cos(b.angle * (std.math.pi / 180.0));
            b.y += b.speed * std.math.sin(b.angle * (std.math.pi / 180.0));
        }

        if (b.x < 0 or b.x > 800 or b.y < 0 or b.y > 600) {
            b.speed = 0;
        }
    }
}

fn calculateRotationAngle(g: *Game) f32 {
    const dx = g.player.mouseX - g.player.x;
    const dy = g.player.mouseY - g.player.y;
    return std.math.atan2(dy, dx) * (180.0 / std.math.pi);
}
