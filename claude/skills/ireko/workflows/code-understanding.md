# ワークフロー: 既存コード理解

既存のコードベースを読み解いた結果を ireko で構造化するワークフロー。
新しいプロジェクトに参加した時・数ヶ月ぶりに触る時・モジュールを別人が書いた時に使う。

## 適用シーン

- 新規プロジェクトのオンボーディング (自分用の理解メモ)
- チームのリポジトリガイド (新メンバー向けの「地図」)
- レガシーコードのドキュメント化
- 大規模リファクタ前の現状調査

学習ノート・設計ドキュメントとの違い:
- 学習ノート = 概念の深掘り (汎用)
- 設計ドキュメント = これから作るもの (未来)
- **既存コード理解 = 既にあるものの解読 (現在)**

## ステップ

### 1. 理解の目的を決める

なぜこのコードを理解する必要があるか、先に決める。目的次第で図の粒度が変わる:

| 目的 | 粒度 | 重点 |
|---|---|---|
| 自分が機能を追加する | 細かい | 変更したい箇所とその周辺 |
| 新メンバーに見せる | 粗い | 全体像と主要フロー |
| 障害調査のため | 特定箇所だけ細かい | エラーが起きる箇所 |
| リファクタ前の調査 | 全体を均等に | 結合度・依存関係 |

目的が曖昧だと「全部書こうとして途中で力尽きる」ので最初に決める。

### 2. テンプレートを読む

`templates/code-map.ireko` を `view` で読む。

### 3. ルートは「このリポジトリを理解するための地図」

```
@root
diagram "リポジトリ X の読み方" {
  flowchart TB
    Repo([リポジトリ X]) --> Overview[全体像: 何をするシステムか]
    Repo --> Tree[ディレクトリ構成]
    Repo --> Entry[エントリーポイント]
    Repo --> Flow[主要なデータフロー]
    Repo --> Domain[ドメイン概念]
    Repo --> Infra[実行環境]
    Repo --> Dev[開発時の動かし方]

    ref Overview > SystemOverview
    ref Tree > DirectoryTree
    ref Entry > EntryPoints
    ref Flow > MainDataFlows
    ref Domain > DomainModel
    ref Infra > InfraStack
    ref Dev > DevWorkflow
}
```

### 4. 全体像は「何をするシステムか」から

コードの細部に入る前に、**そもそも何をするシステムか**を 1 枚にまとめる:

```
diagram SystemOverview "このシステムが解く問題" {
  flowchart TB
    Problem([解決する問題]) --> P1["例: 法律文書の検索を高速化"]

    System([システムの役割]) --> R1["ユーザーの検索クエリを受け付ける"]
    System --> R2["Elasticsearch でフルテキスト検索"]
    System --> R3["結果をランキングして返す"]

    User([主な利用者]) --> U1["法律事務所のパラリーガル"]
    User --> U2["企業の法務部門"]

    Note1["これが分からないとコードを読んでも意味が取れない<br/>README や既存ドキュメントを先に読む"]
}
```

### 5. ディレクトリ構成は「なぜこの分け方か」を重視

単なる `ls -R` の結果ではなく、**各ディレクトリの役割**を書く:

```
diagram DirectoryTree "主要ディレクトリの役割" {
  flowchart TB
    Root([wklr-mono/]) --> Apps[apps/]
    Root --> Packages[packages/]
    Root --> Infra[infra/]

    Apps --> App1["apps/web/<br/>Nuxt 2 のフロントエンド"]
    Apps --> App2["apps/api/<br/>NestJS の API サーバー"]
    Apps --> App3["apps/admin/<br/>React Admin の管理画面"]

    Packages --> Pkg1["packages/schema/<br/>共通の TypeORM エンティティ"]
    Packages --> Pkg2["packages/api-client/<br/>フロントエンド用の API 型"]

    Infra --> Inf1["infra/terraform/<br/>GCP リソース定義"]
    Inf --> Inf2["infra/docker/<br/>ローカル開発用の compose"]

    ref App2 > APIEntryPoint
    ref Pkg1 > SchemaPackage
    ref Inf1 > TerraformStructure
}
```

