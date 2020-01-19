---
date: 2019-07-08
title: C++: Function Lookup in Templates
tags: c++
---

Suppose you have a function that writes the argument to stdout using
`operator<<`. For example, it can be a function from a test framework that
makes some checks and writes a message if the checks fail. Only the output is
relevant to the discussion, so I call the function `dump`.


```
#pragma once
#include <iostream>

template <typename T>
void dump(const T& x)
{
    std::cout << x << '\n';
}
```

You can use this code as follows:

```
#include "test.h"
int main()
{
    dump(1);
}
```

Then you want to apply `dump` to a user-defined type:

```
struct Foo {
    int i;
};

std::ostream& operator<<(std::ostream& o, const Foo& x)
{
    return o << "Foo{" << x.i << "}";
}

int main()
{
    dump(1);
    dump(Foo{1});
}
```

The code is compiled by `gcc` and `clang`.

Then you want to apply `dump` to a `vector` of values. Standard library does
not provide us with an `operator<<` implementation for vectors, so you need to
implement one yourself.

```
#include <vector>
#include <iostream>
#include "test.h"

std::ostream& operator<<(std::ostream& o, const std::vector<int>& x)
{
    o << '[';
    for (const auto& i : x) {
        o << i << ", ";
    }
    o << ']';
    return o;
}


int main()
{
    dump(std::vector<int>{1,2,3});
}
```

This works with `gcc`:

```
$ g++ test.cpp && ./a.out
[1, 2, 3, ]
```

But you have an issue with `clang`:

```
[alex@alex cpp-name-lookup-in-template]$ clang++ test.cpp
In file included from test.cpp:3:
./test.h:8:15: error: call to function 'operator<<' that is neither visible in
	  the template definition nor found by argument-dependent lookup
    std::cout << x << '\n';
              ^
test.cpp:18:5: note: in instantiation of function template specialization
	  'dump<std::vector<int, std::allocator<int> > >' requested here
    dump(std::vector<int>{1,2,3});
    ^
test.cpp:5:15: note: 'operator<<' should be declared prior to the call site
std::ostream& operator<<(std::ostream& o, const std::vector<int>& x)
              ^
1 error generated.

```

What the heck is going on here? I thought that the lookup is performed in the
point of the template instantiation, but it looks like that it is not. You can
solve the issue placing the code of ```std::ostream& operator<<(std::ostream&
o, const std::vector<int>& x)``` before ```#include "test.h"```.

There is a [page from LLVM
project](https://clang.llvm.org/compatibility.html#dep_lookup) that describes
a similar issue. It says that clang is compatible with the standard and gcc is not.
The page has a little bit different example: the template is instantiated with
`int` as a template parameter, and I  have `std::vector<int>`. There is also
no direct references to the standard, so I was curious to check it with the
standard.

I used [this
version](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2014/n4296.pdf) of
C++ standard, dated 2014-11-19.

Section 14 is devoted to templates.

> 14.6.4.2  Candidate functions
> 
> For a function call where the postfix-expression is a dependent name, the
> candidate functions are found using the usual lookup rules (3.4.1, 3.4.2) except
> that:
> 
> -   For the part of the lookup using unqualified name lookup (3.4.1), only
>     function declarations from the template definition context are found.
> 
> -   For the part of the lookup using associated namespaces (3.4.2), only
>     function declarations found in either the template definition context or the
>     template instantiation context are found.

So, according to the standard, in my example, when the `dump` function is
instantiated, the unqualified name lookup is performed for `operator<<`. Only
template definition context is used. There is no user-defined `operator<<`
functions in the template definition context. Then, argument-dependent name
lookup is performed.

In the first case, the argument has type `struct Foo`,
that is declared in the global namespace.
`std::ostream& operator<<(std::ostream& o, const Foo& x)` is searched in the
global namespace, and template instantiation context is also used at this
moment. We have the function in the instantiation context, and the code
compiles.

In the second case, the argument has type `const std::vector<int>&`, that is
declared in the `std` namespace. Even taking into account the template
instantiation context, there is no desired function in `std` namespace, because
it is declared in the global namespace. The compilation should fail. The
`gcc`'s behaviour does not correspond to the standard.

To fix the issue, one could declare the function in `std` namespace. This works
actually, but it is an undefined behaviour because of this section:

> 17.6.4.2.1  Namespace std
> 
> The behavior of a C++ program is undefined if it adds declarations or
> definitions to namespace std or to a namespace within namespace std unless otherwise
> specified. A program may add a template specialization for any standard library
> template to namespace std only if the declaration depends on a user-defined
> type and the specialization meets the standard library requirements for the
> original template and is not explicitly prohibited

We add an overloading of a function from `std` namespace. I have not found a
clause that allows this, so the clause "The behavior of a C++ program is
undefined if it adds declarations or definitions to namespace std" applies.

The legal way is to add the function definition before the definition of the
template. We have to do this:

```
#include <vector>
#include <iostream>

std::ostream& operator<<(std::ostream& o, const std::vector<int>& x)
{
    o << '[';
    for (const auto& i : x) {
        o << i << ", ";
    }
    o << ']';
    return o;
}

#include "test.h"

int main()
{
    dump(std::vector<int>{1,2,3});
}
```
