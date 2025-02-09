const rl = @import("raylib");
const std = @import("std");

pub const Sound = struct {
    shooting: rl.Sound,
    damage: rl.Sound,
    explosion: rl.Sound,
    gameover: rl.Sound,
    healing: rl.Sound,
    clicked: rl.Sound,
    shield_fill: rl.Sound,
    shield_empty: rl.Sound,
};

pub fn init() !Sound {
    const sound = Sound{
        .shooting = try rl.loadSound("assets/sounds/fire.ogg"),
        .damage = try rl.loadSound("assets/sounds/damage.wav"),
        .explosion = try rl.loadSound("assets/sounds/explosion.ogg"),
        .gameover = try rl.loadSound("assets/sounds/gameover.mp3"),
        .healing = try rl.loadSound("assets/sounds/health-pickup-6860.mp3"),
        .clicked = try rl.loadSound("assets/sounds/select-sound-121244.mp3"),
        .shield_fill = try rl.loadSound("assets/sounds/shield_fill.wav"),
        .shield_empty = try rl.loadSound("assets/sounds/shield_empty.wav"),
    };
    return sound;
}
