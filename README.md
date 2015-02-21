DuoD
====

By combining the powers of [Duo](https://duojs.org) and D's templates, *DuoD*
provides a simple method to integrate the construction of frontend web
resources with ease.

[Duo](https://duojs.org) allows you to write simple front end requirement
files that pull in their dependencies when constructed. Combined with D's
awesome templating, these assets can be constructed and utilized anywhere
in your code or even in a [Vibe.d](https://vibed.org) diet template!.

Usage
=====

Once *DuoD* is imported (`import duod;`) you can, simultaniously, register
an asset to be built when the `--duod-build` switch is given to your
application, as well as write the code to use that asset like so:

``` D
    Asset!"assets/index.css".require;
```

This will return the HTML code to use the resource when it is built which
aslo allows this to be used in a deit template.


Example
=======

Please see the examples directory of the repository for a usage example.
