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

* In the rails console is checked:

```
Strain.new.wines
Wine.new.strains
Blend.new.wine
Blend.new.strains
```

### 2. Wines Index

The wine name 

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

In the model of Wine the scope to keep an alphabetical order of the wines list.

```
default_scope { order('wines.name ASC') }
```