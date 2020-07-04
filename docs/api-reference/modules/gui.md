# Gui
Includes native Gui classes.

## `Gui.Window`
Base window class for displaying information.
Includes closing, refreshing, and moving.

### `static Window.new()`
Creates a window.

### `Frame Window.WindowFrame`
Frame containing all of the contents. It should be
parented to a `ScreenGui` to use the window, as well
as control the size and position.

### `Frame Window.TopBarAdorn`
Adorn frame for the top bar.

### `Frame Window.ContentsAdorn`
Adorn frame for adorning contents.

### `string Window.Title`
Title of the window.

### `function? Window.OnRefresh`
Optional function that can be defined to show the refresh
button. It is invoked when the refresh button is pressed.

### `function? Window.OnClose`
Optional function that can be defined to show the close
button. It is invoked when the close button is pressed.

### `void Window:Destroy()`
Destroys the window.

## `Gui.ResizableWindow (extends Gui.Window)`
Extends the window to add resizing.

### `static ResizableWindow.new(number? MinWidth,number? MinHeight,number? MaxWidth,number? MaxHeight)`
Creates a resizable window.