# x86_assembly

## 1. Finding the greatest common divisor

|  input  | output |
|---------|--------|
| 36, 60  |   12   |
| 49, 14  |   7    |
| 25, 30  |   5    |


## 2. Merge Sort

|       input        |       output       |
|--------------------|--------------------|
| 5, 2, 3            | 2, 3, 5            |
| 9, 2, 2, 10, 4     | 2, 2, 4, 9, 10     |
| 4, 10, 58, 2, 1, 9 | 1, 2, 4, 9, 10, 58 |


## 3. String Compression

| input                        | output |
|------------------------------|--------|
| aabbaccc                     |   7    |
| ababcdcdababcdcd             |   9    |
| abcabcded                    |   7    |
| abcabcabcabcdededededede     |   14   |
| xababcdcdababcdcd            |   17   |

Further Explanation
1. The string compression method represents consecutive repeating characters as the character followed by its count. For example, "aaabccddd" is compressed to "a3bc2d3"

2. However, this method may result in lower compression rates when there are fewer repeating characters. For example, "abcabcabc" does not compress at all. To address this issue, we use a method of dividing the string into one or more units.
For example, if we divide "abcabcabc" into units of 3, it can be compressed to "abc3". For "ababcdcdababcdcd", dividing into units of 2 yields "ab2cd2ab2cd2", but dividing into units of 8 results in "ababcdcd2", which compresses from a total length of 16 to 9!