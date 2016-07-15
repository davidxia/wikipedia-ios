//  Created by Monte Hurd on 12/16/15.
//  Copyright (c) 2015 Wikimedia Foundation. All rights reserved.

#import "WMFArticlePreviewDataSource.h"

// Frameworks
#import "Wikipedia-Swift.h"

// View
#import "WMFArticlePreviewTableViewCell.h"
#import "UIView+WMFDefaultNib.h"
#import "UITableViewCell+WMFLayout.h"

// Fetcher
#import "WMFArticlePreviewFetcher.h"

// Model
#import "MWKArticle.h"
#import "MWKSearchResult.h"
#import "MWKHistoryEntry.h"
#import "MWKDataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMFArticlePreviewDataSource ()

@property (nonatomic, strong) WMFArticlePreviewFetcher* titlesSearchFetcher;
@property (nonatomic, strong, readwrite, nullable) NSArray<MWKSearchResult*>* previewResults;
@property (nonatomic, strong) NSURL* domainURL;
@property (nonatomic, strong) NSArray<NSURL*>* urls;
@property (nonatomic, assign) NSUInteger resultLimit;

@property (nonatomic, strong) MWKDataStore* dataStore;

@end

@implementation WMFArticlePreviewDataSource

- (NSString*)analyticsContext {
    return @"Article Disambiguation";
}

- (instancetype)initWithArticleURLs:(NSArray<NSURL*>*)articleURLs
                          domainURL:(NSURL*)domainURL
                          dataStore:(MWKDataStore*)dataStore
                            fetcher:(WMFArticlePreviewFetcher*)fetcher {
    NSParameterAssert(articleURLs);
    NSParameterAssert(fetcher);
    NSParameterAssert(dataStore);
    NSParameterAssert(domainURL);
    self = [super init];
    if (self) {
        self.dataStore           = dataStore;
        self.urls                = articleURLs;
        self.domainURL           = domainURL;
        self.titlesSearchFetcher = fetcher;

#warning move
//        self.cellClass = [WMFArticlePreviewTableViewCell class];
//
//        @weakify(self);
//        self.cellConfigureBlock = ^(WMFArticlePreviewTableViewCell* cell,
//                                    MWKSearchResult* searchResult,
//                                    UITableView* tableView,
//                                    NSIndexPath* indexPath) {
//            @strongify(self);
//            NSURL* URL = [self urlForIndexPath:indexPath];
//            NSParameterAssert([URL.wmf_domain isEqual:domainURL.wmf_domain]);
//            cell.titleText       = URL.wmf_title;
//            cell.descriptionText = searchResult.wikidataDescription;
//            cell.snippetText     = searchResult.extract;
//            [cell setImageURL:searchResult.thumbnailURL];
//
//            [cell setSaveableURL:URL savedPageList:self.savedPageList];
//
//            [cell wmf_layoutIfNeededIfOperatingSystemVersionLessThan9_0_0];
//        };
    }
    return self;
}

- (MWKSavedPageList*)savedPageList {
    return self.dataStore.userDataStore.savedPageList;
}

#warning move
//- (void)setTableView:(nullable UITableView*)tableView {
//    [super setTableView:tableView];
//    [self.tableView registerNib:[WMFArticlePreviewTableViewCell wmf_classNib] forCellReuseIdentifier:[WMFArticlePreviewTableViewCell identifier]];
//}

#pragma mark - Fetching

- (void)fetch {
    @weakify(self);
    [self.titlesSearchFetcher fetchArticlePreviewResultsForArticleURLs:self.urls domainURL:self.domainURL]
    .then(^(NSArray<MWKSearchResult*>* searchResults) {
        @strongify(self);
        if (!self) {
            return;
        }
        self.previewResults = searchResults;
        [self didChangeContent];
    });
}

#pragma mark - WMFDataSource

- (nullable id)itemAtIndexPath:(NSIndexPath *)indexPath {
    MWKSearchResult* result = self.previewResults[indexPath.row];
    return result;
}

#pragma mark - WMFArticleListDataSource

- (MWKSearchResult*)searchResultForIndexPath:(NSIndexPath*)indexPath {
   
    return (MWKSearchResult *)[self itemAtIndexPath:indexPath];;
}

- (NSURL*)urlForIndexPath:(NSIndexPath*)indexPath {
    return [self.domainURL wmf_URLWithTitle:[self searchResultForIndexPath:indexPath].displayTitle];
}

- (NSUInteger)titleCount {
    return [self.previewResults count];
}

- (nullable NSString*)displayTitle {
    return MWLocalizedString(@"page-similar-titles", nil);
}

- (BOOL)canDeleteItemAtIndexpath:(NSIndexPath* __nonnull)indexPath {
    return NO;
}

@end

NS_ASSUME_NONNULL_END
