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

Once *DuoD* is imported (`import duod;`) you can setup an asset to be
built when the `--duod-build` switch is given to your application:

``` D
    Require!"assets/index.css";
```

But what is really fun is using the above command in a diet template
with a mixin.

``` jade
    - mixin(Require!"assets/index.css");
```

This is all that is required to provide the same build functionality as
well as placing the HTML to use the asset in the rendered template output!

Example
=======

Please see the examples directory of the repository for a usage example.
