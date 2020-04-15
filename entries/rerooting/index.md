---
title: Rerooting (全方位木 DP) の気持ち
date: 2020-04-15
---

一から説明していますが，既に大まかには分かっている人向けです．二項演算で畳み込むタイプの中ではかなり汎用的^[辺に何かが乗っているときや，部分木の値を二項演算で潰す前に何らかの変換をしたい場合に対応できます．]だと思います．


## 解説

### 根付き木の畳み込み^[convolution ではなく，[fold](https://ja.wikipedia.org/wiki/%E9%AB%98%E9%9A%8E%E9%96%A2%E6%95%B0#fold) とか呼ばれるもの] (木 DP)

ここでいう根付き木とは，ひとまず，Haskell で書くと次のようになるデータ構造を指すことにします．

```haskell
data Tree v e = Tree v [(e, Tree v e)]
```

`v` は頂点に乗っている値の型，`e` は辺に乗っている値 (重みとか距離とか) の型です．根と，根に隣接する辺とその先の部分木の対のリスト^[今後，このリストの要素は順不同であると思う人 (つまり，リストではなく単なる集合であるべきと考える人) は，すぐ後に出てくるモノイドの条件に可換であることを付け加えてください．]が根付き木であると定義しました．

この `Tree v e` に，何も考えず fold を実装するなら次のようになると思います．

```haskell
foldTree :: (v -> [(e, a)] -> a) -> Tree v e -> a
foldTree f (Tree v t) =
  f v . map (\ (e, st) -> (e, foldTree f st)) $ t
```

`a` は部分木の値の型と言って良いでしょう．ここで，`f :: v -> [(e, a)] -> a` は，頂点の値と，辺とその先の部分木の値の対のリストを受け取って，部分木の値を返す仕事をしています．これをもう少し分解します．

```haskell
foldTree :: Monoid m => (v -> m -> a) -> (e -> a -> m) -> Tree v e -> a
foldTree f g (Tree v t) =
  f v . mconcat . map (\ (e, st) -> g e (foldTree f g st)) $ t
```

先ほど出てきたリストは，何かのモノイドの演算で concat することにしました．そのために，先ほどの `f` に対応する関数は，辺の値と部分木の値を受け取ってモノイドの要素を返す `g :: e -> a -> m` と，頂点の値とモノイドの要素を受け取って部分木の値を返す `f :: v -> m -> a` の二つになりました．

このアルゴリズムは，頂点数を $n$ として $\Theta(n)$ 時間で動作します^[`f` や `g`，モノイドの演算などはすべて定数時間で計算できるとします．]．

以下では，考える根付き木 $t$，部分木の値の集合 $A$，モノイド $M$，および $f : V \times M \to A$，$g : E \times A \to M$ を固定して，$\mathrm{val}(t)$ を上のように計算した $t$ の値とします．$M$ の二項演算を $\odot$，単位元を $1_M$ とします．$t$ の頂点数は十分大きいとします．


### Rerooting (全方位木 DP)

いったん根のことは忘れて，単なる (無向) 木として考えます．頂点数を $n$ とします．木は隣接リストとして持っているとし，頂点には $0$ から $n - 1$ の添字が振られているとして，それを頂点の値の代わりとします．

```rust
type Tree<E> = Vec<Vec<(E, usize)>>;
```

注意として，辺は双方向に同じ値のものが張ってあるとします．つまり，任意の頂点 `src`，`dst`，辺の値 `e`，添字 `i` について「`t[src][i] == (e, dst)` であるなら，ある `j` が存在して `t[dst][j] == (e, src)`」が成り立つとします．

頂点 $u$ と $v$ を繋ぐ辺が存在するとき，その値を $e_{u, v}$ ($= e_{v, u}$) とします．

木をこのように持つと，頂点を一つ指定することで，その頂点を根とする根付き木が一意に定まります．前述した通り，$v$ を根とする根付き木の値を $\mathrm{val}(v)$ とします．

また，そのような根付き木に対し，さらに頂点を一つ指定することで，その頂点を根とする部分木が一意に定まります．そのような部分木には，その根がもとの木の根と異なるときには，ちょうど一つだけ親となる頂点が存在するので，(部分木の) 根と親を決めることでも部分木は一意に定まります．そこで，$v$ を (部分木の) 根，$p$ を親としたときの部分木の値を $\mathrm{val}_p(v)$ とします．

$g\mathrm{val} _ {u}(v) = g(e_{u, v}, \mathrm{val}_{u}(v))$ とします．

さて，次の問題を考えます：すべての頂点 $v$ について，それぞれ $\mathrm{val}(v)$ を求めよ．すなわち，列 $(\mathrm{val}(v))_{v = 0}^{n - 1}$ を求めよ．

これは，上述した根付き木の畳み込みをすべての頂点について行えば $\Theta(n^2)$ ですが，これから説明する Rerooting と呼ばれるテクニックを用いることで $\Theta(n)$ に落ちます．

さて，まず任意の頂点を一つ選び，それを根とした根付き木を考えます．ここではそのような頂点として $0$ を選ぶことにします．この根付き木の畳み込みをして $\mathrm{val}(0)$ を求める気持ちで，_ついでに_，その過程で求まる部分木の値をすべてメモしておくことにします．

```default
generator next(tree, parent, root):
  for (e, dst) in tree[root]:
    if dst == parent:
      continue
    yield (e, dst)

procedure scanTree(tree, parent, root):
  acc <- 1
  for (e, dst) in next(tree, parent, root):
    scanTree(tree, root, dst)
    acc <- acc * g(e, val[root][dst])
  val[parent].insert(root, f(root, acc))
```

