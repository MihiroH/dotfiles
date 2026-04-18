# ワークフロー: 設計ドキュメント

システム設計やアーキテクチャを ireko で書くためのワークフロー。設計レビューの合意形成や、新規参入メンバーのオンボーディング資料として使える。

## 適用シーン

- 新機能のアーキテクチャ設計 (design doc)
- 既存システムのリアーキテクト提案
- インフラ構成図 (ただし実装後の記述ではなく、設計意図を伝える目的)
- API 設計・データモデル設計

学習ノートとの違い: **設計は具体的 (特定の会社・プロダクトのコンテキストがある)**。汎用的な概念説明ではなく、「この組織で、この要件で、こう作る」を書く。

## ステップ

### 1. 設計の 4 象限を意識する

設計ドキュメントは概ね以下 4 つで構成される。全部書く必要はないが、**どれを書いてどれを省くか**を意識する。

| 象限 | 内容 | 図の種類 |
|---|---|---|
| Context | なぜこれを作るのか・何を解決するのか | flowchart (現状 → 課題 → 解決策) |
| Architecture | システムの静的構造・コンポーネント関係 | flowchart / classDiagram |
| Behavior | 動的な振る舞い・主要なフロー | sequenceDiagram / stateDiagram-v2 |
| Tradeoffs | 選択肢の比較・採用理由 | classDiagram (比較) / flowchart (決定木) |

### 2. テンプレートを読む

`templates/design-system.ireko` を `view` で読む。

### 3. ルートダイアグラムは「設計の地図」

設計ドキュメントのルートは、**読者が欲しい情報にすぐ辿り着ける目次**として機能させる:

```
@root
diagram "機能 X の設計" {
  flowchart TB
    Design([機能 X の設計]) --> Why[なぜ作るか]
    Design --> Arch[アーキテクチャ]
    Design --> Flow[主要フロー]
    Design --> Data[データ設計]
    Design --> Choice[技術選定]
    Design --> Open[未解決の論点]

    ref Why > Context
    ref Arch > Architecture
    ref Flow > MainFlows
    ref Data > DataModel
    ref Choice > TechChoices
    ref Open > OpenQuestions
}
```

読者が「アーキテクチャだけ見たい」「なぜこの技術を選んだか見たい」に個別に飛べるようにする。

### 4. Context (なぜ作るか) を省略しない

技術者は「何を作るか」から書きたがるが、設計レビューでは **「何故作るか」が最も重要**。これが無いと「本当に必要?」の議論ができない。

```
diagram Context "背景と目的" {
  flowchart TB
    Current([現状の課題]) --> P1[課題 1]
    Current --> P2[課題 2]

    P1 --> Goal([解決したいゴール])
    P2 --> Goal

    Goal --> NG[Non-Goals: 今回やらないこと]
    Goal --> Cons[制約]

    ref P1 > ProblemDetail1
    ref NG > OutOfScope
    ref Cons > Constraints
}
```

**Non-Goals を明示する**のがポイント。「今回やらないこと」を先に書くと議論が発散しない。

### 5. Architecture は 2 段階で

アーキテクチャ図は概ね以下 2 段階で書くと読みやすい:

**段階 1: コンポーネント図 (静的な構造)**

```
diagram Architecture "システム全体構成" {
  flowchart TB
    subgraph Client["Client"]
      Web[Web App]
      Mobile[Mobile App]
    end

    subgraph Backend["Backend"]
      API[API Server]
      Worker[Background Worker]
    end

    subgraph Data["Data Layer"]
      DB[(MySQL)]
      Cache[(Redis)]
    end

    Web --> API
    Mobile --> API
    API --> DB
    API --> Cache
    API --> Worker
    Worker --> DB

    ref API > APIDetail
    ref Worker > WorkerDetail
    ref DB > DataSchema
}
```

**段階 2: 主要フロー (動的な振る舞い)**

