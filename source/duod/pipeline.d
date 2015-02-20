module duod.pipeline;

import core.atomic : atomicOp;
import std.path : buildPath, baseName, extension;
import std.string : format, toLower;
version (unittest)
    import std.algorithm : canFind;


shared string[] registeredAssets;
shared string staticDir = "public";
shared string webStaticDir = "/";


template Asset (string sourcePath) {
    static immutable string webPath;
    static immutable string staticPath;
    static immutable string require;

    shared static this () {
        webPath = buildPath(webStaticDir, baseName(sourcePath));
        staticPath = buildPath (staticDir, baseName(sourcePath));
        require = extension(staticPath).toLower() == "css" ?
            format ("<link rel=\"stylesheet\" type=\"text/css\" href=\"%s\">", webPath) :
            format ("<script type=\"text/javascript\" src=\"%s\"></script>", webPath);

        registeredAssets ~= sourcePath;
        //atomicOp!"~="(registeredAssets, sourcePath);
    }
} unittest {
    assert(Asset!"assets/index.js".webPath == "/index.js");
    assert(Asset!"assets/index.js".staticPath == "public/index.js");
    assert(Asset!"assets/index.js".require == "<script type=\"text/javascript\" src=\"/index.js\"></script>");
    assert(registeredAssets.length == 1);
}
