import diet.html;
import diet.input;
import diet.parser;
import std.stdio;
import std.file;

// mimic diet-ng's mechanism to compute a diet hash function (hopefully this
// becomes public at some point).
ulong computeDietHash(InputFile[] files)
{
    ulong ret = 0;
    void hash(string s)
    {
        foreach (char c; s) {
            ret *= 9198984547192449281;
            ret += c * 7576889555963512219;
        }
    }

    foreach (ref f; files) {
        hash(f.name);
        hash(f.contents);
    }
    return ret;
}

string hashFilename(string name, InputFile[] files)
{
    auto hash = computeDietHash(files);
    import std.format;
    return format("%s_cached_%s.d", name, hash);
}

int main(string[] args)
{
    import std.getopt;
    import std.algorithm : splitter, canFind;
    import std.string : startsWith;

    bool doLive = false;
    bool doClear = false;
    auto helpInformation = getopt(
        args,
        "live", "Use live mode for code generation instead of normal mode", &doLive,
        "clean", "Clear all existing cached files. Does not create any new files", &doClear
        );

    if(helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Pre compile Diet templates for cached use",
            helpInformation.options);
        return 1;
    }

    // clear any cached files if requested
    if(doClear)
    {
        writeln("Cleaning existing cache files");
        DirEntry prev;
        // need to iterate the files BEFORE removing, otherwise we get exceptions.
        auto filesToClear = dirEntries("views", "*_cached_*.d", SpanMode.breadth);
        while(!filesToClear.empty)
        {
            auto entry = filesToClear.front;
            filesToClear.popFront;
            remove(entry.name);
        }
        return 0;
    }

    // for each item in the "views" directory, pre-compute a diet cached
    // version of the generated code.
    foreach(de; dirEntries("views", "*.dt", SpanMode.breadth))
    {
        // skip any hidden directories
        if(de.isFile && !de.name.splitter('/').canFind!(n => n.startsWith('.')))
        {
            // remove the "views/" prefix
            auto dietName = de.name["views/".length .. $];
            // load all the files associated with this template
            auto files = rtGetInputs(dietName, "views/");
            try
            {
                auto hashfile = hashFilename(de.name, files);
                if(!hashfile.exists)
                {
                    writef("parsing file %s...", de.name);
                    stdout.flush();
                    auto doc = parseDiet(files);
                    write("generating code...");
                    stdout.flush();
                    auto file = File(hashfile, "w+");
                    scope(failure)
                    {
                        file.close();
                        // ignore any errors in removal, exception is in flight.
                        try
                        {
                            remove(hashfile);
                        } 
                        catch(Exception e)
                        {}
                    }

                    // TODO: figure out a way to output this via ranges instead
                    // of producing the entire code output at once.
                    auto code = doLive ? getHTMLLiveMixin(doc) : getHTMLMixin(doc);

                    file.rawWrite(code);
                    writeln("Completed");
                }
            }
            catch(Exception e)
            {
                writeln("FAILED!");
                // log that the particular file cannot be processed
                writefln("skipping file %s, pre-caching gives exception: %s(%s): %s", de.name, e.file, e.line, e.msg);
            }
        }
    }

    return 0;
}
