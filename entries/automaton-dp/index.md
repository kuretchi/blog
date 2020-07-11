---
title: オートマトン上の DP (桁 DP の一般化)
date: 2020-07-10
---

桁 DP で解くことのできる多くの問題は，「条件○○を満たすすべての非負整数について，それぞれに○○を適用し，それらの和を求めよ」のような形式であり，多くの場合「条件○○」は「あるオートマトンが受理する」と言い換えることができます．その視点においては，桁 DP とはすなわちオートマトン上の DP である，ということになり，あらゆるオートマトンで動作する一般的なアルゴリズムが得られます．

## できること

ざっくりと：「オートマトン $A$ が与えられる．$A$ が受理するすべての長さ $n$ の文字列に対して，適当な $f$ をそれぞれに適用したのち，それらの和を求めよ」

正確に：次の問題を，時間計算量 $O(n \cdot \vert Q \vert \cdot \vert \Sigma \vert)$，空間計算量 $O(n \cdot \vert Q \vert)$ または $O(\vert Q \vert)$ で解きます．

入力：

* 決定性有限オートマトン (DFA) $A = \langle Q, \Sigma, \delta, q _ \text{init}, F \rangle$
* $n \in \mathbb{N}$
* 可換モノイド $\langle M, \oplus \rangle$ (単位元を $0 _ M$ とします)
* $e \in M$^[$\langle M, \oplus \rangle$ の単位元という意味ではないので注意してください．]
* $\odot : M \times \Sigma \rightarrow M$
  * ただし，分配法則：$\forall x, y \in M \, \forall c \in \Sigma \, \lbrack (x \oplus y) \odot c = (x \odot c) \oplus (y \odot c) \rbrack$ を満たす．

出力：$\bigoplus _ {s \in \mathrm{L}(A) \cap \Sigma^n} f(s)$

ただし，$\mathrm{L}(A)$ を $A$ が受理する文字列の全体とし，$f(s) = (((e \odot s _ 1) \odot s _ 2) \dots) \odot s _ {\vert s \vert}$ としました ($s _ i$ は $s$ の $i$ 番目の文字，$\vert s \vert$ は $s$ の長さ)．

$\epsilon$ を空文字列とし，以降，$e$ のことを $f(\epsilon)$ と書くことがあります．

## 理論

### ボトムアップ的な手法 (配る DP)

