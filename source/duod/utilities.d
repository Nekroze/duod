/++ Utilities for duod.
 +  Provides tools for checking if the build commands are available and executing them.
 +/
module duod.utilities;
import std.array : appender;
import std.process : executeShell, pipeShell, Redirect, wait;
/// True if the `duo` command is avilable at runtime
static bool hasDuo;
/// True if the `yuglify` command is avilable at runtime
static bool hasYuglify;
/// Once per runtime for all threads, checks for the existance of duo and yuglify commands.
shared static this () {
    hasDuo = !executeShell("duo --version").status;
    hasYuglify = !executeShell("yuglify --version").status;
}
/++ Get the output of a shell command after passing it some input.
 +  Params:
 +      command =   Shell command to run.
 +      input   =   Input to pass to the command via stdin. Defaults to no input.
 +  Returns: A string containing all stdout output from the given commands execution.
 +/
string getOutput (string command, string input="") {
    auto pipes = pipeShell (command, Redirect.stdin | Redirect.stdout);
    scope (exit) wait (pipes.pid);

    if (input)
        pipes.stdin.rawWrite (input);
    pipes.stdin.close ();

    auto output = appender!string ();
    foreach (line; pipes.stdout.byLine ())
        output ~= line;
    return output.data;
}
unittest {
    assert (getOutput ("echo test") == "test");
}
/// A simple example for giving a program input programatically and returning the result.
unittest {
    assert (getOutput ("awk '{print tolower($0)}'", "TEXT") == "text");
}
