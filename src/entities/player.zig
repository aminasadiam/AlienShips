const std = @import("std");
const rl = @import("raylib");
const main = @import("../main.zig");
const men = @import("../menu.zig");

pub const Player = struct {
    x: f32,
    y: f32,
    mouseX: f32,
    mouseY: f32,
    health: i32,
    shield: bool,
    shieldTimer: u32,
};

pub fn draw(g: *main.Game) void {
    // Player Health
    rl.drawRectangle(10, 10, 200, 20, rl.Color.gray);
    rl.drawRectangle(10, 10, g.player.health * 2, 20, rl.Color.red);

    // player health text on rectangle
    rl.drawText("Health", 10, 10, 20, rl.Color.white);

    const angle = main.calculateRotationAngle(g);
    rl.drawRectanglePro(rl.Rectangle{ .x = g.player.x, .y = g.player.y, .width = 30, .height = 15 }, rl.Vector2{ .x = 15, .y = 7.5 }, angle, rl.Color.red);
}

pub fn update(g: *main.Game, menu: *men.Menu) void {
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

    // Check for collision between player and health
    if (g.health.active) {
        if (g.player.x < g.health.x + 10 and g.player.x + 30 > g.health.x and g.player.y < g.health.y + 10 and g.player.y + 15 > g.health.y) {
            if (g.player.health < 100) {
                g.player.health += 30;
                g.health.active = false;
                rl.playSound(g.sound.healing);
            }
        }
    }

    // Check for collision between player and shield
    if (g.shield.active) {
        if (g.player.x < g.shield.x + 10 and g.player.x + 30 > g.shield.x and g.player.y < g.shield.y + 10 and g.player.y + 15 > g.shield.y) {
            g.shield.active = false;
            g.player.shield = true;
            rl.playSound(g.sound.shield_fill);
        }
    }

    if (g.player.shield) {
        g.player.shieldTimer -= 1;
        if (g.player.shieldTimer == 0) {
            g.player.shield = false;
            g.player.shieldTimer = 10;
            rl.playSound(g.sound.shield_empty);
        }
    }

    // Check for collision between player and enemy
    for (&g.enemies) |*e| {
        if (e.active) {
            if (g.player.x < e.x + 20 and g.player.x + 30 > e.x and g.player.y < e.y + 20 and g.player.y + 15 > e.y) {
                if (!g.player.shield) {
                    g.player.health -= 10;
                    rl.playSound(g.sound.damage);
                }
                e.active = false;
                e.respawnDelay = 300; // Set respawn delay after enemy dies
            }
        }
    }

    // Check for collision between player bullets and enemies
    for (&g.bullets) |*b| {
        if (b.speed > 0) {
            for (&g.enemies) |*e| {
                if (e.active) {
                    if (b.x < e.x + 20 and b.x > e.x and b.y < e.y + 20 and b.y > e.y) {
                        e.active = false;
                        rl.playSound(g.sound.explosion);
                        b.speed = 0;
                        e.respawnDelay = 300; // Set respawn delay after enemy dies
                    }
                }
            }
        }
    }

    // Check for collision between enemy bullets and player
    for (&g.enemyBullets) |*b| {
        if (b.speed > 0) {
            if (g.player.x < b.x + 5 and g.player.x + 30 > b.x and g.player.y < b.y + 5 and g.player.y + 15 > b.y) {
                if (!g.player.shield) {
                    g.player.health -= 10;
                    rl.playSound(g.sound.damage);
                }
                b.speed = 0;
            }
        }
    }

    // Game Over
    if (g.player.health <= 0) {
        menu.state = men.Menu.State.GameOver;
        rl.playSound(g.sound.gameover);
    }
}
