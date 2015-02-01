# SassMeister #

Become a Sass master with SassMeister, the Sass playground.


## Installation ##

__tl;dr:__ Running the app locally is much more involved than it used to be. 

Up through version 2.0 of SassMeister, local set up and installation was fairly straightforward, but with [the introduction of support for LibSass in January 2014](https://twitter.com/sassmeisterapp/status/420093890729766912), things got... complicated.

I may someday write an article on the evolution of the architecture of SassMeister, but that's a much longer story than I can fit in a simple README. For now, here are some highlights. 

In order to support LibSass—and to offer both Sass 3.3 _and_ 3.2—I broke out the "compile" functions of SassMeister to separate apps. Sass compilation now happens in dedicated apps, giving each version of Sass its own sandbox. That refactor leaves this app with responsibility for the front end and communication with the GitHub API. I also saw _significant_ improvements in performance and throughput by moving computationally heavy compilation away from the front end app. 

These micro-service apps are:

* [Sass 3.4 compiler app](https://github.com/SassMeister/sass34.sassmeister), compiles against Sass 3.4. This is the default compiler, if you only install one compiler, this should be it.
* [Sass 3.3 compiler app](https://github.com/SassMeister/sass33.sassmeister), compiles against Sass 3.3. Optional.
* [Sass 3.2 compiler app](https://github.com/SassMeister/sass32.sassmeister), compiles against Sass 3.2. Optional.
* [LibSass compiler app](https://github.com/SassMeister/libsass.sassmeister), compiles against libsass. Optional. This is a Node.js app, not a Ruby app, like the others.
* [HTML compiler app](https://github.com/SassMeister/sandbox.sassmeister), compiles HTML. Optional.

Full installation instructions would be overwhelming for this document; if you _really_ want to run SassMeister locally, and run into trouble, [contact me](https://twitter.com/jed_foster) and I'll help you out.

## Caveats

@imports will probably not work the way you'd expect. Spriting with Compass will definitely not work.

If you find anything else that doesn't work, please let me know.

## Authors

SassMeister and all supporting apps are written by [Jed Foster][jedfoster]. I credit [@anotheruiguy](https://github.com/anotheruiguy) with the original idea for SassMeister, and he has provided very helpful advice through the years.

The name was inspired by a [Seattle Sass Meetup][meetup] presentation from [PeepCode Screencasts][peepcode].

## License

Copyright (c) 2012-2015 Jed Foster

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[jedfoster]: http://jedfoster.com
[meetup]: http://www.meetup.com/SASSlang/
[peepcode]: [https://peepcode.com]

