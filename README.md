ActsAsTaggableOnActiveRecordRelation
====================================

Allow you to bulk add/remove tags directly on extended models


How to use it
-------------

If you are using *Rails 3* Just put the .rb file it in your */lib* folder and add a scope to extend

```ruby
require "acts_as_taggable_on_bulk"

class Person < ActiveRecord::Base
scope :with_bulk, lambda{ scoped.extending ::ActsAsTaggableOnBulk }
end


# Adding and removing tags
Person.with_bulk.add_tags(["new"]).remove_tag("old", 'jobs')
```

Note:
-----
Works on MySQL databases
Requires activerecord-import
