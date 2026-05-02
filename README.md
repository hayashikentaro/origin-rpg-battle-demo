# オリジナルRPGバトルデモ

Godot 4 と TypeScript で構成した、サ・ガ系の構造に着想を得たオリジナルRPGバトルデモです。

## 構成

- `core/`
  - TypeScript 製のコアロジック
  - `battle`
  - `growth`
  - `transform`
  - `rng`
- `scenes/`
  - Godot のシーン
- `scripts/frontend/`
  - Godot 側の UI / 入力 / 表示 / TypeScript ブリッジ

## 実行方法

1. TypeScript コアをビルド
2. Godot 4 でプロジェクトを起動

```bash
tsc -p core/tsconfig.json
godot --path .
```

## 現在のデモ内容

- 4人パーティ対3体のターン制バトル
- 人間、エスパー、モンスター、メカの種族差
- 戦闘後成長
- 肉によるモンスター変身
- 装備によるメカ能力補正
- ゲームボーイ風のバトルUI
