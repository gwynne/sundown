//
//  MKDParser.m
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

#import "MKDParser.h"

/******************************************************************************/
@implementation NSOutputStream (MKDParserExtensions)

/******************************************************************************/
- (void)writeFormat:(NSString *)format, ...
{
	va_list		args;
	
	va_start(args, format);
	[self writeFormat:format arguments:args];
	va_end(args);
}

/******************************************************************************/
- (void)writeFormat:(NSString *)format arguments:(va_list)args
{
	[self writeString:[[NSString alloc] initWithFormat:format arguments:args]];
}

/******************************************************************************/
- (void)writeString:(NSString *)string
{
	[self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

/******************************************************************************/
- (void)writeData:(NSData *)data
{
	[self write:data.bytes maxLength:data.length];
}

@end

/******************************************************************************/
@interface MKDBufferStream : NSOutputStream
- (id)initWithBuf:(struct buf *)buf_;
@property(nonatomic,assign)	struct buf *buf;
- (void)pushBuf:(struct buf *)buf_;
- (void)popBuf;
@end

@implementation MKDBufferStream
{
	struct buf *_saveBuf;
}

@synthesize buf;

- (id)initWithBuf:(struct buf *)buf_
{
	if ((self = [super init]))
	{
		buf = buf_;
	}
	return self;
}

- (void)pushBuf:(struct buf *)buf_
{
	_saveBuf = buf;
	buf = buf_;
}

- (void)popBuf
{
	buf = _saveBuf;
}

- (BOOL)hasSpaceAvailable { return YES; }

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
	bufput(buf, buffer, len);
	return len;
}

@end

/******************************************************************************/
static inline MKDParser	* __attribute__((const)) MKDGetParser(void *opaque) { return (__bridge MKDParser *)opaque; }
static inline MKDBufferStream * __attribute__((const)) MKDGetStream(void *opaque) { return (MKDBufferStream *)MKDGetParser(opaque).outputStream; }
static inline void MKDPushBuf(void *opaque, struct buf *b) { [MKDGetStream(opaque) pushBuf:b]; }
static inline void MKDPopBuf(void *opaque) { [MKDGetStream(opaque) popBuf]; }

/******************************************************************************/
static inline NSString *NSStringFromBuf(const struct buf *b)
{
	return b ? [[NSString alloc] initWithBytesNoCopy:b->data length:b->size encoding:NSUTF8StringEncoding freeWhenDone:NO] : @"<null>";
}

/******************************************************************************/
static void	MKDParseBlockcode(struct buf *ob, const struct buf *text, const struct buf *lang, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseBlockCode:withLanguage:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseBlockCode:NSStringFromBuf(text) withLanguage:NSStringFromBuf(lang)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseBlockquote(struct buf *ob, const struct buf *text, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseBlockQuote:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseBlockQuote:NSStringFromBuf(text)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseBlockHTML(struct buf *ob, const struct buf *text, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseBlockHTML:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseBlockHTML:NSStringFromBuf(text)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseHeader(struct buf *ob, const struct buf *text, int level, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseHeader:atLevel:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseHeader:NSStringFromBuf(text) atLevel:level];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseHRule(struct buf *ob, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parserDidParseHorizontalRule:)])
		[MKDGetParser(opaque).delegate parserDidParseHorizontalRule:MKDGetParser(opaque)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseList(struct buf *ob, const struct buf *text, int flags, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseList:isOrdered:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseList:NSStringFromBuf(text) isOrdered:(flags & MKD_LIST_ORDERED) != 0];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void MKDParseListItem(struct buf *ob, const struct buf *text, int flags, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseListItem:asBlock:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseListItem:NSStringFromBuf(text) asBlock:(flags & MKD_LI_BLOCK) != 0];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseParagraph(struct buf *ob, const struct buf *text, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseParagraph:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseParagraph:NSStringFromBuf(text)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseTable(struct buf *ob, const struct buf *header, const struct buf *body, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseTableHeader:withBody:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseTableHeader:NSStringFromBuf(header) withBody:NSStringFromBuf(body)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseTableRow(struct buf *ob, const struct buf *text, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseTableRow:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseTableRow:NSStringFromBuf(text)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseTableCell(struct buf *ob, const struct buf *text, int flags, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseTableCell:withAlignment:isHeader:)])
	{
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseTableCell:NSStringFromBuf(text)
									   withAlignment:(flags & MKD_TABLE_ALIGNMASK) isHeader:(flags & MKD_TABLE_HEADER) != 0];
	}
	MKDPopBuf(opaque);
}

/******************************************************************************/
static int	MKDParseAutolink(struct buf *ob, const struct buf *link, enum mkd_autolink type, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseLink:withTitle:content:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseLink:NSStringFromBuf(link) withTitle:@"" content:NSStringFromBuf(link)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseCodespan(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseCodespan:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseCodespan:NSStringFromBuf(text)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseDoubleEmphasis(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseEmphasis:level:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseEmphasis:NSStringFromBuf(text) level:2];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseEmphasis(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseEmphasis:level:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseEmphasis:NSStringFromBuf(text) level:1];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseImage(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *alt, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseImage:withTitle:withAlt:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseImage:NSStringFromBuf(link) withTitle:NSStringFromBuf(title) withAlt:NSStringFromBuf(alt)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseLinebreak(struct buf *ob, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parserDidParseLineBreak:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parserDidParseLineBreak:MKDGetParser(opaque)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseLink(struct buf *ob, const struct buf *link, const struct buf *title, const struct buf *content, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseLink:withTitle:content:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseLink:NSStringFromBuf(link) withTitle:NSStringFromBuf(title) content:NSStringFromBuf(content)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseRawHTMLTag(struct buf *ob, const struct buf *tag, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseRawHTMLTag:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseRawHTMLTag:NSStringFromBuf(tag)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseTripleEmphasis(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseEmphasis:level:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseEmphasis:NSStringFromBuf(text) level:3];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseStrikethrough(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseStrikethrough:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseStrikethrough:NSStringFromBuf(text)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static int	MKDParseSuperscript(struct buf *ob, const struct buf *text, void *opaque)
{
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseSuperscript:)])
	{
		MKDPushBuf(opaque, ob);
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseSuperscript:NSStringFromBuf(text)];
		MKDPopBuf(opaque);
	}
	else
		return 0;
	return 1;
}

/******************************************************************************/
static void	MKDParseEntity(struct buf *ob, const struct buf *entity, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseEntity:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseEntity:NSStringFromBuf(entity)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseNormalText(struct buf *ob, const struct buf *text, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parser:didParseNormalText:)])
		[MKDGetParser(opaque).delegate parser:MKDGetParser(opaque) didParseNormalText:NSStringFromBuf(text)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseDocHeader(struct buf *ob, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parserDidBeginParsing:)])
		[MKDGetParser(opaque).delegate parserDidBeginParsing:MKDGetParser(opaque)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static void	MKDParseDocFooter(struct buf *ob, void *opaque)
{
	MKDPushBuf(opaque, ob);
	if ([MKDGetParser(opaque).delegate respondsToSelector:@selector(parserDidEndParsing:)])
		[MKDGetParser(opaque).delegate parserDidEndParsing:MKDGetParser(opaque)];
	MKDPopBuf(opaque);
}

/******************************************************************************/
static const struct sd_callbacks		MKDParserCallbacks = {
	.blockcode = MKDParseBlockcode,		.blockquote = MKDParseBlockquote,			.blockhtml = MKDParseBlockHTML,
	.header = MKDParseHeader,			.hrule = MKDParseHRule,						.list = MKDParseList,
	.listitem = MKDParseListItem,		.paragraph = MKDParseParagraph,				.table = MKDParseTable,
	.table_row = MKDParseTableRow,		.table_cell = MKDParseTableCell,			.autolink = MKDParseAutolink,
	.codespan = MKDParseCodespan,		.double_emphasis = MKDParseDoubleEmphasis,	.emphasis = MKDParseEmphasis,
	.image = MKDParseImage,				.linebreak = MKDParseLinebreak,				.link = MKDParseLink,
	.raw_html_tag = MKDParseRawHTMLTag,	.triple_emphasis = MKDParseTripleEmphasis,	.strikethrough = MKDParseStrikethrough,
	.superscript = MKDParseSuperscript,	.entity = MKDParseEntity,					.normal_text = MKDParseNormalText,
	.doc_header = MKDParseDocHeader,	.doc_footer = MKDParseDocFooter,
};

/******************************************************************************/
@interface MKDParser ()
@property(nonatomic,strong,readwrite)	NSOutputStream	*outputStream;
@end

/******************************************************************************/
@implementation MKDParser
{
	struct sd_markdown		*renderer;
}

/******************************************************************************/
@synthesize delegate, options, maxNestingLevel, outputStream;

/******************************************************************************/
+ (NSString *)sundownVersion
{
	int			major, minor, patch;
	
	sd_version(&major, &minor, &patch);
	return [NSString stringWithFormat:@"%d.%d.%d", major, minor, patch];
}

/******************************************************************************/
- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_
{
	return [self initWithDelegate:delegate_ options:0 maxNestingLevel:32];
}

/******************************************************************************/
- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_ options:(MKDParserOptions)options_
{
	return [self initWithDelegate:delegate_ options:options_ maxNestingLevel:32];
}

/******************************************************************************/
- (id)initWithDelegate:(id<MKDParserDelegate>)delegate_ options:(MKDParserOptions)options_ maxNestingLevel:(NSUInteger)maxNestingLevel_
{
	if ((self = [super init]))
	{
		delegate = delegate_;
		options = options_;
		maxNestingLevel = maxNestingLevel_;
	}
	return self;
}

/******************************************************************************/
- (NSString *)renderStringToString:(NSString *)input
{
	NSInputStream		*instream = [NSInputStream inputStreamWithData:[input dataUsingEncoding:NSUTF8StringEncoding]];
	NSOutputStream		*outstream = [NSOutputStream outputStreamToMemory];
	
	[self renderStream:instream toStream:outstream];
	return [[NSString alloc] initWithData:[outstream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:NSUTF8StringEncoding];
}

/******************************************************************************/
- (NSString *)renderFileToString:(NSURL *)inputFile
{
	NSInputStream		*instream = [NSInputStream inputStreamWithURL:inputFile];
	NSOutputStream		*outstream = [NSOutputStream outputStreamToMemory];
	
	[self renderStream:instream toStream:outstream];
	return [[NSString alloc] initWithData:[outstream propertyForKey:NSStreamDataWrittenToMemoryStreamKey] encoding:NSUTF8StringEncoding];
}

/******************************************************************************/
- (void)renderStream:(NSInputStream *)input toStream:(NSOutputStream *)output
{
	renderer = sd_markdown_new(options, maxNestingLevel, &MKDParserCallbacks, (__bridge void *)self);
	
	// All the extra data copying implied here is badly suboptimal. In the
	//	future, modify the buffer functionality in sundown for streaming.
	NSMutableData			*indata = [NSMutableData data];
	
	[input open];
	while ([input hasBytesAvailable])
	{
		uint8_t				buffer[1024] = { 0 };
		NSUInteger			bread = 0;
		
		bread = [input read:buffer maxLength:sizeof(buffer) / sizeof(uint8_t)];
		if (bread > 0)
			[indata appendBytes:buffer length:bread];
	}
	[input close];
	
	struct buf				*ob = bufnew(64);
	
	outputStream = [[MKDBufferStream alloc] initWithBuf:ob];
	sd_markdown_render(ob, indata.bytes, indata.length, renderer);
	[output open];
	[output write:ob->data maxLength:ob->size];
	[output close];
	bufrelease(ob);
	outputStream = nil;
	sd_markdown_free(renderer);
	renderer = NULL;
}

@end
