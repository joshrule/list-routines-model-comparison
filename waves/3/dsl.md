# List Routines DSL ([Symbols](#symbols) &middot; [Definitions](#definitions)  &middot; [Lambdas](#lambdas) &middot; [Types](#type-system))

This document describes a pair of Domain-specific languages (DSLs) for list manipulation routines following a lisp-like syntax. They are deliberately sparse. The two DSLs differ only in the set of numbers they make available. The smaller DSL contains only the integers 0..9, while the larger DSL contains 0..99.

## Symbols

This section contains a table of symbols in the DSL, along with their type signatures and a brief description.

Notes:
- The DSL supports explicit recursion (e.g. `c = (lambda (if (is_empty $0) 0 (+ 1 (c (tail $0)))))`).
- The DSL supports anonymous functions (i.e. `lambda`).
- For an applicative formalism (e.g. combinatory logic), set all arities to 0 and add an application symbol of type `(t1 -> t2) -> t1 -> t2`.

<table>
  <col>
  <col>
  <col>
  <col>
<thead>
<tr class="header">
<th><strong>Symbol</strong></th>
<th><strong>Arity</strong></th>
<th><strong>Type Signature</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>lambda</code></td>
<td>1</td>
<td></td>
<td>a mechanism for creating anonymous functions.</td>
</tr>
<tr>
<td><code>0..9</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: integers between 0 and 9, inclusive.</td>
</tr>
<tr>
<td><code>10..99</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: integers between 10 and 99, inclusive. Problems 81&ndash;100 only.</td>
</tr>
<tr>
<td><code>nan</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: An out-of-bounds number.</td>
</tr>
<tr>
<td><code>true</code></td>
<td>0</td>
<td><code>bool</code></td>
<td>Constant: Boolean literal.</td>
</tr>
<tr>
<td><code>false</code></td>
<td>0</td>
<td><code>bool</code></td>
<td>Constant: Boolean literal.</td>
</tr>
<tr>
<td><code>empty</code></td>
<td>0</td>
<td><code>[t1]</code></td>
<td>Constant: an empty list.</td>
</tr>
<tr>
<td><code>c</code></td>
<td>1</td>
<td><code>[int] → [int]</code></td>
<td>the target concept</td>
</tr>
<tr>
<td><code>+</code></td>
<td>2</td>
<td><code>int → int → int</code></td>
<td>Binary addition operator.</td>
</tr>
<tr>
<td><code>-</code></td>
<td>2</td>
<td><code>int → int → int</code></td>
<td>Binary subtraction operator.</td>
</tr>
<tr>
<td><code>&gt;</code></td>
<td>2</td>
<td><code>int → int → bool</code></td>
<td>Binary greater than predicate.</td>
</tr>
<tr>
<td><code>==</code></td>
<td>2</td>
<td><code>t0 → t0 → bool</code></td>
<td>Binary equality predicate.</td>
</tr>
<tr>
<td><code>cons</code></td>
<td>2</td>
<td><code>t1 → [t1] → [t1]</code></td>
<td>Prepends a given item to the beginning of a list.</td>
</tr>
<tr>
<td><code>head</code></td>
<td>1</td>
<td><code>[t1] → t1</code></td>
<td>Returns the first element of a list (i.e. the head).</td>
</tr>
<tr>
<td><code>if</code></td>
<td>3</td>
<td><code>bool → t1 → t1 → t1</code></td>
<td>standard conditional</td>
</tr>
<tr>
<td><code>is_empty</code></td>
<td>1</td>
<td><code>[t1] → bool</code></td>
<td><code>true</code> if the list is empty, else <code>false</code></td>
</tr>
<tr>
<td><code>is_equal</code></td>
<td>2</td>
<td><code>t1 → t1 → bool</code></td>
<td><code>true</code> if the arguments are identical, else <code>false</code></td>
</tr>
<tr>
<td><code>tail</code></td>
<td>1</td>
<td><code>[t1] → [t1]</code></td>
<td>Returns all but the first element of a list (i.e. the tail).</td>
</tr>
</tbody>
</table>

*Table 1.0 - DSL symbols*

## Definitions

Below are definitions for the symbols in the DSL.

- `0`...`99`, `nan`, `true`, `false`, `empty`, and `cons`-cells are constants.
- `c` varies per task, so it isn't defined here. It's available for explicit recursion.
- Use standard definitions for `+`, `-`, and `>`; out-of-bounds operations go to `nan` (e.g. `+ 9 9 = nan`, `- 2 3 = nan`) .
- The remaining symbols follow these rules:
  ```
  if true  x y = x;
  if false x y = y;

  is_empty empty = true;
  is_empty (cons x y) = false;

  is_equal x x = true;
  is_equal x y = false;

  head (cons x y) = x;

  tail (cons x y) = y;
  ```
## Lambdas

`lambda` returns an anonymous function that runs an input expression when called. For example, lambda functions can be passed as input functions to count, map, filter, and fold. The $-prefixed integers (e.g. `$0`, `$1`, … `$n`) represent [De Bruijn indices](https://en.wikipedia.org/wiki/De_Bruijn_index), where the index then refers to how many variable bindings you are from the variable you're referring to. For instance, `K x y = x` would be written as `(lambda (lambda $1))`.

Some more examples of Lambda functions can be seen below:

| **Example**                     | **Type Signature**  | **Description**                                                 |
| ------------------------------- | ------------------- | --------------------------------------------------------------- |
| `(lambda 5)`                     | `(t1 → int)`         | Returns 5.                                                      |
| `(lambda (+ $0 1))`              | `(int → int)`        | Increments an input value by 1.                                 |
| `(lambda (\> $0 0))`             | `(int → int)`        | Returns whether or not the input value is greater than 0.       |
| `(lambda (index 5 $0))`          | `(\[t1\] → t1)`      | Returns the 6th value (due to 0-indexing) in an input list.     |
| `(lambda (lambda (index $1 $0)))` | `(int → \[t1\] → t1)` | Returns the *N-1*th value of an input list for input value *N*. |

*Table 1.1 - Lambda Examples*

## Type System

This DSL uses a [Hindley-Milner type system](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system).

<table>
<thead>
<tr class="header">
<th><strong>Symbol</strong></th>
<th><strong>Description</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>t1,t2,...</code></td>
<td>Universally quantified type variables.</td>
</tr>
<tr>
<td><code>→</code></td>
<td>Arrow type. Left hand side of arrow represents input types, right represents output type. Chaining of arrows represents multiple function arguments, e.g. a function that takes two <code>int</code>s and returns an <code>int</code> would be <code>int → int → int</code>.</td>
</tr>
<tr>
<td><code>int</code></td>
<td>Integer value.</td>
</tr>
<tr>
<td><code>bool</code></td>
<td>Boolean value.</td>
</tr>
<tr>
<td><code>[&lt;type&gt;]</code></td>
<td>List where each value is of type &lt;type&gt;. E.g.:
<ul style="margin-bottom: 0;">
<li><code>[t1]</code> - List of values of type <code>t1</code>.</li>
<li><code>[int]</code> - List of integers.</li>
<li><code>[[int]]</code> - List of lists of integers.</li></ul></td>
</tr>
</tbody>
</table>

*Table 1.2 - Type Definitions*
