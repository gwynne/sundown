//
//  sundown-Tests.m
//  sundown
//  Created by Gwynne on 3/8/12.
//	
//	Copyright (c) 2012, Gwynne Raskind. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	
//	Redistributions of source code must retain the above copyright notice, this
//	list of conditions and the following disclaimer.
//
//	Redistributions in binary form must reproduce the above copyright notice,
//	this list of conditions and the following disclaimer in the documentation
//	and/or other materials provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//	POSSIBILITY OF SUCH DAMAGE.
//
//
//	Use of the Sundown library for Markdown parsing and rendering is governed
//	by the following copyrights and license:
//
//	Copyright (c) 2009, Natacha Porté
//	Copyright (c) 2011, Vicent Marti
//
//	Permission to use, copy, modify, and distribute this software for any
//	purpose with or without fee is hereby granted, provided that the above
//	copyright notice and this permission notice appear in all copies.
//	
//	THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//	WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//	MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//	SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//	WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
//	OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
//	CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

#import "sundown-Tests.h"

/******************************************************************************/
@implementation sundown_Tests

/******************************************************************************/
- (void)setUp
{
	[super setUp];
	
	// Set-up code here.
}

/******************************************************************************/
- (void)tearDown
{
	// Tear-down code here.
	
	[super tearDown];
}

/******************************************************************************/
- (void)parserDidBeginParsing:(MKDParser *)parser
{
	[parser.outputStream writeString:@"BEGIN PARSE\n"];
}

- (void)parserDidEndParsing:(MKDParser *)parser
{
	[parser.outputStream writeString:@"END PARSE\n"];
}

- (void)parser:(MKDParser *)parser didParseHeader:(NSString *)header atLevel:(int)level
{
	[parser.outputStream writeFormat:@"<h%d>%@</h%d>\n", level, header, level];
}

- (void)parser:(MKDParser *)parser didParseBlockCode:(NSString *)text withLanguage:(NSString *)lang
{
	[parser.outputStream writeFormat:@"<code lang=\"%@\">%@</code>\n", lang, text];
}

- (void)parser:(MKDParser *)parser didParseBlockQuote:(NSString *)text
{
	[parser.outputStream writeFormat:@"<blockquote>%@</blockquote>\n", text];
}

- (void)parser:(MKDParser *)parser didParseBlockHTML:(NSString *)html
{
	[parser.outputStream writeFormat:@"%@\n", html];
}

- (void)parserDidParseHorizontalRule:(MKDParser *)parser
{
	[parser.outputStream writeString:@"<hr />\n"];
}

- (void)parser:(MKDParser *)parser didParseList:(NSString *)list isOrdered:(BOOL)isOrdered
{
	[parser.outputStream writeFormat:@"<%cl>%@</%cl>\n", isOrdered ? 'o' : 'u', list, isOrdered ? 'o' : 'u'];
}

- (void)parser:(MKDParser *)parser didParseListItem:(NSString *)text asBlock:(BOOL)isBlock
{
	[parser.outputStream writeFormat:@"<li>%@</li>\n", text];
}

- (void)parser:(MKDParser *)parser didParseParagraph:(NSString *)text
{
	[parser.outputStream writeFormat:@"<p>%@</p>\n", text];
}

- (void)parser:(MKDParser *)parser didParseTableHeader:(NSString *)header withBody:(NSString *)body
{
	[parser.outputStream writeFormat:@"<table><caption>%@</caption>\n%@</table>\n", header, body];
}

- (void)parser:(MKDParser *)parser didParseTableRow:(NSString *)text
{
	[parser.outputStream writeFormat:@"<tr>%@</tr>", text];
}

- (void)parser:(MKDParser *)parser didParseTableCell:(NSString *)text withAlignment:(MKDCellAlignment)alignment isHeader:(BOOL)isHeader
{
	NSString *alignments[] = { [MKDCellAlignmentLeft] = @"left", [MKDCellAlignmentCenter] = @"center", [MKDCellAlignmentRight] = @"right" };
	
	[parser.outputStream writeFormat:@"<t%c style=\"text-align: %@\">%@</t%c>\n", isHeader ? 'h' : 'd', alignments[alignment], text, isHeader ? 'h' : 'd'];
}

- (void)parser:(MKDParser *)parser didParseCodespan:(NSString *)text
{
	[parser.outputStream writeFormat:@"<code>%@</code>", text];
}

- (void)parser:(MKDParser *)parser didParseEmphasis:(NSString *)text level:(int)level
{
	const char * const levels[] = { "", "i", "b", "emph" };
	
	[parser.outputStream writeFormat:@"<%s>%@</%s>", levels[level], text, levels[level]];
}

- (void)parser:(MKDParser *)parser didParseImage:(NSString *)src withTitle:(NSString *)title withAlt:(NSString *)alt
{
	[parser.outputStream writeFormat:@"<img src=\"%@\" alt=\"%@\" title=\"%@\" />", src, alt, title];
}

- (void)parser:(MKDParser *)parser didParseLink:(NSString *)url withTitle:(NSString *)title content:(NSString *)content
{
	[parser.outputStream writeFormat:@"<a href=\"%@\">%@%@</a>", url, content ?: @"", title ?: @""];
}

- (void)parserDidParseLineBreak:(MKDParser *)parser
{
	[parser.outputStream writeString:@"<br />"];
}

- (void)parser:(MKDParser *)parser didParseRawHTMLTag:(NSString *)tag
{
	[self parser:parser didParseNormalText:tag];
//	[parser.outputStream writeString:tag];
}

- (void)parser:(MKDParser *)parser didParseStrikethrough:(NSString *)text
{
	[parser.outputStream writeFormat:@"<strike>%@</strike>", text];
}

- (void)parser:(MKDParser *)parser didParseSuperscript:(NSString *)text
{
	[parser.outputStream writeFormat:@"<sup>%@</sup>", text];
}

- (void)parser:(MKDParser *)parser didParseEntity:(NSString *)entity
{
	[parser.outputStream writeString:entity];
}

- (void)parser:(MKDParser *)parser didParseNormalText:(NSString *)text
{
	text = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
	text = [text stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
	text = [text stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
	[parser.outputStream writeString:text];
}

/******************************************************************************/
- (void)testRenderer
{
	MKDParser		*parser = [[MKDParser alloc] initWithDelegate:self options:MKDParserOptionAutolink | MKDParserOptionAvoidInlineEmphasis |
								MKDParserOptionCaretSuperscript | MKDParserOptionFencedCode | MKDParserOptionRecognizeHTMLBlocks |
								MKDParserOptionTables | MKDParserOptionTildeStrikethrough | MKDParserOptionHashHeadersRequireSpace maxNestingLevel:128];
	
	NSLog(@"%@", [parser renderStringToString:
@"# Header 1\n"
@"## Header 2\n"
@"### Header 3\n"
@"#### Header 4\n"
@"##### Header 5\n"
@"###### Header 6\n"
@"\n"
@"_Emphasis 1_\n"
@"*Emphasis 2*\n"
@"_*Emphasis 3*_\n"
@"\n"
	]);
}

@end
