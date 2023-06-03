## ScriptQuest API

#### `quest_data = {}`
Data required for the quest.

#### `enum {ACTION_STEP,INCREMENTAL_STEP,ITEM_STEP,TIMER_STEP}`
Class wide enumerators to use when creating new Quest Steps.

#### `_init(quest_name:String) -> void`
Creates a new ScriptQuest giving it a name.

#### `add_step(quest_step:QuestStep) -> void`
Adds a step to the the quest. Each quest step added is added in sequence.

#### `set_quest_details(details:String) -> void`
Adds description for the quest.

#### `set_rewards(rewards:Dictionary) -> void`
Sets rewards for the quest as a dictionary.

#### `set_quest_meta_data(meta_data:Dictionary) -> void`
Sets quest meta data as a Dictionary.

#### `add_quest_to_group(group:String) -> void`
Add quest to a group.

#### `finalize_quest() -> void`
Finalizes the quest after adding all the required steps.
Must be called after all steps are added.

### QuestStep class API

#### `var data = {}`
Data for this current step

#### `_init(step_type:Step_Type) -> void`
Creates a new Quest Step giving it a Step Type.

#### `set_step_details(details:String) -> void`
Add the steps description

#### `set_incremental_data(item_name:String, required:int) -> void`
Adds incremental step data to a step if its incremental

#### `set_item_step_items(items:Array) -> void`
Adds item step data to a step if its an item step

#### `set_timer_data(time_in_seconds:int,is_count_down:bool = true,fail_on_timeout:bool = true) -> void`
Adds timer step data to the step if its a timer step

#### `set_step_meta_data(meta_data:Dictionary)`
Adds meta data to step as a Dictionary
Step Type 