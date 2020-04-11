;=============================
;PC-8001 "RALLY-X"用パッチ
;2020/04/11
;=============================

FALSE		EQU	00H
TRUE		EQU	!FALSE

MAIN		EQU	 9B00H	;パッチプログラム
SUBS		EQU	 9D00H	;追加サブルーチン
DRIVER		EQU	0A200H	;サウンドドライバ
BGM		EQU	0A900H	;曲データ

;サウンドドライバ関連
PLAY_SONG	EQU	DRIVER + 010H
INIT_BGM	EQU	DRIVER + 013H
PLAY_BGM	EQU	DRIVER + 016H
STOP_PCG	EQU	DRIVER + 019H
INIT_SE		EQU	DRIVER + 01FH
PLAY_SE		EQU	DRIVER + 022H
MUTE_BGM	EQU	DRIVER + 025H
MUTE_SE		EQU	DRIVER + 028H
BGMMARK		EQU	0E1H

;ゲーム本体関連
MYCAR		EQU	0BB17H	;マイカー数
REDCNUM		EQU	0BB2BH	;レッド・カーの数
ROUND		EQU	0BBE7H	;ラウンド数
SOUND		EQU	0BBF1H	;曲番号（BEEP音用カウンタを流用）
MAJOR_WAIT	EQU	0D001H	;ゲーム全体のスピード調整用ウェイト値
START		EQU	0E400H	;ゲーム開始アドレス
GPUTC		EQU	0E63BH	;スタック文字列出力

;-----------------------------

	ORG	MAIN

	LD	HL,P1
	CALL	PATCH
	CALL	SET_PCG_CHR
	JP	START

PATCH:	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,D
	OR	E
	RET	Z
	LD	C,(HL)
	INC	HL
	LD	B,00H
	LDIR
	JR	PATCH

;=============================
;パッチデータ
;=============================

;リスタート
P1:
	DW	0C7D7H
	DB	P2-$-1
	JP	RESTART

;新ラウンド
P2:
	DW	0C526H
	DB	P3-$-1
	CALL	NEW_ROUND


;マイカー爆発音の調整
P3:	DW	0E5DFH
	DB	P4-$-1
	DB	40H		;音の長さを短くする

;ロゴ変更
P4:
IF FALSE
	DW	0E4FAH
	DB	P5-$-1
	DB	80H,88H,08H,00H,88H,08H,80H,88H,08H,00H,88H,88H,00H,88H,08H
	DB	0F0H,00H,0F0H,0E0H,0AAH,0FAH,0F0H,0F0H,0F0H,70H,88H,88H,70H,88H,78H
ENDIF

;ゲーム名変更
P5:	DW	0E473H
	DB	P6-$-1
	CALL	NAME

;爆発マーク表示
P6:	DW	0E5C8H
	DB	P7-$-1
	JP	BOMB

;ゲームオーバー
P7:	DW	0E61FH
	DB	P8-$-1
	JP	GAMEOVER

;フォント追加
P8:
	DW	0E758H
	DB	P9-$-1
	DB	02H,50H,03H,00H,00H,00H,00H	;シングルクオーテーション 5FH
	DB	02H,00H,00H,10H,00H,00H,00H	;ピリオド 60H
	DB	02H,00H,0FH,00H,01H,00H,00H	; "1" 61H 
	DB	02H,5DH,07H,11H,01H,00H,00H	; "2" 62H
	DB	02H,1FH,0FH,11H,01H,00H,00H	; "0" 63H
	DB	03H,50H,03H,35H,00H,00H,00H	;ダブルクオーテーション 64H

;タイトル画面
P9:	DW	0C510H
	DB	P10-$-1
	CALL	TITLE

;ハイスコア更新
P10:	DW	0C9E4H
	DB	P11-$-1
	CALL	SCORE
	NOP
	NOP
	NOP

;チャレンジングステージタイトル
P11:	DW	0E51AH
	DB	P12-$-1
	CALL	CHALLENGE

;ラウンド毎に画面の色を変える
P12:	DW	0D8DDH
	DB	P13-$-1
	CALL	INIT_SCRN
	NOP

;レッド・カー待機処理
P13:
	DW	0DE75H
	DB	P14-$-1
	JP	IS_STDBY

