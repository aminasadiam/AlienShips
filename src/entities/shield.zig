const std = @import("std");
const rl = @import("raylib");
const main = @import("../main.zig");

pub const Shield = struct {
    x: f32,
    y: f32,
    speed: f32,
    active: bool,
    delay: u32,
};

pub fn draw(g: *main.Game) void {
    // Draw shield from the top of the screen
    if (!g.shield.active) {
        g.shield.x = g.random.random().float(f32) * 800; // Assuming the screen width is 800
        g.shield.y = 0;
        g.shield.speed = 3;
        g.shield.delay = 600;
        g.shield.active = true;
    }

    if (g.shield.active) {
        rl.drawCircle(@intFromFloat(g.shield.x), @intFromFloat(g.shield.y - 10), 10, rl.Color.blue);
    }
}

pub fn update(g: *main.Game) void {
    if (g.shield.active) {
        if (g.shield.delay > 0) {
            g.shield.delay -= 1;
        } else {
            g.shield.y += g.shield.speed;
            if (g.shield.y > 600) {
                g.shield.active = false;
            }
        }
    }
}
