// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheFilteredExpression_private.h"
#import "GRMustacheFilter.h"

@interface GRMustacheFilteredExpression()
@property (nonatomic, retain) id<GRMustacheExpression> filterExpression;
@property (nonatomic, retain) id<GRMustacheExpression> parameterExpression;
- (id)initWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression;
@end

@implementation GRMustacheFilteredExpression
@synthesize filterExpression = _filterExpression;
@synthesize parameterExpression = _parameterExpression;

+ (id)expressionWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression
{
    return [[[self alloc] initWithFilterExpression:filterExpression parameterExpression:parameterExpression] autorelease];
}

- (id)initWithFilterExpression:(id<GRMustacheExpression>)filterExpression parameterExpression:(id<GRMustacheExpression>)parameterExpression
{
    self = [super init];
    if (self) {
        _filterExpression = [filterExpression retain];
        _parameterExpression = [parameterExpression retain];
    }
    return self;
}

- (void)dealloc
{
    [_filterExpression release];
    [_parameterExpression release];
    [super dealloc];
}

- (BOOL)isEqual:(id<GRMustacheExpression>)expression
{
    if (![expression isKindOfClass:[GRMustacheFilteredExpression class]]) {
        return NO;
    }
    if (![_filterExpression isEqual:((GRMustacheFilteredExpression *)expression).filterExpression]) {
        return NO;
    }
    return [_parameterExpression isEqual:((GRMustacheFilteredExpression *)expression).parameterExpression];
}


#pragma mark GRMustacheExpression

- (id)valueForContext:(GRMustacheContext *)context filterContext:(GRMustacheContext *)filterContext
{
    id parameter = [_parameterExpression valueForContext:context filterContext:filterContext];
    id<GRMustacheFilter> filter = [_filterExpression valueForContext:filterContext filterContext:nil];
    
    if (filter == nil) {
        [NSException raise:GRMustacheFilterException format:@"Missing filter"];
    }
    
    if (![filter conformsToProtocol:@protocol(GRMustacheFilter)]) {
        [NSException raise:GRMustacheFilterException format:@"Object does not conform to GRMustacheFilter protocol"];
    }
    
    return [filter transformedValue:parameter];
}

@end
