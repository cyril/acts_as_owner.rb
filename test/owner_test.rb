require 'test_helper'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3', :database => ':memory:')

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :login
    end

    create_table :blogs do |t|
      t.references :user, :null => false
      t.string :title
    end

    create_table :categories do |t|
      t.references :blog, :null => false
      t.string :title
    end

    create_table :articles do |t|
      t.references :publishable, :polymorphic => true, :null => false
      t.references :user
      t.string :title
      t.text :content
    end

    create_table :comments do |t|
      t.references :article, :null => false
      t.references :user
      t.text :content
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class User < ActiveRecord::Base
  acts_as_owner(:verbose => true) do |a|
    a.owns_many :categories
    a.owns_many :articles
    a.owns_many :comments
    a.owns_many :publishables
    a.owns_one :blog
  end

  has_one :blog, :dependent => :destroy
  has_many :articles, :dependent => :destroy
  has_many :comments, :dependent => :destroy
end

class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :articles, :as => :publishable, :dependent => :destroy
  has_many :categories, :dependent => :destroy
end

class Category < ActiveRecord::Base
  belongs_to :blog
  has_many :articles, :as => :publishable, :dependent => :destroy
end

class Article < ActiveRecord::Base
  belongs_to :publishable, :polymorphic => true
  belongs_to :user
  has_many :comments, :dependent => :destroy
end

class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :user
end

class OwnerTest < MiniTest::Unit::TestCase
  def setup
    setup_db

    @admin = User.create! :login => 'admin'
    @bob = User.create :login => 'bob'

    @blog = @admin.create_blog :title => 'my_blog'
    @category = @blog.categories.create! :title => 'main'
    @article0 = @category.articles.create! :title => 'hello, world',
      :user => @admin
    @article1 = @blog.articles.create! :title => 'hello, all',
      :user => @bob
    @comment0 = @article0.comments.create! :content => 'foo'
    @comment1 = @article0.comments.create! :content => 'bar',
      :user => @bob
  end

  def teardown
    teardown_db
  end

  def test_the_ownability
    refute User.could_own_a?(:tank)
    refute User.could_own_a?("dinosaur")
    refute User.could_own_a?(42.to_s)
    assert User.could_own_a?(:blog)
    assert User.could_own_an?(:article)
  end

  def test_the_ownership
    assert @admin.owns?(@blog)
    refute @bob.owns?(@blog)
    assert @admin.owns?(@article0)
    refute @bob.owns?(@article0)
    assert @admin.owns?(@article1)
    assert @bob.owns?(@article1)
    assert @admin.owns?(@comment0)
    refute @bob.owns?(@comment0)
    assert @bob.owns?(@comment1)
    assert @admin.owns?(@comment1)
  end
end
