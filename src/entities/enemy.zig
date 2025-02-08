const std = @import("std");
const rl = @import("raylib");
const main = @import("../main.zig");

pub const Enemy = struct {
    x: f32,
    y: f32,
    speed: f32,
    active: bool,
    shootDelay: i32,
    spawnDelay: i32,
    respawnDelay: i32,
};

pub fn draw(g: *main.Game) void {
    // Draw enemies
    for (g.enemies) |e| {
        if (e.active) {
            rl.drawCircle(@intFromFloat(e.x), @intFromFloat(e.y), 20, rl.Color.red);
        }
    }
}

pub fn update(g: *main.Game) void {
    // Move enemies and make them shoot bullets
    for (&g.enemies) |*e| {
        if (e.respawnDelay > 0) {
            e.respawnDelay -= 1;
        } else if (e.spawnDelay > 0) {
            e.spawnDelay -= 1;
        } else if (!e.active) {
            e.active = true;
            e.x = g.random.random().float(f32) * 800;
            e.y = g.random.random().float(f32) * 600;
        }

        if (e.active) {
            const dx = g.player.x - e.x;
            const dy = g.player.y - e.y;
            const angle = std.math.atan2(dy, dx);
            e.x += e.speed * std.math.cos(angle);
            e.y += e.speed * std.math.sin(angle);

            if (e.shootDelay > 0) {
                e.shootDelay -= 1;
            } else {
                for (&g.enemyBullets) |*b| {
                    if (b.speed == 0) {
                        b.x = e.x;
                        b.y = e.y;
                        b.angle = angle * (180.0 / std.math.pi);
                        b.speed = 5;
                        e.shootDelay = @rem(g.random.random().int(i32), 120); // Reset shoot delay
                        break;
                    }
                }
            }
        }
    }
}
