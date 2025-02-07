all: build run

build:
	@zig build

run: build
	@./zig-out/AlienShips.exe

clean:
	rm -f $(APP_NAME)
	rm -rf zig-cache
