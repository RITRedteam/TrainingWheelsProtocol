# TrainingWheelsProtocol
Payloads and functions for the [TitanFall](https://github.com/micahjmartin/TitanFall) dropper system.
These modules are for adding low hanging fruit on a system and are things that are meant to be found by the blueteam


## Payload files vs Function files
 * Payload files are one or more functions that get called directly by the
dropper. 

 * Function files contain a single function that will not get run unless it is
called by a payload.


All payload files will be found in the `payloads` folder. Function files should
be placed in the `functions` folder.