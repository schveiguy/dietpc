# Diet Template Pre Compiler

This is a simple little utility that pre-compiles all the diet templates in your views directory. It basically does so by executing the diet template function at runtime instead of at compile time, and then writes the result to the appropriate cached filename. It is required to build your project with the `DietUseCache` version enabled.

Note that this depends on an update to diet-ng that allows runtime processing of the diet files (see my [DietUseLive PR](https://github.com/rejectedsoftware/diet-ng/pull/70)). It also completely duplicates the hashing function in the diet-ng code, because it's not publically accessible.

## Usage

Just run dietpc in your project directory. It will process the views directory, and pre-compile every file. If files can't be pre-compiled, they are skipped. If the cached files already exist, they are skipped. No support yet for traits, but those are compile-time anyway (for now). No support yet for pretty-printing of HTML. Note that this does not know how you called the diet compiler in your code, so it will not know which files are used. It just does all of them (it's really fast, don't worry about it).
