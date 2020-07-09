---
title: Rust でコンパイル時/実行時定数を統一的に扱う
date: 2020-07-10
---

## モチベーション

[modint](https://noshi91.hatenablog.com/entry/2019/03/31/174006) を Rust でいい感じに実装したい！

## 方法

次のトレイトを実装する空の列挙型を作りディスパッチします．

```rust
trait Constant<T> {
  fn get() -> T;
}
```

### コンパイル時定数

`const` にすれば安心です．

```rust
enum C {}

impl Constant<u64> for C {
  fn get() -> u64 {
    const VALUE: u64 = 2020;
    VALUE
  }
}
```

### 実行時定数

thread local storage に置きます．

```rust
enum C {}

thread_local! {
  static VALUE: Cell<Option<u64>> = Cell::new(None);
}
VALUE.with(|val| val.set(2020));

impl Constant<u64> for C {
  fn get() -> u64 {
    VALUE.with(|val| val.get().expect("not yet initialized"))
  }
}
```

### 合体！

これらをマクロでラップします．

```rust
macro_rules! constant {
  () => {};
  (const $Name:ident: $T:ty = $val:expr; $($rest:tt)*) => {
    enum $Name {}

    impl Constant<$T> for $Name {
      fn get() -> $T {
        const VALUE: $T = $val;
        VALUE
      }
    }

    constant! { $($rest)* }
  };
  (static $Name:ident: $T:ty = $val:expr; $($rest:tt)*) => {
    enum $Name {}

    {
      thread_local! {
        static VALUE: Cell<Option<$T>> = Cell::new(None);
      }
      VALUE.with(|val| val.set(Some($val)));

      impl Constant<$T> for $Name {
        fn get() -> $T {
          VALUE.with(|val| val.get().expect("not yet initialized"))
        }
      }
    }

    constant! { $($rest)* }
  };
}
```

こんな感じで使えます．

```rust
// ライブラリ
fn mod_add<Mod: Constant<u64>>(x: u64, y: u64) -> u64 {
  let mut sum = x + y;
  if sum >= Mod::get() {
    sum -= Mod::get()
  }
  sum
}

// ライブラリを使う
// コンパイル時定数
fn solve1(x: u64, y: u64) -> u64 {
  constant! {
    const M: u64 = 998_244_353;
  }
  mod_add::<M>(x, y)
}
// 実行時定数
fn solve2(x: u64, y: u64, m: u64) -> u64 {
  constant! {
    static M: u64 = m;
  }
  mod_add::<M>(x, y)
}
```
