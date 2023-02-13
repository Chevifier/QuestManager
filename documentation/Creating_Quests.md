# Creating Quests

## The Editor

To create a quest you should use the editor. The editor has various node required to create quest. These nodes are:
1. `Quest Node` - This Node is the main quest node it requires the `quest_name` and the `quest_details`
2. `Step Node` - This node is an `action_step` node and only requires a discription of the action to complete.
3. `Incremental Step Node` - This node is an incremental_step node and requires both its `details` and the `required` amount to complete
4. `Item Step Node` - This node is an `items_step` node and requires the `details` as well as the list of items/actions to complete
5. `End Node` - This node is required to end a quest after the final step
6. `Group Node` - a group node only requires its roup name and can be connected to multiple quest nodes
7. `Meta Data Node` - A meta data node is use to add meta data to quest such as quest rewards of any arbitrary information stored as a `String`, `Integer`, `float` or `boolean`

## How to use

Add Nodes to the scene for example add a Quest node a Step Node and a End Node.
Connect these node dragging the green connection pins from one to another
QUESTNODE>Step Node> End Node