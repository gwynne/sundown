//
//  MKDParser.h
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

#import <Foundation/Foundation.h>
#import "markdown.h"

/******************************************************************************/
typedef enum
{
	// Do not count underscores inside words (i.e. my_function_name) as
	//	emphasis.
	MKDParserOptionAvoidInlineEmphasis		= MKDEXT_NO_INTRA_EMPHASIS,
	
	// Interpret tables syntax.
	MKDParserOptionTables					= MKDEXT_TABLES,
	
	// Use ``` as fencing for code blocks.
	MKDParserOptionFencedCode				= MKDEXT_FENCED_CODE,
	
	// Automatically recognize various types of URLs in the Markdown without
	//	explicit annotation.
	MKDParserOptionAutolink					= MKDEXT_AUTOLINK,
	
	// Recognize ~ as strikethrough.
	MKDParserOptionTildeStrikethrough		= MKDEXT_STRIKETHROUGH,
	
	// Recognize various raw HTML blocks in regular paragraphs.
	MKDParserOptionRecognizeHTMLBlocks		= MKDEXT_LAX_HTML_BLOCKS,
	
	// Require spaces after hashes to recognize headers (maybe?)
	MKDParserOptionHashHeadersRequireSpace	= MKDEXT_SPACE_HEADERS,
	
	// Recognize ^ as superscript.
	MKDParserOptionCaretSuperscript			= MKDEXT_SUPERSCRIPT,
} MKDParserOptions;

/******************************************************************************/
typedef enum
{
    MKDCellAlignmentLeft = 0,
    MKDCellAlignmentCenter,
    MKDCellAlignmentRight,
} MKDCellAlignment;

/******************************************************************************/
@class MKDParser;

/******************************************************************************/
@protocol MKDParserDelegate <NSObject>

@optional
- (void)parserDidBeginParsing:(MKDParser *)parser;
- (void)parser:(MKDParser *)parser didParseBlockCode:(NSString *)text withLanguage:(NSString *)lang;
- (void)parser:(MKDParser *)parser didParseBlockQuote:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseBlockHTML:(NSString *)html;
- (void)parser:(MKDParser *)parser didParseHeader:(NSString *)header atLevel:(int)level;
- (void)parserDidParseHorizontalRule:(MKDParser *)parser;
- (void)parser:(MKDParser *)parser didParseList:(NSString *)list isOrdered:(BOOL)isOrdered;
- (void)parser:(MKDParser *)parser didParseListItem:(NSString *)text asBlock:(BOOL)isBlock;
- (void)parser:(MKDParser *)parser didParseParagraph:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseTableHeader:(NSString *)header withBody:(NSString *)body;
- (void)parser:(MKDParser *)parser didParseTableRow:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseTableCell:(NSString *)text withAlignment:(MKDCellAlignment)alignment isHeader:(BOOL)isHeader;
- (void)parser:(MKDParser *)parser didParseCodespan:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseEmphasis:(NSString *)text level:(int)level;
- (void)parser:(MKDParser *)parser didParseImage:(NSString *)src withTitle:(NSString *)title withAlt:(NSString *)alt;
- (void)parser:(MKDParser *)parser didParseLink:(NSString *)url withTitle:(NSString *)title content:(NSString *)content;
- (void)parserDidParseLineBreak:(MKDParser *)parser;
- (void)parser:(MKDParser *)parser didParseRawHTMLTag:(NSString *)tag;
- (void)parser:(MKDParser *)parser didParseStrikethrough:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseSuperscript:(NSString *)text;
- (void)parser:(MKDParser *)parser didParseEntity:(NSString *)entity;
- (void)parser:(MKDParser *)parser didParseNormalText:(NSString *)text;
- (void)parserDidEndParsing:(MKDParser *)parser;

@end

/******************************************************************************/
@interface MKDParser : NSObject

// Return the version of the Sundown library in use.
+ (NSString *)sundownVersion;

- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_;
- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_ options:(MKDParserOptions)options_;
- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_ options:(MKDParserOptions)options_ maxNestingLevel:(NSUInteger)maxNestingLevel_;

@property(nonatomic,weak)				id<MKDParserDelegate>		delegate;
@property(nonatomic,assign)				MKDParserOptions			options;
@property(nonatomic,assign)				NSUInteger					maxNestingLevel;

// Valid only in delegate callbacks. Output data to this stream.
@property(nonatomic,strong,readonly)	NSOutputStream				*outputStream;

- (NSString *)renderStringToString:(NSString *)input;
- (NSString *)renderFileToString:(NSURL *)inputFile;
- (void)renderStream:(NSInputStream *)input toStream:(NSOutputStream *)output;

@end

/******************************************************************************/
@interface NSOutputStream (MKDParserExtensions)

- (void)writeFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)writeFormat:(NSString *)format arguments:(va_list)args NS_FORMAT_FUNCTION(1, 0);
- (void)writeString:(NSString *)string;
- (void)writeData:(NSData *)data;

@end
