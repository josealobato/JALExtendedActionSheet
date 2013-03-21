//
//  MasterViewController.m
//  JALExtendedActionSheetDemo
//
//  Created by Jose Lobato on 3/15/13.
//  Copyright (c) 2013 Jose Lobato. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "JALExtendedActionSheetVC.h"

@interface MasterViewController () <JALExtendedActionSheetVCDelegate> {
    NSMutableArray *_objects;
}
@property (nonatomic,strong) JALExtendedActionSheetVC  *jeas;
@property (nonatomic,strong) NSArray *actions;
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Master", @"Master");
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		    self.clearsSelectionOnViewWillAppear = NO;
		    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		}
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.leftBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;

	self.actions = @[@"Actions1",@"Actions2",@"Actions3",@"Actions4",@"Actions5",@"Actions6",@"Actions7"];

	UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:@[@"nil",@"0act", @"1act", @"3act", @"7act",]];
	segControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segControl.selectedSegmentIndex = 4;
	self.navigationItem.titleView = segControl;

	[segControl addTarget:self
				   action:@selector(segmentedControlEvent:)
		 forControlEvents:UIControlEventValueChanged];

}

- (void)segmentedControlEvent:(id)sender
{
	switch ([(UISegmentedControl*)sender selectedSegmentIndex]) {
		case 0:
			self.actions = nil;
			break;
		case 1:
			self.actions = @[];
			break;
		case 2:
			self.actions = @[@"Actions1"];
			break;
		case 3:
			self.actions = @[@"Actions1",@"Actions2",@"Actions3"];
			break;
		case 4:
			self.actions = @[@"Actions1",@"Actions2",@"Actions3",@"Actions4",@"Actions5",@"Actions6",@"Actions7"];
			break;

		default:
			break;
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.jeas dismissExtendedActionSheet];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//        }
    }


	NSDate *object = _objects[indexPath.row];
	cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = _objects[indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];

	} else {
        self.detailViewController.detailItem = object;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	self.jeas = [[JALExtendedActionSheetVC alloc] init];
	self.jeas.actions = self.actions;
	[self.jeas showInView:[cell.subviews objectAtIndex:1]];
	[self.jeas setMainTitle:@"This is the title"];
	self.jeas.delegate = self;
}

- (void)actionSheet:(JALExtendedActionSheetVC*)actionSheet didSelectAction:(NSInteger)index
{
	[self.jeas setEventualMessage:[self.actions objectAtIndex:index]];
}

- (void)actionSheetDidCancel:(JALExtendedActionSheetVC*)actionSheet
{
	
}


@end
