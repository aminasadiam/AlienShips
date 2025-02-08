const std = @import("std");
const rl = @import("raylib");
const main = @import("../main.zig");

pub const Health = struct {
    x: f32,
    y: f32,
    speed: f32,
    active: bool,
    delay: i32,
};

pub fn draw(g: *main.Game) void {
    // draw healing potion from the top of the screen
    if (!g.health.active) {
        g.health.x = g.random.random().float(f32) * 800; // Assuming the screen width is 800
        g.health.y = 0;
        g.health.speed = 3;
        g.health.delay = 500;
        g.health.active = true;
    }

    if (g.health.active) {
        rl.drawCircle(@intFromFloat(g.health.x), @intFromFloat(g.health.y - 10), 10, rl.Color.green);
    }
}

pub fn update(g: *main.Game) void {
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