;SET NORMAL TIMER (FOR BGM1,BGM2)
P14:
	DW	0DA0AH
	DB	P15-$-1
	JP	TIMER

;SET FUEL TIMER (FOR BGM3)
P15:
	DW	0D9A0H
	DB	P16-$-1
	LD	HL,0EH
	CALL	FUEL_TIMER

;OPENING SONG TIMING
P16:
	DW	0E4F3H
	DB	P17-$-1
	JP	OPENING

;CRUSH TIMING
P17:
	DW	0DFC8H
	DB	P18-$-1
	DW	CRUSH

;CLEAR TIMING
P18:
	DW	0D98AH
	DB	P19-$-1
	DW	CLEAR

;CLEAR END TIMING
P19:
	DW	0D98DH
	DB	P20-$-1
	DW	CLEAR_END

;BONUS STAGE TIMING
P20:
	DW	0E5A7H
	DB	P21-$-1
	DW	BONUS

;効果音セット
P21:
	DW	0DF6BH
	DB	P22-$-1
	LD	HL,SOUND
	LD	A,(HL)
	AND	A
	JR	Z,.L1
	LD	(HL),0
	CALL	INIT_SE_NUM
.L1:	JP	0D000H

;アトリビュート
P22:
	DW	0CB34H
	DB	P23-$-1
	DB	0F8H

;アトリビュート
P23:
	DW	0CB40H
	DB	P24-$-1
	DB	0F8H

;アトリビュート
P24:
	DW	0CB4CH
	DB	P25-$-1
	DB	0F8H

;アトリビュート
P25:
	DW	0CBAAH
	DB	P26-$-1
	DB	0F8H

;煙幕のBEEP音をスキップ
P26:
	DW	0D9E7H
	DB	P27-$-1
	JP	0DA02H

;煙幕音
P27:
	DW	0D264H
	DB	P28-$-1
	JP	SMOKESND

;チェックポイント音
P28:
	DW	0D204H
	DB	P29-$-1
	CALL	CPSND

;スペシャルフラッグ音
P29:
	DW	0D17CH
	DB	P30-$-1
	CALL	SPFLG

;ラッキーフラッグ
P30:
	DW	0E7F8H
	DB	P31-$-1
	LD	A,03H
	CALL	INIT_SE_NUM
	JP	0D992H

;FUEL音 消音
P31:
	DW	0D9AAH
	DB	P32-$-1
	CALL	MUTE_SE

;エクステンド音
P32:
	DW	0C9CAH
	DB	P33-$-1
	CALL	EXTEND

;燃料切れ音
P33:
	DW	0DF42H
	DB	P34-$-1
	CP	12H
	JP	C,EMPTY

;チートコマンド
P34:
	DW	0C523H
	DB	P35-$-1
	CALL	CHEAT

;転回時のBGMテンポ修正
P35:
	DW	0D2AEH
	DB	P36-$-1
	JP	TURN180

;チャレンジングステージデモの文字出力
P36:
	DW	0E520H
	DB	P37-$-1
	CALL	GPRTBGM

;煙幕の持続時間変更
P37:
	DW	0D245H
	DB	P38-$-1
	DB	40H

;ラウンドのレッド・カー数をAC版の値に修正
P38:
IF FALSE
	DW	0C822H
	DB	P39-$-1
	DB	0,0,1,0	;#1
	DB	0,1,2,0	;#2
	DB	0,5,7,1	;#3
	DB	1,2,2,0	;#4
	DB	1,3,2,0	;#5
	DB	1,3,3,0	;#6
	DB	1,5,7,1	;#7
	DB	2,4,3,0	;#8
	DB	2,5,3,0	;#9
	DB	2,5,4,0	;#10
	DB	2,5,7,1	;#11
	DB	3,5,4,0	;#12
	DB	3,5,4,0	;#13
	DB	3,5,4,0	;#14
	DB	3,5,4,0	;#15
	DB	3,5,7,1	;#16
	DB	3,5,5,0	;#17~
ENDIF

;フラッグ数減少による負荷調整
P39:
	DW	0D1DEH
	DB	P40-$-1
	CALL	SLOWDOWN

;チャレンジングステージデモのセミグラ出力
P40:
	DW	0E541H
	DB	P41-$-1
	CALL	PGRPHBGM

