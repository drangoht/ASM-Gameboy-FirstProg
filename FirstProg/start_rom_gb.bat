wla-gb -o main.o main.s
wlalink -r -S link.txt game.gb
bgb64.exe game.gb