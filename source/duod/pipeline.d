module duod.pipeline;

import core.atomic : atomicOp;
import std.path : buildPath, baseName, extension;
import std.string : format, toLower;
version (unittest)
    import std.algorithm : count;


shared string[] registeredAssets;
shared string staticDir = "public";
shared string webStaticDir = "/";


template Asset (string sourcePath) {
    shared static immutable string webPath;
    shared static immutable string staticPath;
    shared static immutable string require;

    shared static this () {
        webPath = buildPath(webStaticDir, baseName(sourcePath));
        staticPath = buildPath (staticDir, baseName(sourcePath));
        require = extension(staticPath).toLower() == "css" ?
            format ("<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">", webPath) :
            format ("<script type=\"text/javascript\" src=\"%s\"></script>", webPath);

        registeredAssets ~= sourcePath;
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
