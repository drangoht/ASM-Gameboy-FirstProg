; Header pour Gameboy

.ROMDMG                         ;Pas de features CGB
.NAME "MONJEU"                ;Nom du ROM inscrit dans le header
.CARTRIDGETYPE 0                ;ROM only
.RAMSIZE 0
.COMPUTEGBCHECKSUM              ;WLA-DX écrira le checksum lui-même (nécessaire sur une vraie GB)
.COMPUTEGBCOMPLEMENTCHECK       ;WLA-DX écrira le code de verif du header (nécessaire sur une vraie GB)
.LICENSEECODENEW "00"           ;Code de license Nintendo, j'en ai pas donc...
.EMPTYFILL $00                  ;Padding avec des 0

.MEMORYMAP
SLOTSIZE $4000
DEFAULTSLOT 0
SLOT 0 $0000
SLOT 1 $4000
.ENDME

.ROMBANKSIZE $4000              ;Deux banks de 16Ko
.ROMBANKS 2

.BANK 0 SLOT 0

.ENUM $C000
; ici on déclare les variables
RaquetteY DB
BalleX DB
BalleY DB
VitX DB
VitY DB
.ENDE

.ORG $0040
call VBlank
reti

.ORG $0100
nop
jp    start                     ;Entry point

.ORG $0104
;Logo Nintendo, obligatoire
.db $CE,$ED,$66,$66,$CC,$0D,$00,$0B,$03,$73,$00,$83,$00,$0C
.db $00,$0D,$00,$08,$11,$1F,$88,$89,$00,$0E,$DC,$CC,$6E,$E6
.db $DD,$DD,$D9,$99,$BB,$BB,$67,$63,$6E,$0E,$EC,$CC,$DD,$DC
.db $99,$9F,$BB,$B9,$33,$3E