;
P41:
	DW	0E550H
	DB	P42-$-1
	CALL	PGRPHBGM

;
P42:
	DW	0E55FH
	DB	P43-$-1
	CALL	PGRPHBGM

;
P43:
	DW	0E56EH
	DB	P44-$-1
	CALL	PGRPHBGM

;チャレンジングステージ デモの旗の位置
P44:
	DW	0E536H
	DB	P45-$-1
	DW	1608H

P45:
	DW	0E545H
	DB	P46-$-1
	DW	1E08H

P46:
	DW	0E554H
	DB	P47-$-1
	DW	160CH

P47:
	DW	0E563H
	DB	P48-$-1
	DW	1E0CH

P48:
	DW	0E571H
	DB	P49-$-1
	JP	CSTEXT

;レッド・カー待機中の負荷調整
P49:
	DW	0DEA8H
	DB	P50-$-1
	CALL	STDBY_WAIT

P50:

;END MARKER
P99:
	DW	0000H

	DS	SUBS-$,00H

	ORG	SUBS

;=============================
;追加ルーチン
;=============================

;-----------------------------
;レッド・カー待機中のスピード調整
;-----------------------------
STDBY_WAIT:
	LD	(0BB29H),A
	PUSH	BC
	LD	B,80H
.L1:	DJNZ	.L1
	POP	BC
	RET

;-----------------------------
;チャレンジングステージ デモの文字修正
;-----------------------------
CSTEXT:
	LD	HL,0A12H
	CALL	GPRTBGM
	DB	"RED",40H,"CARS",40H,"DON",5FH,"T",40H,"MOVE",00H
	LD	HL,0A14H
	CALL	GPRTBGM
	DB	"UNTIL",40H,"FUEL",40H,"RUNS",40H,"OUT",60H,00H
	JP	0E5A3H

;-----------------------------
;転回時のBGMテンポ修正
;-----------------------------
TURN180:
	LD	C,0AH
.L2:	LD	B,00H
.L1:	DJNZ	.L1
	DEC	C
	JR	NZ,.L2
	JP	0DC00H		;REDCAR

;-----------------------------
;スピード微調整用 初期設定
;-----------------------------
NEW_ROUND:
	XOR	A
	LD	(MINOR_WAIT),A
	LD	A,(ROUND)
	RET

;-----------------------------
;スピード微調整
;-----------------------------
SLOWDOWN:
	LD	A,(MINOR_WAIT)
	ADD	A,1CH		;=256/9
	LD	(MINOR_WAIT),A
	LD	A,(0BB15H)
	RET

;-----------------------------
;スタックの文字列をBGM付きで出力する
;IN	HL
;-----------------------------
GPRTBGM:
	POP	DE		
.L1:	LD	A,(DE)		
	INC	DE		
	CP	00H		
	JP	Z,.L2		
	CALL	GPUTC		
	LD	B,08H
	CALL	PWAIT
	JP	.L1		
.L2:	PUSH	DE		
	RET			

;-----------------------------
;BGMを演奏しながらウェイト処理する
;IN	B=1TICK演奏を繰り返す数
;-----------------------------
PWAIT:
.L1	LD	A,01H		;=TICK数
	CALL	PLAY_BGM_NUM
	PUSH	HL
	PUSH	DE
	LD	HL,0004H
	CALL	WAIT
	POP	DE
	POP	HL
	DJNZ	.L1
	RET

;-----------------------------
;BGM付きのPUTGRPH
;-----------------------------
PGRPHBGM:
	CALL	0D5D5H		;PUTGRPH
	LD	B,60H
	JR	PWAIT
;	RET

;-----------------------------
;燃料切れ音
;-----------------------------
EMPTY:
	CP	00H
	JP	Z,0DF51H
	LD	C,A
	LD	HL,EMPTY_FLG
	XOR	A
	CP	(HL)
	JR	NZ,.L1
	LD	(HL),0FFH
	LD	A,0BH
	LD	(SOUND),A
.L1:	LD	A,C
	JP	0DF47H

;-----------------------------
;エクステンド音
;-----------------------------
EXTEND:
	LD	A,0AH
	LD	(SOUND),A
	JP	0CA89H

;-----------------------------
;スペシャルフラッグ音
;-----------------------------
SPFLG:
	LD	A,08H
	LD	(SOUND),A
	LD	A,(0BB15H)
	RET

