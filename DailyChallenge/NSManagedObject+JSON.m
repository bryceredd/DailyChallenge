//
//  NSManagedObject+JSON.m
//  DailyChallenge
//
//  Created by Bryce Redd on 4/25/12.
//  Copyright (c) 2012 Itv. All rights reserved.
//

#import "NSManagedObject+JSON.h"
#import "RFCoreDataModel.h"
#import "NSArray+Additions.h"
#import "ISO8601DateFormatter.h"


@implementation NSManagedObject (JSON)

+ (id) objectWithDefinition:(NSDictionary*)definition inContext:(NSManagedObjectContext*)context {
    NSManagedObject* object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    
    static ISO8601DateFormatter* formatter = nil;
    if(!formatter) formatter = [[ISO8601DateFormatter alloc] init];
    
    
    
    // set all the primitive data
    
    NSDictionary* attributes = [[object entity] attributesByName];
    for(NSString* attribute in attributes) {
        id value = [definition objectForKey:attribute];
        if(!value) continue;
        
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        
        if(attributeType == NSStringAttributeType && [value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        } else if ((attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType || attributeType == NSBooleanAttributeType) && [value isKindOfClass:[NSString class]]) {
            value = [NSNumber numberWithInt:[value intValue]];
        } else if (attributeType == NSFloatAttributeType && [value isKindOfClass:[NSString class]]) {
            value = [NSNumber numberWithFloat:[value floatValue]];
        } else if (attributeType == NSDateAttributeType && [value isKindOfClass:[NSString class]]) {
            value = [formatter dateFromString:value];
        }
        
        [object setValue:value forKey:attribute];
    }
    
    
    
    // attempt to set the relationships
    
    NSDictionary* relationships = [[object entity] relationshipsByName];
    for(NSString* relationship in relationships) {
        id value = [definition objectForKey:relationship];
        if(!value) continue;
        
        [object setValue:value forKey:relationship];
    }

    return object;
}

+ (id) objectWithJSON:(NSString*)json inContext:(NSManagedObjectContext*)context {
    NSError* error;
    id result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    
    NSAssert(!error, @"There was an error parsing the json!: %@", error);
    
    __block id(^parseResults)(id) = ^(id result) {
        if([result isKindOfClass:[NSDictionary class]]) {
            return [self objectWithDefinition:result inContext:context];
        }
        if([result isKindOfClass:[NSArray class]]) {
            return [(NSArray*)result arrayByMappingWithBlock:^(id item) { return parseResults(item); }];
        }
        
        NSAssert(0, @"Something went wrong! JSON parse should only return a dictionary or array");
        return nil;
    };
    
    return parseResults(result);
}

@end
