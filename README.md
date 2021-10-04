# Strains Challenge

This project implements a sistem that covers the elaboration of wines with diverse strains proportions. The platform implicates the aplication of nested forms and a testing series.

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

Now we can add a Strain from the new form of wines.

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

#### 1. Oenologist model

#### 2. Database of the Oenologists

#### 3. Admin authorization

### Part III

#### 1. Testing the model Strain
#### 2. Testing the controller Wine
