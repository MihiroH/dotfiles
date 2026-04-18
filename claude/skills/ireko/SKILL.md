---
name: ireko
description: Create, review, and maintain nested Mermaid diagrams in .ireko format. Trigger when the user mentions .ireko files, asks for nested diagrams that drill down from overview to detail, or wants to document concepts, system designs, or code walkthroughs as interactive diagrams. Also trigger when reviewing existing .ireko files for structural issues (cycle refs, shallow Why, overused flowchart, undefined refs).
---

# ireko — Nested Mermaid Diagrams

ireko ファイルは、Mermaid ダイアグラムを `ref` で入れ子にして「概念の全体像 → 深掘り」を表現するテキスト形式。ビルドするとクリックで子ダイアグラムへ遷移できる静的 HTML が出る。

このスキルは ireko を使って以下 4 種類のドキュメントを書く/レビューするためのもの:

1. **学習ノート** — ある概念を 5W1H で深掘る (例: Proxy, TLS, RDB のインデックス)
2. **設計ドキュメント** — システムやアーキテクチャの全体像と各コンポーネント詳細
3. **コードレビュー** — PR の変更内容を構造化して説明する
4. **既存コード理解** — コードベースを読み解いた結果をマップ化する

## 最初に判定する: どの用途か?

| ユーザーの言葉 | 用途 | 読むファイル |
|---|---|---|
| 「X について学びたい/まとめたい」「X の 5W1H」 | 学習ノート | `workflows/learning-notes.md` |
| 「X の設計ドキュメント」「アーキテクチャ図」「X を設計したい」 | 設計ドキュメント | `workflows/design-doc.md` |
| 「この PR を図で説明」「変更のレビュー資料」 | コードレビュー | `workflows/code-review.md` |
| 「このコードベースを読み解いて」「既存実装を図に」 | 既存コード理解 | `workflows/code-understanding.md` |

判定に迷ったら、成果物が「**読者が何度も参照する資料か (= 学習/設計)**」 vs 「**一度読まれて役目を終える資料か (= レビュー)**」で切り分ける。

## 共通原則 (どの用途でも守る)

### 1. ルートは「全体像」であり、枝葉はすべて ref で遅延する

ルートダイアグラムに情報を詰め込まない。ルートは「この先に何があるか」の目次として機能させ、詳細は子ダイアグラムに追いやる。**ルートが単独で意味を成す**こと。

### 2. ref は必ず一方向 (下向き) に統一する

親 → 子 の向きで ref を張る。**子 → 親 / 共通ハブへの戻り ref は絶対に張らない** (循環参照でビルドエラー)。戻りたくなるのは UX 上の欲求だが、ireko のパンくずで辿れるので不要。

### 3. 共通トピックはハブとして集約するが、片方向

`TLS` のような複数箇所で触れるトピックは共通ハブ (例: `TLSOverview`) を作り、そこから各詳細へ ref する。各詳細図から共通ハブへは ref しない。

### 4. Why から How への ref ブリッジを必ず張る

「なぜ使うのか」を説明する Why ダイアグラムの各目的から、それを実現する How の詳細ダイアグラムへ ref する。これにより読者が「目的 → 手段」を辿れる。

### 5. 図の種類は内容で選ぶ (flowchart 偏重を避ける)

詳しくは `reference/diagram-selection.md`。ざっくり:

- **flowchart** — 階層・分類・判定フロー (デフォルト候補だが乱用注意)
- **sequenceDiagram** — 時系列・プロトコル・通信
- **stateDiagram-v2** — 状態遷移・排他的な選択肢
- **classDiagram** — 属性比較・並列エンティティの対比
- **mindmap** — 気軽な発散 (最終成果物には非推奨)

### 6. ネストの深さは 3〜4 階層が目安

ルート → カテゴリ → 詳細 → (必要なら) 補足、まで。それ以上は読者が迷子になる。深くしたくなったら横に広げる (兄弟関係にする) ことを検討。

## ワークフロー: ファイルを作る時

1. ユーザーの意図を判定し、適切な `workflows/*.md` を `view` で読む
2. そのワークフローが指定するテンプレート (`templates/*.ireko`) を `view` で読む
3. テンプレートを下敷きに、ユーザーのトピックに合わせて埋めていく
4. 書き終わったら必ず `reference/antipatterns.md` の「提出前チェックリスト」で検証
5. 循環 ref・未定義 ref がないか軽くチェック (下記の検証スクリプト)

## ワークフロー: 既存ファイルをレビューする時

1. 対象の `.ireko` を `view` で読む
2. `reference/antipatterns.md` を `view` で読む
3. アンチパターンに該当する箇所をリストアップ
4. 構造的問題 (Why が浅い、flowchart 偏重、共通テーマの重複) を指摘
5. 修正案を提示

## 検証スクリプト (循環 ref と未定義 ref の検出)

ファイルを書いた/受け取った後、以下を実行して構造的な問題を検出する:

```python
import re, sys

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()

# 定義を抽出
defined = set(re.findall(r'^diagram\s+([A-Za-z_][A-Za-z0-9_]*)\s+"', content, re.MULTILINE))

# ref を抽出
refs = re.findall(r'^\s*ref\s+(.+?)\s*$', content, re.MULTILINE)
referenced = set()
for r in refs:
    target = r.split('>')[1].strip() if '>' in r else r.strip()
    referenced.add(target)

# 隣接リスト構築
blocks = re.findall(r'diagram\s+([A-Za-z_][A-Za-z0-9_]*)\s+"[^"]*"\s*\{(.*?)\n\}', content, re.DOTALL)
adj = {}
for name, body in blocks:
    children = []
    for r in re.findall(r'^\s*ref\s+(.+?)\s*$', body, re.MULTILINE):
        t = r.split('>')[1].strip() if '>' in r else r.strip()
        children.append(t)
    adj[name] = children

# 循環検出
def find_cycle(node, path, visited, cycles):
    if node in path:
        idx = path.index(node)
        cycles.append(path[idx:] + [node])
        return
    if node in visited:
        return
    for c in adj.get(node, []):
        find_cycle(c, path + [node], visited, cycles)
    visited.add(node)

cycles = []
visited = set()
for n in list(adj.keys()):
    find_cycle(n, [], visited, cycles)

print(f"定義: {len(defined)}")
print(f"未定義参照: {referenced - defined or 'なし'}")
print(f"循環: {cycles or 'なし'}")
```

`@root` が 1 つだけあること、循環 0、未定義参照 0 を確認する。

## ファイル一覧

### reference/ (いつ読むか: 文法/図選択/アンチパターンを確認する時)

- `syntax.md` — ireko 記法の要約
- `diagram-selection.md` — Mermaid 図の使い分けルール
- `antipatterns.md` — よくある失敗と提出前チェックリスト

### workflows/ (いつ読むか: 用途を判定した直後)

- `learning-notes.md`
- `design-doc.md`
- `code-review.md`
- `code-understanding.md`

### templates/ (いつ読むか: ワークフローの指示に従って)

- `learning-concept.ireko` — 5W1H で概念を深掘る
- `design-system.ireko` — システム設計を書く
- `review-walkthrough.ireko` — PR のレビュー資料
- `code-map.ireko` — 既存コードの構造マップ
