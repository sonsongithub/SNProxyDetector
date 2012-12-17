//
//  SNProxyDetector.m
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

#import "SNProxyDetector.h"

#import "SBJson.h"

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>

//Printing description of proxies:
//{
//    ExceptionsList =     (
//						  "*.local",
//						  "169.254/16",
//						  "10.81.247.*",
//						  "10.81.220.*",
//						  "127.0.0.1"
//						  );
//    FTPEnable = 1;
//    FTPPassive = 1;
//    FTPPort = 8080;
//    FTPProxy = "10.81.247.8";
//    HTTPEnable = 1;
//    HTTPPort = 8080;
//    HTTPProxy = "10.81.247.8";
//    HTTPSEnable = 1;
//    HTTPSPort = 8080;
//    HTTPSProxy = "10.81.247.8";
//    ProxyAutoConfigEnable = 1;
//    ProxyAutoConfigURLString = "http://10.81.247.2/labproxy.pac";
//    "__SCOPED__" =     {
//        en0 =         {
//            ExceptionsList =             (
//										  "*.local",
//										  "169.254/16",
//										  "10.81.247.*",
//										  "10.81.220.*",
//										  "127.0.0.1"
//										  );
//            FTPEnable = 1;
//            FTPPassive = 1;
//            FTPPort = 8080;
//            FTPProxy = "10.81.247.8";
//            HTTPEnable = 1;
//            HTTPPort = 8080;
//            HTTPProxy = "10.81.247.8";
//            HTTPSEnable = 1;
//            HTTPSPort = 8080;
//            HTTPSProxy = "10.81.247.8";
//            ProxyAutoConfigEnable = 1;
//            ProxyAutoConfigURLString = "http://10.81.247.2/labproxy.pac";
//        };
//    };

@implementation SNProxyDetector

CFArrayRef CopyPACProxiesForURL(CFURLRef targetURL, CFErrorRef *error) {
    CFDictionaryRef proxies = SCDynamicStoreCopyProxies(NULL);
	
    if (!proxies)
        return NULL;
	
    CFNumberRef pacEnabled;
	
    if ((pacEnabled = (CFNumberRef)CFDictionaryGetValue(proxies, kSCPropNetProxiesProxyAutoConfigEnable))) {
        int enabled;
        if (CFNumberGetValue(pacEnabled, kCFNumberIntType, &enabled) && enabled) {
            CFStringRef pacLocation = (CFStringRef)CFDictionaryGetValue(proxies, kSCPropNetProxiesProxyAutoConfigURLString);
			
            CFURLRef pacUrl = CFURLCreateWithString(kCFAllocatorDefault, pacLocation, NULL);
			
            CFDataRef pacData;
			
            SInt32 errorCode;
			
            if (!CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault, pacUrl, &pacData, NULL, NULL, &errorCode))
                return NULL;
			
            CFStringRef pacScript = CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, pacData, kCFStringEncodingISOLatin1);
            if (!pacScript)
                return NULL;
			
            CFArrayRef pacProxies = CFNetworkCopyProxiesForAutoConfigurationScript(pacScript, targetURL, error);
            return pacProxies;
        }
    }
    return NULL;
}

+ (NSDictionary*)proxyInfo {
	CFDictionaryRef proxies = SCDynamicStoreCopyProxies(NULL);
	if (proxies) {
		NSDictionary *dict = [NSDictionary dictionaryWithDictionary:(NSDictionary*)proxies];
		CFRelease(proxies);
		return  dict;
	}
	return nil;
}

+ (NSDictionary*)proxyInfoWithURLString:(NSString*)URLString {
	CFURLRef targetURL = (CFURLRef)[NSURL URLWithString : URLString];
	CFErrorRef error = NULL;
    CFArrayRef proxies = CopyPACProxiesForURL(targetURL, &error);
    if (proxies) {
		if (CFArrayGetCount(proxies)) {
			NSDictionary *dict = @{@"ProxyAutoConfigs" : (NSDictionary*)proxies};
			CFRelease(proxies);
			return dict;
		}
    }
	return [self proxyInfo];
}

@end
