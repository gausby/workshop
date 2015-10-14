Workshop
========
A couple of mix tasks for building workshops and running them in the terminal.

Commands
--------
### `mix workshop`
List exercises in the current workshop and the status of the exercises (in progress, completed, etc).

### `mix workshop.next`
Proceed the workshop to the next exercise.

If the workshop has not been started yet (no state file has been created), the system- and workshop integrity tests will get executed; The workshop will not start before both pass.

### `mix workshop.info`
Display info about the current exercise if the command is executed from within an exercise. Alternatively it will display information about the workshop itself if not executed from an exercise folder.

This should prepare the student for solving the exercise task, which can be seen by executing `mix workshop.task`.

### `mix workshop.task`
Display the task text for the given exercise.

### `mix workshop.hint`
Display a hint about the current exercise. Like info, but with a bit more help for finishing the exercise.

If the exercise has more than one hint it will show one more hint than the previous time the command was run. This allows the hints to reveal a bit more of the solution so that the user can explore on their own, and run the hint command if the user gets stuck.

### `mix workshop.check`
Should run the acceptance test against the users solution for the current exercise.

For now it will just set the current exercise status to *completed*, making the `mix workshop.next` command progress to the next exercise.

### `mix workshop.doctor`
Perform a system integrity check. It will fail the test if prerequisites, such as having specific software required for the workshop installed.

I.e. a workshop that require a specific database to be installed could have a test that fails if the user does not have that database installed.

### `mix workshop.version`
Will print the version number of the current exercise. This is mostly for troubleshooting reasons, and to make sure every student at a seminar is running the same version of the workshop.

### `mix workshop.help`
Describe the workshop command to the user, and if a *home* link is set for the workshop it will get displayed on this screen.

Workshop Generator Tasks
------------------------
Two mix tasks will help generate workshops; first `mix new.workshop NAME` and then `mix new.exercise NAME`.

### `mix new.workshop`
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

#### *README.md*
This file can be used to describe the workshop itself, what the workshop aim to teach the student and pointers on how to get started.

Please mention that the workshop mix task archive should be installed, and that the student will be started by typing `mix workshop.next`; also mention the `mix workshop.help`-command if the student get lost or confused about the workshop system.

The purpose of having this file in Markdown format is that services like GitHub, BitBucket, etc., will display this nicely in a browser if the workshop is uploaded as a project.

#### *.workshop/workshop.exs*
This define various information about the workshop, such as its human readable title; its title; its descriptions in various forms, and special text that will get displayed to the user at various events in the workshop life cycle; such as introduction and debriefing text.

All of this is implemented as module attributes.

#### *.workshop/prerequisite.exs*
The prerequisite file can be used to define tests and checks that will get run during the system check process, run before the workshop starts, or whenever the `mix workshop.doctor` task is run.

The purpose is to check the system for existence of workshop dependencies; ie. a workshop that teaches the user to use the Riak database could check if Riak is installed on the system, and are writable, etc.

#### *.workshop/exercises/*
This is where the exercises created with `mix new.exercise` are stored.

### `mix new.exercise`
Create and add a new exercise from a template to the current workshop. This command needs to be executed from within a folder structure created by (or similar to) `mix new.workshop NAME`.

```bash
$ cd my_workshop
$ mix new.exercise my_first_exercise
* creating exercise.exs
* creating files/
* creating solution/
* creating test/
* creating test/check.exs
* creating test/test_helper.exs
[omitted output]
```

These files will get created in *my_workshop/.workshop/exercises/my_first_exercise*.

#### exercise.exs
Contain meta data about a given workshop, such as its title, a description, a task, and a list of hints that will help the user complete the task.

This file also contain a *weight*-value that determine the order the exercises are presented—an exercise with a low value will come before an exercise with a high value.

##### Callbacks
So far the system defines one exercise callback function:

  * `on_exercise_completed/0` - run every time the student complete the given exercise.

All callback functions are optional and will do a noop if undefined.

#### files/
This folder contains files that will get copied into the workshop sandbox folder (the root of the workshop) when the exercise gets activated. The user will work with these files to solve the assignment.

#### test/
The test folder contains scripts used to verify the users solution. Think of it as unit tests that the user should not touch.

The *test_helper.exs*-file should know how to bootstrap the solution, and the *check.exs*-file should contain verification functions that test the users exercise solution.

#### solution/
The solution folder should contain an implementation that solves the exercise. This will be run when the exercise is verified, so it should pass. This will also be used so that the user can compare solutions when their exercise has been handed in.

The `mix workshop.check` command accept a `--solution` flag to aid in the development of an exercise solution. Given the `--solution` flag the check command will use the implementation found in the solution folder.

### `mix workshop.validate`
Will check if the workshop is valid. This can aid in the development of workshops.

Notice: this will also get run when the end user start the workshop. This is done to help preventing the user getting stuck in a broken workshop; if the workshop is not valid it will not start.


License
-------
See the LICENSE file included in the project. If it is not please contact the creator of the project.
