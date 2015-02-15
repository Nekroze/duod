module duod.assets;
import duod.utilities;

import std.exception : enforce;
import std.string : format, chompPrefix, toLower;
import std.file : readText, write, getSize;
import std.path : buildPath, extension, isValidFilename;
import std.functional : memoize;
import std.stdio : writeln;

string duo (string source, bool js=true, string staticdir="public") {
    enforce (hasDuo, "Duo command not available, please install");

    string command = format ("duo -o %s -t %s -c -S",
            staticdir, js ? "js" : "css");
    return getOutput (command, source);
}

string uglify (string source, bool js=true) {
    enforce (hasYuglify, "Uglify command not available");

    string command = format ("yuglify --terminal --type %s",
            js ? "js" : "css");
    return getOutput (command, source);
}

string getAssetPath (string path, string staticdir="public") {
    return buildPath(staticdir, path.chompPrefix("/"));
}

string compile (string source, bool js=true, string staticdir="public", bool min=true) {
    string compiled = duo (source, js, staticdir);
    return min ? uglify (compiled, js) : compiled;
}

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

alias require = memoize!build;
