# List-Routines Model Comparison: Wave 3 Concepts

Below is a list of functions used during Wave 3 of our model comparison experiments and simulations. Inputs and outputs are assumed to be `[int]` with 0 to 10 elements of values 0 to 9 (i.e. each concept is `[int] → [int]`). [The DSL used in the simulations][] is small, so I use [a richer DSL][] here for brevity.

For each function, we've generated 5 unique orderings of a single set of 11 machine-generated examples. In the list below, each function links to a representative ordering. The rest can be found [here](./json).

[the DSL used in the simulations]: ./dsl.md
[a richer DSL]: https://github.com/joshrule/list-routines-human-experiments/blob/master/dsl.md

## Functions [P1](#p1--11--12--13--14)&nbsp;&nbsp;[P2](#p2)

The functions can be broken into two subsets, P1 and P2, that provide a total of 100 problems to solve.

### P1  [1.1](#p11-5-tuples)&nbsp;&nbsp;[1.2](#p12-4-tuples)&nbsp;&nbsp;[1.3](#p13-structural-manipulation-problems)&nbsp;&nbsp;[1.4](#p14-recursive-problems)

P1 contains 80 problems and can itself be divided into 4 groups of 20 functions.

#### P1.1 5-tuples

P1.1 is organized as 4 5-tuples. Each tuple contains 5 variants of the same problem:
- non-recursive, early in the list
  *return the third item*
- non-recursive, early in the list, with exceptional data
  *return the third item, or the empty list if the input has fewer than 3 elements*
- non-recursive, late in the list
  *return the seventh item*
- non-recursive, late in the list, with exceptional data
  *return the seventh item, or the empty list if the input has fewer than 7 elements*
- recursive, without exceptions
  *return the firsth item in the tail*

1. [`(lambda (singleton (third $0)))`](./json/c001_0.json)
2. [`(lambda (if (> 3 (length $0)) empty (singleton (third $0))))`](./json/c002_0.json)
3. [`(lambda (singleton (nth 7 $0)))`](./json/c003_0.json)
4. [`(lambda (if (> 7 (length $0)) empty (singleton (nth 7 $0))))`](./json/c004_0.json)
5. [`(lambda (singleton (nth (first $0) (drop 1 $0))))`](./json/c005_0.json)
6. [`(lambda (take 2 $0))`](./json/c006_0.json)
7. [`(lambda (take 2 $0))`](./json/c007_0.json)
8. [`(lambda (take 6 $0))`](./json/c008_0.json)
9. [`(lambda (take 6 $0))`](./json/c009_0.json)
10. [`(lambda (take (first $0) (drop 1 $0)))`](./json/c010_0.json)
11. [`(lambda (slice 2 4 $0))`](./json/c011_0.json)
12. [`(lambda (slice 2 4 $0))`](./json/c012_0.json)
13. [`(lambda (slice 3 7 $0))`](./json/c013_0.json)
14. [`(lambda (slice 3 7 $0))`](./json/c014_0.json)
15. [`(lambda (slice (first $0) (second $0) (drop 2 $0)))`](./json/c015_0.json)
16. [`(lambda (replace 2 8 $0))`](./json/c016_0.json)
17. [`(lambda (replace 2 8 $0))`](./json/c017_0.json)
18. [`(lambda (replace 6 3 $0))`](./json/c018_0.json)
19. [`(lambda (replace 6 3 $0))`](./json/c019_0.json)
20. [`(lambda (replace 1 (last $0) $0))`](./json/c020_0.json)

#### P1.2 4-tuples

P1.2 is organized as 5 4-tuples. Each tuple contains 4 problems:

- 2 simple rules
  *insert 8 as the second element*
  *insert 5 as the second element*
- a conditional form based on the list structure (e.g. length, element equality)
  *insert 8 as the second element if the list length is less than 5, else 5*
- a conditional form based on elements in the list as numbers (e.g. numerical equalities)
  *insert 8 as the second element if the first element is less than 5, else 5*

