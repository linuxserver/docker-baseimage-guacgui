jQueryliscious
==============

A tinyMediaManager export template utilizing jQuery and CSS3.

Add this template to {install dir}\tinyMediaManager\templates\

Add languages by editing list.jmte. On line 34 you will find an unordered list in the div with id "langSelect."

```html
<div id="langSelect">
		<ul>
			<li class="language">en</li>
			...
```

Add another list item replacing "en" with the language code of your translation. You can find the language codes here:
http://msdn.microsoft.com/en-us/library/ms533052%28VS.85%29.aspx

Next, browse to {install dir}\tinyMediaManager\templates\jQueryliscious\include\lang and make a copy of "en.xml."
Rename the new file with your language code then translate its contents.
