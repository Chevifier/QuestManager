# Creating Quests

## The Editor

To create a quest you should use the editor. The editor has various nodes required to create quests. These nodes are:
1. `Quest Node` - This Node is the main quest node it requires the `quest_name` and the `quest_details`
2. `Step Node` - This node is an `action_step` node and only requires a discription of the action to complete.
3. `Incremental Step Node` - This node is an `incremental_step` node and requires both its `details` , `item_name` and the `required` amount to complete. 
4. `Item Step Node` - This node is an `items_step` node and requires the `details` as well as the list of items/actions to complete
5. `End Node` - This node is required to end a quest after the final step.
6. `Group Node` - A group node only requires its `group` name and can be connected to multiple quest nodes.
7. `Meta Data Node` - A meta data node is use to add meta data to quest such as quest rewards or any arbitrary information stored as a `String`, `Integer`, `float` or `boolean`
8. `Timer Node` - This Node is a `timer_step` node that is used as a Timer or a Stopwatch

## How to use

For this example we'll keep it simple and create a 1 step Quest to kill 15 enemies.
![Arcade Shooter](arcade_shooter.png)
1. First add a Quest node, an Incremental Step Node and a End Node.
2. Connect these nodes dragging the green connection pins from one to another: Quest Node > Incremental Node > End Node

    ![Example Editor Quest](example_editor_quest.jpg)
3. Additionally, you can add a group and Meta Data Node and Fill in the information for each node we wont use the Group and meta data so theyre not required here.
4. Save the quest file choosing a location and giving it a name. Quest files are save with the `.quest` extension.
5. The Space Arcade Scene is included in the Examples Folder. Open it and find the UI node. Drag the quest file into the Quest property in the UI inspector window.
6. Notice the Quest Resource is Read only and has 2 dictionaries.
   - `Quest Data` -Contains all the quests stored in the quest resource
   - `Graph Data` -Contains all the Data for the Editor
7. Open up the UI.gd script. Notice in the _ready() function we do a few things:
    - `QuestManager.add_quest_from_resource(quest,"ShootEmUp")` - Here we tell the Quest Manager to load this resource and add its quest thats named `ShootEmUp` to the player quests
    - We also connect a few signals:
        - `step_updated` - we update the UI to show what changed in the case an enemy was killed so the value increases
        - `step_complete` - We just use a lambda here to print step complete
        - `quest complete` - We update to UI to show that the quest was completed
        - `quest_failed` - Show if the quest failed if the player died
    - Then we set the QuestStart label text to the quest details and do some tweening the start the level
8. Open up the `Example/ExampleOne/Projectile.gd` script. Notice we check to see it the bullet hits an enemy. If it did, we call `QuestManager.progress_quest("ShootEmUp","Enemies")` before removing the projectile. This increases the the `collected` items of the `Incremental Step` by 1 by default.
9. In the Player.gd we also check if the player ran out of lives. If so we call `QuestManager.fail_quest("ShootEmUp")` This sets the quest as failed and emits the `quest_failed` signal.
10. And Thats about it for the tutorial it a quest has multiple steps the `step_updated` signal returns the new step its up to you how you want to display the information of that current step by checking its `step_type`. Check the [API](Quest_Manager_API.md) for what properties each step_type contains 

## Exporting Projects

Running a project in the editor is fine but when you want to export a project youll need to tell godot to export your quest files. To do this, in the export window, select your export format(Window/Linux/Android etc) then open the Resources tab and add `*.quest` as an entry with comma seperating other file types.