;-----------------------------
;チェックポイント音
;-----------------------------
CPSND:
	LD	HL,SOUND
	LD	A,(HL)
	AND	A
	RET	NZ
	LD	(HL),07H
	RET

;-----------------------------
;煙幕音
;-----------------------------
SMOKESND:
	LD	A,09H
	LD	(SOUND),A
	JP	0D26CH

;-----------------------------
;画面の色指定
;-----------------------------
INIT_SCRN:
	CALL	SET_MAPCOL
	LD	L,030H
	LD	E,02H
	RET

SET_MAPCOL:
	LD	A,(ROUND)	;
	SRL	A		;
	SRL	A		;A<-(ROUND)/4

	CP	011H		;
	JP	C,.L1		;
	LD	A,011H		;=17

.L1:	AND	03H		;
	LD	C,A		;
	LD	B,00H		;
	LD	HL,.TBL		;
	ADD	HL,BC		;
	LD	A,(HL)		;
	JP	PALETTE		;
	;RET			;
.TBL:	DB	98H,0B8H,0D8H,78H

;-----------------------------
;チャレンジングステージ画面
;-----------------------------
CHALLENGE:
	CALL	0E626H
	LD	A,0D8H		;文字を黄色にする
	CALL	PALETTE		;
	LD	A,58H		;
	LD	(0F533H),A	;
	LD	(0F533H+120),A	;
	LD	A,4		;チャレンジングステージのBGMセット
	JP	INIT_BGM_NUM
	;RET

;-----------------------------
;タイトル画面
;-----------------------------
TITLE:
	CALL	STOP_PCG
	XOR	A		;ハイスコア更新フラグを降ろす
	LD	(NEWHSC),A
	CALL	0E423H
	LD	A,03EH
	JP	0E626H
	;RET

;-----------------------------
;タイトル画面の文字色変更など
;-----------------------------
NAME:
	LD	A,0D8H		;文字を黄色にする
	CALL	PALETTE		;
	LD	A,58H		;指定行を赤色にする
	LD	(0F3CBH),A	;
	LD	(0F443H),A	;
	LD	(0FD2BH),A	;
	LD	(0FDA3H),A	;
	LD	A,0F8H		;指定行を白色にする
	LD	(0F4BBH),A	;
	LD	(0F533H),A	;
	LD	HL,01101H	;"NEW"を表示する
	CALL	0E66FH		;
	DB	"NEW",00H	;
	LD	HL,01C01H
	RET

;-----------------------------
;爆発マーク表示
;-----------------------------
BOMB:
	CALL	0D92AH
	LD	DE,.DATA
	LD	BC,0603H
	CALL	0D5D5H
	JP	0E5DDH
.DATA:	DB	0C6H,0F8H,0CEH,0C8H,0C8H,16H
	DB	62H,0BFH,10H,0B0H,0CFH,00H
	DB	74H,13H,7FH,72H,1FH,43H

;-----------------------------
;属性値をセットする
;IN	A=属性値,B=行数,HL=先頭アドレス
;-----------------------------
SET_ATRB:
	LD	DE,78H
.L1:	LD	(HL),A
	ADD	HL,DE
	DJNZ	.L1
	RET

;-----------------------------
;ハイスコア画面
;-----------------------------
HISCRN:
	LD	A,03EH
	CALL	0E626H
	LD	A,58H
	LD	B,4
	LD	HL,0F4BBH
	CALL	SET_ATRB
	LD	A,58H
	LD	B,2
	LD	HL,0F9E3H
	CALL	SET_ATRB
	LD	A,0D8H
	LD	B,5
	LD	HL,0FBC3H
	CALL	SET_ATRB
	LD	HL,1003H
	CALL	0E66FH
	DB	"YOU",40H,"DID",40H,"IT",40H,5EH,5EH,00H
	LD	HL,1008H
	CALL	0E66FH
	DB	"THE",40H,"HI",5CH,"SCORE",00H
	LD	HL,120BH
	CALL	0E66FH
	DB	"OF",40H,"THE",40H,"DAY",60H,00H
	LD	HL,120EH
	CALL	0E66FH
	DB	64H,40H,40H,40H,40H,40H,40H,40H,64H,00H	;='    '
	LD	HL,160EH
	LD	DE,0BBE1H
	LD	B,06H
	CALL	0CA07H
	LD	HL,0B12H
	CALL	0E66FH
	DB	"GO",40H,"FOR",40H,"THE",40H,"WORLD",00H
	LD	HL,1015H
	CALL	0E66FH
	DB	"RECORD",40H,"NOW",40H,5EH,5EH,00H
	LD	A,6
	CALL	INIT_BGM_NUM
	LD	B,20H		;点滅回数
