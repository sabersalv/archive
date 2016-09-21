#= require_self
#= require      ./routes
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./templates

window.API_URL = "http://localhost:3000"

DS.RESTAdapter.configure "plurals", 
  hero: "heroes"

window.A = window.App = Ember.Application.create
  Store: DS.Store.extend
    revision: 13
    adapter: DS.RESTAdapter.create
      url: API_URL
