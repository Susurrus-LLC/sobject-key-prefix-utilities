/**
 * Get Key Prefix from SObject
 * @author Ian Cook
 * @description Given an object's ApiName, return the associated three-character Key Prefix
 */
public with sharing class GetKeyPrefixFromSObject {
    /**
     * Input
     * @description Defines the input
     */
    public class Input {
        @InvocableVariable(
            label='SObject API Name'
            description='The API Name of the Salesforce object, e.g., \'Account\' or \'Custom_Object__c\''
            required=true
        )
        public String apiName;
    }

    /**
     * Output
     * @description Defines the output
     */
    public class Output {
        @InvocableVariable(
            label='Key Prefix'
            description='The three-character key prefix of the given SObject'
        )
        public String keyPrefix;
    }

    /**
     * Look up Key Prefix
     * @description Look up the key prefix
     * @param apiName String the SObject API name
     * @return String key prefix
     */
    private static String lookupKeyPrefix(String apiName) {
        try {
            return Schema.describeSObjects(new List<String>{apiName})[0].getKeyPrefix();
        } catch (InvalidParameterValueException e) {
            return null;
        }
    }

    /**
     * @description Given a list of SObject API names, return a list of key prefixes
     * @param inputs A list of Inputs, each of which is an SObject API name
     * @return A list of Outputs, each of which is a key prefix
     */
    @InvocableMethod(
        label='Get SObject Key Prefix'
        description='Get the key prefix for a given SObject'
        category='Utilities'
    )
    public static List<Output> getKeyPrefix(List<Input> inputs) {
        // build a cache to store values in case the same value is requested multiple times
        Map<String, String> cache = new Map<String, String>();

        List<Output> outputs = new List<Output>();

        for (Input input : inputs) {
            // trim and lowercase, since maps are case sensitive
            String apiName = input?.apiName?.trim().toLowerCase();
            Output result = new Output();

            if (String.isBlank(apiName)) {
                result.keyPrefix = null;
            } else if (cache.containsKey(apiName)) {
                result.keyPrefix = cache.get(apiName);
            } else {
                result.keyPrefix = lookupKeyPrefix(apiName);
                cache.put(apiName, result.keyPrefix);
            }

            outputs.add(result);
        }

        return outputs;
    }
}