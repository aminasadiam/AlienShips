const std = @import("std");
const rl = @import("raylib");
const main = @import("../main.zig");

pub const Bullet = struct {
    x: f32,
    y: f32,
    angle: f32,
    speed: f32,
};

pub fn draw(g: *main.Game) void {
    // Draw Player bullets
    for (g.bullets) |b| {
        if (b.speed > 0) {
            rl.drawCircle(@intFromFloat(b.x), @intFromFloat(b.y), 5, rl.Color.yellow);
        }
    }

    // Draw enemy bullets
    for (g.enemyBullets) |b| {
        if (b.speed > 0) {
            rl.drawCircle(@intFromFloat(b.x), @intFromFloat(b.y), 5, rl.Color.orange);
        }
    }
}

pub fn update(g: *main.Game) void {
    // Shoot bullet
    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        for (&g.bullets) |*b| {
            if (b.speed == 0) {
                b.x = g.player.x;
                b.y = g.player.y;
                b.angle = main.calculateRotationAngle(g);
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

    // Move enemy bullets
    for (&g.enemyBullets) |*b| {
        if (b.speed > 0) {
            b.x += b.speed * std.math.cos(b.angle * (std.math.pi / 180.0));
            b.y += b.speed * std.math.sin(b.angle * (std.math.pi / 180.0));
        }

        if (b.x < 0 or b.x > 800 or b.y < 0 or b.y > 600) {
            b.speed = 0;
        }
    }
}
