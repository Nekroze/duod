/++ This module implements the compilation functionality.
 +  Provides commands to compile and minify assets from their source with duod.
 +/
module duod.compilation;
import duod.utilities;
import std.exception : enforce;
import std.string : format, chompPrefix, toLower;
import std.file : readText, write, getSize, mkdirRecurse, dirName;
import std.path : buildPath, extension;
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

    string command = format ("duo -o %s -t %s -c -S -q",
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
/++ Much the same as `compile` however `build` takes and outputs files.
 +  Params:
 +      sourcePath =    Path to asset source to be built.
 +      staticPath =    Path to the compile assets output destination.
 +      staticdir  =    Your statically served asset directory. Default is `public/`
 +      min       =     If true the output will be minified/uglifies with yuglify.
 +/
void build (string sourcePath, string staticPath, string staticdir="public", bool min=true) {
    string source = compile(
            readText (sourcePath),
            extension(staticPath).toLower() == ".js", staticdir, hasYuglify && min);
    staticPath.dirName.mkdirRecurse;

    write (staticPath, source);
    writeln (format ("Compiled asset %s to %s which is %s bytes.",
                sourcePath, staticPath, getSize(staticPath)));
}