```
diagram MainFlow1 "主要フロー: ユーザー登録" {
  sequenceDiagram
    participant C as Client
    participant API as API_Server
    participant Auth as Firebase_Auth
    participant DB as MySQL
    participant Q as Queue

    C->>API: POST /signup
    API->>Auth: Create user
    Auth->>API: User ID
    API->>DB: Insert user record
    API->>Q: Enqueue welcome email
    API->>C: 201 Created
}
```

### 6. Tradeoffs (技術選定) は classDiagram で比較

「なぜ A を選んだか」は候補の比較で示すのが最も説得力がある:

```
diagram TechChoice "データストアの選定" {
  classDiagram
    class MySQL {
      +一貫性: 強い
      +スケール: 垂直
      +運用コスト: 中
      +既存採用: あり
      +学習コスト: 低
    }
    class PostgreSQL {
      +一貫性: 強い
      +スケール: 垂直
      +運用コスト: 中
      +既存採用: なし
      +学習コスト: 中
    }
    class DynamoDB {
      +一貫性: 結果整合性
      +スケール: 水平
      +運用コスト: 低
      +既存採用: なし
      +学習コスト: 高
    }

    note for MySQL "採用: 既存採用実績と運用ノウハウ"
}
```

### 7. Open Questions (未解決の論点) を明示する

設計レビューの目的の半分は「未解決の論点を見つける/埋める」こと。**わからない部分を隠さない**。

```
diagram OpenQuestions "未解決の論点" {
  flowchart TB
    Open([未解決の論点]) --> Q1["Q1: キャッシュの TTL は?<br/>→ 負荷試験で決める"]
    Open --> Q2["Q2: 失敗時のリトライ戦略<br/>→ 次スプリントで設計"]
    Open --> Q3["Q3: データ移行の方式<br/>→ 別 design doc で"]

    ref Q3 > MigrationDesignDoc
}
```

### 8. 実装とドリフトしないよう書き方を工夫

設計ドキュメントあるある: 書いた直後は良いが、実装後に更新されず嘘になる。

**対策:**
- **変更可能性が高い部分は具体的に書かない** (「MySQL 8.0」ではなく「RDB」、「nginx 1.25」ではなく「Reverse Proxy」)
- **コード/設定ファイルの完全コピーをしない** (リンクに留める)
- **図のタイトルに日付やバージョンを入れる** (例: `diagram Architecture "v1.0 時点の全体構成"`)

### 9. 検証

`reference/antipatterns.md` のチェックリストに加え、設計ドキュメント固有のチェック:

- [ ] Context (なぜ作るか) が書かれているか
- [ ] Non-Goals が明示されているか
- [ ] 主要フローが sequence 図で書かれているか
- [ ] 技術選定に比較 (classDiagram) があるか
- [ ] Open Questions が隠されていないか

## 品質の見分け方

**良い設計ドキュメント:**
- レビュアーが「なぜこれを作るか」を理解できる
- 主要フローが時系列で追える
- 技術選定の根拠が他の選択肢と比較されている
- 未解決部分が明示されている

**悪い設計ドキュメント:**
- いきなりアーキテクチャ図から始まる (背景がない)
- 全てが静的な構造図で動的フローがない
- 「こうする」とだけ書かれ比較がない
- 実装後に更新されておらず現実と乖離

## 特殊ケース: 巨大システムの設計

1 ファイルに書くと管理不能な規模の場合:

1. トップレベルの `system.ireko` でシステム全体の目次
2. 各コンポーネントは別ファイル (例: `auth.ireko`, `billing.ireko`)
3. トップレベルから各コンポーネントへは**リンクで誘導** (ireko は複数ファイル間の ref をサポートしないため、HTML 出力のリンクを工夫)

ただし ireko の設計思想 (単一 HTML にインライン) からすると、1 ファイルで収まる規模に留めるほうが本来の強みを活かせる。
