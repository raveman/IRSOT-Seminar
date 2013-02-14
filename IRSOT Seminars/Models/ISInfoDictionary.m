//
//  ISInfoDictionary.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 14.02.13.
//  Copyright (c) 2013 IRSOT. All rights reserved.
//

#import "ISInfoDictionary.h"

@implementation ISInfoDictionary

//<dict>
//<key>Дистанционное участие</key>
//<dict>
//<key>Дистанционное обучение</key>
//<string>http://www.ruseminar.ru/distance</string>
//<key>РОДО</key>
//<string>http://www.ruseminar.ru/rodo</string>
//</dict>
//<key>Условия участия</key>
//<dict>
//<key>Раздел «Кадры»</key>
//<string>http://www.ruseminar.ru/terms-kadry</string>
//<key>Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»</key>
//<string>http://www.ruseminar.ru/terms</string>
//<key>Региональные представители</key>
//<string>http://www.ruseminar.ru/region</string>
//<key>Образец договора</key>
//<string>http://www.ruseminar.ru/dogovor</string>
//</dict>
//<key>О Компании</key>
//<dict>
//<key>О нас</key>
//<string>http://www.ruseminar.ru/about</string>
//<key>Контакты</key>
//<string>http://www.ruseminar.ru/contacts</string>
//<key>Лицензии</key>
//<string>http://www.ruseminar.ru/licenses</string>
//</dict>
//</dict>
+ (NSArray *)infoArray
{
    NSMutableArray *infoArray = [NSMutableArray array];
    
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

+ (NSDictionary *) info
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSDictionary *dict1 = [NSDictionary dictionary];
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    [dict setObject:@"http://www.ruseminar.ru/dogovor" forKey:NSLocalizedString(@"Образец договора", @"Образец договора")];
    //    [dict setObject:@"http://www.ruseminar.ru/terms" forKey:NSLocalizedString(@"Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»", @"Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»")];
    //    [dict setObject:@"http://www.ruseminar.ru/terms-kadry" forKey:NSLocalizedString(@"Раздел «Кадры»", @"Раздел «Кадры»")];


//    NSMutableDictionary  *dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"http://www.ruseminar.ru/distance" forKey:NSLocalizedString(@"Дистанционное обучение", @"Дистанционное обучение")];
//    [dict setObject:@"http://www.ruseminar.ru/rodo" forKey:NSLocalizedString(@"РОДО", @"РОДО")];
//    [info setObject:dict forKey:NSLocalizedString(@"Дистанционное участие", @"Дистанционное участие")];


//    dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"http://www.ruseminar.ru/contacts" forKey:NSLocalizedString(@"Контакты", @"Контакты")];
//    [dict setObject:@"http://www.ruseminar.ru/region" forKey:NSLocalizedString(@"Региональные представители", @"Региональные представители")];
//    [dict setObject:@"http://www.ruseminar.ru/licenses" forKey:NSLocalizedString(@"Лицензии", @"Лицензии")];
//    [dict setObject:@"http://www.ruseminar.ru/about" forKey:NSLocalizedString(@"О нас", @"О нас")];
    

    
    dict1 = [NSDictionary dictionaryWithObjectsAndKeys: @"http://www.ruseminar.ru/distance",NSLocalizedString(@"Дистанционное обучение", @"Дистанционное обучение"),
             @"http://www.ruseminar.ru/rodo",NSLocalizedString(@"РОДО", @"РОДО"), nil];
    [info setObject:dict1 forKey:NSLocalizedString(@"Дистанционное участие", @"Distance attendance")];
   
    dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.ruseminar.ru/terms", NSLocalizedString(@"Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»", @"Разделы «Бухгалтерский учет и налогообложение», «Финансы», «Право», «Управление»"), @"http://www.ruseminar.ru/terms-kadry", NSLocalizedString(@"Раздел «Кадры»", @"Раздел «Кадры»"), @"http://www.ruseminar.ru/dogovor", NSLocalizedString(@"Образец договора", @"Образец договора"), nil];
    
    [info setObject:dict1 forKey:NSLocalizedString(@"Условия участия", @"Participation terms")];

    dict1 = [NSDictionary dictionaryWithObjectsAndKeys: @"http://www.ruseminar.ru/contacts", NSLocalizedString(@"Контакты", @"Контакты"),
             @"http://www.ruseminar.ru/region", NSLocalizedString(@"Региональные представители", @"Региональные представители"),
             @"http://www.ruseminar.ru/licenses", NSLocalizedString(@"Лицензии", @"Лицензии"),
             @"http://www.ruseminar.ru/about", NSLocalizedString(@"О нас", @"О нас"), nil];
    
    [info setObject:dict1 forKey:NSLocalizedString(@"О компании", @"About company")];
    
    return info;
}

@end
