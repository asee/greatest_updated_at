# Greatest Updated At
Find the greatest updated_at from all included records in an AR scope

# Usage

Start with a scope.  Then use greatest_updated_at.  See the most recently updated_at value for all records selected by the scope.

```ruby
Document.all.maximum(:updated_at) # =>  2015-02-18 16:36:04 UTC
Author.all.maximum(:updated_at) # =>  2015-02-17 04:12:55 UTC

Document.all.includes(:authors).greatest_updated_at # => 2015-02-18 16:36:04 UTC
```
#### Why use this?

Caching mostly.  You want to cache, and you want to expire when things change.

Consider the following alternative:
```ruby
class Document < ActiveRecord::Base
  has_many :authors
end
class Author < ActiveRecord::Base
  belongs_to :document, touch: true
end
```

That will let you keep doing things like
```erb
<% cache(@document) do %>
  ... something about the document ...
  ... something about the authors ...
<% end %>
```

but then all your records share a timestamp, authors are not updated when their document changes, 
and as your views rely on more related records the number of things to touch increases.  greatest_updated_at offers a pleasant alternative:

```erb
<% cache(@document, @document.authors.includes(:contact_info, {:friends => :contact_info}).greatest_updated_at) do %>
  ... something about the document ...
  ... something about the authors ...
<% end %>
```

Or even for a collection of records, preload your associations so they're ready and then re-use that for your cache key:

Controller:

```ruby
class DocumentsController < ApplicationController
  def index
    @documents = Document.all.includes(:authors => [:contact_info, {:friends => :contact_info}])
  end
end
```

View:

```erb
<% cache("documents-index", @documents.greatest_updated_at) %>
  ...
<% end %>
```


## Installation

To use it, add it to your Gemfile:

```ruby
gem 'greatest_updated_at'
```

and bundle:

```shell
bundle
```

## Warnings

Currently it is both extremely naive and extremely simple.  If you use it with a polymorphic relation it will break.  Relations using non-standard table names will break.  Referencing tables without an updated_at will cause it to break.  In fact, it is really only useful for the most simple of cases.  

Pull requests and suggestions for improvement are welcome.