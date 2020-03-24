# Diet Template Pre Compiler

Diet templates can sometimes consume an inordinate amount of memory and compile time just to render. However, the diet-ng library provides a mechanism to "cache" the compiled version of the diet template into your views directory (see the README file in the diet-ng directory and the `DietUseCache` version configuration). If that cache file is present, then instead of parsing and processing the diet template at comiple time, it simply imports the file and uses it as-is.

However, the caching feature of diet-ng requires that you compile at least *once* in order to gain any benefit, as the cached files are written at runtime after the project is built. Using cached files can save on the order of 25% of compiler memory usage, which can mean the difference between compiling successfully and running out of memory. If you don't have the memory to compile your set of templates for the first run, then you must face the issue of breaking up your project or other drastic means.

`dietpc` processes all the templates in your views directory and provides the same feature as `DietUseCache`, but without having to compile your whole project. It also runs in a small fraction of the time it takes to compile using CTFE. Using this together with the `DietUseCache` version can significantly save compiler memory usage and shorten compile times, making your edit-compile-test cycle much faster.

## Usage

Just run dietpc in your project directory. It will process the views directory, and pre-compile every file. If files can't be pre-compiled, they are skipped. If the cached files already exist, they are skipped. No support yet for traits, but those are compile-time anyway (for now). No support yet for pretty-printing of HTML. Note that this does not know how you called the diet compiler in your code, so it will not know which files are used. It just does all of them (it's really fast, don't worry about it).

To use it automatically with dub, add `dietpc` to your dub configuration's `preGenerateCommands` list.

### Options

* --live: Use the new `DietUseLive` mode introduced in diet-ng 1.7.0 to compile the files. Note that the cached hash code is based on the _source_ contents, not the mode used to compile, so if you have built your cached files previously without the `--live` switch, you should clean your cache files in order to have them rebuilt.
* --clean: Clean any cache files in the views subdirectory. This does not run the caching, so you would have to rerun `dietpc` to reproduce the cache files. If you clean the files and rebuild them, this alters the dependencies in your project, so you should avoid doing this every time unless you like rebuilding your whole application for no reason.

## This is for development

Note that at this time, the `DietUseCache` is only recommended for development. If you use this precompiler in production, it means your application is going to spew out cached files every time it's run. At some point in the future, `diet-ng` may introduce a way to simply depend on `dietpc`, but for now, use this for development and run a full build for production. A valid use case for requiring dietpc would be helpful for motivating any new `diet-ng` features.

Please report any bugs or requests to the github issues.