21. [`(lambda (insert 8 2 $0))`](./json/c021_0.json)
22. [`(lambda (insert 5 2 $0))`](./json/c022_0.json)
23. [`(lambda (insert (if (> 5 (length $0)) 8 5) 2 $0))`](./json/c023_0.json)
24. [`(lambda (insert (if (> 5 (first $0)) 8 5) 2 $0))`](./json/c024_0.json)
25. [`(lambda (cut_idx 2 $0))`](./json/c025_0.json)
26. [`(lambda (cut_idx 3 $0))`](./json/c026_0.json)
27. [`(lambda (cut_idx (if (== (first $0) (third $0)) 3 2) $0))`](./json/c027_0.json)
28. [`(lambda (cut_idx (if (> (first $0) (third $0)) 3 2) $0))`](./json/c028_0.json)
29. [`(lambda (drop 2 $0))`](./json/c029_0.json)
30. [`(lambda (drop 4 $0))`](./json/c030_0.json)
31. [`(lambda (drop (if (and (== (second $0) (first $0)) (> (length $0) 5)) 2 4) $0))`](./json/c031_0.json)
32. [`(lambda (drop (if (and (== (second $0) 0) (> (first $0) 5)) 2 4) $0))`](./json/c032_0.json)
33. [`(lambda (swap 1 4 $0))`](./json/c033_0.json)
34. [`(lambda (swap 2 3 $0))`](./json/c034_0.json)
35. [`(lambda (if (or (== (second $0) (nth 4 $0)) (> (length $0) 7)) (swap 1 4 $0) (swap 2 3 $0)))`](./json/c035_0.json)
36. [`(lambda (if (or (== (second $0) 7) (> (nth 4 $0) 7)) (swap 1 4 $0) (swap 2 3 $0)))`](./json/c036_0.json)
37. [`(lambda (append $0 3))`](./json/c037_0.json)
38. [`(lambda (append $0 9))`](./json/c038_0.json)
39. [`(lambda ((lambda (if (> (length $0) 5) (append $0 3) $0)) ((lambda (if (== (second $0) (third $0)) (append $0 9) $0)) $0)))`](./json/c039_0.json)
40. [`(lambda ((lambda (if (> (third $0) 3) (append $0 3) $0)) ((lambda (if (== (second $0) 9) (append $0 9) $0)) $0)))`](./json/c040_0.json)

#### P1.3 non-recursive problems

P1.3 contains 20 problems which can all be solved without recursion given the DSL available to the models.

41. [`(lambda (singleton 9))`](./json/c041_0.json)
42. [`(lambda (cons 5 (singleton 2)))`](./json/c042_0.json)
43. [`(lambda (cons 8 (cons 2 (cons 7 (cons 0 (singleton 3))))))`](./json/c043_0.json)
44. [`(lambda (cons 1 (cons 9 (cons 4 (cons 3 (cons 2 (cons 5 (cons 8 (cons 0 (cons 4 (singleton 9)))))))))))`](./json/c044_0.json)
45. [`(lambda $0)`](./json/c045_0.json)
46. [`(lambda (cons 7 $0))`](./json/c046_0.json)
47. [`(lambda (cons 9 (cons 6 (cons 3 (cons 8 (cons 5 $0))))))`](./json/c047_0.json)
48. [`(lambda (take 1 $0))`](./json/c048_0.json)
49. [`(lambda (drop 1 $0))`](./json/c049_0.json)
50. [`(lambda (cons (first $0) $0))`](./json/c050_0.json)
51. [`(lambda (concat (repeat (first $0) 5) $0))`](./json/c051_0.json)
52. [`(lambda (repeat (first $0) 10))`](./json/c052_0.json)
53. [`(lambda (concat (repeat (first $0) 2) (drop 2 $0)))`](./json/c053_0.json)
54. [`(lambda (concat (repeat (third $0) 3) (drop 3 $0)))`](./json/c054_0.json)
55. [`(lambda (concat (slice 3 4 $0) (concat (take 2 $0) (drop 4 $0))))`](./json/c055_0.json)
56. [`(lambda (cut_idx 5 $0))`](./json/c056_0.json)
57. [`(lambda (insert 4 7 $0))`](./json/c057_0.json)
58. [`(lambda (drop 7 $0))`](./json/c058_0.json)
59. [`(lambda (swap 4 8 $0))`](./json/c059_0.json)
60. [`(lambda (swap 3 1 (replace 4 4 (cut_idx 6 (take 7 $0)))))`](./json/c060_0.json)

#### P1.4 recursive problems

P1.4 contains 20 problems which all require explicit recursion given the DSL available to the models.

