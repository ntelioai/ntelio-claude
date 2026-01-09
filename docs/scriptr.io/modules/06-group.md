## **group Module**

Scriptr.io allows you to manage the access permissions by organizing users and devices by groups and assigning ACLs to these groups. The users and devices under a specific group will automatically be assigned the ACLs of that group.

**create**

Creates a new group.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name of the group to be created. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**rename**

Renames an existing group.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name of the group to be renamed. |
| newName | String representing the new name of the group. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**delete**

Deletes an existing group. The devices or users belonging to that group will lose the permissions that were assigned to that group.

| **Parameter** | **Description** |
| --- | --- |
| name | String representing the name of the group to be deleted. |

**Return value:** no result is returned. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).

**list**

Retrieves the list of all existing groups.

**Return value:** JSON object containing the array of the group names. In case of a failure the appropriate error code and details will be returned in the metadata property (refer to [common function response](https://www.scriptr.io/documentation#documentation-typical-response)).
