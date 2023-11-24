wla-gb -o main.o main.s
wlalink -r -S link.txt game.rom
bgb64.exe game.rom