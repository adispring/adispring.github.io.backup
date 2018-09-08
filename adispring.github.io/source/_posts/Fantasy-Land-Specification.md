---
title: Fantasy-Land-Specification
date: 2018-09-08 16:45:36
tags:
---
(又名 "代数 JavaScript 规范")

该项目规定了通用代数数据结构的互操作性：

* [Setoid](#setoid)
* [Ord](#ord)
* [Semigroupoid](#semigroupoid)
* [Category](#category)
* [Semigroup](#semigroup)
* [Monoid](#monoid)
* [Group](#group)
* [Filterable](#filterable)
* [Functor](#functor)
* [Contravariant](#contravariant)
* [Apply](#apply)
* [Applicative](#applicative)
* [Alt](#alt)
* [Plus](#plus)
* [Alternative](#alternative)
* [Foldable](#foldable)
* [Traversable](#traversable)
* [Chain](#chain)
* [ChainRec](#chainrec)
* [Monad](#monad)
* [Extend](#extend)
* [Comonad](#comonad)
* [Bifunctor](#bifunctor)
* [Profunctor](#profunctor)

[dependencies](#dependencies)

概览
代数是遵循一定法则的、具有封闭性的，一系列值及一系列操作的集合。

每个 Fantasy Land 代数是一个单独的规范。一个代数可能依赖于其他必需实现的代数。

术语
"值"：任何 JavaScript 值，包括下面定义的结构的任何值。

"等价"：对给定值的等价性的恰当定义。这个定义应该保证两个值可以在其对应的抽象的程序中，能够安全地进行交换。例如：

当两个列表对应的索引上的值都相等时，它们是等价的。
当两个普通的 JavaScript 对象所有键值对都相等时，它们（作为字典）是等价的。
当两个 promises 生成相等的值时，它们是等价的。
当两个函数给定相同的输入，产生相同的输出时，它们是等价的。
类型签名符号
本文档使用的类型签名符号如下所述：[^1]

:: "是 xx 的成员"。
e :: t 读作："表达式 e 是类型 t 的成员"。
true :: Boolean - "true 是类型 Boolean 的成员"。
42 :: Integer, Number - "42 是类型 Integer 和 Number 的成员"。
新类型可以通过类型构造函数创建。
类型构造函数可以接受零或多个类型参数。
Array 是一个接受单个参数的类型构造函数。
Array String 代表包含字符串的数组的类型。后面每个都是 Array String 类型的：[]，['foo', 'bar', 'baz']。
Array (Array String) 代表包含字符串的数组的数组的类型。后面每个都是 Array (Array String) 类型的：[]，[[], []]， [[], ['foo'], ['bar', 'baz']]。
小写字母代表类型变量。
类型变量可以接受任何类型，除非受到类型约束的限制（参见下面的胖箭头）。
-> (箭头) 函数类型的构造函数
-> 是一个中缀构造函数，它接受两个类型参数，左侧参数为输入的类型，右侧参数为输出的类型。
-> 的输入类型可以通过一组类型创建出来，该函数接受零个或多个参数。其语法是：(<input-types>) -> <output-type>，其中 <input-types> 包含零个或多个 "逗号-空格" （,）分开的类型表示，对于一元函数，圆括号也可以省略。
String -> Array String 是一种接受一个 String 并返回一个 Array String 的函数的类型。
String -> Array String -> Array String 是一种函数类型，它接受一个 String 并返回一个函数，返回的函数接受一个 Array String 并返回一个 Array String。
(String, Array String) -> Array String 是一种函数类型，它接受一个 String 和 Aray String 作为参数，并返回一个 Array String 。
() -> Number 是一种不带输入参数，返回 Number 的函数类型。
~> (波浪形箭头) 方法类型的构造函数。
当一个函数是一个对象（Object）的属性时，它被称为方法。所有方法都有一个隐含的参数类型 - 它是属性所在对象的类型。
a ~> a -> a 是一种对象中方法的类型，它接受 a 类型的参数，并返回一个 a 类型的值。
=> (胖箭头) 表示对类型变量的约束。
在 a ~> a -> a（参见上面的波浪形箭头）中，a 可以为任意类型。半群 a => a ~> a -> a 会添加一个约束，使得类型 a 现在必须满足该半群的类型类。满足类型类意味着，须合法地实现该类型类指定所有函数/方法。
例如：

traverse :: Applicative f, Traversable t => t a ~> (TypeRep f, a -> f b) -> f (t b)
'------'    '--------------------------'    '-'    '-------------------'    '-----'
 '           '                               '      '                        '
 '           ' - type constraints            '      ' - argument types       ' - return type
 '                                           '
 '- method name                              ' - method target type
[^1]: 更多相关信息，请参阅 Sanctuary 文档中的 类型 部分。

前缀方法名
为了使数据类型与 Fantasy Land 兼容，其值必须具有某些属性。这些属性都以 fantasy-land/ 为前缀。例如：

//  MyType#fantasy-land/map :: MyType a ~> (a -> b) -> MyType b
MyType.prototype['fantasy-land/map'] = ...
在本文中，不使用前缀的名称，只是为了减少干扰。

为了方便起见，你可以使用 fantasy-land 包：

var fl = require('fantasy-land')

// ...

MyType.prototype[fl.map] = ...

// ...

var foo = bar[fl.map](x => x + 1)
类型表示 (JavaScript 中的构造函数？)
某些行为是从类型成员的角度定义的。而另外一些行为不需要类型成员。因此，某些代数需要一个类型来提供值层面上的表示（具有某些属性）。例如，Identity 类型可以提供 Id 作为其类型表示：Id :: TypeRep Identity。

如果一个类型提供了类型表示，那么这个类型的每个成员都必须有一个指向该类型表示的 contructor 属性。

代数
Setoid
a.equals(a) === true (自反性)
a.equals(b) === b.equals(a) (对称性)
如果 a.equals(b) 并且 b.equals(a)，则 a.equals(c) (传递性)
equals 方法
equals :: Setoid a => a ~> a -> Boolean
具有 Setoid 的值必须提供 equals 方法。equals 方法接受一个参数。

a.equals(b)
b 必须是相同 Setoid 的值
如果 b 不是相同的 Setoid，则 equals 的行为未指定（建议返回 false）。
equals 必须返回一个布尔值（true 或 false）。
Ord
实现 Ord 规范的值还必须实现 Setoid 规范。

a.lte(b) 或 b.lte(a) (完全性)
如果 a.lte(b) 且 b.lte(a)，则 a.equals(b) (反对称性)
如果 a.lte(b) 且 b.lte(c)，则 a.lte(c) (传递性)
lte 方法
lte :: Ord a => a ~> a -> Boolean
具有 Ord 的值必须提供 lte 方法。lte 方法接受一个参数：

a.lte(b)
b 必须是相同 Ord 的值。
如果 b 不是相同的 Ord，则 lte 的行为未指定 (建议返回 false)。
lte 必须返回布尔值（true 或 false）。
Semigroupoid
a.compose(b).compose(c) === a.compose(b.compose(c)) (结合性)
compose (组合)方法
compose :: Semigroupoid c => c i j ~> c j k -> c i k
具有 Semigoupoid 的值必须提供 compose 组合方法。compose 方法接受一个参数：

a.compose(b)
b 必须返回相同 Semigroupoid 规范。
如果 b 不是相同的 Semigroupoid，compose 的行为未指定。
compose 必须返回相同 Semigroupoid 的值。
Category
实现范畴规范的值还必须实现半群规范。

a.compose(C.id()) 等价于 a (右同一性)
C.id().compose(a) 等价于 a (左同一性)
id 方法
id :: Category c => () -> c a a
具有范畴的值必须在其类型表示中提供一个 id 函数。

C.id()
给定值 c，可以通过 contructor 属性来访问其类型表示：

c.constructgor.id()
id 必须返回相同范畴的值。
Semigroup
a.concat(b).concat(c) 等价于 a.concat(b.concat(c)) （结合性）
concat 方法
concat :: Semigroup a => a ~> a -> a
具有 Semigroup 的值必须提供 concat 方法。concat 方法接受一个参数：

s.concat(b)
b 必须是相同 Semigroup 的值
如果 b 不是相同的 Semigroup，则 concat 的行为未指定。
concat 必须返回相同 Semigroup 的值。
Monoid
实现 Monoid 规范的值还必须实现 Semigroup 规范

m.concat(M.empty()) 等价于 m (右结合性)
M.empty().concat(m) 等价于 m (左结合性)
empty 方法
empty :: Monoid m => () -> m
具有 Monoid 的值必须在其类型表示上提供 empty 方法：

M.empty()
给定值 m，可以通过 constructor 属性来访问其类型表示。

m.constructor.empty()
empty 必须返回相同 Monoid 的值。
Group
实现 Group 规范的值还必须实现 Monoid 规范。

g.concat(g.invert()) 等价于 g.constructor.empty() (右反转性??)
g.invert().concat(g) 等价于 g.constructor.empty() (左翻转性??)
invert 方法
invert :: Group g => g ~> () -> g
具有 Semigroup 的值必须提供 invert 方法。invert 方法接受零个参数：

g.invert()
invert 必须返回相同 Group 的值。
Filterable
v.filter(x => p(x) && q(x)) 等价于 v.filter(p).filter(q) (分配性)
v.filter(x => true) 等价于 v (同一性)
v.filter(x -> false) 等价于 w.filter(x => false)，如果 v 和 w 具有相同的 Filterable 值 (湮灭??)
filter 方法
filter :: Filterable f => f a ~> (a -> Boolean) -> f a
具有 Filterable 的值必须提供 filter 方法。filter 方法接受一个参数：

v.filter(p)
p 必须是一个函数。
如果 p 不是函数，则 filter 的行为未指定。
p 必须返回 ture 或 false。如果返回任何其它值，filter 的行为未指定。
filter 必须返回相同 Filterable 的值。
Functor
u.map(a => a) 等价于 u (同一性)
u.map(x => f(g(x))) 等价于 u.map(g).map(f) (组合性)
map 方法
map :: Functor f => f a ~> (a -> b) -> f b
具有 Functor 的值必须提供 map 方法。map 方法接受一个参数：

u.map(f)
f 必须是一个函数，
如果 f 不是函数，则 map 的行为未指定。
f 可以返回任何值。
f 返回值的任何部分都不应该被检查(??)。
map 必须返回相同 Functor 的值。
Contravariant
u.contramap(a => a) 等价于 u (同一性)
u.contramap(x => f(g(x))) 等价于 u.contramap(f).contramap(g) (组合性)
contramap 方法
contramap :: Contravariant f => f a ~> (b -> a) -> f b
具有 Contravariant 的值必须提供 contramap 方法。contramap 方法接受一个参数：

u.contramap(f)
f 必须是一个函数，
如果 f 不是函数，则 contramap 的行为未指定。
f 可以返回任何值。
f 返回值的任何部分都不应该被检查(??)。
contramap 必须返回相同 Contravariant 的值。
Apply
实现 Apply 规范的值还必须实现 Functor 规范。

v.ap(u.ap(a.map(f => g => x => f(g(x))))) 等价于 v.ap(u).ap(a) (组合型)，推导过程??
ap 方法
ap :: Apply f => f a ~> f (a -> b) -> f b
具有 Apply 的值必须提供 ap 方法。ap 方法接受一个参数：

a.ap(b)
b 必须是一个函数的 Apply
如果 b 不代表函数，则 ap 的行为未指定。
b 必须与 a 具有相同的 Apply。
a 可以是任意值的 Apply。(??)
ap 必须能将 Apply b 内的函数应用于 Apply a 的值上
函数返回值的任何部分都不应该被检查。
由 ap 返回的 Apply 必须与 a 和 b 的相同。
Applicative
实现 Applicative 规范的值还必须实现 Apply 规范。

v.ap(A.of(x => x)) 等价于 v (同一性)
A.of(x).ap(A.of(f)) 等价于 A.of(f(x)) (同态性, homomorphism)
A.of(y).ap(u) 等价于 u.ap(A.of(f => f(y))) (交换性)
of 方法
of :: Applicative f => a -> f a
具有 Applicative 的值必须在其类型表示中提供 of 函数。of 函数接受一个参数：

F.of(a)
给定值 f，可以通过 contructor 属性访问其类型表示：

f.contructor.of(a)
of 必须提供相同的 Applicative
a 的任何部分都不应该被检查
Alt
实现 Alt 规范的值还必须实现 Functor 规范。

a.alt(b).alt(c) 等价于 a.alt(b.alt(c)) (结合性)
a.alt(b).map(f) 等价于 a.map(f).alt(b.map(f)) (分配性) (看起来像乘法，有什么实际用途呢？)
alt 方法
alt :: Alt f => f a ~> f a -> f a
具有 Alt 的值必须提供 alt 方法。alt 方法接受一个参数：

a.alt(b)
b 必须是相同 Alt 的值
如果 b 不是相同的 Alt，则 alt 的行为未指定。
a 和 b 可以包含相同类型的任何值。
a 和 b 包含值的任何部分都不应该被检查。
alt 必须返回相同 Alt 的值。
Plus
实现 Plus 规范的值还必须实现 Alt 规范。

x.alt(A.zero()) 等价于 x (右同一性)
A.zero().alt(x) 等价于 x (左同一性)
A.zero().map(f) 等价于 A.zero() (湮灭??)
zero 方法
zero :: Plus f => () -> f a
具有 Plus 的值必须在其类型表示中提供 zero 函数：

A.zero()
给定值 x，可以通过 contructor 属性访问其类型表示：

x.contructor.zero()
zero 必须返回相同 Plus 的值。
Alternative
实现 Alternative 规范的值还必须实现 Applicative 和 Plus 规范。

x.ap(f.alt(g)) 等价于 x.ap(f).alt(x.ap(g)) (分配性)
x.ap(A.zero()) 等价于 A.zero() (湮灭)
Foldable
u.reduce 等价于 u.reduce((acc, x) => acc.concat([x]), []).reduce
reduce 方法

reduce :: Foldable f => f a ~> ((b, a) -> b, b) -> b
具有 Foldable 的值必须在其类型表示中提供 reduce 函数。reduce 函数接受两个参数：

u.reduce(f, x)
f 必须是一个二元函数
如果 f 不是函数，则 reduce 的行为未指定。
f 的第一个参数类型必须与 x 的相同。
f 的返回值类型必须与 x 的相同。
f 返回值的任何部分都不应该被检查。
x 是归约的初始累积值
x 的任何部分都不应该被检查
Traversable
实现 Traversable 规范的值还必须实现 Functor 和 Foldable 规范。

对于任意 t，t(u.traverse(F, x => x)) 等价于 u.traverse(G, t) ，因为 t(a).map(f) 等价于 t(a.map(f)) (自然性)
对于任意 Applicative F，u.traverse(F, F.of) 等价于 R.of(u) (同一性)
u.traverse(Compose, x => new Compose(x)) 等价于 new Compose(u.traverse(F, x => x).map(x => x.traverse(G, x => x)))，对下面定义的 Compose 和 任意 Applicatives F 和 G 都适用 (组合性)
var Compose = function(c) {
  this.c = c;
};

Compose.of = function(x) {
  return new Compose(F.of(G.of(x)));
};

Compose.prototype.ap = function(f) {
  return new Compose(this.c.ap(f.c.map(u => y => y.ap(u))))
};

Compose.prototype.map = function(f) {
  return new Compose(this.c.map(y => y.map(f)));
};
traverse 方法
traverse :: Applicative f, Traversable t => t a ~> (TypeRep f, a -> f b) -> f (t b)
具有 Traversable 的值必须提供 traverse 函数。traverse 函数接受两个参数：

u.traverse(A, f)
A 必须是一个 Applicative 的类型表示。
f 必须是一个返回值的函数
如果 f 不是函数，则 traverse 的行为未指定。
f 必须返回类型表示为 A 的值。
traverse 必须返回类型表示为 A 的值。
Chain
实现 Chain 规范的值还必须实现 Apply 规范。

m.chain(f).chain(g) 等价于 m.chain(x => f(x).chain(g)) (结合性)
chain 方法
chain :: Chain m => m a ~> (a -> m b) -> m b
具有 Chain 的值必须提供 chain 函数。chain 函数接受一个参数：

m.chain(f)
f 必须是一个返回值的函数
如果 f 不是函数，则 chain 的行为未指定。
f 必须返回相同 Chain 的值。
chain 必须返回相同 Chain 的值。
ChainRec
实现 ChainRec 规范的值还必须实现 Chain 规范。

M.chainRec((next, done, v) => p(v) ? d(v).map(done) : n(v).map(next), i) 等价于 function step(v) { return p(v) ? d(v) : n(v).chain(step); }(i) (等价性)
M.chainRec(f, i) 栈的用量必须是 f 自身栈用量的常数倍。
chainRec 方法
chainRec :: ChainRec m => ((a -> c), b -> c, a) -> m b
具有 ChainRec 的值必须在其类型表示中提供 chainRec 函数。chainRec 函数接受两个参数：

M.chainRec(f, i)
给定值 m，可以通过 contructor 属性访问其类型表示：

m.constructor.chainRec(f, i)
f 必须是一个返回值的函数
如果 f 不是函数，则 chainRec 的行为未指定。
f 接受三个参数 next，done，value
next 是一个函数，其接受一个与 i 类型相同的参数，可以返回任意值
done 也是一个函数，其接受一个参数，并返回一个与 next 返回值类型相同的值
value 是一个与 i 类型相同的值。
f 必须返回一个相同 ChainRec 的值，其中包含的是从 done 或 next 返回的值。
chainRec 必须返回一个相同 ChainRec 的值，其中包含的值的类型与 done 的参数类型相同。
Monad
实现 Monad 规范的值还必须实现 Applicative 和 Chain 规范。

M.of(a).chain(f) 等价于 f(a) (左同一性)
m.chain(M.of) 等价于 m (右同一性)
Extend
实现 Extend 规范的值还必须实现 Functor 规范。

w.extend(g).extend(f) 等价于 w.extend(\_w => f(\_w.extend(g)))
extend 方法
extend :: Extend w => w a ~> (w a -> b) -> w b
具有 Extend 的值必须提供 extend 函数。extend 函数接受一个参数：

w.extend(f)
f 必须是一个返回值的函数，

如果 f 不是函数，则 extend 的行为未指定。
f 必须返回一个 v 类型的值，其中 v 是 w 中包含的某个变量 v (??)
f 返回值的任何部分都不应该被检查。
extend 必须返回相同 Extend 的值。

Comonad
实现 Comonad 规范的值还必须实现 Extend 规范。

w.extend(_w => _w.extract()) 等价于 w (左同一性)
w.extend(f).extract() 等价于 f(w) (右同一性)
extract 方法
具有 Comonad 的值必须提供 extract 函数。extract 函数接受零个参数：

w.extract()
extract 必须返回一个 v 类型的值，其中 v 是 w 中包含的某个变量 v (??)
v 必须与在 extend 中的 f 返回的类型相同。
Bifunctor
实现 Bifunctor 规范的值还必须实现 Functor 规范。

p.bimap(a => a, b => b) 等价于 p (同一性)
p.bimap(a => f(g(a)), b => h(i(b))) 等价于 p.bimap(g, i).bimap(f, h) (组合性)
bimap 方法
bimap :: Bifunctor f => f a c ~> (a -> b, c -> d) -> f b d
具有 Bifunctor 的值必须提供 bimap 函数。bimap 函数接受两个参数：

c.bimap(f, g)
f 必须是一个返回值的函数，

如果 f 不是函数，则 bimap 的行为未指定。
f 可以返回任意值
f 返回值的任何部分都不应该被检查。
g 必须是一个返回值的函数，

如果 g 不是函数，则 bimap 的行为未指定。
g 可以返回任意值
g 返回值的任何部分都不应该被检查。
bimap 必须返回相同 Bifunctor 的值。

Profunctor
实现 Profunctor 规范的值还必须实现 Functor 规范。

p.promap(a => a, b => b) 等价于 p (同一性)
p.promap(a => f(g(a)), b => h(i(b))) 等价于 p.promap(f, i).promap(g, h) (组合性)
promap 方法
promap :: Profunctor p => p b c ~> (a -> b, c -> d) -> p a d
f 必须是一个返回值的函数，

如果 f 不是函数，则 promap 的行为未指定。
f 可以返回任意值
f 返回值的任何部分都不应该被检查。
g 必须是一个返回值的函数，

如果 g 不是函数，则 promap 的行为未指定。
g 可以返回任意值
g 返回值的任何部分都不应该被检查。
promap 必须返回相同 Profunctor 的值。

推导
当创建满足多个代数的数据类型是，作者可以选择实现某些方法，然后推导出剩余的方法。推导：

equals 可以由 lte 推导出：
function(other) { retrun this.lte(other) && other.lte(this) }
map 可以由 ap 和 of 推导出：
function(f) { return this.ap(this.of(f))}
map 可以由 chain 和 of 推导出：
function(f) { return this.chain(a => this.of(f(a))); }
map 可以由 bimap 推导出 (??)：
function(f) { return this.bimap(a => a, f); }
map 可以由 promap 推导出：
function(f) { return this.promap(a => a, f); }
ap 可以由 chain 推导出：
function(m) { return m.chain(f => this.map(f)); }
reduce 可以由下列推导出：
function(f, acc) {
  function Const(value) {
    this.value = value;
  }
  Const.of = function(\_) {
    return new Const(acc);
  }
  Const.prototype.map = function(\_) {
    return this;
  }
  Const.prototype.ap = function(b) {
    return new Const(f(b.value, this.value));
  }
  return this.traverse(x => new Const(x), Const.of).value;
}
map 的推导如下：

function(f) {
  function Id(value) {
    this.value = value;
  }
  Id.of = function(x) {
    return new Id(x);
  }
  Id.prototype.map = function(f) {
    return new Id(f(b.value));
  }
  Id.prototype.ap = function(b) {
    return new Id(this.value(b.value));
  }
  return this.traverse(x => Id.of(f(x)), Id.of).value;
}
filter 可以由 of，chain 和 zero 推导出：
function(pred) {
  var F = this.constructor;
  return this.chain(x => pred(x) ? F.of(x) : F.zero());
}
filter 还可以由 concat，of，zero 和 reduce：

function(pred) {
  var F = this.constructor;
  return this.reduce((f, x) => pred(x) ? f.concat(F.of(x)) : f, F.zero());
}
注意
如果实现的方法和规则不止一种，应该选择一种实现，并为其他用途提供包装。
我们不鼓励重载特定的方法。那样会很容易造成崩溃和错误的行为。
建议对未指定的行为抛出异常。
在 internal/id.js 中提供了一个实现了许多方法的 Id 容器。
备选方案
此外，还存在一个 Static Land 规范，其思想与 Fantasy Land 完全相同，但是是基于静态方法而非实例方法。
