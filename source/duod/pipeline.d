module duod.pipeline;
import duod.compilation;

import std.runtime : runtime;
import std.string : format, toLower;
import std.path : buildPath, baseName, extension;
import std.algorithm : canFind;

enum buildSwitch = "--duod-build";
shared string[] registeredAssets;
shared string staticDir = "public";
shared string webStaticDir = "/";


template Asset (string sourcePath) {
    shared static immutable string webPath;
    shared static immutable string staticPath;
    shared static immutable string require;

    shared static this () {
        registeredAssets ~= sourcePath;
    }

    static this () {
        webPath = buildPath(webStaticDir, baseName(sourcePath));
        staticPath = buildPath (staticDir, baseName(sourcePath));
        require = extension(staticPath).toLower() == "css" ?
            format ("<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">", webPath) :
            format ("<script type=\"text/javascript\" src=\"%s\"></script>", webPath);

        if (runtime.args.canFind (buildSwitch)) {
            build (sourcePath, staticPath, staticDir)
        }
    }
} unittest {
    enum testAsset = "unittests/duod-pipeline.js";
    assert(Asset!testAsset.webPath == "/duod-pipeline.js");
    assert(Asset!testAsset.staticPath == "public/duod-pipeline.js");
    assert(Asset!testAsset.require == "<script type=\"text/javascript\" src=\"/duod-pipeline.js\"></script>");
    int count;
    foreach (string a; registeredAssets)
        if (a == testAsset) count += 1;
    assert(count == 1);
}
