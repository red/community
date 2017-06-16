Red [
	Author: "Arnold van Hofwegen"
	file: %tooltip.red
  Tabs: 4
]

show-tooltip: func [
	val
	evt
][
	;print val
	tip-label/visible?: not val
	tip-label/offset: evt/offset + 20x20
]

main-window: [
	title "Main window"
	help-message: text khaki "Hover here to see the mouse!" on-over [
		;print ["Event over" event/offset event/away?]
		show-tooltip event/away? event
	]
	return
	button "OK" [unview]
	tip-label: text yello "Squeek!" hidden
]

view/flags main-window ['resize]
