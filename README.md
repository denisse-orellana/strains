# Strains

This project implements a sistem that covers the elaboration of wines with diverse strains proportions. The platform implicates the aplication of nested forms and a testing series.

- [Strains Challenge](#strains-challenge)
  * [Ruby version](#ruby-version)
  * [Ruby Gems](#ruby-gems)
  * [First Part](#first-part)
    + [1. Making the model and controllers](#1-making-the-model-and-controllers)
    + [2. Developing the Nested form](#2-developing-the-nested-form)
      - [2.1. Gems Install](#21-gems-install)
      - [2.2. Model associations](#22-model-associations)
      - [2.3. Wines Index](#23-wines-index)
    + [3. Wines Scope](#3-wines-scope)
  * [Second Part](#second-part)
    + [Part I](#part-i)
      - [1. User authentication](#1-user-authentication)
      - [2. Admin authorization](#2-admin-authorization)
    + [Part II](#part-ii)
    + [Part III](#part-iii)
      - [1. Testing the model Strain](#1-testing-the-model-strain)
      - [2. Testing the controller Wine](#2-testing-the-controller-wine)

## Ruby version 

* Ruby 2.6.1
* Rails 5.2.4

## Ruby Gems

For the nested forms:

* gem 'cocoon'. More information available at: https://github.com/nathanvda/cocoon
* gem 'jquery-rails'
* gem 'devise'. More information available at: https://github.com/heartcombo/devise

For the testing series:

* gem 'rspec-rails'. More information available at: https://github.com/rspec/rspec-rails
* gem 'rails-controller-testing'

## First Part

### 1. Making the model and controllers

The Strain and Wine models are generated with scaffold while the Blend model will contain the associations between them.

```
rails g scaffold Strain name
rails g scaffold Wine name
rails g model Blend strain:references wine:references percent:integer
```

The relation is described in the models as it follows:

```
class Strain < ApplicationRecord
    has_many :blends
    has_many :wines, through: :blends, dependent: :destroy
end
```

```
class Wine < ApplicationRecord
    has_many :blends
    has_many :strains, through: :blends, dependent: :destroy
end
```

```
class Blend < ApplicationRecord
  belongs_to :wine
  belongs_to :strain
end
```

* In the rails console can be checked as:

```
Strain.new.wines
Wine.new.strains
Blend.new.wine
Blend.new.strains
```

### 2. Developing the Nested form

#### 2.1. Gems Install

First step: add the gems Coccon and jQuery Rails to the Gemfile.

```
gem 'cocoon'
gem 'jquery-rails'
```

The install command is run in the terminal:

```
rails g cocoon:install
```

To compile the asset pipeline is added:

```
application.js

//= require jquery3
//= require cocoon
```

#### 2.2. Model associations 

The models are associated as it follows:

```
class Wine < ApplicationRecord
    has_many :blends
    has_many :strains, through: :blends, dependent: :destroy

    accepts_nested_attributes_for :blends, reject_if: :all_blank, allow_destroy: true
end
```

In the WinesController the nested attributes are incorporated.

```
controllers/wines_controller.rb

# GET /wines/new
def new
    @wine = Wine.new
    @strains = Strain.all
    @wine.blends.build
end

def wine_params
    params.require(:wine).permit(:name, { blends_attributes: [:id, :percent, :strain_id] })
end
```

Also, a new partial is generated for the new fields and it contains:

```
_blend_fields.html.erb

<div class="field">
    <%= f.label :strain_id %>
    <%= f.collection_select :strain_id, @strains, :id, :name %>
</div>

<div class="field">
    <%= f.label :percent %>
    <%= f.number_field :percent %>
</div>
```

Finally, in the partial of the form is added the following:

```
wines/_form.html.erb

<div class="field">
    <%= form.fields_for :blends do |ff| %>
      <%= render 'blend_fields', f: ff %>
    <% end %>
  </div>

<div class="field">
    <%= link_to_add_association 'Add another Strain', form, :blends %>
</div>
```

Now we can add a Strain with a certain proportion of wines from the new form of wines.

#### 2.3. Wines Index

The attributes of percent and strain are added to the Index:

```
wines/index.html.erb

 <tbody>
      <% @wines.each do |wine| %>
        <tr>
          <td><%= wine.name %></td>
          <td>
            <ul>
              <% wine.blends.each do |wine| %>
                <li>(<%= number_to_percentage(wine.percent, precision: 0) %>) <%= wine.strain.name %></li>
              <% end %>
            </ul>
          </td>
        <% end %>
</tbody>
```

### 3. Wines Scope

In the model of Wine is added the default scope to keep an alphabetical order of the wines list.

```
default_scope { order('wines.name ASC') }
```

## Second Part

### Part I

#### 1. User authentication

The Gem Devise is incorporated to the Gemfile:

```
gem 'devise'
```

The install command is run in the terminal:

```
rails generate devise:install
```

The User is generated:

```
rails g devise User
```

Then, the helper is added in WinesController to set up user authentication:

```
controllers/wines_controller.rb

before_action :authenticate_user!
```

#### 2. Admin authorization

An admin attribute is added to User, since only the admin can make new wine blends.

```
rails g migration addAdminToUser admin:boolean
```

This method is implemented in WinesController for the admin authorization:

```
controllers/wines_controller.rb

before_action :not_admin, except: [ :index ]

def not_admin
    redirect_to root_path, alert: "You can only watch Peter's wines" and return if !current_user.admin
end
```

### Part II

The Oenologist is generated with scaffold while the Comment model will contain the associations between them.

```
rails g scaffold Oenologist name age:integer country workplace writer:boolean editor:boolean reviewer:boolean
rails g migration addOenologistToWine oenologist:references
rails g model Comment wine:references oenologist:references score:integer
```

Now, to the models it is added: 

```
class Oenologist < ApplicationRecord
    has_many :comments
    has_many :wines, through: :comments, dependent: :destroy
end
```

```
class Wine < ApplicationRecord
    has_many :comments
    has_many :oenologists, through: :comments, dependent: :destroy

    accepts_nested_attributes_for :comments, reject_if: :all_blank, allow_destroy: true
end
```

```
class Comment < ApplicationRecord
  belongs_to :wine
  belongs_to :oenologist
end
```

In the WinesController it is incorporated:

```
controllers/wines_controller.rb

def edit
    @strains = Strain.all
    @oenologists = Oenologist.all
    @wine.comments.build
end

def wine_params
    params.require(:wine).permit(:name, { blends_attributes: [:id, :percent, :strain_id] }, {comments_attributes: [:id, :oenologist_id, :score]} )
end
```

The new partial for Comment is made:

```
wines/_comment_fields.html.erb

<div class="field">
    <%= f.label :oenologist_id %>
    <%= f.collection_select :oenologist_id , @oenologists, :id, :name %>
</div>

<div class="field">
    <%= f.label :score %>
    <%= f.number_field :score %>
</div>
```

A new partial for the edit is made and it will contain:

```
wines/_form_edit.html.erb

<div class="field">
<%= form.fields_for :comments do |ff| %>
    <%= render 'comment_fields', f: ff %>
<% end %>
</div>

<div class="field">
<%= link_to_add_association 'Add Oenologist', form, :comments %>
</div>
```

Now the Oenologist's score could be added to the wine when the Admin edited the wine. To be seen from the Wine Index we add:

```
wines/index.html.erb

<td>
    <ul>
        <% wine.comments.each do |wine|  %>
        <li><%= wine.oenologist.name %> (age: <%= wine.oenologist.age %>)</li>
        <% end %>    
    </ul>
</td>
<td>
    <ul>
        <% wine.comments.each do |wine|  %>
        <li><%= wine.score %></li>
        <% end %>    
    </ul>
</td>
```

Finally, the scope for order by the Oenologist's age is added:

```
class Oenologist < ApplicationRecord
    default_scope { order('oenologists.age ASC') }
end
```

* In the rails console the functionality of the relations can be checked:

```
Oenologist.new.wines
Wine.new.oenologists
```

```
Comment.new.wine
Comment.new.oenologist
```

### Part III

#### 1. Testing the model Strain

The gems are added to the Gemfile and installed as it follows:

```
group :test do
  gem 'rspec-rails'
  gem 'rails-controller-testing'
end
```

```
rails g rspec:install
```

The test for the model is generated:

```
rails g rspec:model Strain
```

The model is test in the Strain spec:

```
spec/models/strain_spec.rb

  context "Testing the strains first" do
    it "cannot have the same name" do
      strain_1 = Strain.create(name: 'Merlot')
      strain_2 = Strain.create(name: 'Merlot')
      expect(strain_2).to_not be_valid
    end 
  end

  context "Testing the strains second" do
    it "cannot have a blank name" do
      s = Strain.create(name: "")
      expect(s).to_not be_valid
    end
  end

  context "Testing the strains third" do
    it "cannot have a nil name" do
      st = Strain.create()
      expect(st).to_not be_valid
    end  
  end
end
```

This testing is checked with the next command in the terminal:

```
bundle exec rspec spec/models/strain_spec.rb
```

#### 2. Testing the controller Wine

The test for the controller is generated:

```
rails g rspec:controller Wine
```

First, this specifications are needed for the devise authentication:

```
spec/controllers/wines_controller_spec.rb

require 'rails_helper'
require 'rspec/rails'
require 'devise'
```

The controller is test in the Wines spec:

```
spec/controllers/wines_controller_spec.rb

describe 'GET index' do
    it "routes to #index" do
        get :index
        expect(get: "/wines").to route_to("wines#index")
    end

    it "routes to #show" do
        expect(get: "/wines/9").to route_to("wines#show", id: "9")
    end
end

describe 'GET show' do
    render_views # under describe or context 

    user = User.create(email: "peter@example.com", password: '1234567', admin: true)

    before do
        sign_in user
    end

    it "renders show template" do
        wine = Wine.create
        get :show, params: { id: wine.id }
        expect(response.status).to eq(302)
    end
end
```  

Finally, this testing is checked with the next command in the terminal:

```
bundle exec rspec spec/controllers/wines_controller_spec.rb
```