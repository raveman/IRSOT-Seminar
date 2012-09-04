//
//  ISSHKConfigurator.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 03.09.12.
//  Copyright (c) 2012 IRSOT. All rights reserved.
//

#import "ISSHKConfigurator.h"

@implementation ISSHKConfigurator

- (NSString*)appName {
	return @"Семинары ИРСОТ";
}

- (NSString*)appURL {
	return @"http://edu.ruseminar.ru/irsot-seminars";
}

- (NSString*)facebookAppId {
	return @"226726620786584";
}

- (NSString*)facebookLocalAppId {
	return @"";
}

- (NSString*)vkontakteAppId {
	return @"3109219";
}

- (NSString*)twitterConsumerKey {
	return @"8GLCFqyWb0dABTJcYYOMw";
}

- (NSString*)twitterSecret {
	return @"HllyKvBsSj9C8oNVzOyY0huMgwGaUkaO3HsnQrX91xU";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:1];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}

- (NSString*)evernoteConsumerKey
{
    return @"raveman-3416";
}

- (NSString*)evernoteSecret
{
    return @"96f96d1c2b5d21e0";
}
- (NSString *)evernoteHost
{
    return @"http://www.evernote.com";
}


@end
