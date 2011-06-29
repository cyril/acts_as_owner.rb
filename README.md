Acts as owner
=============

Acts as owner is a plugin for Ruby on Rails that provides to an owner object the
ability to self-query about the possession of an ownable object.

Ownable objects can be any objects belonging to the owner object and any objects
belonging to an ownable object.

Any ownable child, which belongs to an owned ownable parent, is also owned by
the owner.

Philosophy
----------

General library that does only one thing, without any feature.

Installation
------------

Include the gem in your `Gemfile`:

    gem 'acts_as_owner'

And run the `bundle` command.  Or as a plugin:

    rails plugin install git://github.com/cyril/acts_as_owner.git

Getting started
---------------

### Configuring models

Owner models just have to be declared thanks to `acts_as_owner`, with each
ownable object passed through a block (using `owns_one` or `owns_many` method).

Example
-------

``` ruby
class User < ActiveRecord::Base
  acts_as_owner do |u|
    u.owns_many :articles
    u.owns_many :comments
  end

  with_options(dependent: :destroy) do |opts|
    opts.has_many :articles
    opts.has_many :comments
  end
end

class Article < ActiveRecord::Base
  belongs_to :user
  has_many :comments, dependent: :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :user
end

# An article should be ownable by a user, so:
User.could_own_an?(:article)  # => true

# Considering this one:
article = current_user.articles.first

# We can see that:
current_user.owns? article    # => true

# Now, considering its first comment:
comment = article.comments.first

# Just like article, we can check that:
User.could_own_an? :comment   # => true

# Let's see if the current user is the author:
current_user == comment.user  # => false

# Never mind.  It belongs to his article so that's also his one:
current_user.owns? comment    # => true
```

Copyright (c) 2009-2011 Cyril Wack, released under the MIT license
