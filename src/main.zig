const std = @import("std");
const rl = @import("raylib");

const player = @import("entities/player.zig");
const bullet = @import("entities/bullet.zig");
const health = @import("entities/health.zig");
const enemy = @import("entities/enemy.zig");
const shield = @import("entities/shield.zig");
const sound = @import("sound.zig");

const menu = @import("menu.zig");

pub const Game = struct {
    player: player.Player,
    bullets: [100]bullet.Bullet,
    health: health.Health,
    enemies: [4]enemy.Enemy,
    enemyBullets: [100]bullet.Bullet,
    shield: shield.Shield,
    sound: sound.Sound,

    random: std.rand.DefaultPrng,
};

pub fn init(random: std.rand.DefaultPrng) !Game {
    return Game{
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
        .sound = try sound.init(),

        .random = random,
    };
}

pub fn main() !void {
    rl.initWindow(800, 600, "Alien Ships");
    rl.initAudioDevice();
    rl.setTargetFPS(60);
    defer rl.closeAudioDevice();
    defer rl.closeWindow();

    const random = std.rand.DefaultPrng.init(42);

    var game = try init(random);

    var men = menu.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        if (men.state == menu.Menu.State.Main) {
            menu.draw(&men);
            try menu.update(&men, &game, random);
        } else if (men.state == menu.Menu.State.InGame) {
            start_game(&game, &men);
        } else if (men.state == menu.Menu.State.Exit) {
            break;
        } else {
            menu.draw(&men);
            try menu.update(&men, &game, random);
        }

        rl.endDrawing();
    }
}

pub fn start_game(game: *Game, men: *menu.Menu) void {
    rl.clearBackground(rl.Color.sky_blue);

    player.draw(game);
    bullet.draw(game);
    enemy.draw(game);
    health.draw(game);
    shield.draw(game);

    player.update(game, men);
    bullet.update(game);
    health.update(game);
    shield.update(game);
    enemy.update(game);
}

pub fn calculateRotationAngle(g: *Game) f32 {
    const dx = g.player.mouseX - g.player.x;
    const dy = g.player.mouseY - g.player.y;
    return std.math.atan2(dy, dx) * (180.0 / std.math.pi);
}
