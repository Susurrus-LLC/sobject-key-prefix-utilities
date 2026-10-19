/**
 * Get SObject from Key Prefix
 * @author Ian Cook
 * @description Given an object's key prefix, return the associated object's API Name
 */
public with sharing class GetSObjectFromKeyPrefix {
    private static final String ID_PADDING = '000000000000';

    /**
     * Input
     * @description Defines the input
     */
    public class Input {
        @InvocableVariable(
            label='Key Prefix'
            description='The three-character key prefix of the given SObject; ignored if a valid record Id is provided'
            required=false
        )
        public String keyPrefix;
        @InvocableVariable(
            label='Record Id'
            description='The record Id; falls back to the Key Prefix if blank or invalid'
            required=false
        )
        public String recordId;
    }

    /**
     * Output
     * @description Defines the output
     */
    public class Output {
        @InvocableVariable(
            label='SObject API Name'
            description='The API Name of the Salesforce object, e.g., \'Account\' or \'Custom_Object__c\''
        )
        public String apiName;
    }

    /**
     * Get API Name from Record Id
     * @description Get the SObject API Name directly from the record Id
     * @param recordId String record Id
     * @return String API Name
     */
    private static String getApiNameFromRecordId(Id recordId) {
        Schema.SObjectType objType;
        // If the SObject can't be found from the recordId, it throws an exception
        try {
            objType = recordId.getSObjectType();
        } catch (SObjectException e) {
            return null;
        }
        return objType == null ? null : objType.getDescribe().getName();
    }

    /**
     * Get API Name from Key Prefix
     * @description Get the SObject API Name using a fake record Id built from the key prefix
     * @param keyPrefix String key prefix
     * @return String API Name
     */
    private static String getApiNameFromKeyPrefix(String keyPrefix) {
        if (keyPrefix.length() != 3) {
            return null;
        }
        Id fakeId = stringToId(keyPrefix + ID_PADDING);
        return fakeId == null ? null : getApiNameFromRecordId(fakeId);
    }

    /**
     * String to Id
     * @description Safely convert a String to an Id or null
     * @param raw String to convert
     * @return Id or null from String
     */
    private static Id stringToId(String raw) {
        String trimmed = raw?.trim();
        if (String.isBlank(trimmed)) {
            return null;
        }
        try {
            return Id.valueOf(trimmed);
        } catch (StringException e) {
            return null;
        }
    }

    /**
     * @description Given a list of key prefixes or record Ids, return a list of SObject API names
     * @param inputs A list of Inputs, each of which is a key prefix or record Id
     * @return A list of Outputs, each of which is an SObject name
     */
    @InvocableMethod(
        label='Get SObject API name'
        description='Get the SObject API name for a given key prefix or record Id'
        category='Utilities'
    )
    public static List<Output> getApiName(List<Input> inputs) {
        List<Output> outputs = new List<Output>();

        for (Input input : inputs) {
            String keyPrefix = input?.keyPrefix?.trim();
            Id recordId = stringToId(input?.recordId);
            Output result = new Output();

            if (recordId != null) {
                result.apiName = getApiNameFromRecordId(recordId);
            } else if (String.isNotBlank(keyPrefix)) {
                result.apiName = getApiNameFromKeyPrefix(keyPrefix);
            }

            outputs.add(result);
        }

        return outputs;
    }
}