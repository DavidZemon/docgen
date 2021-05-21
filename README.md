# Document Generation

DEPRECATED! Use the
[FindDoxygen](https://cmake.org/cmake/help/latest/module/FindDoxygen.html)
module introduced in CMake 3.9

This repository provides tools and resources for generating Doxygen
documentation.

## Usage

### Setup

Generated HTML documents rely on the `resources` folder existing in your server
root. You can use the `-r` flag with a path to resources if the folder will not
be in the same directory as your output html files.

### md2html

Run the md2html script with input and output files like so:

    ./md2html README.md html/index.html

After copying the `resources` folder into the same `html/` directory, you will
have the following layout:

    html/
    ├── index.html
    └── resources
        ├── default.min.css
        ├── highlight.min.js
        ├── logo.png
        └── custom.css

You may want to customize the content of `custom.css` and replace `logo.png` as
desired.

And you can serve the `html/` directory using any server supporting static
content.

Alternatively, call md2html with just an output directory for automatic file
name translation.

    ./md2html MyDoc.md html/

Will produce file `html/mydoc.html`

#### Resources

By default, output html expect the `resources` folder to live in the same
directory. E.g.

    html/
    ├── index.html
    └── resources

To change this, use the `-r` flag. For example, to generate a file in a
sub-directory of the html root:

    html/
    ├── resources
    └── subdir

Run:

    md2html -r html/resources input.md html/subdir/output.html

## Writing Documents

The generator and styles in this project work best with **Github**-styled
**markdown**.

### Examples

* Bulleted List
    * Nested Bullet
* Nested Code Block:

    ```
    md2html <input markdown> <output>
    ```

| Left | Center | Right |
| --- | :---: | ---: |
| Left-justified | Centered | Right-justified |
| Third | Row | Striped |

[Link](#examples) to examples

#### Syntax Highlighting Samples

**C++**
```c++
#include <iostream>

int main() {
    std::cout << "Hello World!\n";
    return 0;
}
```
**Perl**
```perl
#!/usr/bin/perl

use strict;
use warnings;

print "Hello, World!\n";
```

## Tests

md2html is unit-tested. Run the md2htmlTest script in test/ from anywhere. E.g.

    ./test/md2htmlTest

> **Note**: you will need `showdown` nodejs-based markdown-to-html converter
