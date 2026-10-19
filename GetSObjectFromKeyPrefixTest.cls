@IsTest
private class GetSObjectFromKeyPrefixTest {
    private static final String ACC_ID = '001000000000001';
    private static final String CON_ID = '003000000000001';
    private static final String OPP_ID = '006000000000001';

    private static GetSObjectFromKeyPrefix.Input buildInput(String keyPrefix, String recordId) {
        GetSObjectFromKeyPrefix.Input input = new GetSObjectFromKeyPrefix.Input();
        input.keyPrefix = keyPrefix;
        input.recordId = recordId;
        return input;
    }

    private static List<String> apiNamesFor(List<GetSObjectFromKeyPrefix.Input> inputs) {
        List<String> names = new List<String>();
        for (GetSObjectFromKeyPrefix.Output result : GetSObjectFromKeyPrefix.getApiName(inputs)) {
            names.add(result.apiName);
        }
        return names;
    }

    @IsTest
    static void returnsNamesInOrder() {
        List<String> expected = new List<String>{
            'Account',
            'Contact',
            'Opportunity'
        };
        List<String> actualKP = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', null),
            buildInput('003', null),
            buildInput('006', null)
        });
        List<String> actualId = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput(null, ACC_ID),
            buildInput(null, CON_ID),
            buildInput(null, OPP_ID)
        });
        Assert.areEqual(
            expected,
            actualKP,
            'Key prefixes should match to API names in order'
        );
        Assert.areEqual(
            expected,
            actualId,
            'Record Ids should match to API names in order'
        );
    }

    @IsTest
    static void returnsNamesWithMixedInputs() {
        List<String> expected = new List<String>{
            'Account',
            'Contact',
            'Opportunity'
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', null),
            buildInput(null, CON_ID),
            buildInput('006', OPP_ID)
        });
        Assert.areEqual(
            expected,
            actual,
            'When processing a list containing mixed inputs, the API names should still return without issue'
        );
    }

    @IsTest
    static void returnsDuplicateOutputsForDuplicateInputs() {
        List<String> expected = new List<String>{
            'Account',
            'Account'
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', null),
            buildInput('001', null)
        });
        Assert.areEqual(
            expected,
            actual,
            'When processing a list with duplicates, the API names should include duplicates'
        );
    }

    @IsTest
    static void trimsWhitespace() {
        List<String> expected = new List<String>{
            'Account',
            'Account',
            'Account'
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', null),
            buildInput('   001   ', null),
            buildInput(null, '   ' + ACC_ID + '   ')
        });
        Assert.areEqual(
            expected,
            actual,
            'Key prefixes and record Ids with whitespaces should still return the same API name'
        );
    }

    @IsTest
    static void recordIdWinsIfBothInputsPresent() {
        List<String> expected = new List<String>{
            'Contact',
            'Account'
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', CON_ID),
            buildInput('006', ACC_ID)
        });
        Assert.areEqual(
            expected,
            actual,
            'If a key prefix is provided that differs from the record Id, the API name should be based on the record Id'
        );
    }

    @IsTest
    static void isNullForBlankInput() {
        List<String> expected = new List<String>{
            null,
            null,
            null,
            null,
            null,
            null
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput(null, null),
            buildInput('', null),
            buildInput(null, ''),
            buildInput('   ', null),
            buildInput(null,'   '),
            null
        });
        Assert.areEqual(
            expected,
            actual,
            'null inputs and null, empty, and blank strings should all return null'
        );
    }

    @IsTest
    static void isNullForUnknownOrBadPrefix() {
        List<String> expected = new List<String>{
            null,
            null,
            null,
            null
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('0001', null),
            buildInput('01', null),
            buildInput('@#!', null),
            buildInput('zzz', null)
        });
        Assert.areEqual(
            expected,
            actual,
            'Invalid key prefixes and objects that aren\'t found should return null'
        );
    }

    @IsTest
    static void malformedRecordIdFallsBackToKeyPrefix() {
        List<String> expected = new List<String>{
            'Account',
            null
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput('001', 'not-an-id'),
            buildInput(null, 'not-an-id')
        });
        Assert.areEqual(
            expected,
            actual,
            'A malformed record Id counts as not provided'
        );
    }

    @IsTest
    static void isNullForWellFormedIdWithUnknownPrefix() {
        List<String> expected = new List<String>{ null };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput(null, 'zzz123456789abc')
        });
        Assert.areEqual(
            expected,
            actual,
            'An Id whose prefix matches no object should return null, not throw'
        );
    }

    @IsTest
    static void acceptsFifteenAndEighteenCharacterIds() {
        String eighteen = Id.valueOf(ACC_ID);
        List<String> expected = new List<String>{
            'Account',
            'Account'
        };
        List<String> actual = apiNamesFor(new List<GetSObjectFromKeyPrefix.Input>{
            buildInput(null, ACC_ID),
            buildInput(null, eighteen)
        });
        Assert.areEqual(
            expected,
            actual,
            'Both Id formats should resolve'
        );
    }

    @IsTest
    static void doesNotConsumeSoqlQueries() {
        Integer queriesBefore = Limits.getQueries();
        GetSObjectFromKeyPrefix.getApiName(new List<GetSObjectFromKeyPrefix.Input>{buildInput('001', null)});
        Assert.areEqual(
            queriesBefore,
            Limits.getQueries(),
            'The number of SOQL queries used should be the same before and after retrieving the key prefix'
        );
    }
}