### 6. エントリーポイントを辿る

「どこから実行が始まるか」を明示し、主要な呼び出し経路を sequence で追う:

```
diagram EntryPoints "エントリーポイントと実行開始" {
  flowchart TB
    Entry([エントリーポイント]) --> Web[Web: apps/web/server/index.ts]
    Entry --> API[API: apps/api/src/main.ts]
    Entry --> Worker[Worker: apps/worker/src/main.ts]
    Entry --> CLI[CLI: apps/cli/src/index.ts]

    ref API > APIBootstrap
    ref Worker > WorkerBootstrap
}

diagram APIBootstrap "API サーバーの起動手順" {
  sequenceDiagram
    participant Main as main.ts
    participant Nest as NestFactory
    participant App as AppModule
    participant DB as TypeORM

    Main->>Nest: NestFactory.create(AppModule)
    Nest->>App: AppModule のロード
    App->>DB: TypeORM 接続確立
    App->>App: Middleware 登録
    App->>App: Route 登録
    Nest->>Main: app instance
    Main->>Nest: app.listen(port)
    Note over Main: 以降はリクエストを待機
}
```

### 7. 主要なデータフローを辿る

ユーザー視点の 1 つの操作が、コード上でどう流れるかを追う:

```
diagram SearchFlow "検索機能のデータフロー" {
  sequenceDiagram
    participant User as User
    participant Web as Web (Nuxt)
    participant API as API (NestJS)
    participant Svc as SearchService
    participant ES as Elasticsearch
    participant DB as MySQL

    User->>Web: 検索キーワード入力
    Web->>API: POST /api/search
    API->>Svc: SearchService.search(query)
    Svc->>ES: Elasticsearch クエリ
    ES->>Svc: ヒット文書 ID
    Svc->>DB: 文書メタデータ取得 (TypeORM)
    DB->>Svc: 文書データ
    Svc->>API: ランキング済み結果
    API->>Web: JSON レスポンス
    Web->>User: 検索結果表示

    Note over Svc: apps/api/src/search/search.service.ts
}
```

### 8. ドメイン概念を図にする

コード上の独自用語・ドメイン固有の概念を classDiagram で整理:

```
diagram DomainModel "ドメイン概念の関係" {
  classDiagram
    class Publisher {
      +id: string
      +name: string
      +departments: Department[]
    }
    class Department {
      +id: string
      +name: string
      +publisher: Publisher
      +bibliographicInfos: BibliographicInfo[]
    }
    class BibliographicInfo {
      +id: string
      +title: string
      +department: Department
    }

    Publisher "1" --> "N" Department
    Department "1" --> "N" BibliographicInfo

    note for Publisher "packages/schema/src/entities/publisher.ts"
}
```

### 9. 「罠」セクションを必ず入れる

既存コードには必ず「見た目と違う」「ハマりやすい」部分がある。これを正直に書くと将来の自分と同僚が救われる:

```
diagram Gotchas "ハマりどころ・罠" {
  flowchart TB
    Gotcha([注意点]) --> G1["foo.service.ts の createXxx は<br/>トランザクション外で呼ぶと整合性が壊れる"]
    Gotcha --> G2["Nuxt の asyncData は<br/>setup() より先に走る<br/>ref 先: setup の制約"]
    Gotcha --> G3["MySQL の collation が utf8mb4_0900_bin<br/>email の大文字小文字が区別される"]

    ref G2 > NuxtAsyncDataTrap
    ref G3 > EmailCollationTrap
}
```

### 10. 読み手のための「ここから読むと良い」を示す

新メンバー向けなら、いきなりルートを見せるのではなく「まずこれ、次にこれ」の順路を示す:

