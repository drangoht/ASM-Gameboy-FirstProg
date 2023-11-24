wla-gb -o bpong.o bpong.s
wlalink -r -S link-pong.txt bpong.rom
bgb64.exe bpong.rom