$dp(i, q)$ を，「$A$ に与えたとき最終的な遷移先が $q$ であるような長さ $i$ の文字列すべてに $f$ を適用し，$\oplus$ で [fold](https://ja.wikipedia.org/w/index.php?title=%E9%AB%98%E9%9A%8E%E9%96%A2%E6%95%B0&oldid=78331470#fold) した結果」とする気持ちで，次のように定義します．

$$
  \begin{align}
    dp(0, q) &= \begin{cases}
      0 _ M & (q \ne q _ \text{init}) \newline
      f(\epsilon) & (q = q _ \text{init})
    \end{cases} \newline
    dp(i, q) &= \bigoplus _ {\delta(p, c) = q} (dp(i - 1, p) \odot c) & (i \gt 0)
  \end{align}
$$

$\bigoplus _ {q \in F} dp(n, q)$ が求める答えです．これを DP で求めることで解けました．

証明：TODO

擬似コード：

1.  $\hspace{0em} \texttt{procedure}$
2.  $\hspace{1em} \texttt{for}\ i = 0\ \texttt{to}\ n$
3.  $\hspace{2em} \texttt{foreach}\ q \in Q$
4.  $\hspace{3em} \mathit{dp}\lbrack i \rbrack\lbrack q \rbrack \gets \texttt{if}\ i = 0 \land q = q _ \text{init}\ \texttt{then}\ f(\epsilon)\ \texttt{else}\ 0 _ M$
5.  $\hspace{1em} \texttt{for}\ i = 1\ \texttt{to}\ n$
6.  $\hspace{2em} \texttt{foreach}\ p \in Q$
7.  $\hspace{3em}\texttt{foreach}\ c \in \Sigma$
8.  $\hspace{4em} q \gets \delta(p, c)$
9.  $\hspace{4em} \mathit{dp}\lbrack i \rbrack\lbrack q \rbrack \gets \mathit{dp}\lbrack i \rbrack\lbrack q \rbrack \oplus (\mathit{dp}\lbrack i - 1 \rbrack\lbrack p \rbrack \odot c)$
10. $\hspace{1em} \mathit{acc} \gets 0 _ M$
11. $\hspace{1em} \texttt{foreach}\ q \in F$
12. $\hspace{2em} \mathit{acc} \gets \mathit{acc} \oplus \mathit{dp}\lbrack n \rbrack\lbrack q \rbrack$
13. $\hspace{1em} \texttt{return}\ \mathit{acc}$

### トップダウン的な手法 (貰う DP / メモ化再帰)

ここでのみ，$f(s) = (((e \odot s _ {\vert s \vert}) \odot s _ {\vert s \vert - 1}) \dots) \odot s _ 1$ とします．

$dp(i, q)$ を，「状態 $q$ の $A$ に与えたとき最終的な遷移先が受理状態であるような長さ $i$ の文字列すべてに $f$ を適用し，$\oplus$ で fold した結果」とする気持ちで，次のように定義します．

$$
  \begin{align}
    dp(0, q) &= \begin{cases}
      0 _ M & (q \notin F) \newline
      f(\epsilon) & (q \in F)
    \end{cases} \newline
    dp(i, q) &= \bigoplus _ {c \in \Sigma} (dp(i - 1, \delta(q, c)) \odot c) & (i \gt 0)
  \end{align}
$$

$\mathit{dp}(n, q _ \text{init})$ が求める答えです．これを DP で求めることで解けました．

証明：TODO

擬似コード：

1. $\hspace{0em} \texttt{procedure}$
2. $\hspace{1em} \texttt{foreach}\ q \in Q$
3. $\hspace{2em} \mathit{dp}\lbrack 0 \rbrack \lbrack q \rbrack \gets \texttt{if}\ q \notin F\ \texttt{then}\ 0 _ M\ \texttt{else}\ f(\epsilon)$
4. $\hspace{1em} \texttt{for}\ i = 1\ \texttt{to}\ n$
5. $\hspace{2em} \texttt{foreach}\ q \in Q$
6. $\hspace{3em} \mathit{dp}\lbrack i \rbrack\lbrack q \rbrack \gets 0 _ M$
7. $\hspace{3em} \texttt{foreach}\ c \in \Sigma$
8. $\hspace{4em} \mathit{dp}\lbrack i \rbrack \lbrack q \rbrack \gets \mathit{dp}\lbrack i \rbrack \lbrack q \rbrack \oplus \mathit{dp}\lbrack i - 1 \rbrack \lbrack \delta(q, c) \rbrack \odot c$
9. $\hspace{1em} \texttt{return}\ \mathit{dp}\lbrack n \rbrack \lbrack q _ \text{init} \rbrack$

または

1. $\hspace{0em} \texttt{function}\ \mathit{dp}(i, q)$
2. $\hspace{1em} \texttt{if}\ i = 0\ \texttt{then}$
3. $\hspace{2em} \texttt{return}\ \texttt{if}\ q \notin F\ \texttt{then}\ 0 _ M\ \texttt{else}\ f(\epsilon)$
4. $\hspace{1em} \mathit{acc} \gets 0 _ M$
5. $\hspace{1em} \texttt{foreach}\ c \in \Sigma$
6. $\hspace{2em} \mathit{acc} \gets \mathit{acc} \oplus (\mathit{dp}(i - 1, \delta(q, c)) \odot c)$
7. $\hspace{1em} \texttt{return}\ \mathit{acc}$
8. $\hspace{0em} \texttt{procedure}$
9. $\hspace{1em} \texttt{return}\ \mathit{dp}(n, q _ \text{init})$

ただし関数 $\mathit{dp}$ はメモ化すること．

## 実践

次の問題を，上の「ボトムアップ的な手法」で解いてみましょう．

> 正整数であって，その $10$ 進表記において桁の数字が増加と減少を交互に繰り返すようなものをジグザグ数とよぶ．
> $x$ 以下かつ $m$ の倍数であるようなすべてのジグザグ数の**総和**を $10^9 + 7$ で割った余りを求めよ．
>
> * $1 \le x \le 10^{500}$
> * $1 \le m \le 500$
>
> <cite>[ジグザグ数 (Zig-Zag Numbers)](https://onlinejudge.u-aizu.ac.jp/problems/0570) 改題 </cite>

$x$ の $10$ 進表記の桁数を $n$ とします．$x$ 以下の正整数は，leading zero を適当な個数加えることで，文字集合 $\Sigma = \lbrace 0, 1, \dots, 9 \rbrace$ 上の長さ $n$ の文字列と見ることができます．

「$x$ 以下 かつ $m$ の倍数であるようなジグザグ数」のみを受理する DFA を $A$ としましょう．まずは次の三つの DFA $A _ 1, A _ 2, A _ 3$ を考えます．

* $x$ 以下の正整数のみを受理する DFA $A _ 1 = \langle Q _ 1, \Sigma, \delta _ 1, {q _ \text{init}} _ 1, F _ 1 \rangle$
  * $Q _ 1 = \lbrace \mathtt{tight}, \mathtt{loose}, \mathtt{exceeded} \rbrace \times \lbrack n \rbrack$^[$\lbrack n \rbrack$ との直積を取ったことによって状態数が $n + 1$ 倍され，計算量のオーダーが悪化しそうに見えるかもしれませんが，これは簡単な枝刈りによって回避することができます．詳しくは実装を参照してください．]
    <!-- * 最上位からある桁まで見たときに，
      * $\texttt{tight}$：$x$ との大小関係が未確定．
      * $\texttt{loose}$：$x$ 未満であることが確定している．
      * $\texttt{exceeded}$：$x$ を超えることが確定している．
    * $\lbrack n \rbrack$ は今見ているのが何桁目かを表す． -->
  * $i < n$ のとき，
    * $\delta _ 1(\langle \mathtt{tight}, i \rangle, c) = \begin{cases}
      \langle \mathtt{loose}, i + 1 \rangle & (c < x _ {i + 1}) \newline
      \langle \mathtt{tight}, i + 1 \rangle & (c = x _ {i + 1}) \newline
      \langle \mathtt{exceeded}, i + 1 \rangle & (c > x _ {i + 1})
    \end{cases}$
    * $\delta _ 1(\langle \mathtt{loose}, i \rangle, c) = \langle \mathtt{loose}, i + 1 \rangle$
    * $\delta _ 1(\langle \mathtt{exceeded}, i \rangle, c) = \langle \mathtt{exceeded}, i + 1 \rangle$
  * $\delta _ 1(\langle q, n \rangle, c) = \langle \texttt{exceeded}, n \rangle$
  * ${q _ \text{init}} _ 1 = \langle \mathtt{tight}, 0 \rangle$
  * $F _ 1 = \lbrace \mathtt{tight}, \mathtt{loose} \rbrace \times \lbrack n \rbrack$

* $m$ の倍数のみを受理する DFA $A _ 2 = \langle Q _ 2, \Sigma, \delta _ 2, {q _ \text{init}} _ 2, F _ 2 \rangle$
  * $Q _ 2 = \lbrack m - 1 \rbrack$
  * $\delta _ 2(q, c) = (10q + c) \bmod m$
  * ${q _ \text{init}} _ 2 = 0$
  * $F _ 2 = \lbrace 0 \rbrace$

* ジグザグ数のみを受理する DFA $A _ 3 = \langle Q _ 3, \Sigma, \delta _ 3, {q _ \text{init}} _ 3, F _ 3 \rangle$
  * $Q _ 3 = \lbrace \mathtt{empty}, \mathtt{rejected} \rbrace \cup (\lbrace \mathtt{single}, \mathtt{increasing}, \mathtt{decreasing} \rbrace \times \Sigma)$
    <!-- * 最上位からある桁まで見たときに，
      * $\texttt{empty}$：一桁も見ていないか，見たすべての桁が $0$ (leading zero)．
      * $\texttt{single}$：一桁しか見ていない．
      * $\texttt{increasing}$：ジグザグ数の可能性があり，一つ上の桁は二つ上の桁より大きい．
      * $\texttt{decreasing}$：ジグザグ数の可能性があり，一つ上の桁は二つ上の桁より小さい．
      * $\texttt{rejected}$：ジグザグ数ではないことが確定している．
    * $\Sigma$ は一つ上の桁を表す． -->
  * $\delta _ 3(\mathtt{empty}, c) = \begin{cases}
  \mathtt{empty} & (c = 0) \newline
    \langle \mathtt{single}, c \rangle & (c \neq 0)
    \end{cases}$
  * $\delta _ 3(\langle \mathtt{single}, c _ \text{prev} \rangle, c) =
  \begin{cases}
    \langle \mathtt{increasing}, c \rangle & (c _ \text{prev} \lt c) \newline
    \mathtt{rejected} & (c _ \text{prev} = c) \newline
    \langle \mathtt{decreasing}, c \rangle & (c _ \text{prev} \gt c)
  \end{cases}$
  * $\delta _ 3(\langle \mathtt{increasing}, c _ \text{prev} \rangle, c) =
  \begin{cases}
    \mathtt{rejected} & (c _ \text{prev} \le c) \newline
    \langle \mathtt{decreasing}, c \rangle & (c _ \text{prev} \gt c)
  \end{cases}$
  * $\delta _ 3(\langle \mathtt{decreasing}, c _ \text{prev} \rangle, c) =
  \begin{cases}
    \langle \mathtt{increasing}, c \rangle & (c _ \text{prev} \lt c) \newline
    \mathtt{rejected} & (c _ \text{prev} \ge c)
  \end{cases}$
  * $\delta _ 3(\mathtt{rejected}, c) = \mathtt{rejected}$
  * ${q _ \text{init}} _ 3 = \mathtt{empty}$
  * $F _ 3 = Q _ 3 \setminus \lbrace \mathtt{empty}, \mathtt{rejected} \rbrace$

ただし，タイプライタ体で書いたものはすべて相異なる定数，$x _ i$ は $x$ の上から $i$ 桁目，$n \in \mathbb{N}$ について $\lbrack n \rbrack = \lbrace 0, 1, \dots, n \rbrace$ とします．

すると，$A = \langle Q, \Sigma, \delta, q _ \text{init}, F \rangle$ は次のように $A _ 1, A _ 2, A _ 3$ の intersection として書くことができます．

* $Q = Q _ 1 \times Q _ 2 \times Q _ 3$
* $\delta(\langle q _ 1, q _ 2, q _ 3 \rangle, c) = \langle \delta _ 1(q _ 1, c), \delta _ 2(q _ 2, c), \delta _ 3(q _ 3, c) \rangle$
* $q _ \text{init} = \langle {q _ \text{init}} _ 1, {q _ \text{init}} _ 2, {q _ \text{init}} _ 3 \rangle$
* $F = F _ 1 \times F _ 2 \times F _ 3$

あとは，$f(s)$ が文字列 $s$ の正整数としての値を返すようにして，$\oplus$ でそれらの和を取る気持ちでいきますが，そのままだと分配法則を満たさないため次のように工夫^[区間加算更新+区間和取得の遅延伝播セグメント木などを参照するとよいです．]をします．

* $M = \mathbb{Z}/(10^9 + 7)\mathbb{Z} \times \mathbb{N}$
* $\langle x, n \rangle \oplus \langle y, m \rangle = \langle x + y, n + m \rangle$
* $e = \langle 0, 1 \rangle$
* $\langle x, n \rangle \odot c = \langle 10 x + c n, n \rangle$

これが分配法則を満たすことは簡単に確かめられます．以上で解けました．

実装 (Rust)：

今回は紹介しなかった，エラー状態を利用した枝刈りなどが入っています．

```rust
use std::{cmp::Ordering::*, collections::HashMap, hash::Hash, mem};

trait Monoid {
  fn op(&self, rhs: &Self) -> Self;
  fn identity() -> Self;
}

// モノイドの直積
impl<T0: Monoid, T1: Monoid> Monoid for (T0, T1) {
  fn op(&self, rhs: &Self) -> Self {
    (self.0.op(&rhs.0), self.1.op(&rhs.1))
  }

  fn identity() -> Self {
    (T0::identity(), T1::identity())
  }
}

const MOD: u64 = 1_000_000_007;

// モノイド (ℤ/(10^9 + 7)ℤ, +)
#[derive(Clone)]
struct ModSum(u64);

impl Monoid for ModSum {
  fn op(&self, rhs: &Self) -> Self {
    ModSum((self.0 + rhs.0) % MOD)
  }

  fn identity() -> Self {
    ModSum(0)
  }
}

trait Dfa {
  type Char;
  type State;

  fn initial_state(&self) -> Option<Self::State>;
  fn next_state(&self, state: &Self::State, c: &Self::Char) -> Option<Self::State>;
  fn is_accept_state(&self, state: &Self::State) -> bool;
}

fn automaton_dp<A, M>(
  dfa: A,
  sigma: impl Iterator<Item = A::Char> + Clone,
  len: usize,
  mut mul: impl FnMut(&M, &A::Char) -> M,
  e: M,
) -> M
where
  A: Dfa,
  A::State: Eq + Hash,
  M: Monoid,
{
  let mut dp = HashMap::<A::State, M>::new();
  let mut dp_next = HashMap::<A::State, M>::new();

  if let Some(initial_state) = dfa.initial_state() {
    dp.insert(initial_state, e);
  }
  for _ in 0..len {
    for (state, value) in dp.drain() {
      for c in sigma.clone() {
        if let Some(next_state) = dfa.next_state(&state, &c) {
          let value = mul(&value, &c);
          dp_next
            .entry(next_state)
            .and_modify(|acc| *acc = acc.op(&value))
            .or_insert(value);
        }
      }
    }
    mem::swap(&mut dp, &mut dp_next);
  }

  let mut acc = M::identity();
  for (state, value) in dp {
    if dfa.is_accept_state(&state) {
      acc = acc.op(&value);
    }
  }
  acc
}

// DFA の intersection
struct And<A0, A1>(A0, A1);

impl<A0, A1> Dfa for And<A0, A1>
where
  A0: Dfa,
  A1: Dfa<Char = A0::Char>,
{
  type Char = A0::Char;
  type State = (A0::State, A1::State);

  fn initial_state(&self) -> Option<Self::State> {
    match (self.0.initial_state(), self.1.initial_state()) {
      (Some(st0), Some(st1)) => Some((st0, st1)),
      _ => None,
    }
  }

  fn next_state(&self, state: &Self::State, c: &Self::Char) -> Option<Self::State> {
    match (
      self.0.next_state(&state.0, c),
      self.1.next_state(&state.1, c),
    ) {
      (Some(st0), Some(st1)) => Some((st0, st1)),
      _ => None,
    }
  }

  fn is_accept_state(&self, state: &Self::State) -> bool {
    self.0.is_accept_state(&state.0) && self.1.is_accept_state(&state.1)
  }
}

// ある整数以下のみ受理する DFA
struct Le<'a>(&'a [u8]);

#[derive(Clone, PartialEq, Eq, Hash)]
struct LeState {
  i: usize,
  tight: bool,
}

impl Dfa for Le<'_> {
  type Char = u8;
  type State = LeState;

  fn initial_state(&self) -> Option<Self::State> {
    Some(LeState { i: 0, tight: true })
  }

  fn next_state(&self, state: &Self::State, c: &Self::Char) -> Option<Self::State> {
    (self.0.get(state.i))
      .and_then(|upper| match (state.tight, c.cmp(upper)) {
        (false, _) => Some(false),
        (true, Less) => Some(false),
        (true, Equal) => Some(true),
        (true, Greater) => None,
      })
      .map(|tight| LeState {
        i: state.i + 1,
        tight,
      })
  }

  fn is_accept_state(&self, _: &Self::State) -> bool {
    true
  }
}

// ある整数の倍数のみ受理する DFA
struct MultipleOf(u64);

impl Dfa for MultipleOf {
  type Char = u8;
  type State = u64;

  fn initial_state(&self) -> Option<Self::State> {
    Some(0)
  }

  fn next_state(&self, state: &Self::State, c: &Self::Char) -> Option<Self::State> {
    Some((10 * *state + u64::from(*c)) % self.0)
  }

  fn is_accept_state(&self, state: &Self::State) -> bool {
    *state == 0
  }
}

// ジグザグ数のみ受理する DFA
struct ZigZag;

#[derive(Clone, PartialEq, Eq, Hash)]
enum ZigZagState {
  Empty,
  Single(u8),
  Increasing(u8),
  Decreasing(u8),
}

impl Dfa for ZigZag {
  type Char = u8;
  type State = ZigZagState;

  fn initial_state(&self) -> Option<Self::State> {
    Some(ZigZagState::Empty)
  }

  fn next_state(&self, state: &Self::State, c: &Self::Char) -> Option<Self::State> {
    use ZigZagState::*;

    match state {
      Empty => match *c {
        0 => Some(Empty),
        _ => Some(Single(*c)),
      },
      Single(c_prev) => match c_prev.cmp(c) {
        Less => Some(Increasing(*c)),
        Equal => None,
        Greater => Some(Decreasing(*c)),
      },
      Increasing(c_prev) => match c_prev.cmp(c) {
        Less | Equal => None,
        Greater => Some(Decreasing(*c)),
      },
      Decreasing(c_prev) => match c_prev.cmp(c) {
        Less => Some(Increasing(*c)),
        Equal | Greater => None,
      },
    }
  }

  fn is_accept_state(&self, state: &Self::State) -> bool {
    !matches!(state, ZigZagState::Empty)
  }
}

fn solve(x: &[u8], m: u64) -> u64 {
  let (ModSum(ans), _) = automaton_dp(
    And(And(Le(&x), MultipleOf(m)), ZigZag),
    0..=9,
    x.len(),
    |&(ModSum(x), ModSum(n)), &c| (ModSum((10 * x + u64::from(c) * n) % MOD), ModSum(n)),
    (ModSum(0), ModSum(1)),
  );
  ans
}
```

この問題特有の部分 (ジグザグ数を受理する DFA) が，その他の汎用的な部分から分離されていることが分かると思います．この汎用的な部分をライブラリにしておけば，実際に問題を解くときにはその問題特有の DFA を実装するだけでよいことになり，煩雑になりがちな桁 DP の実装を回避することができます．

## 参考

* [algorithm/digit_dp.cc at master · spaghetti-source/algorithm](https://github.com/spaghetti-source/algorithm/blob/4fdac8202e26def25c1baf9127aaaed6a2c9f7c7/dynamic_programming/digit_dp.cc)
