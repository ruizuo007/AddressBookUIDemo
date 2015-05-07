//
//  BasePeoplePickerController.m
//  AddressBookUIDemo
//
//  Created by allinpay-shenlong on 14/12/19.
//  Copyright (c) 2014年 Allinpay.inc. All rights reserved.
//

#import "BasePeoplePickerController.h"

@interface BasePeoplePickerController ()

@end

@implementation BasePeoplePickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _peoples = [[AddressBookManager sharedManager] peoples];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self custom];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChanged:) name:ABMExternalAddressBookChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak __typeof(&*self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __strong __typeof(&*self) strongSelf = weakSelf;
        [strongSelf readAvailablePeoples];
    });
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.searchBar.frame;
    frame.size.width = self.view.frame.size.width;
    self.searchBar.frame = frame;
    frame = self.tableView.frame;
    frame.size.width = self.view.frame.size.width;
    frame.size.height = self.view.frame.size.height;
    self.tableView.frame = frame;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - search bar delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setDataSource:nil];
    [self.tableView reloadData];
}

#pragma mark - table view datasource and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_peoples count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_peoples objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
#if __IPHONE_6_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        [tableView registerClass:[PeoplePickerCell class] forCellReuseIdentifier:identifier];
    }
#endif
    PeoplePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PeoplePickerCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    Person *person = [[_peoples objectAtIndex:section] objectAtIndex:row];
    cell.lb_main.text = [Person showingPropertyOfPerson:person];
    cell.lb_sub.text = @"";
    cell.imgv_member.image = nil;
    if ([Person subShowingPropertyOfPerson:person] != nil) {
        cell.lb_sub.text = [Person subShowingPropertyOfPerson:person];
    }
    if ([person.tongLianMember boolValue]) {
        cell.imgv_member.image = [UIImage imageNamed:@"member"];
    }
    if (row < [[_peoples objectAtIndex:section] count] - 1) {
        cell.seperatorLine.hidden = NO;
    } else {
        cell.seperatorLine.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.personSelecting) {
        NSInteger section = [indexPath section];
        NSInteger row = [indexPath row];
        Person *person = [[_peoples objectAtIndex:section] objectAtIndex:row];
        self.personSelecting(person);
    }
}

//#################################################//

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [AddressBookManager sharedManager].indexes;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat w = tableView.frame.size.width;
    CGFloat h = [self tableView:tableView heightForHeaderInSection:section];
    UIColor *color = [UIColor colorWithRed:DIV255(245) green:DIV255(245) blue:DIV255(245) alpha:1.0];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    view.backgroundColor = color;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, w - 10, h)];
    Person *person = [[_peoples objectAtIndex:section] firstObject];
    label.text = person.index;
    label.backgroundColor = color;
    label.font = [UIFont boldSystemFontOfSize:18];
    [view addSubview:label];
    return view;
}

#pragma mark - addressBookChanged Notification

- (void)addressBookChanged:(NSNotification *)notification { ; }

#pragma mark - read availabe peoples

- (void)readAvailablePeoples {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_group_t dispatchGroup = dispatch_group_create();
    __block UIActivityIndicatorView *aiv;
    dispatch_group_async(dispatchGroup, dispatch_get_main_queue(), ^{
        __strong __typeof(&*self) strongSelf = weakSelf;
        aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        aiv.center = strongSelf.view.center;
        aiv.hidesWhenStopped = YES;
        [strongSelf.view addSubview:aiv];
        [aiv startAnimating];
        [strongSelf.navigationController.view setUserInteractionEnabled:NO];
    });
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [[AddressBookManager sharedManager] availablePeoples];
    });
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        __strong __typeof(&*self) strongSelf = weakSelf;
        [aiv stopAnimating];
        [strongSelf.navigationController.view setUserInteractionEnabled:YES];
        [strongSelf setDataSource:nil];
        [strongSelf.tableView reloadData];
    });
}

#pragma mark - cancel

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - data source

- (void)setDataSource:(NSString *)searchText {
    if (searchText.length <= 0) {
        _peoples = [[AddressBookManager sharedManager] peoples];
    } else {
        _peoples = [[AddressBookManager sharedManager] filterPeopleWithSearchText:searchText];
    }
}

#pragma mark - been inherit

- (void)setup {
    CGRect frame = self.view.frame;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    _searchBar.placeholder = @"搜索";
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
}

- (void)custom {
    self.view.backgroundColor = [UIColor whiteColor];
    //modal方式调起联系人选择视图
    if (self.navigationController && self.presentingViewController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.title = @"常用联系人";
    }
}

@end
