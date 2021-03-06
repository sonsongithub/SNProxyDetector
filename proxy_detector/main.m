//
//  main.m
//  proxy_detector
//
//  Created by sonson on 2012/12/14.
//  Copyright (c) 2012年 sonson. All rights reserved.
//
//	SNProxyDetector
//
//	Copyright (c) 2012, Yuichi Yoshida
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//	- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//	- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the docume
//	ntation and/or other materials provided with the distribution.
//	- Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this
//	software without specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUD
//	ING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN N
//	O EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR C
//	ONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR P
//						  ROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
//	TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBI
//	LITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

#import "../SNProxyDetector.h"

int main(int argc, const char *argv[]) {
	NSString *URLStringArgument = nil;
	if (argc == 2) {
		URLStringArgument = [NSString stringWithUTF8String:argv[1]];
	}
	if (URLStringArgument) {
		NSDictionary *info = [SNProxyDetector proxyInfoWithURLString:URLStringArgument];
		if ([[info objectForKey:@"ProxyAutoConfigs"] count]) {
			// {"kCFProxyPortNumberKey":8080,"kCFProxyTypeKey":"kCFProxyTypeHTTP","kCFProxyHostNameKey":"10.81.247.8"}]
			NSDictionary *proxy = [[info objectForKey:@"ProxyAutoConfigs"] objectAtIndex:0];
			if ([proxy objectForKey:@"kCFProxyHostNameKey"] && [proxy objectForKey:@"kCFProxyPortNumberKey"] && ([[proxy objectForKey:@"kCFProxyTypeKey"] isEqualToString:(NSString*)kCFProxyTypeHTTP] || [[proxy objectForKey:@"kCFProxyTypeKey"] isEqualToString:(NSString*)kCFProxyTypeHTTPS])) {
				printf("%s\n%d", [[proxy objectForKey:@"kCFProxyHostNameKey"] UTF8String], [[proxy objectForKey:@"kCFProxyPortNumberKey"] intValue]);
				return 0;
			}
		}
	}
	NSDictionary *info = [SNProxyDetector proxyInfo];
	if ([info objectForKey:@"HTTPProxy"] && [info objectForKey:@"HTTPPort"]) {
		printf("%s\n%d", [[info objectForKey:@"HTTPProxy"] UTF8String], [[info objectForKey:@"HTTPPort"] intValue]);
	}
	return 0;
}