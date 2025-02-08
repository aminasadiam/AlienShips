const std = @import("std");
const rl = @import("raylib");
const player = @import("entities/player.zig");
const bullet = @import("entities/bullet.zig");
const health = @import("entities/health.zig");

const Game = struct {
    player: player.Player,
    bullets: [100]bullet.Bullet,
    health: health.Health,

    random: std.rand.DefaultPrng,
};

pub fn main() !void {
    rl.initWindow(800, 600, "Alien Ships");
    rl.setTargetFPS(60);
    defer rl.closeWindow();

    const random = std.rand.DefaultPrng.init(42);

    var game = Game{
        .player = player.Player{
            .x = 400,
            .y = 300,
            .mouseX = 0,
            .mouseY = 0,
            .health = 100,
        },
        // null is used to initialize the array with empty bullets
        .bullets = std.mem.zeroes([100]bullet.Bullet),
        .health = health.Health{
            .x = 0,
            .y = 0,
            .speed = 0,
            .active = false,
            .delay = 0,
        },
        .random = random,
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

    // Player Health
    rl.drawRectangle(10, 10, 200, 20, rl.Color.gray);
    rl.drawRectangle(10, 10, g.player.health * 2, 20, rl.Color.red);

    const angle = calculateRotationAngle(g);
    rl.drawRectanglePro(rl.Rectangle{ .x = g.player.x, .y = g.player.y, .width = 30, .height = 15 }, rl.Vector2{ .x = 15, .y = 7.5 }, angle, rl.Color.red);

    // Draw bullets
    for (g.bullets) |b| {
        if (b.speed > 0) {
            rl.drawCircle(@intFromFloat(b.x), @intFromFloat(b.y), 5, rl.Color.yellow);
        }
    }

    // draw healing potion from the top of the screen
    if (!g.health.active) {
        g.health.x = g.random.random().float(f32) * 800; // Assuming the screen width is 800
        g.health.y = 0;
        g.health.speed = 5;
        g.health.delay = 500;
        g.health.active = true;
    }

    if (g.health.active) {
        rl.drawCircle(@intFromFloat(g.health.x), @intFromFloat(g.health.y - 10), 10, rl.Color.green);
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

    // Move health
    if (g.player.health < 100) {
        if (g.health.active) {
            if (g.health.delay > 0) {
                g.health.delay -= 1;
            } else {
                g.health.y += g.health.speed;
                if (g.health.y > 600) {
                    g.health.active = false;
                }
            }
        }
    }

    // Check for collision between player and health
    if (g.health.active) {
        if (g.player.x < g.health.x + 10 and g.player.x + 30 > g.health.x and g.player.y < g.health.y + 10 and g.player.y + 15 > g.health.y) {
            if (g.player.health < 100) {
                g.player.health += 10;
                g.health.active = false;
            }
        }
    }
}

fn calculateRotationAngle(g: *Game) f32 {
    const dx = g.player.mouseX - g.player.x;
    const dy = g.player.mouseY - g.player.y;
    return std.math.atan2(dy, dx) * (180.0 / std.math.pi);
}