`scanTree(t, nil, 0)` を呼びます．これが終わった後には，`val[p].containsKey(v)` であれば `val[p][v]` に $\mathrm{val}_p(v)$ が入っています．`val[p].containsKey(v)` であることを $\mathrm{val}_p(v)$ は*計算済み*であると呼ぶことにします．

今，頂点 $0$ に隣接する任意の頂点 $v$ について，$\mathrm{val}_0(v)$ は計算済みです．ここで，そのような $v$ を一つ取って，$\mathrm{val}_v(0)$ を考えます．これはどのような値でしょうか？ 最初，頂点 $0$ は根だったので親を持ちませんでした．しかし今度は，頂点 $0$ に唯一の親 $v$ ができることになります．つまり，$\mathrm{val}_v(0)$ は，$\mathrm{val}(0)$ から $\mathrm{val}_0(v)$ を*取り除いた*値になっています．きちんと言うと，$\mathrm{val}(0) = f(0, \bigodot _{u \text{は} 0 \text{に隣接する}} g\mathrm{val}_0(u))$ であったことに注意して，$\mathrm{val}_v(0) = f(0, \bigodot _{u \text{は} 0 \text{に隣接する} \land u \ne v} g\mathrm{val}_0(u))$ であるということです．

以上を踏まえて，頂点 $0$ に隣接するすべての頂点 $v$ について，$\mathrm{val}_v(0)$ を求めることを考えます．頂点 $0$ に隣接する頂点の列を $(v_i)_{i = 0}^{\deg(0) - 1}$ とし，列 $(r_i)_{i = 0}^{\deg(0) - 1}$ を $r _{\deg(0) - 1} = 1_M$，$r_i = g\mathrm{val}_{0}(v _{i + 1}) \odot r _{i + 1} \ (i \lt \deg(0))$ で，列 $(l_i)_{i = 0}^{\deg(0) - 1}$ を $l_0 = 1_M$，$l_i = l_{i - 1} \odot g\mathrm{val}_{0}(v _{i - 1}) \ (i \gt 0)$ でそれぞれ定めます．これらは $\Theta(\deg(0))$ で計算できます．

今，任意の $i$ ($0 \le i \le \deg(0) - 1$) について，$f(0, l_i \odot r_i) = f(0, (\bigodot_{j = 0}^{i - 1} g\mathrm{val}_{0}(v_j)) \odot (\bigodot_{j = i + 1}^{\deg(0) - 1} g\mathrm{val}_{0}(v_j))) = \mathrm{val} _ {v_i}(0)$ です．$l_i$ と $r_i$ はすでに手に入っているので，これは $\Theta(1)$ で得られます．というわけで，$\Theta(\deg(0))$ で，頂点 $0$ に隣接するすべての頂点 $v$ について $\mathrm{val}_v(0)$ が得られました．

さらに，$f(0, l_{\deg(0) - 1} \odot g\mathrm{val}_{0}(v _ {\deg(0) - 1})) = \mathrm{val}(0)$ であることに注意してください．

ここでまたしても，頂点 $0$ に隣接する頂点 $v$ を一つ取ってきて，今度は $\mathrm{val}(v)$ を求めることを考えます．しかし，実は先程の頂点 $0$ の場合と状況は同じで，頂点 $v$ に隣接する任意の頂点 $u$ について，$\mathrm{val}_{v}(u)$ は計算済みです．なぜなら，最初の `scanTree(t, nil, 0)` が終わった段階では唯一計算済みでなかった $\mathrm{val}_v(0)$ は，たった今計算したからです．

というわけで，以上を適当なトポロジカル順序ですべての頂点に対して行えば，すべての頂点 $v$ について $\mathrm{val}(v)$ が求まります．全体の計算量は，それぞれの頂点 $v$ についての計算量を $T(v)$ とすると，$\Theta(\sum_{v = 0}^{n - 1} T(v))$ で，$T(v) \in \Theta(\deg(v))$ であったので $\Theta(n)$ です^[トポロジカルソートの計算量は $O(n)$ です．]．


## 実践

* [AtCoder Regular Contest 028 C - 高橋王国の分割統治](https://atcoder.jp/contests/arc028/tasks/arc028_3)

  * $A = \mathbb{N} \times \mathbb{N}$
    * 部分木の頂点数と「バランス値」
  * $M = \langle \mathbb{N}, + \rangle \times \langle \mathbb{N}, \max \rangle$
    * 部分木の頂点数と「バランス値」
  * $f(v, \langle n, b \rangle) = \langle n + 1, b \rangle$
  * $g(e, \langle n, b \rangle) = \langle n, n \rangle$

TODO: その他の例を加える


## 参考

* [もうひとつのるま式全方位木 DP - -!=x=!-](http://ecasd-qina.hatenablog.com/entry/2020/04/01/010818)
* [【全方位木DP】明日使える便利な木構造のアルゴリズム - Qiita](https://qiita.com/keymoon/items/2a52f1b0fb7ef67fb89e)
* [もうひとつの全方位木DP - ei1333の日記](https://ei1333.hateblo.jp/entry/2018/12/21/004022)
* [™ 🔰さんはTwitterを使っています 「全方位木DP（rerooting）をイラストにしました https://t.co/TFQsk0rkBL」 / Twitter](https://twitter.com/tmaehara/status/980787099472297985)
