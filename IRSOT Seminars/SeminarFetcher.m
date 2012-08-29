//
//  SeminarFetcher.m
//  IRSOT Seminars
//
//  Created by Bob Ershov on 01.08.12.
//  Copyright (c) 2012 Bob Ershov. All rights reserved.
//

#import "SeminarFetcher.h"
#import "SVProgressHUD/SVProgressHUD.h"

@implementation SeminarFetcher

+ (NSArray *) executeFetch: (NSString *)query
{
    query = [NSString stringWithFormat:@"%@.json", query];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);

    NSError *error = nil;

    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding];
    if(error) {
        NSString *errorMessage = [NSString stringWithFormat:@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription];
        [SVProgressHUD showErrorWithStatus:errorMessage];
        NSLog(errorMessage, nil);
    }
    NSArray *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription];
        [SVProgressHUD showErrorWithStatus:errorMessage];
        NSLog(errorMessage, nil);
    }
//    NSLog(@"[%@ %@] received %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
    return results;
}

+ (NSDictionary *)sectionsAndTypes
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray *types = [NSMutableArray array];

    // выбираем список всех словарей
    NSString *taxonomyURL = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, SEMINAR_TAXONOMY_URL];
    NSArray *taxonomy = [self executeFetch:taxonomyURL];
    
    //выбираем список всех терминов
    NSString *termURL = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, SEMINAR_TERM_URL];
    NSArray *terms = [self executeFetch:termURL];
    
    //пробегаем по словаряем, заполняем массивы для типов и секций
    for (NSDictionary *taxonomyDict in taxonomy) {
        if ([[taxonomyDict objectForKey:@"machine_name"] isEqualToString:SEMINAR_SECTION]) {
            for (NSDictionary *term in terms) {
                if ([[term objectForKey:@"vid"] isEqualToString:[taxonomyDict objectForKey:@"vid"]]) {
                    [sections addObject:term];
                }
            }
        }
        if ([[taxonomyDict objectForKey:@"machine_name"] isEqualToString:SEMINAR_TYPE]) {
            for (NSDictionary *term in terms) {
                if ([[term objectForKey:@"vid"] isEqualToString:[taxonomyDict objectForKey:@"vid"]]) {
                    [types addObject:term];
                }
            }
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:sections, @"sections", types, @"types", nil];
}

+ (NSArray *)seminars
{
    NSString *seminarURL = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, SEMINAR_LIST_URL];
    NSArray *seminars = [SeminarFetcher executeFetch:seminarURL];
    
    return seminars;
}


+ (NSArray *)lectors
{

    NSString *lectorURL = [NSString stringWithFormat:@"%@/%@", SEMINAR_URL, LECTOR_LIST_URL];
    NSArray *lectors = [SeminarFetcher executeFetch:lectorURL];
    
    return lectors;
}

@end
