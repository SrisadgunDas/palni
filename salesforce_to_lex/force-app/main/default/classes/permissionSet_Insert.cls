public class Permission_set {
    public static void Permission_set_access(String username, String permissionSetName){
        PermissionSet Get_permissionSetId = [SELECT Id FROM PermissionSet WHERE Name =:permissionSetName];
        User u = [SELECT Id, Username FROM User WHERE Username =:username];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.id;
        psa.PermissionSetId = Get_permissionSetId.Id;
		insert psa;

    }
}