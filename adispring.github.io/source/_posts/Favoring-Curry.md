---
title: 爱上柯里化 (Favoring Curry)
date: 2017-06-27 07:49:41
categories: 'Ramda'
---

译者注：本文翻译自 [Scott Sauyet](https://github.com/CrossEye) 的 《[Favoring Curry](http://fr.umio.us/favoring-curry/)》，转载请与[原作者](https://github.com/CrossEye)或[本人](https://github.com/adispring)联系。下面开始正文。

---

我[最近一篇](http://fr.umio.us/why-ramda/) 关于 [Ramda](https://github.com/ramda/ramda) 函数式组合的文章阐述了一个重要的话题。为了使用 Ramda 函数做这种组合，需要这些函数是柯里化的。

Curry，咖喱？像是辣的食物？什么？在哪里？

实际上，`curry` 是为纪念 Haskell Curry 而命名的，他是第一个研究这种技术的人。（是的，人们还用他的姓氏--Haskell--作为一门函数式编程语言；不仅如此，Curry 的中间名字以 'B' 开头，代表 [Brainf*ck](http://en.wikipedia.org/wiki/Brainfuck)

柯里化将多参数函数转化一个新函数：当接受部分参数时，返回等待剩余参数的新函数。

原始函数看起来像是这样：

```js
// uncurried version
var formatName1 = function(first, middle, last) {
    return first + ' ' + middle + ' ' + last;
};
formatName1('John', 'Paul', 'Jones');
//=> 'John Paul Jones' // (Ah, but the musician or the admiral?)
formatName1('John', 'Paul');
//=> 'John Paul undefined');
```

但柯里化后的函数更有用：

```js
// curried version
var formatNames2 = R.curry(function(first, middle, last) {
    return first + ' ' + middle + ' ' + last;
});
formatNames2('John', 'Paul', 'Jones');
//=> 'John Paul Jones' // (definitely the musician!)
var jp = formatNames2('John', 'Paul'); //=> returns a function
jp('Jones'); //=> 'John Paul Jones' (maybe this one's the admiral)
jp('Stevens'); //=> 'John Paul Stevens' (the Supreme Court Justice)
jp('Pontiff'); //=> 'John Paul Pontiff' (ok, so I cheated.)
jp('Ziller'); //=> 'John Paul Ziller' (magician, a wee bit fictional)
jp('Georgeandringo'); //=> 'John Paul Georgeandringo' (rockers)
```

或这样：

```js
['Jones', 'Stevens', 'Ziller'].map(jp);
//=> ['John Paul Jones', 'John Paul Stevens', 'John Paul Ziller']
```

你也可以分多次传入参数，像这样：

```js
var james = formatNames2('James'); //=> returns a function
james('Byron', 'Dean'); //=> 'James Byron Dean' (rebel)
var je = james('Earl'); also returns a function
je('Carter'); //=> 'James Earl Carter' (president)
je('Jones'); //=> 'James Earl Jones' (actor, Vader)
```

（有些人会坚持认为我们正在做的应该叫作 "部分应用(partial application)"，"柯里化" 的返回函数应该每次只接受一个参数，该函数处理完后返回一个新的接受单参数的函数，直到所有必需的参数都已传入。他们可以坚持他们的观点，无所谓）

**好无聊啊...! 你能为我做什么呢？**

这里有一个稍有意义的示例。如果想计算一个数字集合的总和，可以这样：

```js
// Plain JS:
var add = function(a, b) {return a + b;};
var numbers = [1, 2, 3, 4, 5];
var sum = numbers.reduce(add, 0); //=> 15
```

而如果想编写一个通用的计算数字列表总和的函数，可以这样：

```js
var total = function(list) {
    return list.reduce(add, 0);
};
var sum = total(numbers); //=> 15
```

在 Ramda 中，`total` 和 `sum` 和上面的定义非常相似。可以这样定义 `sum`：

```js
var sum = R.reduce(add, 0, numbers); //=> 15
```

但由于 `reduce` 是柯里化函数，当你跳过最后一个参数时，就像在 `total` 中定义的那样：

```js
// In Ramda:
var total = R.reduce(add, 0);  // returns a function
```

将会获得一个可以调用的函数：

```js
var sum = total(numbers); //=> 15
```

再次注意，函数的定义和将函数作用于数据是多么的相似：

```js
var total = R.reduce(add, 0); //=> function:: [Number] -> Number
var sum =   R.reduce(add, 0, numbers); //=> 15
```

**我不关心这些，我又不是数学极客**

