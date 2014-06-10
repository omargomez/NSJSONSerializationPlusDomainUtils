NSJSONSerializationPlusDomainUtils
==================================

NSJSONSerializationPlusDomainUtils Helps to map JSON hierarchies to domain objects. 
Managing JSON data as NSDIctionaries/NSArrays it's easy but makes the code hard to  maintain. 
Using NSJSONSerializationPlusDomainUtils you can easily map those NSDictionaries 
into regular NSObjects with properties, not only making those properties visible thru Xcode's autocomplete but also making the code easier to read.

## Straightforward Declarative Syntax

You tell NSJSONSerializationPlusDomainUtils how to maps dictionaries to classes using paths expresions, so in the following json object:

    {"menu": {
      "id": "file",
      "value": "File",
      "popup": {
        "menuitem": [
          {"value": "New", "onclick": "CreateNewDoc()"},
          {"value": "Open", "onclick": "OpenDoc()"},
          {"value": "Close", "onclick": "CloseDoc()"}
        ]
      }
    }}

The path expression "$.menu" maps to:

    {
       "id": "file",
        "value": "File",
        "popup": {
          "menuitem": [
            {"value": "New", "onclick": "CreateNewDoc()"},
            {"value": "Open", "onclick": "OpenDoc()"},
            {"value": "Close", "onclick": "CloseDoc()"   
    }

And the path expression "$.menu.popup.menu.menuitem[]" maps to each individual:

    {"value": "New", "onclick": "CreateNewDoc()"}
    
Object. Then you just say which class corresponds to that object. So if you have a declared class like:

    @interface MyMenuItem : NSObject
    
    @property (nonatomic, strong) NSString *value;
    @property (nonatomic, strong) NSString *onclick;
    
    @end

then you pass a NSDictionary entry to NSJSONSerializationPlusDomainUtils like:

    @{ @"$.menu.popup.menu.menuitem[]": [MyMenuItem class] }

Name your class properties as the dictionaries entries and use regular NSJSONSerialization types (NSArray, NSString, NSNumber) or your own for them.

## Example

    const char *json =
    "{\"menu\": {"
    "    \"id\": \"file\","
    "    \"value\": \"File\","
    "    \"popup\": {"
    "        \"menuitem\": ["
    "                     {\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},"
    "                     {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},"
    "                     {\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}"
    "                     ]"
    "    }"
    "}}" ;
    
    id data = [NSData dataWithBytes:json length:strlen(json)];
    
    NSError *error;
    NSDictionary *map =@{
                         @"$": [ModelMenuRoot class],
                         @".menu": [ModelMenu class],
                         @".popup": [ModelPopup class],
                         @".menuitem[]": [ModelMenuItem class],
                         };
    ModelMenuRoot *root =[NSJSONSerialization ModelObjectWithData: data
                                                      options:0
                                                    suffixMap:map
                                                        error:&error];
    
    XCTAssertNotNil(root, @"Nil response");
    XCTAssertEqualObjects([root.menu.popup.menuitem[1] value], @"Open", @"");
    NSLog(@"%@", [root.menu.popup.menuitem[1] value] );
    

Notice how paths are shorter this time?. They are used as suffixes, so unless two different objects are indexed with the same properties you should be ready to go.

## Usage

Look for NSJSONSerialization+DomainUtils.h/m under the NSJSONSerializationPlusDomainUtils
subdirectory, adding those to your protect is enough. The category add the

    +(id)ModelObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt suffixMap:(NSDictionary*) pathClassMap error:(NSError **)error;
 
method to the NSJSONSerialization class, use the same as JSONObjectWithData:options:error: , just pass the appropriate mapping as explained.

This project is also a library project, so add it to your workspace at will.

## PPOC

Just because I'm amazing I created a mobile version of the Libray of Congress' "Prints & Photographs Online Catalog" web site. I could do so because they created an awesome API you can use to obtain the same they offer thru The site. It's a JSON API so you can take a look at the app top see how great the code look without being forced to use NSDictionaries. Enjoy it! 

## TO-DO

* Add entry to cocoadocs

## Sharing

<a href="https://twitter.com/share?text=Map JSON to model classes in Objective-C&hashtags=NSJSONSerializationPlusDomainUtils" class="twitter-share-button" data-lang="en">Tweet to share</a>