```
diagram ReadingPath "初めての人の読む順番" {
  flowchart TB
    S1["1. SystemOverview で目的を掴む"] --> S2["2. DirectoryTree で場所を覚える"]
    S2 --> S3["3. SearchFlow で代表的な処理を辿る"]
    S3 --> S4["4. DomainModel で概念を整理"]
    S4 --> S5["5. Gotchas で罠を知る"]
    S5 --> Done([実装に入れる])

    ref S1 > SystemOverview
    ref S2 > DirectoryTree
    ref S3 > SearchFlow
    ref S4 > DomainModel
    ref S5 > Gotchas
}
```

## 書く時のコツ

### コードそのものをコピーしない

既存コード理解の図は「**どこに何があるか**」のインデックスであって、コードの複製ではない。ファイルパス・関数名・型名は書くが、実装本体は書かない。

```
// 良い
App2["apps/api/src/search/search.service.ts<br/>SearchService.search()"]

// 悪い (コードがそのまま書かれている)
App2["search(query: string) {<br/>  const hits = await this.es.search(...);<br/>  return this.rankingService.rank(hits);<br/>}"]
```

### 最新性の問題に対処

コードは変わり続けるため、ireko ファイルも古くなる。対策:

- **図に最終更新日を入れる** (例: `diagram DirectoryTree "ディレクトリ構成 (2025-11 時点)"`)
- **変更が速い部分は粒度を粗くする** (ファイル名ではなくモジュール名)
- **変更が遅い部分 (ドメイン概念・アーキテクチャ) は詳しく書く**

### 自分の疑問を残す

読んでいて「これ何でこうしてるんだろう」と思ったことは図に残す。後で分かったら更新、分からなければ他人に聞く際のネタになる:

```
diagram OpenQuestions "読んでいて分からなかったこと" {
  flowchart TB
    Q([未解明の疑問]) --> Q1["Q1: なぜ search.service は DI でなく<br/>new で生成されているのか?"]
    Q --> Q2["Q2: user.role の enum に 'legacy_admin' があるが<br/>どこで使われているか不明"]
}
```

### リポジトリに含めるかは目的次第

- **自分用メモ** → 個人のノート (Obsidian など) に置く
- **チーム共有** → `docs/architecture/` のような場所にコミット
- **README のリンクから辿れる場所** → オンボーディング資料として最強

## 検証

`reference/antipatterns.md` のチェックリストに加え、既存コード理解固有のチェック:

- [ ] 「このシステムが何をするか」が最初に書かれているか
- [ ] ファイルパスが具体的に記述されているか
- [ ] 罠・ハマりどころが書かれているか
- [ ] 読む順番が明示されているか (新メンバー向けの場合)
- [ ] コードのコピペになっていないか

## レガシーシステムを読む時の追加テクニック

### 歴史の背景を書く

「なぜこの設計になっているか」は、書かれた当時のコンテキストがある。git log や slack ログから拾って残すと後世のためになる:

```
diagram History "歴史的経緯" {
  flowchart TB
    H([この設計の背景]) --> H1["2020: マイクロサービス化の途中で中断<br/>→ services/ と legacy/ が併存"]
    H --> H2["2022: パフォーマンス問題で<br/>キャッシュ層を強制追加<br/>→ 一部のフローが複雑化"]
    H --> H3["今後: services/ 側に統合予定 (Q2)"]
}
```

### 「触らない方がいい」部分を明示

レガシーには「動いているが触ると壊れる」部分がある。それも書く:

```
diagram DangerZones "触らない方がいい部分" {
  flowchart TB
    Danger([危険地帯]) --> D1["legacy/payment/*<br/>テストなし・仕様書なし<br/>→ 触る前に必ず関係者に確認"]
    Danger --> D2["scripts/migrate-v1-v2.ts<br/>本番で一度だけ実行する想定<br/>→ 削除も注意"]
}
```
