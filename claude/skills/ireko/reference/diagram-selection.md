# Mermaid 図の使い分けルール

ireko では `ref` を使った階層化が主役だが、**各ノードで何の図を使うか**が理解度を決める。flowchart に偏ると情報密度が下がる。以下を意識して選ぶ。

## 判定フローチャート (テキスト版)

```
Q1. 時間の経過や相互作用を表現したい?
  YES → sequenceDiagram
  NO  → Q2

Q2. 排他的な状態/モード間の遷移を表現したい?
  YES → stateDiagram-v2
  NO  → Q3

Q3. 複数のエンティティの属性を並列比較したい?
  YES → classDiagram
  NO  → Q4

Q4. 階層・分類・判定ルート・データフロー?
  YES → flowchart
  NO  → Q5

Q5. とりあえず発散したい (下書き/ブレスト)?
  YES → mindmap (ただし最終成果物には使わない)
  NO  → 図ではなく文章で十分かも。図にしない選択肢も検討
```

## 各図のベストプラクティス

### flowchart — 構造・分類・判定

**使う時:**
- ツリー構造 (組織図・ディレクトリ構造・分類)
- 判定フロー (if/else の連続)
- データフロー (A が B に渡して B が C に渡す)
- 全体の入口となるトップレベル図 (= ref のハブ)

**使わない時:**
- 属性を比較したい (→ classDiagram)
- 時系列がある (→ sequenceDiagram)
- 状態が変わる (→ stateDiagram)
- 単なる箇条書き (→ 図ではなく prose で書く)

**方向の選び方:**
- `TB` (上→下): 階層・分類・判定フローの基本。読み順が明確
- `LR` (左→右): 時系列・パイプライン・対比 (Before/After)
- `BT` / `RL`: ほぼ使わない

**アンチパターン:**
- ノードから単なる説明テキストが 1 本だけ伸びる構造 (= 箇条書きの代替でしかない)
  → ref で子ダイアグラムへ飛ばすか、説明を親ノードに統合する
- 1 枚に 20 個以上のノード
  → 分割して ref で繋ぐ

**例:**

```
flowchart TB
    Req([リクエスト受信]) --> Auth{認証済み?}
    Auth -- No --> Block[407 返却]
    Auth -- Yes --> Allow[転送]
```

### sequenceDiagram — 時系列・通信・プロトコル

**使う時:**
- クライアント/サーバ間の通信 (HTTP, TLS handshake, OAuth flow)
- 処理の時系列 (この関数が呼ばれて、次にこれが呼ばれて、...)
- 複数 participant の相互作用

**使わない時:**
- 時系列がない静的な構造 (→ flowchart)
- 状態遷移が主役 (→ stateDiagram)

**participant 名のルール:**
- Mermaid は participant 名にスペースや記号を嫌うので `participant RP as Reverse_Proxy` のようにアンダースコアで繋ぐ
- as でエイリアスを付けるとシーケンス内で短く書ける

**Note over の活用:**
- 特定 participant の補足: `Note over RP: 復号処理`
- 範囲の補足: `Note over C,S: TLS ハンドシェイク完了`
- フェーズの区切りに有効

**alt/else の活用:**
- 分岐を明示的に表現: `alt キャッシュヒット / else キャッシュミス`
- 入れ子も可能だが 2 階層までに留める

**loop の活用:**
- ヘルスチェックなど繰り返し処理

**アンチパターン:**
- participant が 5 つ以上
  → 読み難い。機能単位で分割して ref
- メッセージ内にセミコロン `;` を使う
  → Mermaid が誤解釈する。カンマに置き換える
- participant 名に日本語や記号
  → `participant C as クライアント` のようにエイリアスで回避

**例:**

```
sequenceDiagram
    participant C as Client
    participant S as Server

    C->>S: GET /api
    alt 認証 OK
      S->>C: 200 OK + data
    else 認証 NG
      S->>C: 401 Unauthorized
    end
```

### stateDiagram-v2 — 状態遷移・排他的選択肢

**使う時:**
- オブジェクト/リソースの状態が時間で変わる (ヘルスチェック, Circuit Breaker)
- 3〜5 個程度の排他的な選択肢を並べる (ある時点ではどれか 1 つ)
- ライフサイクル (作成 → 使用中 → 削除)

**使わない時:**
- 動的な相互作用が主役 (→ sequenceDiagram)
- 単なる分類 (→ classDiagram か flowchart)

**書き方のコツ:**
- `[*] --> Initial` で開始状態を明示
- `Final --> [*]` で終了状態を明示
- 遷移ラベルに「いつ遷移するか」を書く: `Healthy --> Unhealthy: 連続 N 回失敗`
- `note right of X: ...` で各状態の補足を書ける

