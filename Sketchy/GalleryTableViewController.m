//
//  GalleryTableViewController.m
//  Sketchy
//
//  Created by Brandon Plaster on 10/5/14.
//  Copyright (c) 2014 BrandonPlaster. All rights reserved.
//

#import "GalleryTableViewController.h"
#import "GalleryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface GalleryTableViewController ()

@property (nonatomic, strong) NSArray *sketchbookNamesArray;
@property (nonatomic, strong) NSDictionary *sketchbooksDictionary;

@end

@implementation GalleryTableViewController


- (id)initWithArray: (NSArray *) sketchbookNames andDictionary: (NSDictionary *) sketchbooksDictionary {
    self = [super init];
    if (self) {
        self.sketchbookNamesArray = [[NSArray alloc] initWithArray: sketchbookNames];
        self.sketchbooksDictionary = [[NSDictionary alloc] initWithDictionary:sketchbooksDictionary];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        [self.navigationItem setLeftBarButtonItem:backButton];
    }
    return self;
}

- (void) backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.sketchbookNamesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.sketchbooksDictionary objectForKey:[self.sketchbookNamesArray objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sketchbookNamesArray objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Setup cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    // Set text
    NSString *sketchURLString = [[self.sketchbooksDictionary objectForKey:[self.sketchbookNamesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"frame: %i",(int)indexPath.row];
    
    // Add a placeholder image while correct image loads
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder.png"];
    [cell.imageView setImage:placeholderImage];
    
    
    // Get Image
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[NSURL URLWithString:sketchURLString] resultBlock:^(ALAsset *asset)
     {
         CGImageRef imageRef = [asset thumbnail];
         if (imageRef) {
             [cell.imageView setImage: [UIImage imageWithCGImage:imageRef]];
         }
     } failureBlock:^(NSError *error)
     {
         NSLog(@"%@",[error localizedDescription]);
     }];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sketchURLString = [[self.sketchbooksDictionary objectForKey:[self.sketchbookNamesArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    GalleryViewController *sketchView = [[GalleryViewController alloc] initWithSketchURL:[NSURL URLWithString:sketchURLString]];
    [self.navigationController pushViewController:sketchView animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
