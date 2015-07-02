### Implementing a Simple Search Feature in Rails

## Objectives

* Learn how to build a basic search feature for a Rails application
* Incorporate SQL into ActiveRecord queries for precise database querying


### Application flow

* A user should be able to type in a phrase into the search form, and our application should do the following:
  * check if the word exists exactly in the words table (aka conduct an **Exact Search**)
  * check if something LIKE the query exists in the words table (aka conduct a **Fuzzy Search**)
* Upon submitting the search query, the user should either be shown a page of the search results, or be redirected to the exact word match
* If the query returns nothing, a message should appear on the results page indicating that

### What You Need

* Appropriate migration for word table
* Word Model
* Search Model (which does not need to inherit from ActiveRecord::Base)
* Words Controller
* Search Controller
* Corresponding routes
* search/index view to render search results
* words/index view to render list of all words which link to their show pages
* words/show view to render one word
* Search Bar on a root page (handled by a welcome controller). The search bar should be a form that submits (as a GET request) to render the search results, which is handled by the index method on the search controller.

##Step 1 - Migrations
The first thing we should do is read the README, get a feel for our objectives and think about how a user will interact with our app. Now that we have an understanding of what we are trying to accomplish, let's go ahead and look at what our migrations should look like. Starting at the migration level is always a good idea. Your database is the ground level and everything will build on top of it.

If we look in our `db/migrate` file, we can see we have an empty `CreateWords` migration file, let's fill it out. Since this is where we will be storing the words that we can search through, they just need a name column.

**Before**

```ruby
class CreateWords < ActiveRecord::Migration
end
```

**After**

```ruby
class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.timestamps
    end
  end
end

```
Now we can run `rake db:migrate` to migrate our changes.

##Step 2 - Word Model
Following the README, we can see the next thing we need is a `Word` model.  Let's take a look in `models/word.rb` and see what we have. Right now it's empty class. Since we do not need to build out any functionality in this model, we are good to go here.

```ruby
class Word < ActiveRecord::Base
end
```

##Step 3 - Search Model
Let's take a look at `models/search.rb`. Right now it's a blank class.

```ruby
class Search
end
```
Since our `Search` class is going to do the searching, this would be a good place to build that functionality.
Below we define a class method called `self.for` that takes a `keyword` for an argument. Since the class is responsible for doing the searching, we are building a class method. On the first line of the method, we normalize the data by calling `downcase` on it, then we set it equal to the variable `search`. We then use `SQL` to search the `Word` class `where` `LOWER(name)` is `LIKE` our `search` term from the line  before.

```ruby
class Search

  def self.for(keyword)
    search = "%#{keyword.downcase}%"
    Word.where('LOWER(name) LIKE ?', search)
  end
  
end
```
Let's go a head and run `rspec` to see what our tests say. Great! It looks like our `Search` class is doing it's job, let's move on.

##Step 4 - Controllers and Views

In order for our `models` to talk to our database and serve content to our views (that don't exist yet), we are going to need controllers. Let's build those out now.

When we ran `rspec`, we saw:

###Error `No route matches [GET] "/"`
This error is telling us that we do not have our routes set up properly, or at all to be exact. Let's take a look in `config/routes.rb`. Right now it's blank. 

**before**

```ruby
Rails.application.routes.draw do

end
```

**after**

```ruby
Rails.application.routes.draw do

root 'welcome#index'

end
```

Now we have a route setup pointing to the `index` action of our `welcome` controller. Let's go into our `console` and run the command `rake routes` to see what our routes look like now. It looks like we have the following:

```ruby
root GET  /
```

Great! We have a root at `/` pointing to the `index` action of our `welcome` controller. Let's start up our server with `rails s` and visit `localhost:3000` to see what our app looks like so far. 

You should see:

###Error `The action 'index' could not be found for WelcomeController`


Let's open our `WelcomeController` and see what we have. It's blank! Let's go ahead and build our `index` action.

```ruby
class WelcomeController < ApplicationController

  def index
  end
  
end
```
Hit refresh and take a look in your browser. You should see:

###Error`Missing template welcome/index`  

It's telling us we are missing our `index` view, let's create it.

Create a new file `views/welcome/index.html.erb` Refresh again and you should see a blank page. Great, no errors. Now that we have our view rendering, let's go ahead and build a form for our user to search with. Inside your `index` view add the following form.

```ruby
<div class="jumbotron center">
  <h1 id="home-page-logo">Search Words</h1>
  <%= form_tag search_path, method: :get do %>
    <%= text_field_tag 'keyword', nil, placeholder: 'Search' %>
    <%= submit_tag 'Search', class: "btn btn-primary" %>
  <% end %>
</div>
```

Refresh your browser and you should see the following error.
###Error `undefined local variable or method 'search_path'`

Our form is trying to submit via a `GET` request to `search_path`. Let's run `rake routes` again. Looks like we did not create any routes yet for `search`, so let's do that now. Open up `config/routes.rb` and add the following.

```ruby
Rails.application.routes.draw do

  get 'search' => 'search#index', as: :search
  root 'welcome#index'
  
end

```
Let's run `rake routes` again:
Looks like we have the route we need. 

`search GET  /search(.:format) search#index`

Let's refresh our browser. Sweet! Now we have an `index` page, with a search box, pointing to the correct route. Let's go ahead and try to search for a word.

###Error `The action 'index' could not be found for SearchController`
This sounds familar, let's open our `SearchController`. It's blank, so let's build out some functionality. 

The `SearchControllers` job is to take in the request from the form, talk to the database and display the results. If it does not find any results, it should render a view containing a message that says "no results found." We can this with the following code.

####Method breakdown: 
First we search the `Word` database with the `ActiveRecord` method `find_by` for the `:keyword` we entered. If we find it, we redirect to that word. If we do not find it, 

```ruby

class SearchController < ApplicationController

  def index
    if word = Word.find_by(name: params[:keyword])
      redirect_to word
    else
      @results = Search.for(params[:keyword])
    end
  end
  
end
```

Let's search for a word.
###Error `Missing template search/index`
Looks like we don't have a view for our search `index` page. 

Create `views/search/index.html`

Now if we search again we are redirected to a blank page. 