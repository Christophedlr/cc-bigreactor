# Installation

In computer or advanced computer, tape: `pastebin get WP8mp2ix <name>`.
`name` is name of your file.

# Configuration

This program required the six monitor or advanced monitor minimum (2 lines of 3 monitor).
The informations of bigreactor (attach in back of computer and monitor in top) is displayed in monitor,
and computer is used for type the commands.

# Usage

After start the program, monitor display informations and computer manage the commands type.
List of commands :
* `end` for terminate program
* `start` for start Bigreactor
* `stop` for stop Bigreactor
* `insertion` for control the insertion of rod control
* `reinit` for reinitialise parameters
* `settings` for configurate the program

## Insertion
The insertion command required a percentage of insertion rod control. 100 for stop reaction (100 = 100% insertion of rod control).

## Settings
The settings command required command at configure:
* `energy.level.stop` for indicate the number of energy stored in Bigreactor for stop the Bigreactor
* `energy.level.start` for indicate the number of energy stored in Bigreactor for start the Bigreactor
* `save` for save the new configuration
* `load` or `reload` for restart configuration
* `end` for end the settings command
 
## Reinit
The reinit command is used for stop the start and stop Bigreactor with the configuration file.
Used for start/stop manually in session if the stop/start informations is declared in configuration file.
