# Greatest Updated At
Find the greatest updated_at from all included records in an AR scope

# Usage

Start with a scope.  Then use greatest_updated_at.  See the most recently updated_at value for all records selected by the scope.

```ruby
Author.all.maximum(:updated_at)                     # => Wed, 18 Feb 2015 16:36:04 UTC +00:00
Author.all.greatest_updated_at                      # => Wed, 18 Feb 2015 16:36:04 UTC +00:00

Document.all.maximum(:updated_at)                   # => Fri, 07 Nov 2014 04:12:55 UTC +00:00
Document.all.greatest_updated_at                    # => Fri, 07 Nov 2014 04:12:55 UTC +00:00

Document.all.includes(:authors).greatest_updated_at # => Wed, 18 Feb 2015 16:36:04 UTC +00:00
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
  ... something about the authors contact info ...
  ... something about the authors friends ...
  ... something about the authors friends' contact info ...
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

Or if you have a sense of adventure:

```ruby
gem 'greatest_updated_at', :git => 'https://github.com/asee/greatest_updated_at'
```

and bundle:

```shell
bundle
```

## Warnings

Referencing tables without an updated_at will cause it to break.  It may not work with some polymorphic relations.  It has only been tested on MySQL.  There are no automated tests.

Pull requests and suggestions for improvement are welcome.