.org $0150
start:
di
ld sp,$FFF4 ;SP=$FFF4
xor a ;A=0
ldh ($26),a ;($FF26)=A
waitvbl:
ldh a,($44) ;A=($FF44)
cp 144 ;Comparer A avec 144
jr c, waitvbl ;Sauter à waitvbl si A<144
xor a ;A=0
ldh ($40),a ;($FF40)=A
ld b,3*8*2 ;B=48
ld de,Tiles ;DE=Adresse du label "Tiles", pointeur ROM
ld hl,$8000 ;HL=$8000, pointeur VRAM
ldt:
ld a,(de) ;A=(DE)
ldi (hl),a ;(HL)=A et incrémenter HL
inc de ;Incrémenter DE
dec b ;Décrémenter B (compteur d'itérations)
jr nz,ldt ;Sauter à ldt si B différent de 0
ld de,32*32 ;DE=1024
ld hl,$9800 ;HL=$9800
clmap:
xor a ;A=0
ldi (hl),a ;(HL)=A et incrémenter HL
dec de ;Décrémenter DE
ld a,e ;A=E
or d ;A=A OR D (soit A=E OR D)
jr nz,clmap ;Sauter à clmap si DE différent de 0
ld hl,$FE00 ;HL=$FE00
ld b,40*4 ;B=160
clspr:
ld (hl),$00 ;(HL)=0
inc l ;Incrémenter L
dec b ;Décrementer B
jr nz,clspr ;Sauter à clspr si B différent de 0
xor a ;A=0
ldh ($42),a ;($FF42)=A
ldh ($43),a ;($FF43)=A
ld hl,$FE00 ;HL=$FE00
ld b,4 ;B=4
xor a ;A=0
ldspr:
ld (hl),a ;(HL)=A OAM sprite Y
add 8 ;A=A+8 Prochain Y ++8
inc l ;Incrémenter L
ld (hl),$10 ;(HL)=$10 OAM sprite X
inc l ;Incrémenter L
ld (hl),$01 ;(HL)=1 OAM sprite tile
inc l ;Incrémenter L
ld (hl),$00 ;(HL)=0 OAM sprite attribut
inc l ;Incrémenter L
dec b ;Décrementer B
jr nz,ldspr ;Sauter à ldspr si B différent de 0
ld (hl),$80 ;(HL)=$80 OAM sprite Y
inc l ;Incrémenter L
ld (hl),$80 ;(HL)=$80 OAM sprite X
inc l ;Incrémenter L
ld (hl),$02 ;(HL)=2 OAM sprite tile
inc l ;Incrémenter L
ld (hl),$00 ;(HL)=0 OAM sprite attribut
ld a,$20
ld (RaquetteY),a
ld a,$80
ld (BalleX),a
ld (BalleY),a
ld a,2
ld (VitX),a
ld (VitY),a
ld a,%11100100 ;11=Noir 10=Gris foncé 01=Gris clair 00=Blanc/transparent
ldh ($47),a ; Palette BG
ldh ($48),a ; Palette sprite 0
ldh ($49),a ; Palette sprite 1 (ne sert pas)
ld a,%10010011 ; Ecran on, Background on, tiles à $8000
ldh ($40),a

ld a,%00010000 ; Interruptions VBlank activées
ldh ($41),a
ld a,%00000001 ; Interruptions VBlank activées (double activation à la con)
ldh ($FF),a

ei ;Activer la prise en charge des interruptions

loop:
jr loop ;Boucle infinie
VBlank:
push af ;Empiler AF
push hl ;Empiler HL
ld a,%00100000 ; Selection touches de direction
ldh ($00),a ;($FF00)=$20

ldh a,($00) ;B=($FF00) lire état touches
ld b,a
bit $3,b ;Tester bit 3 de B (croix directionnelle bas)
jr nz,nod
ld a,(RaquetteY) ;Faire descendre la raquette de 2 pixels
inc a
inc a
ld (RaquetteY),a
cp 144+16-32 ;Limite bordure écran bas + décalage HW 16 - taille sprite
jr c,nod
ld a,144+16-32
ld (RaquetteY),a
nod:
bit $2,b ;Tester bit 2 de B (croix directionnelle haut)
jr nz,nou
ld a,(RaquetteY) ;Faire monter la raquette de 2 pixels
dec a
dec a
ld (RaquetteY),a
cp 16 ;Limite bordure écran haut + décalage HW 16
jr nc,nou
ld a,16
ld (RaquetteY),a
nou:
ld hl,$FE00 ;Mise à jour de la position de la raquette en OAM
ld a,(RaquetteY)
ld (hl),a ;OAM sprite 0 Y
ld hl,$FE04
add $8 ;8 pixels plus bas
ld (hl),a ;OAM sprite 1 Y
ld hl,$FE08
add $8 ;8 pixels plus bas
ld (hl),a ;OAM sprite 2 Y
ld hl,$FE0C
add $8 ;8 pixels plus bas
ld (hl),a ;OAM sprite 3 Y
ld hl,BalleX ;Mise à jour position X de la balle selon la vitesse horizontale
ld a,(VitX) ;A=Vitesse horizontale
add (hl) ;A=(BalleX)+Vitesse
cp 160
jr c,nocxr ;BalleX < 160: pas de collision bord droit
call lowbeep ;Collision: bip grave
ld a,$FE ;La vitesse horizontale est mise à -2
ld (VitX),a
ld a,160 ;La position sera remise à la limite, au cas où: 160 (160+8-largeur balle)
nocxr:
cp 2
jr nc,nocxl ;BalleX > 2: pas de collision bord gauche
call lowbeep ;Collision: bip grave
ld a,2 ;La vitesse horizontal est mise à 2
ld (VitX),a
ld a,8 ;La position sera remise à la limite, au cas où: 8 (0+8)
nocxl:
ld (hl),a ;Fixage position X
ld hl,BalleY ;Mise à jour position Y de la balle selon la vitesse verticale
ld a,(VitY)
add (hl)
cp 144+8
jr c,nocyr ;BalleX < 152: pas de collision bord bas
call lowbeep ;Collision: bip grave
ld a,$FE ;La vitesse verticale est mise à -2
ld (VitY),a
ld a,144+8 ;Limite
nocyr:
cp 16
jr nc,nocyl ;BalleX > 16: pas de collision bord haut
call lowbeep ;Collision: bip grave
ld a,2 ;La vitesse verticale est mise à 2
ld (VitY),a
ld a,8+8 ;Limite
nocyl:

ld (hl),a ;Fixage position Y
ld a,(BalleX)
cp 8+16
jr nc,nopaddle ;BalleX > 8+16: pas de collision raquette possible
cp 8+10
jr c,nopaddle ;BalleX < 8+10: pas de collision raquette possible
ld a,(VitX)
cp 2
jr z,nopaddle ;Vitesse positive: pas de collision raquette possible
ld a,(BalleY)
add 8 ;Trouve la position du bord bas de la balle en ajoutant 8 à celle de son bord haut
ld b,a
ld a,(RaquetteY)
cp b ;La compare avec celle du bord haut de la raquette
jr nc,nopaddle ;PaddleY > BalleY+8: pas de collision raquette possible
ld hl,BalleY
ld a,(RaquetteY)
add 32 ;Trouve la position du bord bas de la raquette en ajoutant 32 à celle de son bord haut
cp (hl)
jr c,nopaddle ;PaddleY+32 < BalleY: pas de collision raquette possible
call hibeep ;Rebond paddle, bip aigu
ld a,2 ;Vitesse horizontale à 2
ld (VitX),a
nopaddle:

ld hl,$FE10 ; $FE00 + 4*4 (Sprite numéro 3)
ld a,(BalleY)
ld (hl),a ; OAM balle Y
inc l
ld a,(BalleX)
ld (hl),a ; OAM balle X

pop hl ;Dépiler HL
pop af ;Dépiler AF
ret ;Retour de CALL
lowbeep:
call setsnd
ld a,%00000000
ldh ($13),a
ld a,%11000111
ldh ($14),a
ret
hibeep:
call setsnd
ld a,%11000000
ldh ($13),a
ld a,%11000111
ldh ($14),a
ret
setsnd:
ld a,%10000000
ldh ($26),a
ld a,%01110111
ldh ($24),a
ld a,%00010001
ldh ($25),a
ld a,%10111000
ldh ($11),a
ld a,%11110000
ldh ($12),a
ret
.ORG $800
Tiles:
