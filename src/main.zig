const std = @import("std");
const rl = @import("raylib");
const player = @import("entities/player.zig");
const bullet = @import("entities/bullet.zig");
const health = @import("entities/health.zig");
const enemy = @import("entities/enemy.zig");
const shield = @import("entities/shield.zig");

pub const Game = struct {
    player: player.Player,
    bullets: [100]bullet.Bullet,
    health: health.Health,
    enemies: [6]enemy.Enemy,
    enemyBullets: [100]bullet.Bullet,
    shield: shield.Shield,

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
            .shield = false,
            .shieldTimer = 500,
        },
        .bullets = std.mem.zeroes([100]bullet.Bullet),
        .health = health.Health{
            .x = 0,
            .y = 0,
            .speed = 0,
            .active = false,
            .delay = 0,
        },
        .shield = shield.Shield{
            .x = 0,
            .y = 0,
            .speed = 0,
            .active = false,
            .delay = 0,
        },
        .enemies = undefined,
        .enemyBullets = std.mem.zeroes([100]bullet.Bullet),

        .random = random,
    };

    // Initialize enemies with random spawn delays
    for (&game.enemies) |*e| {
        e.x = game.random.random().float(f32) * 800;
        e.y = game.random.random().float(f32) * 600;
        e.speed = 1;
        e.active = false;
        e.shootDelay = @rem(game.random.random().int(i32), 300); // Random shoot delay
        e.spawnDelay = @rem(game.random.random().int(i32), 600); // Random spawn delay
        e.respawnDelay = 0; // Initialize respawn delay to zero
    }

    while (!rl.windowShouldClose()) {
        rl.clearBackground(rl.Color.sky_blue);

        player.draw(&game);
        bullet.draw(&game);
        enemy.draw(&game);
        health.draw(&game);
        shield.draw(&game);

        rl.beginDrawing();

        player.update(&game);
        bullet.update(&game);

        health.update(&game);
        shield.update(&game);

        enemy.update(&game);

        rl.endDrawing();
    }
}

pub fn calculateRotationAngle(g: *Game) f32 {
    const dx = g.player.mouseX - g.player.x;
    const dy = g.player.mouseY - g.player.y;
    return std.math.atan2(dy, dx) * (180.0 / std.math.pi);
}
