# API

## QuestManager

### Signals

- `quest_complete()` - Emitted when a quest is complete, returns quest name
- `quest_failed` - Emittied when a quest was failed
- `step_complete()` - Emitted when a step is complete returns the step dictionary
- `step_updated()` - Emitted when a step is updated returns the step dictionary
- `new_quest_added`- Emitted when a quest is added to player quests, returns quest_name
- `quest_reset` - Emitted when a quest was reset returns quest name

### Constants

The 7 types of quest steps currently.
- #### ACTION_STEP = "action_step"

- #### INCREMENTAL_STEP = "incremental_step"

- #### ITEM_STEP = "item_step"
  
- #### TIMER_STEP = "timer_step"

- #### BRANCH_STEP = "branch_step"
  
- #### CALLABLE_STEP = "callable_step"
  
- #### END = "end"

### Variables

- `active_quest :String= ""` - Helper variable to assign a quest name
- `current_resource:QuestResource` -current loaded resource
- `player_quests :Dictionary= {}` - all player quests
- `counter :float= 0.0` -counter for tracking time

### Methods

#### `add_quest_from_resource(resource:QuestResource, quest_name:String) ->  void`

Passing in a Quest Resource and a Quest name it will add that quest to the player quests by its `quest_id`

A `Quest` has various properties such as:
- `quest_name` - The name of the added quest.
- `quest_details` - The details of the quest.
- `quest_id` - A id assigned to the quest.
- `completed` - Boolean stating if quest is complete.
- `failed` - Boolean stating if quest was failed.
- `group` - The group that the quest is in.
- `next_id` - The current steps id this value gets updated each step
- `steps` - A Dictionary of Steps as Dictionaries containing one or more of the following:
    1. `action_step` - This step requires an action to be completed.
        - `id` - The ID of this step
        - `details` - Details for this step
        - `step_type`  - The type of step i.e `action_step`
        - `next_id` - The next steps id after this step.
        - `complete` - boolean stating if step is completed
    2. `incremental_step` - This step requires an amount of an item to be collected.
        - `id` - The ID of this step
        - `details` - Details for this step
        - `item_name` - Name of item to collect
        - `step_type`  - The type of step i.e `incremental_step`
        - `collected` - integer of total items collected
        - `required` - integer of total items required
        - `next_id` - The next steps id after this step.  
        - `complete` - boolean stating if step is completed
    3. `items_step` - This step requires a unique set of actions/items to be completed/collected
        - `id` - The ID of this step
        - `details` - Details for this step
        - `step_type`  - The type of step i.e `items_step`
        - `item_list` - An Array of Dictionaries of actions/items required
            - `name` - name of item
            - `complete` - boolean stating if item was collected/complete
        - `next_id` - The next steps id after this step.
        - `complete` - boolean stating if step is completed
    4. `timer_step` - This step tracks time and can serve both as a timer or a stop watch
        - `id` - The ID of this step
        - `details` - Details for this step
        - `step_type`  - The type of step i.e `timer_step`.
        - `time` - The time remaining or time elapsed in seconds.
        - `total_time` - the total time set in seconds
        - `time_minutes` - The total minutes set in the editor.
        - `time_seconds` - The total seconds set in the Editor.
        - `is_count_down` - boolean stating if Time counts down or count up.
        - `fail_on_timeout` - boolean stating if quest fails on timeout if not step becomes complete.
        - `next_id` - The next steps id after this step. 
        - `complete` - boolean stating if step is completed 
    5. `callable_step` - This step calls a function on an autoloaded script then immediately goes to the next step.
        - `id` - The ID of this step
        - `callable` -The function that will be called ie `QuestManager.testfunc`
        - `step_type` -The type of this step i.e `function_call_step`
        - `details` - Details for this step. Not used copy of `callable`
        - `params` - An array of data to be passed to the callable.
        - `next_id` - The next steps id after this step. 
        - `complete` -boolean stating if step was complete
    6. `branch_step` - This step is similar to an action step but optionally branches to alternate steps
        - `id` - The ID of this step
        - `step_type` - The type of this step i.e `branch_step`
    	- `details` - Details for this step
	    - `branch` - Boolean stating if this step should branch default to `false`
        - `next_id` - The next steps id after this step. 
   	    - `complete` - Boolean stating if step was complete
	    - `branch_step_id` - The id of the alternate step for branching
    7. `end` - The End of a quest
        - `id` - The ID of the step
        - `details` - Details of this step. Not used contains 'Complete'
  - `meta_data` - A dictionary containing stored meta data for the quest
      - `key` - name of variable
      - `value` - Variant type of value `int,float,string,boolean,vec2,vec3`

