//
//  PlayingCard.m
//  Matchismo
//
//  Created by Jakob Jakobsen Boysen on 21/02/2013.
//  Copyright (c) 2013 Jakob Jakobsen Boysen. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (int)match:(NSArray *)otherCards
{
    int score = 0;
    
    if ([otherCards count] == 1) {
        id otherCard = [otherCards lastObject];
        if ([otherCard isKindOfClass:[PlayingCard class]]) {
            PlayingCard *otherPlayingCard = (PlayingCard*)otherCard;
            if ([otherPlayingCard.suit isEqualToString:self.suit]) {
                score = 1;
            } else if (otherPlayingCard.rank == self.rank) {
                score = 4;
            }
        }
    } else if ([otherCards count] == 2) {
        id secondCard = [otherCards objectAtIndex:0];
        id thirdCard = [otherCards objectAtIndex:1];
        if ([secondCard isKindOfClass:[PlayingCard class]] && [thirdCard isKindOfClass:[PlayingCard class]]) {
            PlayingCard *secondPlayingCard = (PlayingCard*)secondCard;
            PlayingCard *thirdPlayingCard = (PlayingCard*)thirdCard;
            if ([secondPlayingCard.suit isEqualToString:self.suit] && [thirdPlayingCard.suit isEqualToString:self.suit]) {
                score = 2;
            } else if (secondPlayingCard.rank == self.rank && thirdPlayingCard.rank == self.rank) {
                score = 8;
            }
        }
    }
    
    return score;
}

- (NSString *)contents
{
    NSArray *rankStrings = [PlayingCard rankStrings];
    return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

+ (NSArray *)validSuits
{
    return @[@"♥",@"♦",@"♠",@"♣"];
}

@synthesize suit = _suit; // because we provide setter AND getter

- (void)setSuit:(NSString *)suit
{
    if ([[PlayingCard validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

- (NSString *)suit
{
    return _suit ? _suit : @"?";
}

+ (NSArray *)rankStrings
{
    return @[@"?",@"A",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+ (NSUInteger)maxRank
{
    return [self rankStrings].count-1;
}

- (void)setRank:(NSUInteger)rank
{
    if (rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}


@end
