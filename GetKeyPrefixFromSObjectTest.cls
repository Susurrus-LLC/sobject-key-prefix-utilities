@IsTest
private class GetKeyPrefixFromSObjectTest {
    private static GetKeyPrefixFromSObject.Input buildInput(String name) {
        GetKeyPrefixFromSObject.Input input = new GetKeyPrefixFromSObject.Input();
        input.apiName = name;
        return input;
    }

    private static List<String> prefixesFor(List<String> apiNames) {
        List<GetKeyPrefixFromSObject.Input> inputs = new List<GetKeyPrefixFromSObject.Input>();
        for (String name : apiNames) {
            inputs.add(buildInput(name));
        }

        List<String> prefixes = new List<String>();
        for (GetKeyPrefixFromSObject.Output result : GetKeyPrefixFromSObject.getKeyPrefix(inputs)) {
            prefixes.add(result.keyPrefix);
        }
        return prefixes;
    }

    @IsTest
    static void returnsPrefixForStandardObjects() {
        // Standard objects have standard key prefixes across all orgs
        GetKeyPrefixFromSObject.Output accountKP = GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{buildInput('Account')})[0];
        Assert.areEqual(
            '001',
            accountKP.keyPrefix,
            'The key prefix for Account should be 001'
        );
        GetKeyPrefixFromSObject.Output contactKP = GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{buildInput('Contact')})[0];
        Assert.areEqual(
            '003',
            contactKP.keyPrefix,
            'The key prefix for Contact should be 003'
        );
        GetKeyPrefixFromSObject.Output opportunityKP = GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{buildInput('Opportunity')})[0];
        Assert.areEqual(
            '006',
            opportunityKP.keyPrefix,
            'The key prefix for Opportunity should be 006'
        );
    }

    @IsTest
    static void returnsPrefixesInListInOrder() {
        List<String> expected = new List<String>{
            '001',
            '003',
            '006'
        };
        List<String> actual = prefixesFor(new List<String>{
            'Account',
            'Contact',
            'Opportunity'
        });
        Assert.areEqual(
            expected,
            actual,
            'One prefix per input, in the same order'
        );
    }

    @IsTest
    static void returnsDuplicateOutputsForDuplicateInputs() {
        List<String> expected = new List<String>{
            '001',
            '001'
        };
        List<String> actual = prefixesFor(new List<String>{
            'Account',
            'Account'
        });
        Assert.areEqual(
            expected,
            actual,
            'Duplicate inputs should yield duplicate outputs'
        );
    }

    @IsTest
    static void isCaseInsensitiveAndTrimsWhitespace() {
        List<String> expected = new List<String>{
            '001',
            '001'
        };
        List<String> actual = prefixesFor(new List<String>{
            'account',
            '   Account   '
        });
        Assert.areEqual(
            expected,
            actual,
            'Lowercase names and names with whitespaces should still return the same key prefix'
        );
    }

    @IsTest
    static void isNullForBlankInput() {
        List<String> expected = new List<String>{
            null,
            null,
            null
        };
        List<String> actual = prefixesFor(new List<String>{
            null,
            '',
            '   '
        });
        Assert.areEqual(
            expected,
            actual,
            'null, empty, and blank strings should return null'
        );
    }

    @IsTest
    static void isNullForUnknownObject() {
        GetKeyPrefixFromSObject.Output unknownKP = GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{buildInput('Not_a_Real_Salesforce_Object__c')})[0];
        Assert.isNull(
            unknownKP.keyPrefix,
            'An object that isn\'t found should return null'
        );
    }

    @IsTest
    static void badInputsDoNotShiftNeighboringResults() {
        List<String> expected = new List<String>{
            '001',
            null,
            null,
            '003',
            null
        };
        List<String> actual = prefixesFor(new List<String>{
            'Account',
            'Not_a_Real_Salesforce_Object__c',
            null,
            'Contact',
            'Not_a_Real_Salesforce_Object__c'
        });
        Assert.areEqual(
            expected,
            actual,
            'Unknown and blank inputs yield null in place without disturbing other positions'
        );
    }

    @IsTest
    static void toleratesNullInput() {
        List<GetKeyPrefixFromSObject.Output> results = GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{
            null,
            buildInput('Account')
        });
        Assert.areEqual(
            2,
            results.size(),
            'A null input still gets an output'
        );
        Assert.isNull(
            results[0].keyPrefix,
            'A null input yields a null output'
        );
        Assert.areEqual(
            '001',
            results[1].keyPrefix,
            'Inputs after the null input are unaffected'
        );
    }

    @IsTest
    static void doesNotConsumeSoqlQueries() {
        Integer queriesBefore = Limits.getQueries();
        GetKeyPrefixFromSObject.getKeyPrefix(new List<GetKeyPrefixFromSObject.Input>{buildInput('Account')});
        Assert.areEqual(
            queriesBefore,
            Limits.getQueries(),
            'The number of SOQL queries used should be the same before and after retrieving the key prefix'
        );
    }
}