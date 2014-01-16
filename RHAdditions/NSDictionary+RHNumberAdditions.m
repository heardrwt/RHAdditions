//
//  NSDictionary+RHNumberAdditions.m
//
//  Created by Richard Heard on 15/07/13.
//  Copyright (c) 2013 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDictionary+RHNumberAdditions.h"

@implementation NSDictionary (RHNumberAdditions)

-(NSNumber *)numberForKey:(id)aKey {
    id object = [self objectForKey:aKey];
    if ([object isKindOfClass:[NSNumber class]]) return object;
    return nil;
}

//primitive getters
-(BOOL)boolForKey:(id)aKey                           { return [[self numberForKey:aKey] boolValue];             }
-(int)intForKey:(id)aKey                             { return [[self numberForKey:aKey] intValue];              }
-(long)longForKey:(id)aKey                           { return [[self numberForKey:aKey] longValue];             }
-(unsigned long)unsignedLongForKey:(id)aKey          { return [[self numberForKey:aKey] unsignedLongValue];     }
-(long long)longLongForKey:(id)aKey                  { return [[self numberForKey:aKey] longLongValue];         }
-(unsigned long long)unsignedLongLongForKey:(id)aKey { return [[self numberForKey:aKey] unsignedLongLongValue]; }
-(double)doubleForKey:(id)aKey                       { return [[self numberForKey:aKey] doubleValue];           }
-(float)floatForKey:(id)aKey                         { return [[self numberForKey:aKey] floatValue];            }
-(NSInteger)integerForKey:(id)aKey                   { return [[self numberForKey:aKey] integerValue];          }
-(NSUInteger)usignedIntegerForKey:(id)aKey           { return [[self numberForKey:aKey] unsignedIntegerValue];  }

@end

@implementation NSMutableDictionary (RHNumberAdditions)

//primitive insertions
-(void)setBool:(BOOL)value forKey:(id <NSCopying>)aKey                           { [self setObject:[NSNumber numberWithBool:value] forKey:aKey];             }
-(void)setInt:(int)value forKey:(id <NSCopying>)aKey                             { [self setObject:[NSNumber numberWithInt:value] forKey:aKey];              }
-(void)setLong:(long)value forKey:(id <NSCopying>)aKey                           { [self setObject:[NSNumber numberWithLong:value] forKey:aKey];             }
-(void)setUnsignedLong:(unsigned long)value forKey:(id <NSCopying>)aKey          { [self setObject:[NSNumber numberWithUnsignedLong:value] forKey:aKey];     }
-(void)setLongLong:(long long)value forKey:(id <NSCopying>)aKey                  { [self setObject:[NSNumber numberWithLongLong:value] forKey:aKey];         }
-(void)setUnsignedLongLong:(unsigned long long)value forKey:(id <NSCopying>)aKey { [self setObject:[NSNumber numberWithUnsignedLongLong:value] forKey:aKey]; }
-(void)setDouble:(double)value forKey:(id <NSCopying>)aKey                       { [self setObject:[NSNumber numberWithDouble:value] forKey:aKey];           }
-(void)setFloat:(float)value forKey:(id <NSCopying>)aKey                         { [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];            }
-(void)setInteger:(NSInteger)value forKey:(id <NSCopying>)aKey                   { [self setObject:[NSNumber numberWithInteger:value] forKey:aKey];          }
-(void)setUnsignedInteger:(NSUInteger)value forKey:(id <NSCopying>)aKey          { [self setObject:[NSNumber numberWithUnsignedInteger:value] forKey:aKey];  }

@end

@implementation NSUserDefaults (RHNumberAdditions)

-(NSNumber *)numberForKey:(NSString *)aKey {
    id object = [self objectForKey:aKey];
    if ([object isKindOfClass:[NSNumber class]]) return object;
    return nil;
}

-(int)intForKey:(NSString *)aKey                             { return [[self numberForKey:aKey] intValue];              }
-(long)longForKey:(NSString *)aKey;                          { return [[self numberForKey:aKey] longValue];             }
-(unsigned long)unsignedLongForKey:(NSString *)aKey          { return [[self numberForKey:aKey] unsignedLongValue];     }
-(long long)longLongForKey:(NSString *)aKey                  { return [[self numberForKey:aKey] longLongValue];         }
-(unsigned long long)unsignedLongLongForKey:(NSString *)aKey { return [[self numberForKey:aKey] unsignedLongLongValue]; }
-(NSUInteger)usignedIntegerForKey:(NSString *)aKey           { return [[self numberForKey:aKey] unsignedIntegerValue];  }

-(void)setInt:(int)value forKey:(NSString *)aKey                             { [self setObject:[NSNumber numberWithInt:value] forKey:aKey];              }
-(void)setLong:(long)value forKey:(NSString *)aKey                           { [self setObject:[NSNumber numberWithLong:value] forKey:aKey];             }
-(void)setLongLong:(long long)value forKey:(NSString *)aKey                  { [self setObject:[NSNumber numberWithLongLong:value] forKey:aKey];         }
-(void)setUnsignedLongLong:(unsigned long long)value forKey:(NSString *)aKey { [self setObject:[NSNumber numberWithUnsignedLongLong:value] forKey:aKey]; }
-(void)setUnsignedInteger:(NSUInteger)value forKey:(NSString *)aKey          { [self setObject:[NSNumber numberWithUnsignedInteger:value] forKey:aKey];  }

-(void)incrementKey:(NSString *)aKey { [self incrementKey:aKey byAmount:1];  }
-(void)decrementKey:(NSString *)aKey { [self incrementKey:aKey byAmount:-1]; }

-(void)incrementKey:(NSString *)aKey byAmount:(NSInteger)amount { [self setInteger:([self integerForKey:aKey] + amount) forKey:aKey]; }

@end

//include an implementation in this file so we don't have to use -load_all for this category to be included in a static lib
@interface RHFixCategoryBugClassNSDRHNA : NSObject @end @implementation RHFixCategoryBugClassNSDRHNA @end

