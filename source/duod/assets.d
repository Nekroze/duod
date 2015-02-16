/++ This module implements the core functionality of this project.
 +  Provides simple commands to generate assets when needed for usage.
 +/
module duod.assets;
import duod.utilities;
import std.exception : enforce;
import std.string : format, chompPrefix, toLower;
import std.file : readText, write, getSize;
import std.path : buildPath, extension, isValidFilename;
import std.functional : memoize;
import std.stdio : writeln;
/++ Build a css or js asset based on the given string. This exposes the core
 +  functionality of the duo frontend package manager and as such, may pull in
 +  additional assets such as fonts or images, which should be placed in a
 +  directory for static file serving, the default, as with vibe.d is `public/`.
 +  Params:
 +      source    =     Source code to pass to duo.
 +      js        =     If this is javascript or css. Default true for javascript.
 +      staticdir =     Your statically served asset directory. Default is `public/`
 +  Returns: The duo outputed source file with all external assets built in.
 +/
string duo (string source, bool js=true, string staticdir="public") {
    enforce (hasDuo, "Duo command not available, please install");

    string command = format ("duo -o %s -t %s -c -S",
            staticdir, js ? "js" : "css");
    return getOutput (command, source);
}
/++ Compress assets via uglifying (aka minifying) them with yuglify.
 +  This takes in javascript or css and can output code with the
 +  same functionality at a fraction of the size.
 +  Params:
 +      source =     Source code to pass to yuglify.
 +      js     =     If this is javascript or css. Default true for javascript.
 +  Returns: The inputted source code without formatting which results in a size decrease.
 +/
string uglify (string source, bool js=true) {
    enforce (hasYuglify, "Uglify command not available");

    string command = format ("yuglify --terminal --type %s",
            js ? "js" : "css");
    return getOutput (command, source);
}
/++ Get the path to an asset in the project directory located by its web location.
 +  Params:
 +      path      =     The web path, excluding the routed location of statically
 +                      served assets. Eg. "/index.js".
 +      staticdir =     Your statically served asset directory. Default is `public/`
 +  Returns: The path to this asset within your staticdir.
 +/
string getAssetPath (string path, string staticdir="public") {
    return buildPath(staticdir, path.chompPrefix("/"));
}
/// This example shows the conversion of a URL to the location of the projects asset on disk.
unittest {
    string url = "nekroze.com/index.js";
    string asset = url.chompPrefix("nekroze.com");
    assert (getAssetPath (asset) == "public/index.js");
}
/++ Compile the given asset source with duo and optionally minify/uglify the output.
 +  Params:
 +      source    =     Source code to pass to compile.
 +      js        =     If this is javascript or css. Default true for javascript.
 +      staticdir =     Your statically served asset directory. Default is `public/`
 +      min       =     If true the output will be minified/uglifies with yuglify.
 +  Returns: The duo builtsource code without formatting which results in a size decrease.
 +/
string compile (string source, bool js=true, string staticdir="public", bool min=true) {
    string compiled = duo (source, js, staticdir);
    return min ? uglify (compiled, js) : compiled;
}
/++ Much the same as `compile` however `build` takes and outputs files but only in a
 +  `unittest` versioned build but will always return the html that includes the built asset.
 +  Params:
 +      sourcePath =    Path to asset source to be built.
 +      staticPath =    The web path, excluding the routed location of statically
 +                      served assets. Eg. "/index.js".
 +      staticdir  =    Your statically served asset directory. Default is `public/`
 +  Returns: The html required to include this asset.
 +/
string build (string sourcePath, string staticPath, string staticdir="public") {
    string path = getAssetPath (staticPath, staticdir);

    version (unittest) {  // Build assets only when unittesting
        enforce (sourcePath.isValidFilename, "Asset source not found: " ~ sourcePath);

        string source = compile(
                readText (sourcePath),
                extension(staticPath).toLower() == "js", staticdir, hasYuglify);
        write (path, source);
        writeln ("Compiled asset %s to %s which is %s bytes.", sourcePath, staticPath, getSize(path));
    }

    return extension(staticPath).toLower() == "js" ?
        format ("<script type=\"text/javascript\" src=\"%s\"></script>", staticPath)
        :
        format ("<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">", staticPath);
}
/++ The `require` function is identicle to `build` however it utilizes memoization to ensure
 +  that output, including the building of resources in a `unittest` versioned build, only
 +  happens once for a given input set per application launch. When used in a `unittest`
 +  versioned build this means the asset will only be compiled by duo the first time
 +  `require` is called.
 +
 +  Due to the nature of this function it is best used in diet templates, or before calling any tests,
 +  that require the use of the given asset.
 +  Params:
 +      sourcePath =    Path to asset source to be built.
 +      staticPath =    The web path, excluding the routed location of statically
 +                      served assets. Eg. "/index.js".
 +      staticdir  =    Your statically served asset directory. Default is `public/`
 +  Returns: The html required to include this asset.
 +/
alias require = memoize!build;
