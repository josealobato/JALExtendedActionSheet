
# Introduction #

I needed a more flexible action sheet to accommodate more buttons (actions) fit in the screen so I include a scroll view to hold the buttons. This work is an exercise to experiment with **auto-layout on code**. You will see that there is no NIB so everything is handle on code and not a single frame is set. Some of the technical requirements that drive this work are:

* Auto-layout on code. Experiment creating, animating and moving views around using the auto-layout constraints.
* Flexible number of buttons (actions)
* iPhone and iPad support.
* Landscape and portrait being able to switch between them adjusting dynamically the sizes of the buttons and the content of the scroll.

Here you have some screen shots

![Portrait Extended Action Sheet](https://dl.dropbox.com/u/159275/JALExtendedActionSheet01.png)
![Landscape Extended Action Sheet](https://dl.dropbox.com/u/159275/JALExtendedActionSheet02.png)

# What is pending.

* Not yet support iPad
* There is some artefacts when the view is shown in landscape, under investigation.

# How to use it #

The use is simple (see the example code included):

1. include the JALExtendedActionSheetCV.m/.h in your project.
2. Instantiate the view controller giving a list of actions (strings)

	@interface MasterViewController () <JALExtendedActionSheetVCDelegate>
		@property (nonatomic,strong) JALExtendedActionSheetVC  *jeas;
		@property (nonatomic,strong) NSArray *actions;
	...
	...
	- (void)viewDidLoad
	{
	    [super viewDidLoad];
		self.actions = @[@"Actions1",@"Actions2",@"Actions3",@"Actions4",@"Actions5",@"Actions6",@"Actions7"];


	... (wherever you want)...
	self.jeas = [[JALExtendedActionSheetVC alloc] init];
	self.jeas.actions = self.actions;
	[self.jeas showInView:self.view];
	[self.jeas setMainTitle:@"This is the title"];
	self.jeas.delegate = self;

3. Implement the protocol to receive notification on the selected button.
4. Use *setEventualMessage* to show a 2 seconds message in the location of the title.


# LICENCE

(The MIT License)

Copyright © 2011 Jose A. Lobato, jose.lobato@me.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
