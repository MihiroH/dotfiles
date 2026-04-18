# ワークフロー: コードレビュー

PR の変更内容を ireko で説明し、レビュアーの理解を早めるためのワークフロー。
レビューコメントの代わりに使うのではなく、**大規模な PR や構造的な変更を説明する補助資料**として使う。

## 適用シーン

- 100 行を超える変更で、差分だけでは意図が伝わらない PR
- アーキテクチャレベルの変更 (コンポーネント追加、依存関係の組み替え)
- マイグレーション (スキーマ変更・API バージョンアップ)
- リファクタリング (機能は同じだが構造が変わる)

**使わないケース:**
- 小さなバグ修正 (差分と 1 行のコミットメッセージで十分)
- 純粋な typo 修正
- 設定ファイルの軽微な変更

## ステップ

### 1. レビュアーの視点で書く

コードレビュー資料は**自分の頭の整理ではなく、レビュアーが PR を理解する時間を短縮する**ためのもの。

レビュアーが知りたいのは順に:
1. **なぜこの変更が必要か** (なぜ今、これを変えるか)
2. **全体として何が変わるか** (変更の概要)
3. **主要な変更箇所** (どのファイル・関数・モジュールが変わったか)
4. **注意して見てほしい部分** (特にレビューしてほしい論点)
5. **動作確認の方法** (どう動くことを確認したか)

### 2. テンプレートを読む

`templates/review-walkthrough.ireko` を `view` で読む。

### 3. ルートは「PR の地図」

```
@root
diagram "PR #1234: ユーザー認証を OIDC に統合" {
  flowchart TB
    PR([PR #1234]) --> Why[なぜこの変更が必要か]
    PR --> Before[変更前]
    PR --> After[変更後]
    PR --> Changes[主要な変更点]
    PR --> Review[レビュー依頼事項]
    PR --> Test[動作確認]

    ref Why > Motivation
    ref Before > BeforeArch
    ref After > AfterArch
    ref Changes > ChangeList
    ref Review > ReviewPoints
    ref Test > TestResult
}
```

### 4. Before / After の対比を明示的に

構造変更の PR で最も効果的なのは、**Before と After を並べて見せる**こと:

```
diagram BeforeArch "変更前のアーキテクチャ" {
  flowchart TB
    C[Client] --> App[App Server]
    App --> DB[(MySQL)]
    App --> Custom[独自認証ロジック]
    Custom --> Users[(users table)]
}

diagram AfterArch "変更後のアーキテクチャ" {
  flowchart TB
    C[Client] --> RP[Reverse Proxy]
    RP --> OIDC[OIDC Provider]
    RP --> App[App Server]
    App --> DB[(MySQL)]

    Note1["認証責務を RP に移譲<br/>App は X-User-Id ヘッダを信頼するだけ"]
}
```

または 1 つの図に並置:

```
diagram BeforeAfter "Before / After" {
  flowchart LR
    subgraph Before["Before"]
      B1[Client] --> B2[App + 認証]
      B2 --> B3[(DB)]
    end

    subgraph After["After"]
      A1[Client] --> A2[RP + 認証]
      A2 --> A3[App]
      A3 --> A4[(DB)]
    end
}
```

### 5. 主要な変更点は「何が」「どこで」変わったか

ファイルや関数レベルの変更は flowchart TB で分類:

```
diagram ChangeList "主要な変更点" {
  flowchart TB
    Changes([変更点]) --> Added[追加]
    Changes --> Modified[修正]
    Changes --> Deleted[削除]

    Added --> A1["src/auth/oidc-handler.ts<br/>OIDC 認証ハンドラ"]
    Added --> A2["infra/gcp/lb-config.tf<br/>LB ルーティング設定"]

    Modified --> M1["src/middleware/auth.ts<br/>独自認証 → ヘッダ検証に変更"]
    Modified --> M2["src/routes/*.ts<br/>認証チェックの import を削除"]

    Deleted --> D1["src/auth/custom-auth.ts<br/>不要になった独自認証"]
    Deleted --> D2["test/auth/custom-auth.test.ts"]

    ref A1 > OIDCHandlerDesign
    ref M1 > AuthMiddlewareDiff
}
```

### 6. 主要フローの変化を sequence で

動作の変化は sequence diagram が最も伝わる:

```
diagram AuthFlow "認証フローの変化" {
  sequenceDiagram
    participant C as Client
    participant RP as Reverse_Proxy
    participant App as App
    participant OIDC as OIDC_Provider

    Note over C,OIDC: 変更後の新しいフロー

    C->>RP: GET /api/users (Cookie: session=...)
    RP->>RP: JWT の検証
    alt JWT 有効
      RP->>App: GET /api/users + X-User-Id
      App->>RP: 200 OK
      RP->>C: 200 OK
    else JWT なし
      RP->>C: 302 to OIDC
      C->>OIDC: ログイン
      OIDC->>C: Code
      C->>RP: Code で戻る
      RP->>OIDC: Code → Token 交換
      RP->>C: Set-Cookie + 302
    end
}
```

