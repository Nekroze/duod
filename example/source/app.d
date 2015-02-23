import vibe.d;
import duod;

shared static this()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    auto router = new URLRouter;
    router.get("/", &hello);
    router.get("*", serveStaticFiles("public/"));

    listenHTTP(settings, router);
    logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

void hello(HTTPServerRequest req, HTTPServerResponse res)
{
    res.render!"hello_duo.dt"();
}
