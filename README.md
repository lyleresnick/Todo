# Todo

This Todo app is a full reference implementation for VIPER. It demonstrates many of the tasks you would do on a daily basis in a VIPER based project such as:

- routing, 
- data validation and capture, 
- saving of captured data, 
- localization, 
- the use of view and presentation models
- ViewController parameter passing, 
- data cache injection, 
- output sub-protocols organized by event,
- returning results from sibling Presenters,
- separation of Entity Domain Objects from Data Transfer Objects

The are two Routers:
* A Navigation Controller acts as a root router managing a list and a detail scene. 
* A custom router manages the Editing and Display modes of the detail scene.

No attempt has been made to make the scenes aesthetically pleasing - its all about the code. 

## Demo Modes

The demo has 3 modes: *test* and *coreData* and *networked*. `test` mode uses an in-memory datastore. `coreData` mode uses CoreData on a local database. `networked` mode uses a network server. You can flip between the modes by changing the value of the `gatewayImplementation` in the `EntityGatewayFactory` .



