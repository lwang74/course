new Selectable({
	options: ['one', 'two', 'three', 'four', 'five']
}).insertTo('the-container');

new Selectable('my-selectable', {
	selected: 2,
	disabled: [1,3]
});
