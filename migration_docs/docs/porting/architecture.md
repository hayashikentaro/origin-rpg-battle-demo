# Porting Architecture

## 目的

解析成果を、以下の 2 層へ安全に分離して持ち込めるようにする。

- TypeScript コアロジック
  - `battle`
  - `growth`
  - `transform`
  - `rng`
- Godot フロント
  - `UI`
  - `入力`
  - `表示`

## 役割分離

### TypeScript コア

- 戦闘ルール
- ダメージ算出
- 行動解決
- 成長判定
- 変身結果決定
- 乱数供給
- 戦闘や成長で使う中立データモデル

### Godot フロント

- コマンド入力
- ウィンドウ表示
- バトル演出
- テキスト送り
- マップやイベントの表示
- TypeScript が返した中立イベント列の反映

## データ責務

### コアへ入れるもの

- モンスター基礎データ
- アイテム / 技データ
- usage handler の分類結果
- ダメージ式の確定仕様
- モンスター系統表
- 変身テーブル
- 成長関連の族別ルール

### フロントへ入れるもの

- スクリプト VM の出力を UI 操作へ変換する規則
- マップ / NPC / タイルアクション
- テキスト / メッセージ / メニュー起動
- シーン遷移や演出

### 両者の橋渡し

- action / command / effect の中立表現
- script VM が吐く neutral actions
- バトルログ / メッセージ / 選択肢イベント

## 実装順の推奨

1. `shared-data`
2. `battle`
3. `transform`
4. `growth`
5. `rng`
6. `frontend`

## 現時点の大きな未確定事項

- battle の上流ダメージ算出で、乱数・属性・補正の完全確定がまだ不足
- growth は既存 reports に直接まとまった専用成果が少ない
- rng は単独解析がまだなく、battle 側の暫定使用箇所から逆算している段階
- frontend は map / script / menu / rendering の境界仕様をさらに固める必要がある

## 実装ポリシー

- 未確定 byte は raw 値を保持する
- 推定カテゴリは `kind` と `confidence` を分けて表現する
- Godot は ROM の解釈責務を持ちすぎず、可視化と操作に寄せる
- TypeScript は副作用を持たない関数単位で再現を進める