**「排他的な選択肢」の用法:**
flowchart で「A, B, C の 3 パターンがある」を表現するより、stateDiagram で `[*] --> A`, `[*] --> B`, `[*] --> C` と書いた方が「どれか 1 つ」が明確になる。

**アンチパターン:**
- 非排他的な並列状態を書く (→ flowchart のほうが適切)
- 状態数が 10 以上
  → 分割するか、上位の状態群にまとめる

**例:**

```
stateDiagram-v2
    [*] --> Closed

    Closed --> Open: 失敗率が閾値超過
    Open --> HalfOpen: クールダウン経過
    HalfOpen --> Closed: 試行成功
    HalfOpen --> Open: 試行失敗

    note right of Closed: 通常状態
    note right of Open: 遮断中
```

### classDiagram — 属性比較・並列対比

**使う時:**
- 複数のエンティティを属性で比較したい (L4 LB vs L7 LB, Forward vs Reverse)
- クラス図としての本来の用途 (継承・関連)
- 「比較表」を Mermaid で書きたい

**使わない時:**
- 関係性より動的な振る舞いが主役 (→ sequenceDiagram)
- 1 エンティティの属性を並べるだけ (→ flowchart か箇条書き)

**書き方のコツ:**
- `+属性: 値` の形式で属性を列挙 (`+` は public だが意味は気にしなくてよい)
- `note for ClassName "..."` で補足
- 2〜4 クラスを並べて対比するのが最も効果的

**継承・関連はあまり使わない:**
ireko で classDiagram を使うのはほぼ「**比較表**」の用途。UML 的な継承矢印は不要なことが多い。

**アンチパターン:**
- メソッドまで書き込む (情報過多)
- 比較対象が 1 つだけ (= ただのプロフィールカード。flowchart でいい)

**例:**

```
classDiagram
    class ForwardProxy {
      +配置: Client 側
      +隠すもの: Client の身元
      +HTTPS: CONNECT トンネル
      +例: Squid, Zscaler
    }
    class ReverseProxy {
      +配置: Server 側
      +隠すもの: Backend の構成
      +HTTPS: 終端/Passthrough/再暗号化
      +例: nginx, Envoy, ALB
    }

    note for ForwardProxy "Client 側の代理人"
    note for ReverseProxy "Server 側の代理人"
```

### mindmap — 発散・ブレスト

**使う時:**
- 初期の発散段階で「何を扱うか」を洗い出す
- カジュアルな整理

**使わない時:**
- 最終成果物 (→ flowchart TB のほうが構造が明確)
- 学習ノート (→ 順路が見えない)

**ireko での推奨:**
mindmap は構造が放射状なので「どこから読めばいいか」が分かり難い。ルート図を書く時は最初に mindmap で発散し、最終的に flowchart TB に書き直すのが良い。

**アンチパターン:**
- ルート図を mindmap のままリリース (proxies.ireko 改善前の状態)
  → 学習順序が伝わらない

## 図の選択クイック表

| 伝えたいこと | 第一選択 | 代替 |
|---|---|---|
| システム全体の構造 | flowchart TB | - |
| 階層/分類 | flowchart TB | - |
| 判定ルート (if-else チェーン) | flowchart TB | - |
| データフロー (A → B → C) | flowchart LR | sequenceDiagram |
| 2 つのものの対比 | classDiagram | flowchart (subgraph で左右並置) |
| 3〜5 つの排他的選択肢 | stateDiagram-v2 | flowchart TB |
| 時系列の通信 | sequenceDiagram | - |
| プロトコルハンドシェイク | sequenceDiagram | - |
| 状態遷移 (健全 → 不健全) | stateDiagram-v2 | - |
| ライフサイクル | stateDiagram-v2 | flowchart LR |
| Before / After | flowchart LR (subgraph) | classDiagram |
| 属性の比較表 | classDiagram | - |
| 判定の決定木 | flowchart TB | stateDiagram-v2 |
| メモリ/DB の構造 | flowchart TB | classDiagram |
| API のエンドポイント一覧 | classDiagram | flowchart TB |

## 「図にしない」という選択肢

以下は ireko のダイアグラムにせず、親ダイアグラムのノード内テキストや Note で十分:

- 3 つ以下の短い箇条書き
- 1 文で説明できる定義
- 「〜という概念」のような抽象語

逆に、以下は必ず独立した図にする:

- 複数ステップのフロー
- 比較対象があるもの
- 時系列や状態変化があるもの
- 他の複数箇所から ref したいもの (= 共通ハブ)
