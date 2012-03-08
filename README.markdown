Sundown
=======

`Sundown` is a Markdown parser based on the original code of the excellent [Upskirt library](http://fossil.instinctive.eu/libupskirt/index) by Natacha Porté.

This fork of Sundown adds Objective-C wrappers for Cocoa and Cocoa Touch and adds documentation.

Features
--------

*	**100% compatible with the official Markdown test suites**

	`Sundown` passes out of the box the official Markdown v1.0.0 and v1.0.3 test suites, and has been extensively tested with additional corner cases to make sure its output is as sane as possible at all times.

*	**Extension support**

	`Sundown` has optional support for several (unofficial) Markdown extensions, such as non-strict emphasis, fenced code blocks, tables, autolinks, strikethrough and more.

*	**UTF-8 aware**

	`Sundown` is fully UTF-8 aware for both source document parsing and (X)HTML output.

*	**Production ready**

	`Sundown` has been extensively security audited, and includes protection against DoS attacks (stack overflows, out of memory situations, malformed Markdown syntax, etc.) and against client attacks through malicious embedded HTML.

	We've worked very hard to make `Sundown` never crash or run out of memory under *any* input. `Sundown` renders all the Markdown content in GitHub and so far hasn't crashed a single time.
	
	While no code can ever be perfect, `Sundown` tries its best.

*	**Customizable renderers**

	`Sundown` is not limited to XHTML output: the Markdown parser of the library is decoupled from the renderer, so it's trivial to extend the library with custom renderers. A fully functional (X)HTML renderer is included.
	
	Note: The original `libupskirt` library had only a parser.

*	**Optimized for speed**

	`Sundown` is written in C, with a special emphasis on performance. When wrapped in a dynamic language such as Python or Ruby, it has been shown to be up to 40 times faster than other native alternatives.

*	**No dependencies**

	`Sundown` is a zero-dependency library, composed of a few `.c` files and their headers. It requires no external libraries and is written in fully standards-compliant C99.

Credits
-------

`Sundown` is based on the original Upskirt parser by Natacha Porté, with many additions by Vicent Marti (@tanoku) and contributions from the following authors:

	Ben Noordhuis, Bruno Michel, Joseph Koshy, Krzysztof Kowalczyk, Samuel Bronson, Shuhei Tanuma

This fork, including the Objective-C wrapper, is by Gwynne Raskind (@ameaijou) and could not exist without the work of Natacha Porté and Vicent Marti.

Bindings
--------

`Sundown` is available from other programming languages thanks to these bindings developed by various contributors:

- [Redcarpet](https://github.com/tanoku/redcarpet) (Ruby)
- [RobotSkirt](https://github.com/benmills/robotskirt) (Node.js)
- [Misaka](https://github.com/FSX/misaka) (Python)
- [ffi-sundown](https://github.com/postmodern/ffi-sundown) (Ruby FFI)
- [Sundown HS](https://github.com/rostayob/sundown) (Haskell)
- [Goskirt](https://github.com/madari/goskirt) (Go)
- [Upskirt.go](https://github.com/buu700/upskirt.go) (Go)
- [MoonShine](https://github.com/brandonc/moonshine) (.NET)
- [PHP-Sundown](https://github.com/chobie/php-sundown) (PHP)
- [Sundown.net](https://github.com/txdv/sundown.net) (.NET)
- [MKDParser](https://github.com/gwynne/sundown) (Cocoa/Cocoa Touch)

Help us
-------

`Sundown` is all about security. If you find a (potential) security vulnerability in the library, or a way to make it crash through malicious input, please report it to the original `sundown` fork at http://github.com/tanoku/sundown, either directly via email or by opening an issue on GitHub, and help make the Web safer for everybody.

Unicode character handling
--------------------------

Given that the original Markdown implementation makes no provision for Unicode character handling, `sundown` takes a conservative approach towards deciding which extended characters trigger Markdown features:

*	Punctuation characters outside of the U+007F codepoint are not handled as punctuation. They are considered as normal, in-word characters for word-boundary checks.

*	Whitespace characters outside of the U+007F codepoint are not considered as whitespace. They are considered as normal, in-word characters for word-boundary checks.

Install
-------

For users of the Objective-C wrapper, an Xcode project is included which builds a static library for both OS X and iOS targets. It is designed and intended to be included as a subproject in Xcode, but you can also add the source files to your project directly.

For users of the C API, there is nothing to install. `sundown` is composed of
4 `.c` files, so just throw them in your project. You can include
`render/html.c` if you want to use the included XHTML renderer, or write your
own renderer.

License
-------

The Objective-C wrapper and associated files are distributed under the following
license:

> Copyright (c) 2012, Gwynne Raskind. All rights reserved.
> 
> Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
> 
> Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
> 
> Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
> 
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The `sundown` library is distributed under the following license:

> Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
> 
> THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
