//
//  ISInfoDictionary.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 14.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "ISInfoDictionary.h"

@implementation ISInfoDictionary

+ (NSArray *)infoArray
{
    NSArray *infoArray = [NSArray array];
    
    NSArray *urls = [NSArray array];
    NSArray *titles = [NSArray array];

    urls = [NSArray arrayWithObjects: @"http://www.ruseminar.ru/terms", @"http://www.ruseminar.ru/terms-kadry", @"http://www.ruseminar.ru/dogovor", nil];
    titles = [NSArray arrayWithObjects:NSLocalizedString(@"Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»", @"All sections"),
              NSLocalizedString(@"Раздел «Кадры»", @"Раздел «Кадры»"), NSLocalizedString(@"Образец договора", @"Contract template"), nil];
    NSArray *terms = [NSArray arrayWithObjects:urls, titles, nil];
    
    urls = [NSArray arrayWithObjects: @"http://www.ruseminar.ru/distance", @"http://www.ruseminar.ru/rodo", nil];
    titles = [NSArray arrayWithObjects:NSLocalizedString(@"Дистанционное обучение", @"Distance education"), NSLocalizedString(@"РОДО", @"RODO"), nil];
    NSArray *distance  = [NSArray arrayWithObjects:urls, titles, nil];
    
    urls = [NSArray arrayWithObjects:@"http://www.ruseminar.ru/contacts", @"http://www.ruseminar.ru/region", @"http://www.ruseminar.ru/licenses", @"http://www.ruseminar.ru/about", nil];
    titles = [NSArray arrayWithObjects:NSLocalizedString(@"Контакты", @"Контакты"), NSLocalizedString(@"Региональные представители", @"Региональные представители"),  NSLocalizedString(@"Лицензии", @"Лицензии"), NSLocalizedString(@"О нас", @"О нас"),   nil];
    NSArray *about = [NSArray arrayWithObjects:urls, titles, nil];
    
    infoArray = [NSArray arrayWithObjects:distance, NSLocalizedString(@"Дистанционное участие", @"Distance attendance"), terms, NSLocalizedString(@"Условия участия", @"Participation terms"), about, NSLocalizedString(@"О компании", @"About company"), nil];
    return infoArray;
}

@end
