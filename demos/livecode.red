
Red [
	Title:   "Simple GUI livecoding demo, adapted version"
	Author:  "Nenad Rakocevic"
	File: 	 %livecode.red
	Needs:	 'View
	Usage:  {
		Type VID code in the right area, you will see the resulting GUI components
		rendered live on the left side and fully functional (events/actors/reactors working live).
	}
  Info: {
    Original adapted by Arnold to avoid conflicts with global namespace
    and provide more room on the screen.
 }
 Tabs: 4
]

view [
	title "Red Livecoding"
	output-panel: panel 600x800
	source-area: area 600x800 wrap font-name "Fixedsys" on-key-up [
		attempt [output-panel/pane: layout/only load source-area/text]
	]
]
