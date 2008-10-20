//
// SimpleIMEController.m
//
// Copyright (c) 2004-2008 The OpenVanilla Project (http://openvanilla.org)
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of OpenVanilla nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "SimpleIMEController.h"

@implementation SimpleIMEController
- (id)initWithServer:(IMKServer*)server delegate:(id)delegate client:(id)inputClient
{
	if (self = [super initWithServer:server delegate:delegate client:inputClient]) {
        _composingBuffer = [NSMutableString new];
	}

	return self;
}

- (void)dealloc
{
    [_composingBuffer release];
    [super dealloc];
}

- (void)activateServer:(id)sender
{
}

- (void)deactivateServer:(id)sender
{
}

- (void)commitComposition:(id)sender 
{    
    [sender insertText:_composingBuffer replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    [_composingBuffer setString:@""];
}

- (BOOL)handleEvent:(NSEvent*)event client:(id)sender
{    
    if ([event type] != NSKeyDown) {
		return NO;
	}
	
    BOOL handled = NO;	
	NSString *chars = [event characters];
	unsigned int cocoaModifiers = [event modifierFlags];
	unsigned short virtualKeyCode = [event keyCode];		
	
	if (cocoaModifiers & NSAlphaShiftKeyMask) ;
	if (cocoaModifiers & NSControlKeyMask) ;
	if (cocoaModifiers & NSAlternateKeyMask) ;

	UniChar unicharCode = [chars characterAtIndex:0];
	switch (unicharCode) {
		case 13:
			if ([_composingBuffer length]) {
				[self commitComposition:sender];
				return YES;
			}			
			return NO;
		
		case 27:
			[_composingBuffer setString:@""];
			handled = YES;
			break;
			
		default:
			[_composingBuffer appendString:chars];
			handled = YES;
			break;
	}

        
	NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:_composingBuffer attributes:[NSDictionary dictionary]] autorelease];    

    #if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5
		NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
								  [NSNumber numberWithInt:0], NSMarkedClauseSegmentAttributeName, nil];
    #else
		NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithInt:NSUnderlineStyleSingle], @"UnderlineStyleAttribute",
								  [NSNumber numberWithInt:0], @"MarkedClauseSegmentAttribute", nil];
    #endif		

	[attrString setAttributes:attrDict range:NSMakeRange(0, [_composingBuffer length])];  

	// selectionRange means "cursor position index"
	NSRange selectionRange = NSMakeRange([_composingBuffer length], 0); 
	[sender setMarkedText:attrString selectionRange:selectionRange replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
	
	/*
    // update caret position
    NSPoint caretPosition;
    NSRect lineHeightRect;
    [sender attributesForCharacterIndex:0 lineHeightRectangle:&lineHeightRect];
    caretPosition = [self _fixCaretPosition:lineHeightRect.origin];          
    */
	
    return handled;
}

- (void)_aboutAction:(id)sender
{
	[NSApp orderFrontStandardAboutPanel:sender];
}

- (NSMenu *)menu
{
	NSMenu *menu = [[NSMenu new] autorelease];
	
	NSMenuItem *menuItem = [[NSMenuItem new] autorelease];
	[menuItem setTarget:self];
	[menuItem setAction:@selector(_aboutAction:)];
	[menuItem setTitle:@"About SimpleIME"];
	[menu addItem:menuItem];
	return menu;
}

@end