#### `load_quest_resource(resource:QuestResource)`

Sets the current quest resource

#### `get_player_quest(quest_name:String,is_id:bool=false) -> Dictionary`
Get a quest that the player has accepted `is_id` optional to get the quest by id

#### `get_all_player_quests() -> Dictionary`
Get all the current quests the player has

#### `get_all_player_quests_names() -> Array`
Returns all player quests names as an array

#### `func set_branch_step(quest_name, should_branch:bool=true) => void`
If the current step is a branch set it branch to alternate step.

#### `progress_quest(quest_name:String,item_name:String="",amount:int=1) -> void`
Progresses a quest to its next step if it was an action step updates other steps and progresses to next step if all requirements for that step are met. Completes quest if it was at its last step.
- `quest_name` - Name of the quest to progress
- `item_name` - Name of an item to collect/complete.
- `amount` - Amount to increment `incremental_steps`. 1 by default

#### `func _process(delta) -> void`

Called by the Engine and updates the time of any quest that is currently at a `timer_step`

#### `func set_quest_step_items(quest_name:String,quest_item:String,amount:int=0,collected:bool=false) -> void:`

Set a specific value for Incremental and Item Steps. For example the player could have some of an item already use this to match the players inventory

#### `get_quest_list(group:String="") -> Dictionary`
Returns all the quest stored in the current_resource. optionally get only the quests in the specified group

#### `add_quest(quest_name:String) -> void`
Add quest to player_quest from current dictionary

#### `add_scripted_quest(quest:ScriptQuest) -> void`
Add a ScriptQuest to player_quests.

#### `get_quest_from_resource(quest_name:String) -> Dictionary`
Returns a quest from the current_resource

#### `has_quest(quest_name:String) -> bool`
Returns if the player has this quest `quest_name`

#### `is_quest_complete(quest_name:String) -> bool`
Returns if the player has completed this quest `quest_name`

#### `is_quest_failed(quest_name) -> bool`
Returns if the player has failed this quest `quest_name`

#### `get_current_step(quest_name:String) -> Dictionary`
Returns a dictionary of the current quest step of this quest `quest_name`

#### `remove_quest(quest_name:String) -> void`
Removes quest from player_quests `quest_name`

#### `complete_quest(quest_name:String) -> void`
Completes quest `quest_name`

#### `call_function(autoloadfunction:String,params:Array) -> void`

Used by quest manager to call a function from a `callable_step`

#### `get_meta_data(quest_name:String) -> Dictionary`
Return the meta data Dictionary of the quest `quest_name`

#### `set_meta_data(quest_name:String,meta_data:String, value:Variant) -> void`
Create new or Change meta data of the quest `quest_name` 

#### `fail_quest(quest_name:String) -> void`
Fails the quest `quest_name`

#### `get_quests_in_progress() -> Dictionary`
Returns all quests that have not been completed or failed

#### `reset_quest(quest_name:String) -> void`
Resets the quest `quest_name`

#### `wipe_all_quest_data() -> void`
Wipes the entire player_quests dictionary usefull for starting a name game for example

#### `testfunc(v:Array) -> void`
Test function that prints Hello Quest Manager plus passed array

#### `quest_error(quest_name:String) -> void`
Catch if quest doesnt exist checking

