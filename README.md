Workshop
========
Build workshops. Work in progress.

Commands (Work in progress)
---------------------------
All commands should start with `mix workshop.*command*`.

### `exercises`
Not implemented. Should list exercises in the current workshop. Potentially show which exercise is the current one.

### `next`
Not fully implemented. Should proceed to the next exercise.

If the workshop has not been started yet (no state file has been created), the system integrity test and workshop integrity test will get executed.

Optionally it should run the acceptance test and lock if it does not pass.

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

Workshop Generator Tasks
------------------------
Two mix tasks will help generate workshops; first `mix new.workshop NAME` and then `mix new.exercise NAME`.

### `new.workshop`
Create a new workshop from a template that specify a valid workshop—except for the fact that it has no exercises.

If we create a workshop with the name `hello_world` we would get the following output.

```bash
$ mix new.workshop hello_world
* creating README.md
* creating .workshop/
* creating .workshop/prerequisite.exs
* creating .workshop/workshop.exs
* creating .workshop/exercises/
```

These files would get created in a folder called *hello_world* in the current working directory.

All the stuff in the *.workshop*-folder are the support files for the workshop and should not get touched by the student; it should be used to define and store the workshop and its exercises.

#### /*README.md*
This file can be used to describe the workshop itself, what the workshop aim to teach the student and pointers on how to get started.

Please mention that the workshop mix task archive should be installed, and that the student will be started by typing `mix workshop.next`; also mention the `mix workshop.help`-command if the student get lost or confused about the workshop system.

The purpose of having this file in Markdown format is that services like GitHub, BitBucket, etc., will display this nicely in a browser if the workshop is uploaded as a project.

#### */.workshop/workshop.exs*
This define various information about the workshop, such as its human readable title; its title; its descriptions in various forms, and special text that will get displayed to the user at various events in the workshop life cycle; such as introduction and debriefing text.

All of this is implemented as module attributes.

#### */.workshop/prerequisite.exs*
The prerequisite file can be used to define tests and checks that will get run during the system check process, run before the workshop starts, or whenever the `mix workshop.doctor` task is run.

The purpose is to check the system for existence of workshop dependencies; ie. a workshop that teaches the user to use the Riak database could check if Riak is installed on the system, and are writable, etc.

#### */.workshop/exercises/*
This is where the exercises created with `mix new.exercise` are stored.

### `new.exercise`
Create and add a new exercise from a template to the current workshop. This command needs to be executed from within a folder structure created by (or similar to) `mix new.workshop NAME`.

```bash
$ cd my_workshop
$ mix new.exercise my_first_exercise
* creating exercise.exs
* creating files/
* creating test/
* creating test/test_helper.exs
[omitted output]
```

These files will get created in *my_workshop/.workshop/exercises/010_my_first_exercise*. The "010" part of the destination folder is an auto generated, auto incremental, number based on the number of exercise with the largest assigned number plus 10. This is done so a new exercise can get moved between two already created exercises by changing its "weight" to a number between the two tasks.

Checking dependencies for the workshop
--------------------------------------
Checks in a `prerequisite.exs` file will get executed if this file exist. The file should contain a module that implements a `run/1` function.
