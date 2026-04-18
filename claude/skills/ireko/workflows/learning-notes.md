# ワークフロー: 学習ノート

「ある概念を深く理解したい」ための ireko ファイルを作るワークフロー。
今回の `proxies.ireko` が典型例。

## 適用シーン

- 「X について体系的にまとめたい」
- 「X の 5W1H を整理したい」
- 技術書の読書メモを構造化したい
- 新しい技術領域の学習マップを作りたい

## ステップ

### 1. トピックの性質を見極める

まずユーザーのトピックが以下のどれかを判断する:

| 性質 | 例 | ルートの設計 |
|---|---|---|
| 単一概念の深掘り | TLS, RDB のインデックス, HTTP/2 | 5W1H 構造 (What/Why/How) |
| 複数の関連概念の対比 | Forward vs Reverse Proxy, SQL vs NoSQL | 対比 → 共通点 → 各詳細 |
| 技術スタックの俯瞰 | マイクロサービスアーキテクチャ, 現代のフロントエンド | カテゴリ分類 → 各技術詳細 |

### 2. テンプレートを読む

`templates/learning-concept.ireko` を `view` で読む。これが基本の骨格。

複数概念の対比なら、`proxies.ireko` の構造を参考に:
- ルートで両者を並置
- 共通ハブを作る
- 各詳細は独立したサブツリーで深掘り

### 3. ルートダイアグラムを先に設計する

**先に全体像を決めてから枝を書く**。逆順だと構造がブレる。

ルートは以下のいずれかの型に当てはめる:

#### 型 A: 学習順路型 (単一概念)

```
@root
diagram "X の学び方" {
  flowchart TB
    Start([ここから]) --> What[1. What: X とは]
    What --> Why[2. Why: なぜ使うか]
    Why --> How[3. How: どう動くか]
    How --> Real[4. 実例]

    Why --> Side1[応用: トピック A]
    How --> Side2[応用: トピック B]

    ref What > WhatX
    ref Why > WhyX
    ref How > HowX
    ref Real > RealWorldX
    ref Side1 > TopicA
    ref Side2 > TopicB
}
```

#### 型 B: 対比型 (複数概念)

```
@root
diagram "X と Y" {
  flowchart TB
    Root([X と Y]) --> X[X]
    Root --> Y[Y]
    Root --> Shared[共通する概念]
    Root --> Compare[対比]

    ref X > XRoot
    ref Y > YRoot
    ref Shared > SharedConcepts
    ref Compare > XYComparison
}
```

#### 型 C: 分類俯瞰型 (技術スタック)

```
@root
diagram "X エコシステム" {
  flowchart TB
    Eco([X エコシステム]) --> Cat1[カテゴリ 1]
    Eco --> Cat2[カテゴリ 2]
    Eco --> Cat3[カテゴリ 3]

    ref Cat1 > Category1Detail
    ref Cat2 > Category2Detail
    ref Cat3 > Category3Detail
}
```

### 4. Why から How への ref ブリッジを設計する

学習ノートで最も重要なのは**目的と手段が繋がっていること**。

Why ダイアグラムの各目的から、必ず How の詳細図へ ref する:

```
diagram WhyX "なぜ X を使うか" {
  flowchart TB
    Why([X の目的]) --> G1[目的 1]
    Why --> G2[目的 2]
    Why --> G3[目的 3]

    // 各目的から How への ref
    ref G1 > HowAchievesG1
    ref G2 > HowAchievesG2
    ref G3 > HowAchievesG3
}
```

これが無いと「Why と How が別々に書いてあるだけ」になる。

### 5. 共通ハブを作る (対比型の時)

複数の概念を扱う時、両方に登場するトピックは共通ハブに集約する:

```
diagram SharedConcept "両者に共通するトピック" {
  flowchart TB
    Shared([共通トピック]) --> A[視点 A]
    Shared --> B[視点 B]

    ref A > DetailA
    ref B > DetailB
}
```

**注意:** 共通ハブから各詳細への ref のみ。詳細から共通ハブへの戻り ref は**絶対に張らない** (循環になる)。

### 6. 5W1H のカバレッジを確認する

学習ノートは原則として以下を網羅する:

- **What**: 定義・何か
- **Why**: なぜ使うか・目的
- **How**: どう動くか・仕組み
- **When/Where**: いつ・どこで使うか (適用領域)
- **Who**: 誰が使うか・実例
- **落とし穴**: アンチパターン・限界

全てを独立した図にする必要はないが、ルートから辿ったら一通り分かる構造にする。

### 7. 図の種類を選ぶ

各ダイアグラムで `reference/diagram-selection.md` に従って図の種類を選ぶ。学習ノートでよく使うパターン:

- **比較 (A vs B)** → classDiagram
- **プロトコル・ハンドシェイク** → sequenceDiagram
- **状態遷移** → stateDiagram-v2
- **分類・判定フロー** → flowchart
- **5W1H のルート図** → flowchart TB (学習順路型)

### 8. 書き終わったら検証

`reference/antipatterns.md` の「提出前チェックリスト」を走らせる。
特に以下を重点チェック:

- [ ] Why から How への ref が全ノードに張られているか
- [ ] 図の種類が flowchart 偏重になっていないか
- [ ] ルートが 1 画面に収まっているか
- [ ] 循環 ref・未定義 ref なし (検証スクリプト)

## 品質の見分け方

**良い学習ノート:**
- ルートを見るだけで「この分野で押さえるべき論点」が分かる
- どこから読んでも前後の図に繋がっている
- 目的 (Why) と手段 (How) が ref で繋がっている
- 図の種類が使い分けられている

**悪い学習ノート:**
- ルートが情報過多で圧倒される
- 全部 flowchart で単調
- Why と How が断絶している
- 同じ話が複数箇所で書かれている
- ネストが深すぎて迷子になる

## 成功事例: proxies.ireko

このスキルは `proxies.ireko` の改善プロセスから生まれた。改善前の問題点と改善後の対応:

| 改善前の問題 | 改善後の対応 |
|---|---|
| 2 ファイルが独立、横断視点なし | ルートで Forward/Reverse を並置 |
| ルートが mindmap でフラット | flowchart TB で学習順路を明示 |
| Why が浅く How と断絶 | Why の各目的から How へ ref |
| 共通テーマ (TLS, Cache) が重複 | 共通ハブに集約し片方向 ref |
| 全部 flowchart で単調 | classDiagram, stateDiagram を適材適所 |
| 現代的トピック (gRPC, HTTP/2) が不足 | Modern セクションを追加 |

迷ったらこのパターンに倣う。
