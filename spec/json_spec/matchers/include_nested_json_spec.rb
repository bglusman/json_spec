require "spec_helper"

describe JsonSpec::Matchers::IncludeNestedJson do

  describe "matching nested values" do
    json_strings = [
        %({"fname":"jolly", "lname":"roger", "partners": [{"fname": "dread pirate", "lname": "roberts"}]}),
        %({"fname":"jolly", "lname":"roger", "partner": {"fname": "dread pirate", "lname": "roberts"}}),
        %({"fname":"jolly", "lname":"roger", "connections": {"partners": [{"fname": "dread pirate", "lname": "roberts"}]}})
      ]

    it "matches values regardless of path depth" do
      json_strings.each do |json_string|
        json_string.should include_nested_json '{"fname": "dread pirate", "lname": "roberts"}'
      end
    end

    it "does not match value split across depths" do
      json_strings.each do |json_string|
        json_string.should_not include_nested_json '{"fname": "dread pirate", "lname": "roger"}'
      end
    end
  end


  it "matches included array elements" do
    json = %(["one",1,1.0,true,false,null])
    json.should include_nested_json(%("one"))
    json.should include_nested_json(%(1))
    json.should include_nested_json(%(1.0))
    json.should include_nested_json(%(true))
    json.should include_nested_json(%(false))
    json.should include_nested_json(%(null))
  end

  it "matches an array included in an array" do
    json = %([[1,2,3],[4,5,6]])
    json.should include_nested_json(%([1,2,3]))
    json.should include_nested_json(%([4,5,6]))
  end

  it "matches a hash included in an array" do
    json = %([{"one":1},{"two":2}])
    json.should include_nested_json(%({"one":1}))
    json.should include_nested_json(%({"two":2}))
  end

  it "matches included hash values" do
    json = %({"string":"one","integer":1,"float":1.0,"true":true,"false":false,"null":null})
    json.should include_nested_json(%("one"))
    json.should include_nested_json(%(1))
    json.should include_nested_json(%(1.0))
    json.should include_nested_json(%(true))
    json.should include_nested_json(%(false))
    json.should include_nested_json(%(null))
  end

  it "matches a hash included in a hash" do
    json = %({"one":{"two":3},"four":{"five":6}})
    json.should include_nested_json(%({"two":3}))
    json.should include_nested_json(%({"five":6}))
  end

  it "matches an array included in a hash" do
    json = %({"one":[2,3],"four":[5,6]})
    json.should include_nested_json(%([2,3]))
    json.should include_nested_json(%([5,6]))
  end

  it "matches a substring" do
    json = %("json")
    json.should include_nested_json(%("js"))
    json.should include_nested_json(%("json"))
  end

  it "ignores excluded keys" do
    %([{"id":1,"two":3}]).should include_nested_json(%({"two":3}))
  end

  it "provides a description message" do
    matcher = include_nested_json(%({"json":"spec"}))
    matcher.matches?(%({"id":1,"json":"spec"}))
    matcher.description.should == "include JSON"
  end

  it "raises an error when not given expected JSON" do
    expect{ %([{"id":1,"two":3}]).should include_nested_json }.to raise_error
  end

  it "matches file contents" do
    JsonSpec.directory = files_path
    %({"one":{"value":"from_file"},"four":{"five":6}}).should include_nested_json.from_file("one.json")
  end
end