.L1:	PUSH	BC
	LD	HL,0F9E3H	;画面中央のスコア
	LD	C,50H
	CALL	.SUB
	LD	HL,0F359H	;ハイスコア
	LD	C,50H
	CALL	.SUB
	LD	HL,0F447H	;"1UP"
	LD	C,0F0H
	CALL	.SUB
	LD	HL,0F4C1H	;スコア
	LD	C,30H
	CALL	.SUB
	LD	B,10H
.L2	LD	A,3		;=TICK数
	CALL	PLAY_BGM_NUM
	LD	HL,000AH
	CALL	WAIT
	DJNZ	.L2
	POP	BC
	DJNZ	.L1
	LD	HL,0400H
	JP	0DA0AH
;	RET

.SUB:	LD	A,(HL)
	XOR	C
	LD	B,02H
	JP	SET_ATRB

;-----------------------------
;ゲームオーバー処理
;-----------------------------
GAMEOVER:
	LD	HL,0800H
	CALL	0DA0AH
	LD	A,38H
	CALL	PALETTE		;画面を赤色に
	LD	A,(NEWHSC)
	AND	A
	CALL	NZ,HISCRN	;ハイスコア更新
	JP	SET_MAPCOL	;マップ色設定
	;RET

;-----------------------------
;メイン画面のパレット変更
;IN	A=属性コード
;-----------------------------
PALETTE:
	LD	HL,0F350H+3
	LD	DE,78H
	LD	B,19H
.L1:	LD	(HL),A
	ADD	HL,DE
	DJNZ	.L1
	RET

;-----------------------------
;レッドカーはスタート前か？
;-----------------------------
IS_STDBY:
	JR	NC,.L1
	LD	A,(0BB72H)
	AND	A
	JP	Z,0DF88H
.L1:	JP	0DE78H

;-----------------------------
;ハイスコア更新
;-----------------------------
SCORE:
.L1:	LD	A,(DE)
	LD	(HL),A
	INC	DE
	INC	HL
	DJNZ	.L1
	LD	A,0FFH
	LD	(NEWHSC),A	;ハイスコア更新フラグ
	RET

;-----------------------------
;曲を単独で演奏する
;IN	A=曲番号
;-----------------------------
PLAY_SONG_NUM:
	PUSH	HL
	LD 	HL,SONG_NUMBER
	LD 	(HL),A
	CALL 	PLAY_SONG
	POP 	HL
	RET

;-----------------------------
;BGMの曲番号をセットする
;IN	A=曲番号
;-----------------------------
INIT_BGM_NUM:
	PUSH	HL
	LD 	HL,SONG_NUMBER
	LD 	(HL),A
	CALL	INIT_BGM
	POP 	HL
	RET

;-----------------------------
;指定されたTICK数だけBGMを演奏する
;IN	A=TICK数
;-----------------------------
PLAY_BGM_NUM:
	PUSH	HL
	LD 	HL,NUM_TICK
	LD 	(HL),A
	CALL 	PLAY_BGM
	POP 	HL
	RET

;-----------------------------
;効果音の曲番号をセットする
;IN	A=曲番号
;-----------------------------
INIT_SE_NUM:
	PUSH	HL
	LD	HL,SE_NUMBER
	LD	(HL),A
	CALL	INIT_SE
	POP	HL
	RET

;-----------------------------
;指定されたTICK数だけ効果音を演奏する
;IN	A=TICK数
;-----------------------------
PLAY_SE_NUM:
	PUSH HL
	LD HL,NUM_TICK
	LD (HL),A
	CALL PLAY_SE
	POP HL
	RET

