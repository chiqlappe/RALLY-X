# PC-8001 NEW RALLY-X用パッチ

## 目的
* アーケード版に近づけるための修正や機能の追加

## 更新履歴
* 2020/04/11 メーカーロゴを復旧。コンティニュー機能を追加
* 2020/04/10 githubで公開。カナキーでウェイトカットする機能を追加

## 主な内容
* BGMと効果音追加
* オープニング画面修正  
* チャレンジングステージのデモ追加  
* ハイスコア達成画面追加  
* ゲーム開始直後のレッド・カーすり抜け機能追加  
* 難易度別のコース色設定（４パターン）  
* チートコマンド

## 必要なもの
* ゲーム本体（アイ・オー1982年5月号掲載 P.242~249）  

## 手順
* PC-8001にゲームをロードする  
* パッチプログラム `auto.cmt` をモニタからロードすると自動でゲームが開始する

## アセンブルについて
* PC-8001エミュレータj80付属のtools80でアセンブル可能です  
 1.  `patch.asm` パッチ本体
 2.  `sound_driver.bin` サウンドドライバー
 3.  `bgm.bin` BGM・効果音データ

## サウンドドライバについて
* @bugfire01さんが作成されたサウンドドライバとBGMパッチを使用しています  
  [PC-8001を懐かしむページ](https://bugfire2009.ojaru.jp/bgm.html)  
  [@bugfire01](https://twitter.com/bugfire01)  

## チートコマンド
* ゲームスタート時に`"0"~"F"キー`のいずれかを押し続けるとラウンドセレクトできます 
* ゲームスタート時に`シフトキー`を押し続けるとマップ無しになります
* ゲームスタート時に`コントロールキー`を押し続けるとマイカー255台になります
* ゲームスタート時に`8`と`リターンキー`を押し続けるとコンティニューできます
* ゲーム中に`カナキー`をロックすると一部のウェイト処理がカットされます
