/*
 * objc-behaviortree: http://github.com/andoco/objc-behaviortree
 *
 * Copyright (c) 2012 Andrew O'Connor
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "Kiwi.h"
#import "BehaviorTree.h"
#import "BehaviorReader.h"
#import "TestAction.h"
#import "TestCondition.h"
#import "TestEntity.h"

SPEC_BEGIN(BehaviorReaderSpec)

describe(@"BehaviorReader", ^{
    context(@"when reading behavior json", ^{
        __block BehaviorReader *reader;
        
        beforeEach(^{
            reader = [[BehaviorReader alloc] init];
        });
        
        it(@"should build task", ^{
            NSString *jsonPath = [[NSBundle bundleForClass:[BehaviorReaderSpec class]] pathForResource:@"action" ofType:@"json"];
            BehaviorTree *tree = [reader buildTreeWithFile:jsonPath];
            
            [[[tree.root class] should] equal:[TestAction class]];
        });
        
        it(@"should populate task properties", ^{
            NSString *jsonPath = [[NSBundle bundleForClass:[BehaviorReaderSpec class]] pathForResource:@"action" ofType:@"json"];
            BehaviorTree *tree = [reader buildTreeWithFile:jsonPath];
            
            [[[tree.root class] should] equal:[TestAction class]];
            TestAction *task = tree.root;
            [[task.stringProperty should] equal:@"Test string"];
            [[theValue(task.intProperty) should] equal:theValue(3)];
            [[theValue(task.boolProperty) should] equal:theValue(YES)];
            [[task.classProperty should] equal:[TestEntity class]];
        });
                
        it(@"should build selector", ^{
            NSString *jsonPath = [[NSBundle bundleForClass:[BehaviorReaderSpec class]] pathForResource:@"selector" ofType:@"json"];
            BehaviorTree *tree = [reader buildTreeWithFile:jsonPath];
            
            [[[tree.root class] should] equal:[Selector class]];
            Selector *selector = tree.root;
            [[theValue(selector.children.count) should] equal:theValue(2)];
            [[[[selector.children objectAtIndex:0] class] should] equal:[TestAction class]];
            [[[[selector.children objectAtIndex:0] class] should] equal:[TestAction class]];
        });

        it(@"should build sequence", ^{
            NSString *jsonPath = [[NSBundle bundleForClass:[BehaviorReaderSpec class]] pathForResource:@"sequence" ofType:@"json"];
            BehaviorTree *tree = [reader buildTreeWithFile:jsonPath];
            
            [[[tree.root class] should] equal:[Sequence class]];
            Sequence *selector = tree.root;
            [[theValue(selector.children.count) should] equal:theValue(2)];
            [[[[selector.children objectAtIndex:0] class] should] equal:[TestAction class]];
            [[[[selector.children objectAtIndex:0] class] should] equal:[TestAction class]];
        });
        
        it(@"should build condition", ^{
            NSString *jsonPath = [[NSBundle bundleForClass:[BehaviorReaderSpec class]] pathForResource:@"condition" ofType:@"json"];
            BehaviorTree *tree = [reader buildTreeWithFile:jsonPath];
            
            [[[tree.root class] should] equal:[TestCondition class]];
            Condition *condition = tree.root;
            [[[condition.task class] should] equal:[TestAction class]];
        });

        context(@"and task type not found", ^{
            it(@"should raise exception", ^{
                NSDictionary *data = @{@"type":@"UnknownAction"};
                
                [[theBlock(^{
                    [reader buildTree:data];
                }) should] raiseWithName:@"Unknown task type"];
            });
        });
        
    });
    
});

SPEC_END