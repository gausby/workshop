Workshop
========
Build workshops. Work in progress.

Commands (Work in progress)
---------------------------
All commands should start with `mix workshop.*command*`.

### `start`
Not implemented. Should setup the working directory and show the first exercise.

### `exercises`
Not implemented. Should list exercises in the current workshop. Potentially show which exercise is the current one.

### `next`
Not fully implemented. Should proceed to the next exercise.

Optionally it should run the acceptance test and lock if it does not pass.

### `previous`
Not implemented. Should go to the previous exercise.

### `info`
Display info about the current exercise, or info about the workshop if it hasn't been started yet.

### `hint`
Display a hint about the current exercise. Like info, but with a bit more help for finishing the exercise.

### `check`
Not implemented. Should run the acceptance test against the users solution for the current exercise.

### `doctor`
A system check should be performed. It will fail the test if prerequisites, like not having software like a database installed, is not met.

### `help`
Not implemented. Display a link to the Github issues where the current workshop is hosted. Users could go here and ask questions if it is an online workshop.

### `new.workshop`
Create a new workshop from a template.

### `new.exercise`
Create and add a new exercise from a template to the current workshop.

Checking dependencies for the workshop
--------------------------------------
Checks in a `prerequisite.exs` file will get executed if this file exist. The file should contain a module that implements a `run/1` function.
