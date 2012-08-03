//
//  SeminarFetcher.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SeminarFetcher.h"

#define SEMINAR_URL @"http://devedu.ruseminar.ru/api/nonauth/"
#define SEMINAR_TAXONOMY_URL @"taxonomy_vocavulary"
#define SEMINAR_TERM_URL @"taxonomy_term"
#define SEMINAR_TYPE @"seminar_type"
#define SEMINAR_SECTION @"seminar_section"


@implementation SeminarFetcher

+ (NSArray *) executeFetch: (NSString *)query
{
    query = [NSString stringWithFormat:@"%@.json", query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);

    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    return results;
}

+ (NSDictionary *)sectionsAndTypes
{
    NSMutableArray *sections = [NSArray array];
    NSMutableArray *types = [NSArray array];

    // выбираем список всех словарей
    NSString *taxonomyRequest = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, SEMINAR_TAXONOMY_URL];
    NSArray *taxonomy = [self executeFetch:taxonomyRequest];
    
    //выбираем список всех терминов
    NSString *termRequest = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, SEMINAR_TERM_URL];
    NSArray *terms = [self executeFetch:termRequest];
    
    //пробегаем по словаряем, заполняем массивы для типов и секций
    for (NSDictionary *taxonomyDict in taxonomy) {
        if ([[taxonomyDict valueForKey:@"machine_name"] isEqualToString:SEMINAR_SECTION]) {
            for (NSDictionary *term in terms) {
                if ([term valueForKey:@"vid"] == [taxonomyDict valueForKey:@"vid"]) {
                    [sections addObject:term];
                }
            }
        }
        if ([[taxonomyDict valueForKey:@"machine_name"] isEqualToString:SEMINAR_TYPE]) {
            for (NSDictionary *term in terms) {
                if ([term valueForKey:@"vid"] == [taxonomyDict valueForKey:@"vid"]) {
                    [types addObject:term];
                }
            }
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:sections, @"sections", types, @"types", nil];
}


+ (NSArray *)seminars
{
    return nil;
    
}

+ (NSArray *)lectors
{
    return nil;
    
}

@end
