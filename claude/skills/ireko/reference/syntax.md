# ireko 記法リファレンス (要約)

より詳しくは公式 syntax-guide を参照。ここでは Claude Code が生成する時に必要な最小限をまとめる。

## ファイル構造

```
@root
diagram "ルートタイトル" {
  mermaid の本体
  ref ChildName
}

diagram ChildName "子のタイトル" {
  mermaid の本体
}
```

- `@root` はファイル全体で**ちょうど 1 つ**
- ルート図は識別子を省略できる (他の図は必須)
- 識別子は `[A-Za-z_][A-Za-z0-9_]*`

## ref の 2 形式

### スタンドアロン ref (新しいマーカーを挿入)

```
    ref TokenExchange
```

### アンカー付き ref (既存要素にドリルダウンを付ける)

```
    ref Day1 > TLSDetail
```

`flowchart` のノードや `sequenceDiagram` の participant に貼ると、そのノード/participant がクリック可能になる。

### 複数アンカー (sequence 限定)

```
    ref C,P > SharedDetail
```

Mermaid の `Note over C,P: ...` と同じ意味。複数 participant にまたがる Note になる。

## 書き方の規則

- ref は必ず行全体が `ref 識別子` または `ref 識別子 > 識別子` であること (前後に他のテキストを置けない)
- 先頭の空白は OK
- `{` はダイアグラムヘッダーの最後の行に置く (同じ行に本体を書かない)
- 本体は次の行から

## ファイルレベルのコメント

```
// これはコメント (ireko が無視)
@root
diagram "..." {
  sequenceDiagram
    // ← これは Mermaid に渡される (ireko は無視しない)
    A->>B: hello
}
```

## 文字列 (タイトル)

ダブルクォートで囲む。エスケープは `\"` と `\\` のみ。

```
diagram Foo "He said \"hello\"" { ... }
```

## エラーになる記述

| パターン | エラー |
|---|---|
| `@root` が 2 つ以上 | only one root allowed |
| `@root` がない | no root diagram |
| ref 先が定義されていない | undefined ref |
| ref が循環 (A → B → A) | cycle detected |
| 同じ識別子の diagram が 2 つ | duplicate diagram identifier |
| 自分自身を ref | diagram references itself |
| 非ルートで識別子省略 | only root may omit identifier |

## ビルド

```
npx ireko build path/to/file.ireko -o out/dir
```

`out/dir/index.html` を開けばそのまま動く (file:// でも可)。

## Mermaid 側の落とし穴

ireko は本体をそのまま Mermaid に渡すので、Mermaid の制約がそのまま来る。

| NG | OK |
|---|---|
| `Note over A: a; b; c` | `Note over A: a, b, c` |
| `A->>B: Token[]` | `A->>B: Token list` |
| participant 名にスペース | `participant C as Client Name` でエイリアス |
| ノードラベルに `<br>` | `<br/>` (閉じタグ必須) |
| classDiagram の `:` の前後に空白不足 | `+属性: 値` (コロン後に空白) |

## 図の種類の判定は本体の 1 行目

ireko は本体の 1 行目を見て図の種類を判定し、ref の変換方法を変える。つまり 1 行目は必ず `flowchart TB` や `sequenceDiagram` などの Mermaid 宣言にする (空行や注釈を先頭に置かない)。

| 本体 1 行目 | ref の変換先 |
|---|---|
| `sequenceDiagram` | `Note over <participant>: 🔍 タイトル` |
| `flowchart` / `graph` | 新ノード `__ref_ID__["🔍 タイトル"]` |
| `stateDiagram-v2` | `state "🔍 タイトル" as ID_ref` |
| `classDiagram` / その他 | `%% ref: ID` (コメント扱いだが動作はする) |

### アンカー付き ref の変換

| 本体 1 行目 | 変換先 | 見た目 |
|---|---|---|
| `flowchart` / `graph` | `click Anchor "#Target"` + スタイルクラス | 既存ノードがリンクに |
| `sequenceDiagram` | `Note over Anchor: 🔍 タイトル` | 指定 participant のノート |
| `stateDiagram-v2` | `state "🔍 タイトル" as Anchor_ref` | アンカー付きスタブ |
| その他 | `%% ref: Anchor > Target` | コメント |