;-----------------------------
;ゲーム開始音楽を演奏し、ゲームのBGMをセットする
;-----------------------------
OPENING:
	IN	A,(01H)
	BIT	07H,A
	JR	NZ,OPENING
	CALL	INTRO
	XOR	A
	CALL	PLAY_SONG_NUM	;Play Song (#0:Game Start)
	LD	A,01H
	JP	INIT_BGM_NUM	;Set BGM1 (#1:Normal BGM)
	;RET

;-----------------------------
;イントロ
;-----------------------------
INTRO:
	LD	A,03EH
	CALL	0E626H
	LD	A,0F8H
	LD	B,19H
	LD	HL,0F353H
	CALL	SET_ATRB
	LD	HL,0C06H
	CALL	0E66FH
	DB	"PUSH",40H,"START",40H,"BUTTON",00H
	LD	HL,060AH
	CALL	0E66FH
	DB	61H,"ST",40H,"BONUS",40H,"FOR",40H,40H,62H,63H,63H,63H,63H,40H,"PTS",00H
	LD	HL,060CH
	CALL	0E66FH
	DB	62H,"ND",40H,"BONUS",40H,"FOR",40H,61H,63H,63H,63H,63H,63H,40H,"PTS",00H
	LD	HL,1510H
	CALL	0E66FH
	DB	"CREDIT",40H,61H,00H
	RET

;-----------------------------
;チートコマンド
;-----------------------------
CHEAT:
	IN	A,(08H)	
	BIT	06H,A		;シフトキーが押されたか？
	JR	NZ,.L1
	LD	HL,.PRESET	;レーダーオフ
	JR	.L2
.L1:	LD	HL,.PSET	;レーダーオン
.L2:	LD	DE,0D903H
	LD	BC,03H
	LDIR

	BIT	07H,A		;コントロールキーが押されたか？
	JR	NZ,.L3
	LD	A,0FFH		;マイカー255台
	JR	.L4
.L3:	LD	A,03H
.L4:	LD	(MYCAR),A	;マイカー数<-A

	LD	HL,ROUND
	LD	A,(HL)
	AND	A
	JR	Z,.RA_F

	LD	C,A
	IN	A,(01H)
	AND	%10000001	;"8"とリターンキーが押されていたらラウンド数を初期化しない（コンティニュー処理）
	JR	NZ,.RA_F
	DEC	C
	LD	(HL),C
	RET

.RA_F	IN	A,(02H)
	CPL
	AND	%01111110	;"F"~"A"キーを検索
	JR	Z,.R8_9
	LD	C,10-1
	SRL	A
.L5:	SRL	A
	JR	C,.FOUND
	INC	C
	JR	.L5

.R8_9:	IN	A,(07H)
	CPL
	AND	%00000011	;"9","8"キーを検索
	JR	Z,.R1_7
	LD	C,8-1
.L6:	SRL	A
	JR	C,.FOUND
	INC	C
	JR	.L6

.R1_7:	IN	A,(06H)
	CPL
	CP	%00000001
	JR	NZ,.L9
	LD	C,16-1
	JR	.FOUND

.L9:	AND	%11111110	;"7"~"0"キーを検索
	JR	Z,.L8
	LD	C,7-1
.L7:	SLA	A
	JR	C,.FOUND
	DEC	C
	JR	.L7

.L8:	LD	C,00H
.FOUND:	LD	(HL),C
	RET

.PSET:
	DB	0E5H,0F5H,0CDH
.PRESET:
	DB	0C3H,1EH,0D9H


;-----------------------------
;マイカー爆発画面
;-----------------------------
CRUSH:
	LD	A,58H		;画面を赤くする
	CALL	PALETTE		;
	CALL	STOP_PCG	;Stop PCG
	PUSH	HL
	LD	A,01H		;*
	CALL	INIT_BGM_NUM	;*チャレンジングステージでやられた場合に対応
	POP	HL
	JP	0E5C2H

;-----------------------------
;ラウンドクリア
;-----------------------------
CLEAR:
	PUSH	AF
	CALL	STOP_PCG	;Stop PCG
	LD	A,02H
	CALL	PLAY_SONG_NUM	;play song (#2:Stage Clear)
	CALL	STOP_PCG	;Stop PCG
	CALL	MUTE_BGM	;*
	POP	AF
	JP	0D98FH

;-----------------------------
;新しいラウンドのためにBGMをセットする
;-----------------------------
CLEAR_END:
	PUSH	AF
	CALL	STOP_PCG	;Stop PCG
	LD	A,01H
	CALL	INIT_BGM_NUM	;Set BGM1 (#1:Normal BGM)
	POP	AF
	JP	0C526H

;-----------------------------
;ボーナスステージのタイトル音楽
;-----------------------------
BONUS:
	PUSH	AF
	LD	HL,400H
	CALL	WAIT
	CALL	STOP_PCG	;Stop PCG
	LD	A,05H
	CALL	INIT_BGM_NUM	;Set BGM3 (#5:Bonus Stage)
	POP	AF
	RET

;-----------------------------
;燃料ボーナス音
;-----------------------------
FUEL_TIMER:
	CALL	WAIT
	LD	A,04H		;BGMを4TICK分演奏する
	CALL	PLAY_BGM_NUM	
	LD 	A,06H		;効果音を6TICK分演奏する
	JP 	PLAY_SE_NUM
	;RET

;-----------------------------
;ゲーム中の音楽演奏処理
;-----------------------------
TIMER:
	CALL	WAIT

	IN	A,(08H)		;カナキーが押されていたらウェイトカット
	BIT	05H,A
	JR	Z,.L1
	LD	A,(MINOR_WAIT)
	AND	A
	JR	Z,.L1
	LD	B,A
.L2:	NOP
	NOP
	DJNZ	.L2

.L1:	LD	A,01H
	CALL	PLAY_BGM_NUM	;play 1 tick
	LD	A,03H		;*
	CALL	PLAY_SE_NUM	;* play 3 ticks
	IN	A,(008H)
	BIT	04H,A		;check GRPH
	RET	Z
	LD	A,01H
	CALL	PLAY_BGM_NUM	;play 1 tick
	IN	A,(008H)
	BIT	06H,A		;check SHIFT
	RET	NZ
	LD	A,04H
	JP	PLAY_BGM_NUM	;play 4 ticks
	;RET

;-----------------------------
;ウェイト
;IN	HL=長さ
;-----------------------------
WAIT:
	LD	A,H
	OR	L
	RET	Z

	LD	DE,00001H
	XOR	A
.L1:	DEC	A
	JR	NZ,.L1
	OR	A
	SBC	HL,DE
	JR	NZ,.L1
	RET

;-----------------------------
;再スタート
;-----------------------------
RESTART:
	LD	B,00H
	LD	A,(REDCNUM)
	CP	04H
	JR	NC,.L1		;レッド・カーが4以上でウェイトを0にする
	INC	B
.L1:	LD	A,B
.L2:	LD	(MAJOR_WAIT),A	;ゲームスピード
	XOR	A
	LD	(EMPTY_FLG),A	;燃料切れフラグをリセット
	JP	0DB00H

;-----------------------------
;燃料ゲージキャラクタをPCGに登録する
;-----------------------------
SET_PCG_CHR:
	LD	B,40H
	LD	C,38H
	LD	HL,PCG_DATA
SET_PCG_CHR_LOOP:
	LD	A,(HL)
	INC	HL
	OUT	(00H),A
	LD	A,C
	INC	C
	OUT	(01H),A
	LD	A,10H
	OUT	(02H),A
	XOR	A
	OUT	(02H),A
	DJNZ	SET_PCG_CHR_LOOP
	RET

PCG_DATA:
	DB 255,255,255,255,255,255,255,255
	DB 128,128,128,128,128,128,128,128
	DB 192,192,192,192,192,192,192,192
	DB 224,224,224,224,224,224,224,224
	DB 240,240,240,240,240,240,240,240
	DB 248,248,248,248,248,248,248,248
	DB 252,252,252,252,252,252,252,252
	DB 254,254,254,254,254,254,254,254

;=============================

SONG_NUMBER:	DB	00H	;BGM番号
SE_NUMBER:	DB	00H	;効果音番号
NUM_TICK:	DB	00H	;TICK数
NEWHSC:		DB	00H	;ハイスコア更新フラグ
MINOR_WAIT:	DB	00H	;ゲームスピード微調整用
EMPTY_FLG:	DB	00H	;燃料切れ音フラグ

;=============================

	DS	DRIVER-$,0FFH

	ORG	DRIVER

binclude "sound_driver.bin"

	DS	BGM-$,0FFH

	ORG	BGM

binclude "bgm.bin"

END

