## ABC

All the results has been placed in this floder.

* `testn_expr.txt`: the expression used in the experiment.
* `testn_log.txt`: the log of the experiment.
* `testn_netlist.txt`: the netlist of the experiment.

| Expression                   | Time (ms) | Area Cost  |
| ---------------------------- | --------- | ---------- |
| ~(!a\| b)                    | 73        | 4          |
| b\| (b&c)                    | 74        | 0 (only b) |
| a\| !a & b                   | 73        | 4          |
| ~(a&b)                       | 77        | 2          |
| !(c\|\| d)                  | 81        | 3          |
| a&b&c\| (a&b&!d) \| (a&b&~e) | 77        | 12         |

## SIS

Test results recorded in table but the generated files is not kept in the folder.

| Expression                   | Time (ms) | Area Cost  |
| ---------------------------- | --------- | ---------- |
| ~(!a\| b)                    | 51        | 4          |
| b\| (b&c)                    | 54        | 0 (only b) |
| a\| !a & b                   | 53        | 4          |
| ~(a&b)                       | 49        | 2          |
| !(c\|\|d)                    | 51        | 3          |
| a&b&c\| (a&b&!d) \| (a&b&~e) | 78        | 12         |

## Conclusion

This is a simple experiment to compare the performance of ABC and SIS. The result shows that SIS is faster than ABC and achieve the same area cost. However, the result is not accurate because the experiment is too simple, increasing the complexity of the expression may lead to different results.