### 7. レビュー依頼事項を明示する

PR に求めるレビューの深さを明示すると、レビュアーが効率的に見られる:

```
diagram ReviewPoints "レビュー依頼事項" {
  flowchart TB
    Review([レビュー観点]) --> Must[必ず見てほしい]
    Review --> Nice[できれば見てほしい]
    Review --> Skip[今回は見なくて OK]

    Must --> M1["OIDC の state パラメータ検証<br/>CSRF 対策として正しいか"]
    Must --> M2["JWT 検証のエラーハンドリング<br/>401 で統一されているか"]

    Nice --> N1["リファクタされた auth-middleware<br/>命名やコメントの改善案"]

    Skip --> S1["既存テストのフォーマット修正<br/>大量の変更だが自動生成"]
}
```

### 8. 動作確認の結果を含める

```
diagram TestResult "動作確認" {
  flowchart TB
    Test([確認項目]) --> Unit[ユニットテスト: pass]
    Test --> E2E[E2E テスト: pass]
    Test --> Manual[手動確認]
    Test --> Load[負荷試験]

    Manual --> M1["ログイン → ダッシュボード表示 OK"]
    Manual --> M2["セッション切れ → 自動リダイレクト OK"]
    Manual --> M3["ログアウト → セッション破棄 OK"]

    Load --> L1["1000 RPS で P99 < 100ms"]
}
```

## 書く時のコツ

### 差分の量ではなく「論点の量」で判断する

500 行の PR でも機械的な変更 (API 名の一括リネームなど) なら資料は軽く、50 行でも構造的変更なら厚く。

### コードそのものはコピペしない

ireko は図であって、コードを貼り付ける場所ではない。コードは PR 側で見てもらう。資料では「どこ」「何が変わったか」を説明する。

### 依存関係の変化は特に丁寧に

新しい依存が増えたり、モジュール間の依存が変わった時は、Before/After の依存グラフを flowchart で見せる:

```
diagram DepChange "モジュール依存の変化" {
  flowchart TB
    subgraph Before["Before"]
      B_Route[routes] --> B_Auth[auth]
      B_Route --> B_Handler[handlers]
      B_Handler --> B_Auth
    end

    subgraph After["After"]
      A_Route[routes] --> A_Handler[handlers]
      A_Auth[auth] -.middleware.-> A_Route
    end
}
```

### リスクと mitigation を書く

大きな変更の場合、失敗時の影響と対策を書くと安心感が上がる:

```
diagram Risks "リスクと対策" {
  flowchart TB
    Risk([想定リスク]) --> R1[OIDC プロバイダのダウン]
    Risk --> R2[JWT 検証の性能劣化]
    Risk --> R3[既存セッションの移行失敗]

    R1 --> M1["mitigation: 一時的にレガシー認証にフォールバック<br/>feature flag で切り戻し可能"]
    R2 --> M2["mitigation: ローカルキャッシュ (1 分)<br/>負荷試験で閾値確認済み"]
    R3 --> M3["mitigation: 段階リリース<br/>全ユーザーを強制ログアウトせず自然移行"]
}
```

## 検証

`reference/antipatterns.md` のチェックリストに加え、レビュー資料固有のチェック:

- [ ] Before / After が明示されているか
- [ ] 変更の動機 (Why) が書かれているか
- [ ] レビュー依頼事項が明示されているか
- [ ] 動作確認の結果が書かれているか
- [ ] コードのコピペになっていないか (図であるべき)

## 公開のタイミング

PR 作成と同時に ireko ファイルも公開。ただし:

- **PR 本文にリンクを貼る** (`reverse-proxy-oidc.html` 等)
- **重要な図は PR 本文にも画像として貼る** (一部のレビュアーはリンクを踏まない)
- **マージ後は設計ドキュメントとして残すか判断**: 残す価値があれば `design-doc.md` のワークフローで整形し直す

## 成功パターンと失敗パターン

**成功パターン:**
- 新規メンバーが PR 概要から入れる
- レビューコメントが減る (資料で疑問が先に解消される)
- マージ後も「なぜこうなっているか」の記録として機能

**失敗パターン:**
- 資料が PR と同期していない (コード修正後に資料を更新し忘れ)
- 資料が冗長で読むより差分見た方が早い
- 「説明したい欲」が強く、レビュアーが不要な詳細まで書いている
