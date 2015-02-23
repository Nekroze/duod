module duod.pipeline;
import duod.compilation;

import core.runtime : Runtime;
import std.string : format, toLower;
import std.path : buildPath, baseName, extension;
import std.algorithm : canFind, endsWith;
/// Command line paramater that triggers an asset build.
enum buildSwitch = "--duod-build";
/// A statically served directory.
const string staticDir = "public";
/// The URL path that `staticDir` is mapped to.
const string webStaticDir = "/";
/++ This template, when instantiated represents a front end asset.
 +  The power of this template is in its differing actions from first
 +  instantiation compared to all others calls.
 +
 +  When first instantiated this template will check for a command line
 +  parameter that matches `buildSwitch` and if found compile the asset
 +  that it describes. In order to easily utilize this asset the template
 +  may be used in a mixin inside of a diet template file which will setup
 +  the HTML required required to include the compiled asset.
 +
 +  Param:
 +      sourcePath =    The path to an assets source, relative to the
 +                      compiled binary.
 +/
template Require (const string sourcePath) {
    /// URL path to this asset from the web.
    const string webPath = buildPath (webStaticDir, baseName(sourcePath));
    /// Path to the assets source file.
    const string staticPath = buildPath (staticDir, baseName(sourcePath));
    /// This is the mixin code for diet templates.
    const string Require = sourcePath[$-3..$] == "css" ?
        "output__.put(\"\\n<link rel=\\\"stylesheet\\\" type=\\\"text/css\\\" href=\\\""~webPath~"\\\">\");"
        :
        "output__.put(\"\\n<script type=\\\"text/javascript\\\" src=\\\""~webPath~"\\\"></script>\");";
    shared static this () {
        if (Runtime.args.canFind (buildSwitch)) {
            build (sourcePath, staticPath, staticDir);
        }
    }
} unittest {
    enum testAsset = "unittests/duod-pipeline.js";
    assert(Require!testAsset == "output__.put(\"\\n<script type=\\\"text/javascript\\\" src=\\\"/duod-pipeline.js\\\"></script>\");");
}
