module duod.pipeline;
import duod.compilation;

import core.runtime : Runtime;
import std.string : format, toLower;
import std.path : buildPath, baseName, extension;
import std.algorithm : canFind;
/// Command line paramater that triggers an asset build.
enum buildSwitch = "--duod-build";
/// A statically served directory.
shared static string staticDir = "public";
/// The URL path that `staticDir` is mapped to.
shared static string webStaticDir = "/";
/++ This template, when instantiated represents a front end asset.
 +  The power of this template is in its differing actions from first
 +  instantiation compared to all others calls.
 +
 +  When first instantiated this template will check for a command line
 +  parameter that matches `buildSwitch` and if found compile the asset
 +  that it describes. In any other case the template will provide
 +  properties describing the assets whereabouts and the HTML required
 +  required to include the compiled asset.
 +
 +  Param:
 +      sourcePath =    The path to an assets source, relative to the
 +                      compiled binary.
 +/
template Asset (string sourcePath) {
    /// URL path to this asset from the web.
    static immutable string webPath;
    /// Path to the assets source file.
    static immutable string staticPath;
    /// HTML required to include the compiled asset.
    static immutable string require;

    /// At launch constructor, constructs paths, html, and (if required) asset.
    static this () {
        webPath = buildPath(webStaticDir, baseName(sourcePath));
        staticPath = buildPath (staticDir, baseName(sourcePath));
        require = extension(staticPath).toLower() == "css" ?
            format ("<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">", webPath) :
            format ("<script type=\"text/javascript\" src=\"%s\"></script>", webPath);

        if (Runtime.args.canFind (buildSwitch)) {
            build (sourcePath, staticPath, staticDir);
        }
    }
} unittest {
    enum testAsset = "unittests/duod-pipeline.js";
    assert(Asset!testAsset.webPath == "/duod-pipeline.js");
    assert(Asset!testAsset.staticPath == "public/duod-pipeline.js");
    assert(Asset!testAsset.require == "<script type=\"text/javascript\" src=\"/duod-pipeline.js\"></script>");
}
