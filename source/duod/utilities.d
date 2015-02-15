module duod.utilities;
import std.array : appender;
import std.process : executeShell, pipeShell, Redirect, wait;

static bool hasDuo;
static bool hasYuglify;

shared static this () {
    hasDuo = !executeShell("duo --version").status;
    hasYuglify = !executeShell("yuglify --version").status;
}

string getOutput (string command) {
    auto pipes = pipeShell (command, Redirect.stdout);
    scope (exit) wait (pipes.pid);

    auto output = appender!string ();
    foreach (line; pipes.stdout.byLine ())
        output ~= line;
    return output.data;
}

string getOutput (string command, string input) {
    auto pipes = pipeShell (command, Redirect.stdin | Redirect.stdout);
    scope (exit) wait (pipes.pid);
    pipes.stdin.rawWrite (input);
    pipes.stdin.close ();

    auto output = appender!string ();
    foreach (line; pipes.stdout.byLine ())
        output ~= line;
    return output.data;
}
