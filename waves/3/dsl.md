# List Routines DSL

- [Overview](#overview)
- [Types](#type-system)
- [Symbols](#symbols)
- [Definitions](#definitions)

## Overview

This is a Domain-specific language (DSL) for list routines. It applies to integers between 0 and 99 (inclusive), and lists of lengths between 0 and 10 (inclusive). List are 1-indexed (i.e. index 1 indicates first item in list). This DSL follows a Lisp-like syntax. It is deliberately sparse.

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

*Table 1.0 - Type Definitions*

## Symbols

This section contains a table of symbols in the DSL, along with their type signatures and a brief description.

Notes:
- The DSL assumes explicit recursion is available (e.g. `C (Cons x y) = C y`). Extend the DSL accordingly if necessary.
- The DSL assumes anonymous functions and/or predicate invention is available (e.g. `lambda` or uninterpreted symbols). Extend the DSL accordingly if necessary.
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
<td><code>0..9</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: integers between 0 and 9, inclusive.</td>
</tr>
<tr>
<td><code>10..99</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: integers between 10 and 99, inclusive. Extended DSL only.</td>
</tr>
<tr>
<td><code>NAN</code></td>
<td>0</td>
<td><code>int</code></td>
<td>Constant: An out-of-bounds number.</td>
</tr>
<tr>
<td><code>True</code></td>
<td>0</td>
<td><code>bool</code></td>
<td>Constant: Boolean literal.</td>
</tr>
<tr>
<td><code>False</code></td>
<td>0</td>
<td><code>bool</code></td>
<td>Constant: Boolean literal.</td>
</tr>
<tr>
<td><code>Empty</code></td>
<td>0</td>
<td><code>[t1]</code></td>
<td>Constant: an empty list.</td>
</tr>
<tr>
<td><code>C</code></td>
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
<td><code>Cons</code></td>
<td>2</td>
<td><code>t1 → [t1] → [t1]</code></td>
<td>Prepends a given item to the beginning of a list.</td>
</tr>
<tr>
<td><code>Head</code></td>
<td>1</td>
<td><code>[t1] → t1</code></td>
<td>Returns the first element of a list (i.e. the head).</td>
</tr>
<tr>
<td><code>If</code></td>
<td>3</td>
<td><code>bool → t1 → t1 → t1</code></td>
<td>standard conditional</td>
</tr>
<tr>
<td><code>Tail</code></td>
<td>1</td>
<td><code>[t1] → [t1]</code></td>
<td>Returns all but the first element of a list (i.e. the tail).</td>
</tr>
</tbody>
</table>

*Table 1.1 - DSL symbols*

## Definitions

Below are definitions for the symbols in the DSL.

- `0`...`99`, `NAN`, `True`, `False`, `Empty`, and `Cons`-cells are constants.
- `C` varies per task, so it isn't defined here. It's available for explicit recursion.
- Use standard definitions for `+`, `-`, and `>`; out-of-bounds operations go to `NAN` (e.g. `+ 9 9 = NAN`, `- 2 3 = NAN`) .
- The remaining symbols follow these rules:
  ```
  EMPTY NIL = TRUE;
  EMPTY (CONS x y) = FALSE;

  EQUAL x x = TRUE;
  EQUAL x y = FALSE;

  HEAD (CONS x y) = x;

  IF TRUE  x y = x;
  IF FALSE x y = y;

  TAIL (CONS x y) = y;
  ```
