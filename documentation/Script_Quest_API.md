## ScriptQuest API

Create an instance of this class to make a quest. adding steps using the various step function such as `add_action_step` or `add_incremental_step`. The quest steps are added in order of progression.
When finished call the `finialize_quest` function. Then add this quest to the player's quest using the [QuestManager's](Quest_Manager_API.md) `add_scripted_quest` function.

### Variables
`quest_data :Dictionary` - Dictionary containing all data for this quest. Accessing directly not recommended.

`last_added_id :String` - id tracker for last added step. Used to set a step's `next_id`. Accessing directly not recommended.

### Functions

#### `_init(quest_name:String,quest_details :String= "") -> void`

Class initializer when `ScriptQuest.new()` is called. Requires the name of the quest and optionally its details/discription.

#### `set_quest_details(details:String) -> void`

Set or change the details of a quest.

#### `add_action_step(step_details:String,step_meta_data:Dictionary={}) -> void`

Add an `action_step` to the quest passing its details. Optionally pass meta_data.

#### `add_incremental_step(step_details:String, item_name:String, required:int,step_meta_data:Dictionary={}) -> void`

Adds an `incremental_step` to the quest passing its details item name and the amount required.Optionally pass meta_data.

#### `add_items_step(step_details:String, items:PackedStringArray,step_meta_data:Dictionary={}) -> void`

Adds an `items_step` to the quest passing its details and a Array of strings of the items required. Optionally pass meta_data.

#### `add_callable_step(function:String,params:Array = []) -> void`

Adds an `callable_step` passing the function as a string to be called. For example `"QuestManager.testfunc()"`. Optionally pass an array of parameters to be passed to the calling function. 

#### `add_timer_step(step_details:String,time_in_seconds:int,is_count_down:bool = true,fail_on_timeout:bool=true,step_meta_data:Dictionary={}) -> void`

Adds a `timer_step` passing its details and time in seconds. Optionally set if is_count_down and fail_on_timeout as well as meta_data.

#### `set_rewards(rewards:Dictionary) -> void`
Set quest rewards dictionary.

#### `set_quest_meta_data(meta_data:Dictionary) -> void`
Set quest meta_data dictionary.

#### `add_quest_to_group(group:String) -> void`
Adds this quest to specified group.

#### `add_step(step_data:Dictionary) -> void`

This is called automatically by each `add` function. adds the created step to the quest.

#### `finalize_quest() -> void:`

Finalizes the created quest after steps are added.
Must call after adding all steps to quest.

#### `get_random_id() -> String:`

Returns unique id for quest and steps.