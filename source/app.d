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

void main(string[] args)
{
    // for each item in the "views" directory, pre-compute a diet cached
    // version of the generated code.
    foreach(de; dirEntries("views", "*.dt", SpanMode.breadth))
    {
        if(de.isFile)
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
                    version(DietUseLive)
                    {
                        auto code = getHTMLLiveMixin(doc);
                    }
                    else
                    {
                        auto code = getHTMLMixin(doc);
                    }

                    file.rawWrite(code);
                    writeln("Completed");
                }
            }
            catch(Exception e)
            {
                writeln("FAILED!");
                // log that the particular file cannot be processed
                writefln("skipping file %s, pre-caching gives exception: %s", de.name, e.msg);
            }
        }
    }
}