61. [`(lambda (singleton (last $0)))`](./json/c061_0.json)
62. [`(lambda (droplast 1 $0))`](./json/c062_0.json)
63. [`(lambda (drop (first $0) (drop 1 $0)))`](./json/c063_0.json)
64. [`(lambda (drop 1 (droplast 1 $0)))`](./json/c064_0.json)
65. [`(lambda (cons 9 (append $0 7)))`](./json/c065_0.json)
66. [`(lambda (append (drop 1 $0) (first $0)))`](./json/c066_0.json)
67. [`(lambda (cons (last $0) (append (drop 1 (droplast 1 $0)) (first $0))))`](./json/c067_0.json)
68. [`(lambda (concat $0 (cons 7 (cons 3 (cons 8 (cons 4 (singleton 3)))))))`](./json/c068_0.json)
69. [`(lambda (concat (cons 9 (cons 3 (cons 4 (singleton 0)))) (concat $0 (cons 7 (cons 2 (cons 9 (singleton 1)))))))`](./json/c069_0.json)
70. [`(lambda (concat $0 $0))`](./json/c070_0.json)
71. [`(lambda (map (lambda (+ 2 $0)) $0))`](./json/c071_0.json)
72. [`(lambda (flatten (map (lambda (cons $0 (singleton $0))) $0)))`](./json/c072_0.json)
73. [`(lambda (mapi + $0))`](./json/c073_0.json)
74. [`(lambda (filter (lambda (> $0 7)) $0))`](./json/c074_0.json)
75. [`(lambda (filteri (lambda (lambda (is_odd $1))) $0))`](./json/c075_0.json)
76. [`(lambda (map (lambda (- $0 3)) (filter (lambda (> $0 5)) $0)))`](./json/c076_0.json)
77. [`(lambda (singleton (length $0)))`](./json/c077_0.json)
78. [`(lambda (singleton (max $0)))`](./json/c078_0.json)
79. [`(lambda (singleton (sum $0)))`](./json/c079_0.json)
80. [`(lambda (reverse $0))`](./json/c080_0.json)

### P2

P2 contains variants of these problems from each subset of P1, modified so that the examples, DSL, and any relevant constants include the numbers 0,1,...,99:

- P1.1: 1&ndash;5
- P1.2: 13&ndash;16
- P1.3: 3, 4, 7, 12, & 15
- P1.4: 4, 5, 9, 13, 14, & 20

81. [`(lambda (singleton (third $0)))`](./json/c081_0.json)
82. [`(lambda (if (> 3 (length $0)) empty (singleton (third $0))))`](./json/c082_0.json)
83. [`(lambda (singleton (nth 7 $0)))`](./json/c083_0.json)
84. [`(lambda (if (> 7 (length $0)) empty (singleton (nth 7 $0))))`](./json/c084_0.json)
85. [`(lambda (singleton (nth (first $0) (drop 1 $0))))`](./json/c085_0.json)
86. [`(lambda (swap 1 4 $0))`](./json/c086_0.json)
87. [`(lambda (swap 2 3 $0))`](./json/c087_0.json)
88. [`(lambda (if (or (== (second $0) (nth 4 $0)) (> (length $0) 7)) (swap 1 4 $0) (swap 2 3 $0)))`](./json/c088_0.json)
89. [`(lambda (if (or (== (second $0) 7) (> (nth 4 $0) 7)) (swap 1 4 $0) (swap 2 3 $0)))`](./json/c089_0.json)
90. [`(lambda (cons 18 (cons 42 (cons 77 (cons 20 (singleton 36))))))`](./json/c090_0.json)
91. [`(lambda (cons 81 (cons 99 (cons 41 (cons 23 (cons 22 (cons 75 (cons 68 (cons 30 (cons 24 (singleton 69)))))))))))`](./json/c091_0.json)
92. [`(lambda (cons 92 (cons 63 (cons 34 (cons 18 (cons 55 $0))))))`](./json/c092_0.json)
93. [`(lambda (repeat (first $0) 10))`](./json/c093_0.json)
94. [`(lambda (concat (slice 3 4 $0) (concat (take 2 $0) (drop 4 $0))))`](./json/c094_0.json)
95. [`(lambda (drop 1 (droplast 1 $0)))`](./json/c095_0.json)
96. [`(lambda (cons 98 (append $0 37)))`](./json/c096_0.json)
97. [`(lambda (concat (cons 11 (cons 21 (cons 43 (singleton 19)))) (concat $0 (cons 7 (cons 89 (cons 0 (singleton 57)))))))`](./json/c097_0.json)
98. [`(lambda (mapi + $0))`](./json/c098_0.json)
99. [`(lambda (filter (lambda (> $0 49)) $0))`](./json/c099_0.json)
100. [`(lambda (reverse $0))`](./json/c100_0.json)
